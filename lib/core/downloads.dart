import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'installer.dart';
import 'log.dart';
import 'paths.dart';
import 'tools.dart';

/// Download + unpack jobs for PicoLand links (Yandex Disk, Google
/// Drive, SberDisk) — same sources as the original app.
class DownloadJob extends ChangeNotifier {
  final String id;
  final String title;
  final String url;
  final String kind;
  final Directory targetDir;

  String state = 'waiting'; // waiting, downloading, unpacking, done, failed
  double progress = 0;
  int received = 0;
  int total = 0;
  String? error;
  String? outPath;

  /// Set when the game should be installed right after download.
  Object? installAfter;

  /// The install job this download spawned, if any.
  InstallJob? chained;

  /// Name of the target file inside [targetDir], once known.
  String? fileName;

  CancelToken cancelToken = CancelToken();

  DownloadJob(this.id, this.title, this.url, this.kind, this.targetDir);

  void _notify() => notifyListeners();
}

class Downloads extends ChangeNotifier {
  Downloads._();
  static final Downloads instance = Downloads._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(minutes: 5),
    ),
  );

  final List<DownloadJob> jobs = [];

  File? _metaFile;
  bool _restored = false;

  /// Reload queued/interrupted downloads and resume them. Safe to call once
  /// at startup; subsequent calls are no-ops.
  Future<void> init() async {
    if (_restored) return;
    _restored = true;
    final dir = await AppPaths.downloads();
    await dir.create(recursive: true);
    final meta = _metaFile = File(p.join(dir.path, 'downloads.json'));
    if (!await meta.exists()) return;
    List<dynamic> metas;
    try {
      metas = jsonDecode(await meta.readAsString()) as List;
    } catch (e) {
      dlog('downloads.json unreadable: $e');
      return;
    }
    for (final m in metas.whereType<Map>()) {
      final job = DownloadJob(
        '${m['id'] ?? DateTime.now().millisecondsSinceEpoch}',
        m['title'] ?? 'download',
        m['url'] ?? '',
        m['kind'] ?? 'direct',
        dir,
      );
      job.fileName = m['fileName'] as String?;
      final opts = m['installAfter'];
      if (opts is Map) job.installAfter = _optionsFromMap(opts);
      jobs.add(job);
      dlog('download restored: ${job.title} (${job.fileName ?? '?'})');
      _run(job);
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final f = _metaFile;
    if (f == null) return;
    final active = jobs
        .where((j) => j.state == 'waiting' || j.state == 'downloading')
        .map(
          (j) => {
            'id': j.id,
            'title': j.title,
            'url': j.url,
            'kind': j.kind,
            'fileName': j.fileName,
            'installAfter': _optionsToMap(j.installAfter),
          },
        )
        .toList();
    await f.writeAsString(jsonEncode(active));
  }

  Map<String, dynamic>? _optionsToMap(Object? o) {
    if (o is! InstallOptions) return null;
    return {
      'method': o.method.name,
      'packageSuffix': o.packageSuffix,
      'newKey': o.newKey,
      'keepSdkMeta': o.keepSdkMeta,
      'storeInstaller': o.storeInstaller,
      'cacheFolder': o.cacheFolder,
      'downloadOnly': o.downloadOnly,
    };
  }

  InstallOptions _optionsFromMap(Map m) => InstallOptions(
    method: InstallMethod.values.firstWhere(
      (e) => e.name == m['method'],
      orElse: () => InstallMethod.auto,
    ),
    packageSuffix: m['packageSuffix'] ?? '',
    newKey: m['newKey'] ?? false,
    keepSdkMeta: m['keepSdkMeta'] ?? false,
    storeInstaller: m['storeInstaller'] ?? false,
    cacheFolder: m['cacheFolder'],
    downloadOnly: m['downloadOnly'] ?? false,
  );

  Future<DownloadJob> enqueue({
    required String title,
    required String url,
    required String kind,
    Object? installAfter,
  }) async {
    final dir = await AppPaths.downloads();
    await dir.create(recursive: true);
    _metaFile ??= File(p.join(dir.path, 'downloads.json'));
    final job = DownloadJob(
      '${DateTime.now().millisecondsSinceEpoch}',
      title,
      url,
      kind,
      dir,
    );
    job.installAfter = installAfter;
    jobs.insert(0, job);
    notifyListeners();
    _persist();
    dlog('download queued: $title ($kind) $url');
    _run(job);
    return job;
  }

  Future<String?> _resolveUrl(DownloadJob job) async {
    switch (job.kind) {
      case 'yandex':
        // cloud-api.yandex.net/v1/disk/public/resources?public_key=URL
        final r = await _dio.get(
          'https://cloud-api.yandex.net/v1/disk/public/resources/download',
          queryParameters: {'public_key': job.url},
        );
        return r.data['href'] as String?;
      case 'gdrive':
        final m = RegExp(r'[-\w]{25,}').firstMatch(job.url);
        final id = m?.group(0);
        if (id == null) return null;
        return 'https://drive.usercontent.google.com/download?id=$id&export=download&confirm=t';
      case 'sber':
        // apigw.sberdisk.ru/share/link → files.sberdisk.ru download
        final r = await _dio.get(
          'https://apigw.sberdisk.ru/share/link',
          queryParameters: {'url': job.url},
        );
        final data = r.data is String ? jsonDecode(r.data) : r.data;
        return data['downloadUrl'] as String? ?? job.url;
      default:
        return job.url; // direct / tg links handled elsewhere
    }
  }

  Future<void> _run(DownloadJob job) async {
    job.state = 'downloading';
    job._notify();
    try {
      final resolved = await _resolveUrl(job);
      if (resolved == null) throw Exception('could not resolve link');
      dlog('download resolved (${job.kind}): $resolved');
      job.fileName ??= _fileName(resolved) ?? '${job.title}.bin';
      _persist();
      final out = File(p.join(job.targetDir.path, job.fileName!));
      final part = File('${out.path}.part');
      var offset = await part.exists() ? await part.length() : 0;
      if (await out.exists()) {
        // finished before the last shutdown; just needs bookkeeping
        if (await part.exists()) await part.delete();
        await _finish(job, out.path);
        return;
      }
      dlog(
        'download start: ${job.title} -> ${out.path}'
        '${offset > 0 ? ' (resuming at $offset bytes)' : ''}',
      );

      final headers = <String, dynamic>{'User-Agent': 'Mozilla/5.0 SMPico'};
      if (offset > 0) headers['Range'] = 'bytes=$offset-';
      final res = await _dio.get<ResponseBody>(
        resolved,
        cancelToken: job.cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: true,
          headers: headers,
        ),
      );
      final status = res.statusCode ?? 0;
      var append = false;
      if (offset > 0 && status == 206) {
        append = true;
        final m = RegExp(r'/(\d+)').firstMatch(
          res.headers.value('content-range') ?? '',
        );
        job.total = m != null ? int.parse(m.group(1)!) : 0;
      } else {
        if (offset > 0) {
          if (status == 416 && _rangeSatisfies(res, offset)) {
            await part.rename(out.path);
            await _finish(job, out.path);
            return;
          }
          offset = 0;
        }
        job.total = int.tryParse(
              res.headers.value('content-length') ?? '',
            ) ??
            0;
      }

      final raf = await part.open(
        mode: append ? FileMode.append : FileMode.write,
      );
      var received = offset;
      job.received = offset;
      await for (final chunk in res.data!.stream) {
        await raf.writeFrom(chunk);
        received += chunk.length;
        job.received = received;
        job.progress = job.total > 0 ? received / job.total : 0;
        job._notify();
      }
      await raf.close();
      if (job.total > 0 && received < job.total) {
        throw StateError('incomplete download ($received/${job.total})');
      }
      await part.rename(out.path);
      await _finish(job, out.path);
      return;
    } catch (e) {
      job.state = 'failed';
      job.error = '$e';
      dlog('download FAILED: ${job.title}: $e');
    }
    job._notify();
    notifyListeners();
    _persist();
  }

  bool _rangeSatisfies(Response res, int have) {
    final m = RegExp(r'\*/(\d+)').firstMatch(
      res.headers.value('content-range') ?? '',
    );
    return m != null && int.parse(m.group(1)!) == have;
  }

  Future<void> _finish(DownloadJob job, String path) async {
    job.outPath = path;
    job.progress = 1;
    job.state = 'done';
    dlog('download done: ${job.title} -> ${job.outPath}');
    final opts = job.installAfter;
    if (opts != null) {
      // chain into the install queue like the original does
      dlog('chaining install: ${job.title} (${job.outPath})');
      job.chained = Installer.instance.enqueue(
        path,
        job.title,
        opts is InstallOptions ? opts : InstallOptions(),
        fromDownload: job,
      );
    }
    job._notify();
    notifyListeners();
    _persist();
  }

  String? _fileName(String url) {
    final m = RegExp(r'filename=([^&]+)').firstMatch(url);
    if (m != null) {
      try {
        return Uri.decodeComponent(m.group(1)!);
      } catch (_) {}
    }
    final seg = Uri.tryParse(url)?.pathSegments;
    if (seg != null && seg.isNotEmpty && seg.last.contains('.')) {
      return Uri.decodeComponent(seg.last);
    }
    return null;
  }

  void cancel(DownloadJob job) {
    job.cancelToken.cancel();
    job.state = 'failed';
    job.error = 'cancelled';
    job._notify();
    notifyListeners();
    _persist();
  }

  void remove(DownloadJob job) {
    jobs.remove(job);
    notifyListeners();
    _persist();
  }

  /// Unpack an archive (zip via archive package, rar/7z via tools).
  Future<Directory?> unpack(
    String path, {
    void Function(double)? onProgress,
  }) async {
    final lower = path.toLowerCase();
    final dir = Directory(p.dirname(path));
    final outDir = Directory(
      p.join(
        dir.path,
        p.basenameWithoutExtension(path).replaceAll(RegExp(r'\.\d+$'), ''),
      ),
    );
    if (lower.endsWith('.zip')) {
      final bytes = await File(path).readAsBytes();
      final ar = ZipDecoder().decodeBytes(bytes);
      await outDir.create(recursive: true);
      var done = 0;
      for (final f in ar) {
        final target = p.join(outDir.path, f.name);
        // some archives flag directory entries as files; the trailing
        // slash is the reliable check
        if (f.isFile && !f.name.endsWith('/')) {
          final file = File(target);
          await file.create(recursive: true);
          await file.writeAsBytes(f.content as List<int>);
        } else {
          await Directory(target).create(recursive: true);
        }
        onProgress?.call(++done / ar.length);
      }
      return outDir;
    }
    if (lower.endsWith('.rar') ||
        lower.endsWith('.7z') ||
        lower.endsWith('.001')) {
      final unrar = await Tools.instance.unrar();
      final seven = await Tools.instance.sevenZip();
      final tool = unrar ?? seven;
      if (tool == null) throw StateError('no unpacker (unrar/7z) found');
      dlog('unpack $path -> ${outDir.path} via $tool');
      await outDir.create(recursive: true);
      final args = tool == seven
          ? ['x', path, '-o${outDir.path}', '-y']
          : [
              'x',
              '-o+',
              path,
              '${outDir.path}${Platform.isWindows ? r'\' : '/'}',
            ];
      final r = await Process.run(tool, args);
      if (r.exitCode != 0) {
        dlog('unpack failed ($tool): ${r.stderr}');
        throw StateError('unpack failed: ${r.stderr}');
      }
      return outDir;
    }
    if (lower.endsWith('.apk')) return outDir;
    throw StateError('Invalid archive type: $path (supported: rar, 7z, zip)');
  }
}
