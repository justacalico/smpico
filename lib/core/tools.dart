import 'dart:io';

import 'package:path/path.dart' as p;

import 'paths.dart';

/// Resolves external tools the way the original SMPico does: a bundled
/// tools/ directory first, then PATH. Windows builds ship adb.exe,
/// apktool_2.12.1.jar, apksigner.jar, SignApk.jar, UnRAR.exe, scrcpy.exe,
/// keytool.exe, openssl.exe and overportcli-1.2.2-all.jar plus a JRE in
/// tools/java/bin.
class Tools {
  Tools._();
  static final Tools instance = Tools._();

  static String get _ext => Platform.isWindows ? '.exe' : '';

  Future<Directory> _dir() => AppPaths.tools();

  Future<String?> _find(String name) async {
    final t = await _dir();
    final local = File(p.join(t.path, name));
    if (await local.exists()) return local.path;
    final found = await _which(name);
    return found;
  }

  Future<String?> _which(String name) async {
    try {
      final cmd = Platform.isWindows ? 'where' : 'which';
      final r = await Process.run(cmd, [name]);
      if (r.exitCode == 0) {
        final first = '${r.stdout}'.split(RegExp(r'\r?\n')).first.trim();
        if (first.isNotEmpty) return first;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> adb() => _find('adb$_ext');

  Future<String?> scrcpy() async {
    final t = await _dir();
    for (final cand in ['scrcpy$_ext', 'scrcpy/scrcpy$_ext']) {
      final f = File(p.join(t.path, cand));
      if (await f.exists()) return f.path;
    }
    return _which('scrcpy$_ext');
  }

  Future<String?> java() async {
    final t = await _dir();
    final bundled = File(p.join(t.path, 'java', 'bin', 'java$_ext'));
    if (await bundled.exists()) return bundled.path;
    return _which('java$_ext');
  }

  Future<String?> keytool() async {
    final t = await _dir();
    final bundled = File(p.join(t.path, 'java', 'bin', 'keytool$_ext'));
    if (await bundled.exists()) return bundled.path;
    return _which('keytool$_ext');
  }

  Future<String?> unrar() async {
    final t = await _dir();
    for (final n in ['UnRAR$_ext', 'unrar$_ext', 'unrar/UnRAR$_ext']) {
      final f = File(p.join(t.path, n));
      if (await f.exists()) return f.path;
    }
    return _which('unrar');
  }

  Future<String?> sevenZip() => _which(Platform.isWindows ? '7z.exe' : '7z');

  Future<String?> openssl() async {
    final t = await _dir();
    final f = File(p.join(t.path, 'openssl$_ext'));
    if (await f.exists()) return f.path;
    return _which('openssl');
  }

  Future<File?> _jar(String name) async {
    final t = await _dir();
    for (final cand in [
      name,
      'apktool/$name',
      'signer/$name',
      'overport/$name',
    ]) {
      final f = File(p.join(t.path, cand));
      if (await f.exists()) return f;
    }
    return null;
  }

  Future<File?> apktoolJar() async {
    final t = await _dir();
    for (final n in const ['apktool_2.12.1.jar', 'apktool.jar']) {
      for (final cand in [n, 'apktool/$n']) {
        final f = File(p.join(t.path, cand));
        if (await f.exists()) return f;
      }
    }
    return null;
  }

  Future<File?> apksignerJar() => _jar('apksigner.jar');

  Future<File?> signApkJar() => _jar('SignApk.jar');

  Future<File?> overportJar() async {
    final t = await _dir();
    for (final n in const ['overportcli-1.2.2-all.jar', 'overportcli.jar']) {
      for (final cand in [n, 'overport/$n']) {
        final f = File(p.join(t.path, cand));
        if (await f.exists()) return f;
      }
    }
    return null;
  }

  /// Names of tools that are missing, matching the original's
  /// "tools not found" check.
  Future<List<String>> missing() async {
    final out = <String>[];
    if (await adb() == null) out.add('adb$_ext');
    if (await java() == null) out.add('java$_ext');
    if (await apktoolJar() == null) out.add('apktool_2.12.1.jar');
    if (await apksignerJar() == null) out.add('apksigner.jar');
    return out;
  }
}
