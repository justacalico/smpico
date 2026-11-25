import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'paths.dart';
import 'tools.dart';
import 'installer.dart';

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

  CancelToken cancelToken = CancelToken();

  DownloadJob(this.id, this.title, this.url, this.kind, this.targetDir);

  void _notify() => notifyListeners();
}

class Downloads extends ChangeNotifier {
  Downloads._();
  static final Downloads instance = Downloads._();

  final Dio _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(minutes: 5)));

  final List<DownloadJob> jobs = [];

  Future<DownloadJob> enqueue(
      {required String title,
      required String url,
      required String kind,
      Object? installAfter}) async {
    final dir = await AppPaths.downloads();
    await dir.create(recursive: true);
    final job = DownloadJob(
        '${DateTime.now().millisecondsSinceEpoch}', title, url, kind, dir);
    job.installAfter = installAfter;
    jobs.insert(0, job);
    notifyListeners();
    _run(job);
    return job;
  }

  Future<String?> _resolveUrl(DownloadJob job) async {
    switch (job.kind) {
      case 'yandex':
        // cloud-api.yandex.net/v1/disk/public/resources?public_key=URL
        final r = await _dio.get(
            'https://cloud-api.yandex.net/v1/disk/public/resources/download',
            queryParameters: {'public_key': job.url});
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
            queryParameters: {'url': job.url});
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
      final name = _fileName(resolved) ?? '${job.title}.bin';
      final out = File(p.join(job.targetDir.path, name));
      await _dio.download(resolved, out.path,
          cancelToken: job.cancelToken,
          options: Options(followRedirects: true, headers: {
            'User-Agent': 'Mozilla/5.0 EZPico'
          }), onReceiveProgress: (rec, tot) {
        job.received = rec;
        job.total = tot;
        job.progress = tot > 0 ? rec / tot : 0;
        job._notify();
      });
      job.outPath = out.path;
      job.progress = 1;
      job.state = 'done';
      final opts = job.installAfter;
      if (opts != null) {
        // chain into the install queue like the original does
        Installer.instance.enqueue(out.path, job.title,
            opts is InstallOptions ? opts : InstallOptions());
      }
    } catch (e) {
      job.state = 'failed';
      job.error = '$e';
    }
    job._notify();
    notifyListeners();
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
  }

  void remove(DownloadJob job) {
    jobs.remove(job);
    notifyListeners();
  }

  /// Unpack an archive (zip via archive package, rar/7z via tools).
  Future<Directory?> unpack(String path, {void Function(double)? onProgress}) async {
    final lower = path.toLowerCase();
    final dir = Directory(p.dirname(path));
    final outDir = Directory(p.join(
        dir.path, p.basenameWithoutExtension(path).replaceAll(RegExp(r'\.\d+$'), '')));
    if (lower.endsWith('.zip')) {
      final bytes = await File(path).readAsBytes();
      final ar = ZipDecoder().decodeBytes(bytes);
      await outDir.create(recursive: true);
      var done = 0;
      for (final f in ar) {
        final target = File(p.join(outDir.path, f.name));
        if (f.isFile) {
          await target.create(recursive: true);
          await target.writeAsBytes(f.content as List<int>);
        } else {
          await target.create(recursive: true);
        }
        onProgress?.call(++done / ar.length);
      }
      return outDir;
    }
    if (lower.endsWith('.rar') || lower.endsWith('.7z') ||
        lower.endsWith('.001')) {
      final unrar = await Tools.instance.unrar();
      final seven = await Tools.instance.sevenZip();
      final tool = unrar ?? seven;
      if (tool == null) throw StateError('no unpacker (unrar/7z) found');
      await outDir.create(recursive: true);
      final args = tool == seven
          ? ['x', path, '-o${outDir.path}', '-y']
          : ['x', '-o+', path, '${outDir.path}${Platform.isWindows ? r'\' : '/'}'];
      final r = await Process.run(tool, args);
      if (r.exitCode != 0) throw StateError('unpack failed: ${r.stderr}');
      return outDir;
    }
    if (lower.endsWith('.apk')) return outDir;
    throw StateError('Invalid archive type: $path (supported: rar, 7z, zip)');
  }
}


