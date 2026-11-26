import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'adb.dart';

class RemoteEntry {
  final String name;
  final String path;
  final bool isDir;
  final int size;
  final String modified;
  RemoteEntry(this.name, this.path, this.isDir, this.size, this.modified);
}

/// Headset file manager over `adb shell` — mirrors modules/files/manager.
class RemoteFiles extends ChangeNotifier {
  RemoteFiles._();
  static final RemoteFiles instance = RemoteFiles._();

  String currentPath = '/sdcard';
  List<RemoteEntry> entries = [];
  bool loading = false;
  String? error;
  final List<String> history = [];
  int historyPos = -1;
  bool showHidden = false;

  static const quickPaths = <String>[
    '/sdcard',
    '/sdcard/Download',
    '/sdcard/Android/obb',
    '/sdcard/Android/data',
    '/sdcard/Pictures/Screenshots',
    '/sdcard/Movies/ScreenRecording',
    '/',
  ];

  Future<void> open(String path, {bool pushHistory = true}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final out = await Adb.instance.shell(
        'ls -la "$path" 2>/dev/null || echo __NOENT__',
      );
      if (out.contains('__NOENT__')) {
        error = 'Cannot open this folder';
        loading = false;
        notifyListeners();
        return;
      }
      final list = <RemoteEntry>[];
      for (final line in const LineSplitter().convert(out)) {
        final l = line.trim();
        if (l.isEmpty || l.startsWith('total')) continue;
        final m = RegExp(
          r'^([bcdlps-][rwxts-]{9})\s+\d+\s+\S+\s+\S+\s+(\d+)?\s*(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}|\w+\s+\d+\s+[\d:]+)\s+(.+)$',
        ).firstMatch(l);
        if (m == null) continue;
        var name = m.group(4)!;
        final isDir = m.group(1)!.startsWith('d');
        // strip symlink target
        name = name.split(' -> ').first;
        if (name == '.' || name == '..') continue;
        if (!showHidden && name.startsWith('.')) continue;
        list.add(
          RemoteEntry(
            name,
            p.posix.join(path, name),
            isDir,
            int.tryParse(m.group(2) ?? '') ?? 0,
            m.group(3) ?? '',
          ),
        );
      }
      list.sort((a, b) {
        if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      if (pushHistory) {
        history.removeRange(historyPos + 1, history.length);
        history.add(path);
        historyPos = history.length - 1;
      }
      currentPath = path;
      entries = list;
    } catch (e) {
      error = '$e';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> refresh() => open(currentPath, pushHistory: false);

  Future<void> up() {
    final parent = p.posix.dirname(currentPath);
    return open(parent == currentPath ? '/' : parent);
  }

  Future<void> back() async {
    if (historyPos > 0) {
      historyPos--;
      await open(history[historyPos], pushHistory: false);
    }
  }

  Future<void> forward() async {
    if (historyPos < history.length - 1) {
      historyPos++;
      await open(history[historyPos], pushHistory: false);
    }
  }

  Future<void> mkdir(String name) async {
    if (name.contains('/')) throw ArgumentError('The name cannot contain «/»');
    await Adb.instance.mkdir(p.posix.join(currentPath, name));
    await refresh();
  }

  Future<void> rename(RemoteEntry e, String newName) async {
    if (newName.contains('/')) {
      throw ArgumentError('The name cannot contain «/»');
    }
    await Adb.instance.move(e.path, p.posix.join(currentPath, newName));
    await refresh();
  }

  Future<void> delete(List<RemoteEntry> items) async {
    for (final e in items) {
      if (e.path == '/' || e.path.split('/').length <= 2 && e.isDir) {
        if (e.path == '/') continue; // refuse to delete a drive root
      }
      await Adb.instance.rm(e.path);
    }
    await refresh();
  }

  /// Biggest files under a path: `du -ah | sort -rh`.
  Future<List<RemoteEntry>> heaviest(String path, {int limit = 100}) async {
    final out = await Adb.instance.shell(
      'du -ak "$path" 2>/dev/null | sort -rn | head -$limit',
      timeout: const Duration(minutes: 5),
    );
    final list = <RemoteEntry>[];
    for (final line in const LineSplitter().convert(out)) {
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      final kb = int.tryParse(parts[0]) ?? 0;
      final fp = parts.sublist(1).join(' ');
      if (fp == path) continue;
      list.add(RemoteEntry(p.posix.basename(fp), fp, false, kb * 1024, ''));
    }
    return list;
  }

  Future<int> dirSize(String path) => Adb.instance.remoteSize(path);
}

class Transfer {
  final String name;
  final bool upload; // pc -> headset
  double progress = 0;
  bool done = false;
  String? error;
  Transfer(this.name, this.upload);
}

class Transfers extends ChangeNotifier {
  Transfers._();
  static final Transfers instance = Transfers._();

  final List<Transfer> items = [];

  Future<void> upload(List<String> localPaths, String remoteDir) async {
    for (final lp in localPaths) {
      final t = Transfer(p.basename(lp), true);
      items.insert(0, t);
      notifyListeners();
      try {
        final r = await Adb.instance.push(
          lp,
          p.posix.join(remoteDir, p.basename(lp)),
        );
        if (r.exitCode != 0) throw StateError('${r.stderr}');
        t.done = true;
      } catch (e) {
        t.error = '$e';
      }
      notifyListeners();
    }
    await RemoteFiles.instance.refresh();
  }

  Future<void> download(List<RemoteEntry> items2, Directory target) async {
    await target.create(recursive: true);
    for (final e in items2) {
      final t = Transfer(e.name, false);
      items.insert(0, t);
      notifyListeners();
      try {
        final r = await Adb.instance.pull(e.path, p.join(target.path, e.name));
        if (r.exitCode != 0) throw StateError('${r.stderr}');
        t.done = true;
      } catch (err) {
        t.error = '$err';
      }
      notifyListeners();
    }
  }

  void clearFinished() {
    items.removeWhere((t) => t.done || t.error != null);
    notifyListeners();
  }
}
