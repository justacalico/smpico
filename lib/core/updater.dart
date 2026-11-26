import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String version;
  final int size;
  final String sha256;
  final String url;
  final String notes;
  UpdateInfo(this.version, this.size, this.sha256, this.url, this.notes);
}

/// Checks GitLab releases for a newer build. No update feed is
/// configured yet, so check() stays quiet until one exists.
class Updater extends ChangeNotifier {
  Updater._();
  static final Updater instance = Updater._();

  // last-known fallback; the real version comes from package_info_plus so
  // CI-stamped builds compare correctly
  static String appVersion = '1.0.0';
  static const updatesRepo = 'HttpAnimations/smpico';

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
      appVersion = (await PackageInfo.fromPlatform()).version;
    } catch (_) {}
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));
      final r = await dio.get(
        'https://gitlab.com/api/v4/projects/${Uri.encodeComponent(updatesRepo)}/releases/permalink/latest',
      );
      final d = r.data as Map<String, dynamic>;
      final tag = '${d['tag_name']}'.replaceFirst('v', '');
      if (_newer(tag, appVersion)) {
        available = UpdateInfo(
          tag,
          0,
          '',
          '${d['_links']?['self'] ?? ''}',
          '${d['description'] ?? ''}',
        );
      }
    } catch (_) {
      // no releases yet — nothing to update to
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
