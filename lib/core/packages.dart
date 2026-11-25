import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'adb.dart';
import 'paths.dart';

class PackageEntry {
  final String name;
  String label;
  int? iconRes;
  File? iconFile;
  int sizeBytes;
  bool system;
  PackageEntry(
    this.name, {
    this.label = '',
    this.sizeBytes = 0,
    this.system = false,
  });
}

/// App manager: lists headset packages, launches/uninstalls, saves
/// APKs, backs up and restores game saves (/data/local/tmp/smpico_backup,
/// /sdcard/smpico_restore_tmp like the original).
class Packages extends ChangeNotifier {
  Packages._();
  static final Packages instance = Packages._();

  List<PackageEntry> items = [];
  bool loading = false;
  String? error;
  final Set<String> _iconFailed = {};

  Future<void> refresh({bool thirdPartyOnly = true}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final pkgs = await Adb.instance.listPackages(
        thirdPartyOnly: thirdPartyOnly,
      );
      items = pkgs.map((e) => PackageEntry(e)).toList();
      _loadLabels();
      _loadIcons();
    } catch (e) {
      error = '$e';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> _loadLabels() async {
    // batch: dumpsys package for all? too heavy — read per-package label lazily
    for (final e in items) {
      if (e.label.isNotEmpty) continue;
      try {
        final s = await Adb.instance.shell(
          "dumpsys package ${e.name} | grep -m1 'label='",
        );
        final m = RegExp(r"label='([^']+)'|label=([^\s]+)").firstMatch(s);
        if (m != null) {
          e.label = m.group(1) ?? m.group(2) ?? '';
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  Future<void> _loadIcons() async {
    final cache = await AppPaths.iconCache();
    await cache.create(recursive: true);
    for (final e in items) {
      if (e.iconFile != null || _iconFailed.contains(e.name)) continue;
      final f = File(p.join(cache.path, '${e.name}.png'));
      if (await f.exists()) {
        e.iconFile = f;
        notifyListeners();
        continue;
      }
      try {
        final extracted = await _extractIcon(e.name, f);
        if (extracted) {
          e.iconFile = f;
        } else {
          _iconFailed.add(e.name);
        }
      } catch (_) {
        _iconFailed.add(e.name);
      }
      notifyListeners();
    }
  }

  Future<bool> _extractIcon(String pkg, File out) async {
    final apkPath = await Adb.instance.packageApkPath(pkg);
    if (apkPath == null) return false;
    final tmp = File(p.join((await AppPaths.iconCache()).path, '_tmp.apk'));
    final r = await Adb.instance.pull(apkPath, tmp.path);
    if (r.exitCode != 0) return false;
    final bytes = await tmp.readAsBytes();
    try {
      final ar = ZipDecoder().decodeBytes(bytes);
      // find the biggest launcher icon png
      ArchiveFile? best;
      for (final f in ar) {
        final n = f.name.toLowerCase();
        if (!n.endsWith('.png') && !n.endsWith('.webp')) continue;
        if (!n.contains('ic_launcher') && !n.contains('icon')) continue;
        if (n.contains('foreground') || n.contains('background')) continue;
        if (best == null || f.size > best.size) best = f;
      }
      // fallback: any big png under res/mipmap
      best ??= ar
          .where((f) {
            final n = f.name.toLowerCase();
            return (n.endsWith('.png')) && n.contains('mipmap');
          })
          .fold<ArchiveFile?>(
            null,
            (a, b) => a == null || b.size > a.size ? b : a,
          );
      if (best == null) return false;
      final content = best.content as List<int>;
      if (best.name.toLowerCase().endsWith('.webp')) {
        // flutter can't show webp everywhere — keep file anyway
        await out.writeAsBytes(content);
        return true;
      }
      await out.writeAsBytes(content);
      return true;
    } catch (_) {
      return false;
    } finally {
      await tmp.delete().catchError((_) => tmp);
    }
  }

  Future<void> clearIconCache() async {
    final cache = await AppPaths.iconCache();
    if (await cache.exists()) await cache.delete(recursive: true);
    _iconFailed.clear();
    for (final e in items) {
      e.iconFile = null;
    }
    _loadIcons();
  }

  Future<String> launch(String pkg) => Adb.instance.launchApp(pkg);

  Future<String> uninstall(String pkg) async {
    final res = await Adb.instance.uninstall(pkg);
    await refresh();
    return res;
  }

  Future<String> uninstallForUser(String pkg) async {
    final res = await Adb.instance.uninstall(pkg, forUser: true);
    await refresh();
    return res;
  }

  /// Save the APK(s) of a package to a PC folder.
  Future<String> saveApk(String pkg, Directory target) async {
    await target.create(recursive: true);
    final paths = await Adb.instance.shell('pm path $pkg');
    var saved = 0;
    for (final line in const LineSplitter().convert(paths)) {
      final m = RegExp(r'package:(/.+\.apk)').firstMatch(line);
      if (m == null) continue;
      final remote = m.group(1)!;
      final name = p.posix.basename(remote);
      final r = await Adb.instance.pull(remote, p.join(target.path, name));
      if (r.exitCode == 0) saved++;
    }
    return 'APK saved ($saved)';
  }

  /// Game save backup: pull /sdcard/Android/data/<pkg> + obb into a
  /// backup folder on the PC, via /data/local/tmp staging.
  Future<Directory?> backupSaves(String pkg) async {
    final dir = await AppPaths.backups();
    await dir.create(recursive: true);
    final dest = Directory(p.join(dir.path, pkg));
    await dest.create(recursive: true);
    for (final sub in ['Android/data/$pkg', 'Android/obb/$pkg']) {
      final remote = '/sdcard/$sub';
      final exists = await Adb.instance.shell(
        '[ -d "$remote" ] && echo yes || echo no',
      );
      if (!exists.contains('yes')) continue;
      final local = Directory(p.join(dest.path, sub.replaceAll('/', '_')));
      await local.create(recursive: true);
      await Adb.instance.pull(remote, local.path);
    }
    return dest;
  }

  Future<void> restoreSaves(String pkg, Directory backup) async {
    for (final sub in ['data', 'obb']) {
      final local = Directory(p.join(backup.path, 'Android_${sub}_$pkg'));
      if (!await local.exists()) continue;
      const tmp = '/sdcard/smpico_restore_tmp';
      await Adb.instance.mkdir(tmp);
      // the pulled dir contains <pkg>/ inside
      final inner = Directory(p.join(local.path, pkg));
      final src = await inner.exists() ? inner.path : local.path;
      await Adb.instance.push(src, '$tmp/$pkg');
      await Adb.instance.shell(
        'cp -r $tmp/$pkg /sdcard/Android/$sub/ && rm -rf $tmp/$pkg',
      );
    }
    await Adb.instance.rm('/sdcard/smpico_restore_tmp');
  }

  Future<List<String>> permissions(String pkg) async {
    final s = await Adb.instance.shell(
      'dumpsys package $pkg | grep -E "requested permissions" -A200 | grep android.permission | head -60',
    );
    final names = <String>{};
    for (final line in const LineSplitter().convert(s)) {
      final m = RegExp(r'(android\.permission\.[A-Z_0-9]+)').firstMatch(line);
      if (m != null) names.add(m.group(1)!);
    }
    return names.toList()..sort();
  }

  Future<void> grantAll(String pkg) => Adb.instance.grantAllPermissions(pkg);

  /// Report: headset info + packages + install history + logs.
  Future<File> createReport() async {
    final dir = await AppPaths.reports();
    await dir.create(recursive: true);
    final f = File(
      p.join(
        dir.path,
        'smpico_report_${DateTime.now().millisecondsSinceEpoch}.txt',
      ),
    );
    final b = StringBuffer();
    b.writeln('SMPico report ${DateTime.now().toIso8601String()}');
    b.writeln('--- device ---');
    try {
      b.writeln(await Adb.instance.details());
    } catch (_) {}
    b.writeln('--- packages ---');
    try {
      b.writeln(
        (await Adb.instance.listPackages(thirdPartyOnly: false)).join('\n'),
      );
    } catch (_) {}
    b.writeln('--- history ---');
    try {
      final h = await AppPaths.historyFile();
      if (await h.exists()) b.writeln(await h.readAsString());
    } catch (_) {}
    await f.writeAsString(b.toString());
    return f;
  }
}
