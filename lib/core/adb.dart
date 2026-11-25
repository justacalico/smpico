import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'tools.dart';

class DeviceInfo {
  String addr;
  String serial;
  String model;
  String product;
  String firmware;
  String displayId;
  String oemState;
  String matrixVersion;
  int batteryPct;
  bool charging;
  int freeBytes;
  int totalBytes;
  bool wifi;
  int uptimeSec;
  String signalDbm;

  DeviceInfo({
    this.addr = '',
    this.serial = '',
    this.model = '',
    this.product = '',
    this.firmware = '',
    this.displayId = '',
    this.oemState = '',
    this.matrixVersion = '',
    this.batteryPct = -1,
    this.charging = false,
    this.freeBytes = 0,
    this.totalBytes = 0,
    this.wifi = false,
    this.uptimeSec = 0,
    this.signalDbm = '',
  });

  static const matrixPackage = 'com.bytedance.pico.matrix';

  bool get matrixCracked => matrixVersion.startsWith('9.9.9');
  bool get isPhoenixOvs => model.toLowerCase().contains('phoenix') ||
      product.toLowerCase().contains('phoenix');
  String get matrixText => matrixCracked ? '$matrixVersion ✓' : matrixVersion;
}

/// Thin wrapper over the adb binary, mirroring ADBController.
class Adb {
  Adb._();
  static final Adb instance = Adb._();

  String? _adbPath;
  String? device; // selected serial / host:port

  Future<String?> _adb() async {
    _adbPath ??= await Tools.instance.adb();
    return _adbPath;
  }

  Future<bool> get available async => await _adb() != null;

  List<String> _base() {
    final a = <String>[];
    if (device != null && device!.isNotEmpty) a.addAll(['-s', device!]);
    return a;
  }

  Future<ProcessResult> run(List<String> args,
      {Duration timeout = const Duration(seconds: 30)}) async {
    final adb = await _adb();
    if (adb == null) throw StateError('adb not found');
    return Process.run(adb, args).timeout(timeout);
  }

  Future<String> out(List<String> args,
      {Duration timeout = const Duration(seconds: 30)}) async {
    final r = await run(args, timeout: timeout);
    return '${r.stdout}'.trim();
  }

  Future<String> shell(String cmd,
      {Duration timeout = const Duration(seconds: 30)}) =>
      out(_base() + ['shell', cmd], timeout: timeout);

  Future<void> initServer() async {
    await run(['start-server'], timeout: const Duration(seconds: 15));
  }

  /// Returns (serial, status) pairs from `adb devices`.
  Future<List<(String, String)>> devices() async {
    final s = await out(['devices']);
    final out2 = <(String, String)>[];
    for (final line in const LineSplitter().convert(s)) {
      final l = line.trim();
      if (l.isEmpty || l.startsWith('List of devices')) continue;
      final parts = l.split(RegExp(r'\s+'));
      if (parts.length >= 2) out2.add((parts[0], parts[1]));
    }
    return out2;
  }

  Future<String> getProp(String prop) => shell('getprop $prop');

  Future<Map<String, String>> getProps(List<String> props) async {
    final res = <String, String>{};
    for (final pr in props) {
      res[pr] = await getProp(pr);
    }
    return res;
  }

  Future<int> batteryPct() async {
    final s = await shell('dumpsys battery | grep level');
    final m = RegExp(r'level:\s*(\d+)').firstMatch(s);
    return m == null ? -1 : int.parse(m.group(1)!);
  }

  Future<bool> charging() async {
    final s = await shell('dumpsys battery | grep -E "status|powered"');
    return RegExp(r'status:\s*[235]|powered:\s*1|AC powered:\s*true',
            caseSensitive: false)
        .hasMatch(s);
  }

  /// (free, total) bytes of /sdcard via `df`.
  Future<(int, int)> freeMem() async {
    final s = await shell('df /sdcard | tail -1');
    final parts = s.split(RegExp(r'\s+'));
    if (parts.length >= 4) {
      final total = (int.tryParse(parts[1]) ?? 0) * 1024;
      final avail = (int.tryParse(parts[3]) ?? 0) * 1024;
      return (avail, total);
    }
    return (0, 0);
  }

  Future<String> packageVersion(String pkg) async {
    final s = await shell(
        'dumpsys package $pkg | grep -m1 versionName');
    final m = RegExp(r'versionName=([^\s]+)').firstMatch(s);
    return m?.group(1) ?? '';
  }

  Future<String> uptime() => shell('cat /proc/uptime');

  Future<List<String>> ls(String path) async {
    final s = await shell('ls -la "$path"');
    return const LineSplitter().convert(s);
  }

  Future<void> rm(String path) => shell('rm -rf "$path"');

  Future<void> mkdir(String path) => shell('mkdir -p "$path"');

  Future<void> move(String from, String to) =>
      shell('mv "$from" "$to"');

  Future<ProcessResult> push(String local, String remote,
          {Duration timeout = const Duration(minutes: 30)}) =>
      run(_base() + ['push', local, remote], timeout: timeout);

