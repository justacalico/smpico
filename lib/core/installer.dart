import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'adb.dart';
import 'axml.dart';
import 'devices.dart';
import 'downloads.dart';
import 'log.dart';
import 'paths.dart';
import 'tools.dart';
import '../i18n.dart';

enum InstallMethod { auto, direct, overport, repack }

class InstallOptions {
  InstallMethod method;
  String packageSuffix;
  bool newKey;
  bool keepSdkMeta;
  bool storeInstaller;
  String? cacheFolder; // local folder with obb/data to push
  bool downloadOnly;

  InstallOptions({
    this.method = InstallMethod.auto,
    this.packageSuffix = '',
    this.newKey = false,
    this.keepSdkMeta = false,
    this.storeInstaller = false,
    this.cacheFolder,
    this.downloadOnly = false,
  });

  InstallOptions copy() => InstallOptions(
    method: method,
    packageSuffix: packageSuffix,
    newKey: newKey,
    keepSdkMeta: keepSdkMeta,
    storeInstaller: storeInstaller,
    cacheFolder: cacheFolder,
    downloadOnly: downloadOnly,
  );
}

enum JobState { waiting, running, done, failed, cancelled }

class InstallJob extends ChangeNotifier {
  final String sourcePath;
  final String displayName;
  InstallOptions options;
  JobState state = JobState.waiting;
  String stage = '';
  final List<String> log = [];
  double progress = 0;
  String? error;
  bool cancelled = false;

  // filled by analysis
  ApkInfo? apkInfo;
  bool isOvrport = false;
  String? resolvedApk; // final apk path to install
  String? cacheSrc;
  String? cacheDest; // Android/obb or Android/data

  InstallJob(this.sourcePath, this.displayName, this.options);

  void addLog(String s) {
    log.add(s);
    dlog('install $displayName: $s');
    notifyListeners();
  }

  void setStage(String s, [double? prog]) {
    stage = s;
    if (prog != null) progress = prog;
    notifyListeners();
  }
}

class Installer extends ChangeNotifier {
  Installer._();
  static final Installer instance = Installer._();

  final List<InstallJob> jobs = [];
  bool _processing = false;

  void enqueue(String sourcePath, String displayName, InstallOptions opts) {
    dlog('install queued: $displayName ($sourcePath, ${opts.method.name})');
    jobs.insert(0, InstallJob(sourcePath, displayName, opts));
    notifyListeners();
    _process();
  }

  void cancel(InstallJob job) {
    job.cancelled = true;
    job.state = JobState.cancelled;
    job.notifyListeners();
    notifyListeners();
  }

  Future<void> _process() async {
    if (_processing) return;
    _processing = true;
    for (final job in jobs.where((j) => j.state == JobState.waiting).toList()) {
      await _install(job);
    }
    _processing = false;
  }

  bool _checkCancelled(InstallJob j) {
    if (j.cancelled) {
      j.state = JobState.cancelled;
      j.setStage('Cancelled');
      return true;
    }
    return false;
  }

