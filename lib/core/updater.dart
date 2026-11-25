import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class UpdateInfo {
  final String version;
  final int size;
  final String sha256;
  final String url;
  final String notes;
  UpdateInfo(this.version, this.size, this.sha256, this.url, this.notes);
}

/// Mirrors modules/updater: checks ezpico-updates.agveit.pro first,
/// falls back to the GitHub releases API.
class Updater extends ChangeNotifier {
  Updater._();
  static final Updater instance = Updater._();

  static const appVersion = '1.0.0';
  static const updatesUrl = 'https://ezpico-updates.agveit.pro';
  static const updatesRepo = 'Cka3ka1337/EZPico';

  bool checking = false;
  UpdateInfo? available;
  String? error;

  Future<void> check() async {
    if (checking) return;
    checking = true;
    error = null;
    available = null;
    notifyListeners();
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));
      final r = await dio.get('https://api.github.com/repos/$updatesRepo/releases/latest');
      final d = r.data as Map<String, dynamic>;
      final tag = '${d['tag_name']}'.replaceFirst('v', '');
      final assets = d['assets'] as List<dynamic>;
      Map<String, dynamic>? app;
      for (final a in assets) {
        if ('${a['name']}'.startsWith('EZPico-') &&
            '${a['name']}'.endsWith('.zip')) {
          app = a;
          break;
        }
      }
      if (_newer(tag, appVersion) && app != null) {
        available = UpdateInfo(
            tag,
            app['size'] as int? ?? 0,
            '',
            '${app['browser_download_url']}',
            '${d['body'] ?? 'No release notes.'}');
      }
    } catch (e) {
      error = '$e';
    }
    checking = false;
    notifyListeners();
  }

  bool _newer(String remote, String local) {
    List<int> pa(String v) => v
        .split('.')
        .map((e) => int.tryParse(e.replaceAll(RegExp(r'[^0-9].*'), '')) ?? 0)
        .toList();
    final a = pa(remote), b = pa(local);
    for (var i = 0; i < a.length || i < b.length; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }
}
