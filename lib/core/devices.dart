import 'dart:async';

import 'package:flutter/foundation.dart';

import 'adb.dart';
import 'log.dart';
import '../settings.dart';

/// Mirrors DevicesInteractor: watches `adb devices`, auto-selects a
/// headset, refreshes its details periodically and keeps it awake
/// while SMPico is running.
class Devices extends ChangeNotifier {
  Devices._();
  static final Devices instance = Devices._();

  static const detailsEvery = Duration(seconds: 20);
  static const wakeEvery = Duration(minutes: 4);

  List<String> serials = [];
  DeviceInfo? info;
  bool connecting = false;
  bool wifiSwitching = false;
  String? lastError;

  DateTime _lastDetails = DateTime.fromMillisecondsSinceEpoch(0);
  bool _started = false;

  bool get connected => info != null;

  void start() {
    if (_started) return;
    _started = true;
    updateDevices();
    Timer.periodic(
      const Duration(seconds: 3),
      (_) => updateDevices(),
    );
    Timer.periodic(wakeEvery, (_) => _keepAwakeTick());
  }

  Future<void> updateDevices() async {
    if (!await Adb.instance.available) {
      if (serials.isNotEmpty || info != null) {
        serials = [];
        info = null;
        notifyListeners();
      }
      return;
    }
    List<String> found;
    try {
      final devs = await Adb.instance.devices();
      found = devs.where((d) => d.$2 == 'device').map((d) => d.$1).toList();
    } catch (e) {
      dlog('adb devices poll failed: $e');
      return;
    }
    final changed = !listEquals(found, serials);
    if (changed) dlog('device list: $found');
    serials = found;
    if (found.isEmpty) {
      if (info != null) {
        info = null;
        Adb.instance.device = null;
      }
      notifyListeners();
      return;
    }
    // auto-select: keep current if still present, else first
    final keep = Adb.instance.device;
    if (keep == null || !found.contains(keep)) {
      Adb.instance.device = found.first;
      _lastDetails = DateTime.fromMillisecondsSinceEpoch(0);
      info = null;
    }
    if (changed) notifyListeners();
    if (DateTime.now().difference(_lastDetails) > detailsEvery ||
        info == null) {
      _lastDetails = DateTime.now();
      await refreshDetails();
    }
  }

  Future<void> refreshDetails() async {
    if (Adb.instance.device == null) return;
    try {
      info = await Adb.instance.details();
      lastError = null;
      dlog('device details refreshed: ${info!.model} (${info!.serial})');
    } catch (e) {
      lastError = '$e';
      dlog('device details failed: $e');
    }
    notifyListeners();
  }

  Future<void> selectDevice(String serial) async {
    Adb.instance.device = serial;
    info = null;
    _lastDetails = DateTime.fromMillisecondsSinceEpoch(0);
    notifyListeners();
    await refreshDetails();
  }

  /// Wi-Fi mode: adb tcpip 5555 then connect to the headset's IP.
  Future<bool> switchToWifi() async {
    if (info == null || wifiSwitching) return false;
    wifiSwitching = true;
    notifyListeners();
    try {
      await Adb.instance.tcpip();
      await Future.delayed(const Duration(seconds: 2));
      final ip = await Adb.instance.shell(
        "ip -f inet addr show wlan0 | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}'",
      );
      if (ip.isEmpty) {
        lastError = 'Wi-Fi mode failed';
        return false;
      }
      final res = await Adb.instance.connect(ip);
      dlog('wifi connect $ip -> $res');
      if (res.contains('connected')) {
        await selectDevice('$ip:5555');
        return true;
      }
      lastError = res;
      return false;
    } catch (e) {
      lastError = '$e';
      return false;
    } finally {
      wifiSwitching = false;
      notifyListeners();
    }
  }

  Future<void> _keepAwakeTick() async {
    if (!Settings.instance.get('keep_awake', true) || info == null) return;
    try {
      if (await Adb.instance.isAsleep()) {
        await Adb.instance.wake();
      }
    } catch (e) {
      dlog('keep-awake tick failed: $e');
    }
  }
}

String fmtBytes(int bytes) {
  if (bytes <= 0) return '0';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var v = bytes.toDouble();
  var u = 0;
  while (v >= 1024 && u < units.length - 1) {
    v /= 1024;
    u++;
  }
  return '${v.toStringAsFixed(v >= 100 ? 0 : 1)} ${units[u]}';
}

String fmtUptime(int sec) {
  final d = sec ~/ 86400;
  final h = (sec % 86400) ~/ 3600;
  if (d > 0) return '$d d $h h';
  final m = (sec % 3600) ~/ 60;
  return '$h h $m min';
}