  Future<void> _install(InstallJob job) async {
    job.state = JobState.running;
    job.setStage('Preparing…', 0);
    job.notifyListeners();
    try {
      var src = job.sourcePath;
      var cacheDir = job.options.cacheFolder;

      // ---- extract if archive ----
      if (await FileSystemEntity.isDirectory(src)) {
        final dir = Directory(src);
        final entries = await dir.list().toList();
        String? apk;
        for (final e in entries) {
          if (e is File && e.path.toLowerCase().endsWith('.apk')) apk = e.path;
          if (e is Directory) {
            final n = p.basename(e.path);
            if (n == 'obb' || n.startsWith('obb')) {
              cacheDir ??= e.path;
              job.cacheDest = 'Android/obb';
            } else if (n == 'data' || n == 'Android') {
              cacheDir ??= e.path;
            }
          }
        }
        if (apk == null) {
          for (final e in entries.whereType<Directory>()) {
            await for (final f in e.list(recursive: true)) {
              if (f is File && f.path.toLowerCase().endsWith('.apk')) {
                apk = f.path;
                break;
              }
            }
            if (apk != null) break;
          }
        }
        if (apk == null) throw StateError('Apk not found: $src');
        src = apk;
      } else if (!src.toLowerCase().endsWith('.apk')) {
        job.setStage('Extracting archive', .05);
        job.addLog('extract: $src');
        final outDir = await Downloads.instance.unpack(
          src,
          onProgress: (v) {
            job.setStage(
              '${tr('Extracting archive')} ${(v * 100).round()}%',
              .05 + v * .1,
            );
          },
        );
        if (outDir == null) throw StateError('Unpack error: $src');
        job.addLog('unpacked to ${outDir.path}');
        // look for apk + obb/data inside
        String? apk;
        await for (final e in outDir.list(recursive: true)) {
          if (e is File && e.path.toLowerCase().endsWith('.apk')) {
            apk ??= e.path;
          } else if (e is Directory) {
            final n = p.basename(e.path).toLowerCase();
            if (n == 'obb' && cacheDir == null) {
              cacheDir = e.path;
              job.cacheDest = 'Android/obb';
            } else if (n == 'data' && cacheDir == null) {
              cacheDir = e.path;
              job.cacheDest = 'Android/data';
            }
          }
        }
        if (apk == null) throw StateError('Apk not found: $src');
        src = apk;
      }

      if (_checkCancelled(job)) return;

      // ---- analyze ----
      job.setStage('Analyzing APK', .15);
      job.apkInfo = parseApk(File(src));
      job.addLog(
        'package: ${job.apkInfo!.package} '
        'v${job.apkInfo!.versionName} (${job.apkInfo!.versionCode})',
      );
      job.isOvrport = await _detectOvrport(File(src));
      job.addLog('ovrport: ${job.isOvrport}');

      // ---- pick method ----
      var method = job.options.method;
      if (method == InstallMethod.auto) {
        final info = Devices.instance.info;
        if (info != null && (info.matrixCracked || info.isPhoenixOvs)) {
          method = InstallMethod.direct; // clean install
        } else if (job.isOvrport) {
          method = InstallMethod.direct;
        } else {
          method = InstallMethod.repack;
        }
        job.addLog('auto -> $method');
      }

      // ---- required tools check ----
      final missing = <String>[];
      if (method == InstallMethod.repack) {
        if (await Tools.instance.java() == null) missing.add('java');
        if (await Tools.instance.apktoolJar() == null) {
          missing.add('apktool_2.12.1.jar');
        }
        if (await Tools.instance.apksignerJar() == null) {
          missing.add('apksigner.jar');
        }
      } else if (method == InstallMethod.overport || job.options.newKey) {
        if (await Tools.instance.java() == null) missing.add('java');
        if (await Tools.instance.apksignerJar() == null) {
          missing.add('apksigner.jar');
        }
      }
      if (missing.isNotEmpty) {
        throw StateError(
          tr(
            'Missing tools: {} — installation cannot continue. Put them in the tools folder or add them to PATH',
            [missing.join(', ')],
          ),
        );
      }

      // ---- wait for device ----
      if (Devices.instance.info == null) {
        job.setStage('Waiting for the headset');
        while (Devices.instance.info == null && !job.cancelled) {
          await Future.delayed(const Duration(seconds: 2));
        }
        if (_checkCancelled(job)) return;
      }

      var apkToInstall = src;

      // ---- repack ----
      if (method == InstallMethod.repack) {
        apkToInstall = await _repack(job, src);
      } else if (method == InstallMethod.overport || job.options.newKey) {
        apkToInstall = await _sign(job, src);
      }

      if (_checkCancelled(job)) return;

      // ---- install ----
      job.setStage('Installing on headset', .75);
      final res = await Adb.instance.installOnDevice(
        apkToInstall,
        installer: job.options.storeInstaller ? 'com.picovr.store' : null,
        grantAll: true,
      );
      job.addLog(res);
      if (!res.contains('Success')) {
        throw StateError('Install error: $res');
      }

      // ---- cache ----
      if (cacheDir != null) {
        job.setStage('Copying game cache', .85);
        await _pushCache(job, cacheDir);
      }

      job.state = JobState.done;
      job.setStage('Install complete', 1);
      await _recordHistory(job);
    } catch (e) {
      job.state = JobState.failed;
      job.error = '$e';
      job.setStage('Install error');
      job.addLog('error: $e');
    }
    notifyListeners();
  }