  Future<ProcessResult> pull(String remote, String local,
          {Duration timeout = const Duration(minutes: 30)}) =>
      run(_base() + ['pull', remote, local], timeout: timeout);

  /// pm install with optional extra flags (e.g. -i com.picovr.store).
  Future<String> install(String apkPath,
      {String? installer, bool grantAll = true}) async {
    final args = _base() + ['install'];
    if (grantAll) args.add('-g');
    args.add('-r');
    if (installer != null) args.addAll(['-i', installer]);
    args.add(apkPath);
    final r = await run(args, timeout: const Duration(minutes: 15));
    return '${r.stdout}\n${r.stderr}'.trim();
  }

  /// Push an APK then `pm install` it on the device — used for paths
  /// with characters adb can't handle directly.
  Future<String> installOnDevice(String localApk,
      {String? installer, bool grantAll = true}) async {
    const tmp = '/data/local/tmp/_smpico_install.apk';
    await push(localApk, tmp, timeout: const Duration(minutes: 10));
    var cmd = 'pm install -r';
    if (grantAll) cmd += ' -g';
    if (installer != null) cmd += ' -i $installer';
    cmd += ' $tmp; rm -f $tmp';
    return shell(cmd, timeout: const Duration(minutes: 15));
  }

  Future<String> uninstall(String pkg, {bool forUser = false}) =>
      shell(forUser ? 'pm uninstall -k --user 0 $pkg' : 'pm uninstall $pkg',
          timeout: const Duration(minutes: 5));

  Future<List<String>> listPackages({bool thirdPartyOnly = true}) => shell(
          thirdPartyOnly
              ? 'pm list packages -3'
              : 'pm list packages')
      .then((s) => const LineSplitter()
          .convert(s)
          .map((l) => l.replaceFirst('package:', '').trim())
          .where((l) => l.isNotEmpty)
          .toList()
        ..sort());

  Future<int> remoteSize(String path) async {
    final s = await shell('du -sk "$path" 2>/dev/null | cut -f1');
    return (int.tryParse(s.trim()) ?? 0) * 1024;
  }

  Future<void> tcpip() => run(_base() + ['tcpip', '5555']);

  Future<String> connect(String addr) =>
      out(['connect', '$addr:5555'], timeout: const Duration(seconds: 15));

  Future<String> disconnect(String addr) => out(['disconnect', addr]);

  Future<void> reboot() => shell('reboot');

  Future<void> shutdown() => shell('reboot -p');

  Future<void> waitForDevice() =>
      run(_base() + ['wait-for-device'], timeout: const Duration(minutes: 5));

  Future<DeviceInfo> details() async {
    final d = DeviceInfo();
    d.serial = device ?? '';
    d.wifi = d.serial.contains(':');
    d.product = await getProp('ro.product.name');
    final model = await getProp('pxr.vendorhw.product.model');
    d.model = model.isNotEmpty ? model : d.product;
    d.firmware = await getProp('ro.pui.build.version');
    d.displayId = await getProp('ro.build.display.id');
    d.oemState = await getProp('ro.oem.state');
    d.matrixVersion = await packageVersion(DeviceInfo.matrixPackage);
    d.batteryPct = await batteryPct();
    d.charging = await charging();
    final mem = await freeMem();
    d.freeBytes = mem.$1;
    d.totalBytes = mem.$2;
    try {
      final up = await uptime();
      d.uptimeSec = (double.tryParse(up.split(' ').first) ?? 0).round();
    } catch (_) {}
    if (d.wifi) {
      final s = await shell('cat /proc/net/wireless 2>/dev/null | tail -1');
      final m = RegExp(r'(-\d+)\.').firstMatch(s);
      if (m != null) d.signalDbm = m.group(1)!;
    }
    return d;
  }

  Future<bool> isAsleep() async {
    final s = await shell('dumpsys power | grep mWakefulness=');
    return s.contains('Asleep') || s.contains('Dozing');
  }

  Future<void> wake() => shell('input keyevent KEYCODE_WAKEUP');

  Future<void> grantAllPermissions(String pkg) async {
    final perms = await shell(
        'dumpsys package $pkg | grep -E "requested permissions|android.permission"');
    final names = <String>{};
    for (final line in const LineSplitter().convert(perms)) {
      final m = RegExp(r'(android\.permission\.[A-Z_0-9]+)').firstMatch(line);
      if (m != null) names.add(m.group(1)!);
    }
    for (final name in names) {
      await shell('pm grant $pkg $name').catchError((_) => '');
    }
  }

  /// Pull the launcher icon for a package as PNG bytes (best effort):
  /// finds the APK path, extracts the icon resource.
  Future<String?> packageApkPath(String pkg) async {
    final s = await shell('pm path $pkg');
    final m = RegExp(r'package:(/[^\s]+\.apk)').firstMatch(s);
    return m?.group(1);
  }

  Future<String> launchApp(String pkg) async {
    final act = await shell(
        "cmd package resolve-activity --brief $pkg 2>/dev/null | tail -1");
    if (act.contains('/')) {
      return shell('am start -n $act');
    }
    return shell(
        'monkey -p $pkg -c android.intent.category.LAUNCHER 1');
  }
}
