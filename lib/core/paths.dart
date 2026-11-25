import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppPaths {
  AppPaths._();

  static Directory? _root;
  static Directory? _workspace;

  /// C:/ProgramData/smpico on Windows, ~/.local/share/smpico on Linux,
  /// ~/Library/Application Support/SMPico on macOS.
  static Future<Directory> root() async {
    if (_root != null) return _root!;
    if (Platform.isWindows) {
      _root = Directory(r'C:\ProgramData\smpico');
    } else if (Platform.isMacOS) {
      _root = Directory(p.join(
          Platform.environment['HOME']!, 'Library', 'Application Support', 'SMPico'));
    } else {
      _root = Directory(p.join(
          Platform.environment['HOME']!, '.local', 'share', 'smpico'));
    }
    await _root!.create(recursive: true);
    return _root!;
  }

  static Future<Directory> tools() async =>
      Directory(p.join((await root()).path, 'tools'));

  /// C:/ProgramData/smpico_workspace on Windows.
  static Future<Directory> workspace() async {
    if (_workspace != null) return _workspace!;
    if (Platform.isWindows) {
      _workspace = Directory(r'C:\ProgramData\smpico_workspace');
    } else {
      _workspace = Directory(p.join((await root()).path, 'workspace'));
    }
    await _workspace!.create(recursive: true);
    return _workspace!;
  }

  static Future<Directory> downloads() async =>
      Directory(p.join((await workspace()).path, 'downloads'));

  static Future<Directory> backups() async =>
      Directory(p.join((await workspace()).path, 'backups'));

  static Future<Directory> screenshots() async =>
      Directory(p.join((await workspace()).path, 'screenshots'));

  static Future<Directory> recordings() async =>
      Directory(p.join((await workspace()).path, 'recordings'));

  static Future<Directory> reports() async =>
      Directory(p.join((await workspace()).path, 'reports'));

  static Future<Directory> catalogDir() async =>
      Directory(p.join((await workspace()).path, 'catalog'));

  static Future<Directory> iconCache() async =>
      Directory(p.join((await workspace()).path, 'icon_cache'));

  static Future<Directory> compileDir() async =>
      Directory(p.join((await workspace()).path, 'compiled'));

  static Future<Directory> keysDir() async =>
      Directory(p.join((await root()).path, 'keys'));

  static Future<File> historyFile() async =>
      File(p.join((await workspace()).path, 'history.json'));

  static Future<File> savedCommandsFile() async =>
      File(p.join((await workspace()).path, 'adb_commands.json'));

  static Future<Directory> userDownloads() async =>
      (await getDownloadsDirectory()) ??
      await getApplicationDocumentsDirectory();
}