  Future<bool> _detectOvrport(File apk) async {
    // OVRPORT_HOT_WORDS = ovrport, libopenxr_loader_meta, _yvr
    try {
      final raf = await apk.open();
      try {
        // hot words live in file names / libs; cheap check: raw scan of
        // the first chunk for the marker strings
        final chunk = await raf.read(4 * 1024 * 1024);
        final s = latin1.decode(chunk, allowInvalid: true);
        return s.contains('ovrport') ||
            s.contains('libopenxr_loader_meta') ||
            s.contains('_yvr');
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }

  /// apktool d -> rename package + suffix -> strip metadata -> b -> sign
  Future<String> _repack(InstallJob job, String apk) async {
    final java = await Tools.instance.java();
    final apktool = await Tools.instance.apktoolJar();
    if (java == null || apktool == null) {
      throw StateError('apktool/java not found');
    }
    final work = await AppPaths.compileDir();
    await work.create(recursive: true);
    final base = p.basenameWithoutExtension(apk);
    final decDir = Directory(p.join(work.path, '${base}_dec'));
    if (await decDir.exists()) await decDir.delete(recursive: true);

    job.setStage('Repacking', .3);
    job.addLog('apktool d $apk');
    var r = await Process.run(java, [
      '-jar',
      apktool.path,
      'd',
      '-f',
      '-o',
      decDir.path,
      apk,
    ], workingDirectory: work.path);
    job.addLog('${r.stdout}\n${r.stderr}'.trim());
    if (r.exitCode != 0) throw StateError('apktool d failed');

    // rename package (+suffix)
    var pkg = job.apkInfo?.package ?? '';
    var newPkg = pkg;
    if (job.options.packageSuffix.isNotEmpty && pkg.isNotEmpty) {
      newPkg = '$pkg.${job.options.packageSuffix}';
    }
    if (newPkg != pkg && pkg.isNotEmpty) {
      job.addLog('rename package: $pkg -> $newPkg');
      final manifest = File(p.join(decDir.path, 'AndroidManifest.xml'));
      if (await manifest.exists()) {
        var m = await manifest.readAsString();
        m = m.replaceAll('package="$pkg"', 'package="$newPkg"');
        // provider/fileprovider authorities
        m = m.replaceAll('"$pkg.', '"$newPkg.');
        await manifest.writeAsString(m);
      }
      // apktool.yml package rename tag
      final yml = File(p.join(decDir.path, 'apktool.yml'));
      if (await yml.exists()) {
        var y = await yml.readAsString();
        y = y.replaceAll(pkg, newPkg);
        await yml.writeAsString(y);
      }
    }

    // strip SDK metadata (pvr.sdk.version etc.) unless kept
    if (!job.options.keepSdkMeta) {
      final manifest = File(p.join(decDir.path, 'AndroidManifest.xml'));
      if (await manifest.exists()) {
        var m = await manifest.readAsString();
        m = m.replaceAll(
          RegExp(
            r'\s*<meta-data[^>]*(?:sdk|pvr)[^>]*/>\s*',
            caseSensitive: false,
          ),
          '\n',
        );
        await manifest.writeAsString(m);
        job.addLog('sdk metadata stripped');
      }
    }

    job.setStage('Repacking', .5);
    final outApk = p.join(work.path, '${base}_repack.apk');
    job.addLog('apktool b');
    r = await Process.run(java, [
      '-jar',
      apktool.path,
      'b',
      '-o',
      outApk,
      decDir.path,
    ], workingDirectory: work.path);
    job.addLog('${r.stdout}\n${r.stderr}'.trim());
    if (r.exitCode != 0) throw StateError('apktool b failed');
    return _sign(job, outApk);
  }

  /// Sign an APK with apksigner + a generated keystore.
  Future<String> _sign(InstallJob job, String apk) async {
    final java = await Tools.instance.java();
    final signer = await Tools.instance.apksignerJar();
    if (java == null || signer == null) {
      throw StateError('apksigner/java not found');
    }
    final ks = await _ensureKeystore();
    job.setStage('Signing', .62);
    final signed = p.setExtension(apk, '.signed.apk');
    final r = await Process.run(java, [
      '-jar',
      signer.path,
      'sign',
      '--ks',
      ks.path,
      '--ks-pass',
      'pass:smpico',
      '--key-pass',
      'pass:smpico',
      '--out',
      signed,
      apk,
    ]);
    job.addLog('sign: ${r.stdout}${r.stderr}'.trim());
    if (r.exitCode != 0) throw StateError('signing failed');
    return signed;
  }

  Future<File> _ensureKeystore() async {
    final dir = await AppPaths.keysDir();
    await dir.create(recursive: true);
    final ks = File(p.join(dir.path, 'smpico.keystore'));
    if (await ks.exists()) return ks;
    final keytool =
        await Tools.instance.keytool() ??
        await Tools.instance.java().then(
          (j) => j == null ? null : p.join(p.dirname(j), 'keytool'),
        );
    if (keytool == null) throw StateError('keytool not found');
    await Process.run(keytool, [
      '-genkeypair',
      '-v',
      '-keystore',
      ks.path,
      '-alias',
      'smpico',
      '-keyalg',
      'RSA',
      '-keysize',
      '2048',
      '-validity',
      '10000',
      '-storepass',
      'smpico',
      '-keypass',
      'smpico',
      '-dname',
      'CN=SMPico',
    ]);
    return ks;
  }

  Future<void> _pushCache(InstallJob job, String cacheDir) async {
    final dir = Directory(cacheDir);
    if (!await dir.exists()) return;
    final dest = job.cacheDest ?? 'Android/obb';
    await for (final e in dir.list()) {
      if (_checkCancelled(job)) return;
      final name = p.basename(e.path);
      if (e is Directory) {
        job.addLog('push $name -> /sdcard/$dest/$name');
        final r = await Adb.instance.push(e.path, '/sdcard/$dest/$name');
        job.addLog('${r.stdout} ${r.stderr}'.trim());
      }
    }
    job.addLog('cache done');
  }

  Future<void> _recordHistory(InstallJob job) async {
    try {
      final f = await AppPaths.historyFile();
      List<dynamic> hist = [];
      if (await f.exists()) {
        hist = jsonDecode(await f.readAsString());
      }
      hist.insert(0, {
        'name': job.apkInfo?.label.isNotEmpty == true
            ? job.apkInfo!.label
            : job.displayName,
        'package': job.apkInfo?.package ?? '',
        'version': job.apkInfo?.versionName ?? '',
        'source': job.sourcePath,
        'method': job.options.method.name,
        'at': DateTime.now().toIso8601String(),
      });
      await f.writeAsString(jsonEncode(hist));
    } catch (_) {}
  }
}
