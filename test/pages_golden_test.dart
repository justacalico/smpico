import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smpico/app.dart';
import 'package:smpico/core/adb.dart';
import 'package:smpico/core/catalog.dart';
import 'package:smpico/core/devices.dart';
import 'package:smpico/core/downloads.dart';
import 'package:smpico/core/installer.dart';
import 'package:smpico/core/mcp_server.dart';
import 'package:smpico/core/packages.dart';
import 'package:smpico/core/remote_files.dart';
import 'package:smpico/core/tools.dart';
import 'package:smpico/i18n.dart';
import 'package:smpico/pages/app_manager_page.dart';
import 'package:smpico/pages/device_page.dart';
import 'package:smpico/pages/files_page.dart';
import 'package:smpico/pages/install_page.dart';
import 'package:smpico/pages/picoland_page.dart';
import 'package:smpico/pages/settings_page.dart';
import 'package:smpico/pages/stream_page.dart';
import 'package:smpico/settings.dart';
import 'package:smpico/theme.dart';
import 'package:smpico/widgets/welcome.dart';

// Goldens render every page in every meaningful state against the real
// dark theme — regenerate with `flutter test --update-goldens` and browse
// the PNGs under test/goldens/ to review the UI without running the app.

final _tmp = Directory.systemTemp.createTempSync('smpico-golden');

// 1x1 opaque pixel so cover art renders as a solid tile instead of a
// broken-image box.
const _ioWait = Duration(milliseconds: 150);

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

Widget _wrap(Widget page) => TranslationProvider(
  child: MaterialApp(
    theme: buildEZTheme(),
    home: Scaffold(backgroundColor: EZColors.page, body: page),
    debugShowCheckedModeBanner: false,
  ),
);

void _resetState() {
  Devices.instance.info = null;
  Devices.instance.serials = [];
  Packages.instance.items = [];
  Packages.instance.error = null;
  Packages.instance.loading = false;
  Packages.instance.installedKeys = {};
  Catalog.instance.games = [];
  Catalog.instance.genres = [];
  Catalog.instance.version = '';
  Catalog.instance.available = false;
  Catalog.instance.loading = false;
  Catalog.instance.coversDir = null;
  Downloads.instance.jobs.clear();
  Installer.instance.jobs.clear();
  RemoteFiles.instance.entries = [];
  RemoteFiles.instance.error = null;
  RemoteFiles.instance.loading = false;
  RemoteFiles.instance.currentPath = '/sdcard';
  Transfers.instance.items.clear();
}

void _seedDevice() {
  Devices.instance.serials = ['TEST1234'];
  Devices.instance.info = DeviceInfo(
    serial: 'TEST1234',
    model: 'PICO 4 Ultra',
    product: 'PICO4U',
    firmware: '5.12.0',
    displayId: 'PICO_4U_5.12.0',
    batteryPct: 78,
    charging: true,
    freeBytes: 164 << 30,
    totalBytes: 256 << 30,
    wifi: true,
    uptimeSec: 3 * 3600 + 42 * 60,
    signalDbm: '-52 dBm',
  );
}

void _seedPackages() {
  Packages.instance.seedItems(
    [
      PackageEntry('com.beatgames.beatsaber', label: 'Beat Saber')
        ..sizeBytes = 2 * 1024 * 1024 * 1024,
      PackageEntry('com.pvr.shortcut', label: 'PICO Home')
        ..sizeBytes = 300 * 1024 * 1024
        ..system = true,
      PackageEntry('com.dev.phoboslab', label: 'PhobosLab VR')
        ..sizeBytes = 900 * 1024 * 1024,
      PackageEntry('com.oculus.vrshell', label: 'VRShell')
        ..sizeBytes = 120 * 1024 * 1024
        ..system = true,
    ],
    keys: {
      'beat saber',
      'com.beatgames.beatsaber',
      'phoboslab vr',
      'com.dev.phoboslab',
    },
  );
}

Game _game(int id, String title, {bool ovrport = false}) => Game.fromRow({
  'id': id,
  'slug': 'game-$id',
  'title': title,
  'sheet_title': title,
  'ovrport': ovrport ? 1 : 0,
  'post_id': id,
  'post_url': 'https://t.me/picoIand/$id',
  'posted_at': '2026-11-20',
  'description': 'A polished VR title from the PicoLand catalog.',
  'language': 'EN/RU',
  'multiplayer': 'No',
  'version': '1.0.$id',
  'updated_at': '2026-11-20',
  'cover': 'c$id.jpg',
  'youtube': null,
  'trailer': null,
  'install_notes': null,
  'download_notes': null,
  'hints': '{}',
  'special': 0,
})
  ..genres = ['Action', 'Shooter', 'Sports'].take(1 + (id % 3)).toList()
  ..links = [
    GameLink.fromRow({
      'pos': 0,
      'kind': 'yandex',
      'label': 'Yandex Disk',
      'url': 'https://disk.yandex.ru/d/$id',
      'note': null,
      'via': null,
      'status': 'ok',
      'file_name': '$title.zip',
      'size': 4 * 1024 * 1024 * 1024 + id,
      'is_folder': 0,
    }),
  ];

void _seedCatalog() {
  final covers = Directory('${_tmp.path}/catalog/covers')
    ..createSync(recursive: true);
  Catalog.instance.coversDir = covers.path;
  Catalog.instance.games = [
    _game(1, 'Beat Saber'),
    for (var i = 2; i <= 12; i++) _game(i, 'Test Game $i', ovrport: i.isEven),
  ];
  Catalog.instance.genres = ['Action', 'Shooter', 'Sports'];
  Catalog.instance.version = '2026.11.25.2227';
  Catalog.instance.available = true;
  Catalog.instance.loading = false;
  for (final g in Catalog.instance.games) {
    File('${covers.path}/${g.cover}').writeAsBytesSync(_png);
  }
}

void _seedRemoteFiles() {
  RemoteFiles.instance.seedEntries('/sdcard/Download', [
    RemoteEntry('Android', '/sdcard/Download/Android', true, 0, '2026-11-20 10:00'),
    RemoteEntry('obb', '/sdcard/Download/obb', true, 0, '2026-11-20 10:00'),
    RemoteEntry('big_game.zip', '/sdcard/Download/big_game.zip', false,
        4 * 1024 * 1024 * 1024, '2026-11-22 19:42'),
    RemoteEntry('readme.txt', '/sdcard/Download/readme.txt', false, 1024,
        '2026-11-22 19:43'),
  ]);
}

DownloadJob _dl(
  String id,
  String title,
  String state,
  double progress,
  String? fileName, {
  int received = 0,
  int total = 0,
  String? err,
}) =>
    DownloadJob(id, title, 'https://x/$id', 'direct', _tmp)
      ..state = state
      ..progress = progress
      ..received = received
      ..total = total
      ..fileName = fileName
      ..error = err;

InstallJob _install(
  String name,
  JobState state,
  String stage,
  double progress, {
  String? err,
}) =>
    InstallJob('/tmp/$name.apk', name, InstallOptions())
      ..state = state
      ..stage = stage
      ..progress = progress
      ..error = err;

void _seedJobs() {
  Downloads.instance.jobs.addAll([
    _dl('1', 'Beat Saber', 'downloading', .42, 'beatsaber.zip',
        received: 1720 << 20, total: 4 << 30),
    _dl('2', 'GORN 2', 'waiting', 0, null),
    _dl('3', 'Arizona Sunshine', 'unpacking', .8, 'arizona.zip',
        received: 6 << 30, total: 6 << 30),
    _dl('4', 'The Climb', 'done', 1, 'climb.apk',
        received: 3 << 30, total: 3 << 30)
      ..outPath = '/sdcard/Download/climb.apk',
    _dl('5', 'Broken Link', 'failed', .1, 'bad.zip',
        received: 10 << 20, total: 2 << 30, err: 'HTTP 404'),
  ]);
  Installer.instance.jobs.addAll([
    _install('Beat Saber', JobState.running, 'Installing on headset', .75),
    _install('Waiting Game', JobState.waiting, '', 0),
    _install('Installed Game', JobState.done, 'Install complete', 1),
    _install('Failed Game', JobState.failed, 'Install error', .5,
        err: 'INSTALL_FAILED_OLDER_SDK'),
  ]);
}

Future<void> _snap(
  WidgetTester tester,
  String name,
  Widget page, {
  Size size = const Size(1440, 900),
  Duration settle = const Duration(seconds: 2),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_wrap(page));
  // Asset/file loads do real I/O that fake-async pumps can't wait for —
  // give the real event loop a moment before settling.
  await tester.runAsync(() => Future<void>.delayed(_ioWait));
  await tester.pump(settle);
  await expectLater(
    find.byWidget(page),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Tools.bundledOnly = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => _tmp.path,
    );
    await Settings.instance.init();
    I18n.instance.applySaved('en');
    // Warm the asset cache so the welcome dialog's rootBundle read
    // resolves inside a normal pump.
    await rootBundle.loadString('assets/docs/welcome_en.md');
  });

  setUp(_resetState);

  tearDownAll(() async {
    await McpServer.instance.stop();
  });

  group('device', () {
    testWidgets('disconnected', (t) async {
      await _snap(t, 'device_disconnected', const DevicePage());
    });
    testWidgets('connected', (t) async {
      _seedDevice();
      await _snap(t, 'device_connected', const DevicePage());
    });
  });

  group('app manager', () {
    testWidgets('no device', (t) async {
      await _snap(t, 'appmanager_disconnected', const AppManagerPage());
    });
    testWidgets('populated', (t) async {
      _seedDevice();
      await t.pumpWidget(_wrap(const AppManagerPage()));
      // Let the page's init-time refresh() finish failing — it holds the
      // loading state until the real process call resolves.
      for (var i = 0; i < 20; i++) {
        await t.runAsync(() => Future<void>.delayed(_ioWait));
        await t.pump();
        if (!Packages.instance.loading) break;
      }
      // refresh fired and failed — put the seeded state back
      _seedPackages();
      await t.pump();
      await expectLater(
        find.byType(AppManagerPage),
        matchesGoldenFile('goldens/appmanager_populated.png'),
      );
    });
  });

  group('files', () {
    testWidgets('no device', (t) async {
      await _snap(t, 'files_disconnected', const FilesPage());
    });
    testWidgets('populated', (t) async {
      _seedDevice();
      await t.pumpWidget(_wrap(const FilesPage()));
      // Let the page's init-time open() finish failing — it clears entries
      // and holds a loading state until the real process call resolves.
      for (var i = 0; i < 20; i++) {
        await t.runAsync(() => Future<void>.delayed(_ioWait));
        await t.pump();
        if (!RemoteFiles.instance.loading) break;
      }
      _seedRemoteFiles();
      await t.pump();
      await expectLater(
        find.byType(FilesPage),
        matchesGoldenFile('goldens/files_populated.png'),
      );
    });
    testWidgets('error', (t) async {
      _seedDevice();
      t.view.physicalSize = const Size(1440, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(_wrap(const FilesPage()));
      // open() hits missing adb and lands on the error state for real.
      for (var i = 0; i < 20; i++) {
        await t.runAsync(() => Future<void>.delayed(_ioWait));
        await t.pump();
        if (!RemoteFiles.instance.loading) break;
      }
      await t.pump();
      await expectLater(
        find.byType(FilesPage),
        matchesGoldenFile('goldens/files_error.png'),
      );
    });
  });

  group('install', () {
    testWidgets('empty', (t) async {
      await _snap(t, 'install_empty', const InstallPage());
    });
    testWidgets('queue', (t) async {
      _seedJobs();
      await _snap(t, 'install_queue', const InstallPage());
    });
  });

  group('picoland', () {
    testWidgets('loading', (t) async {
      Catalog.instance.loading = true;
      await _snap(t, 'picoland_loading', const PicoLandPage());
    });
    testWidgets('unavailable', (t) async {
      Catalog.instance.available = false;
      await _snap(t, 'picoland_unavailable', const PicoLandPage());
    });
    testWidgets('grid', (t) async {
      _seedCatalog();
      _seedPackages();
      await _snap(t, 'picoland_grid', const PicoLandPage());
    });
    testWidgets('detail', (t) async {
      _seedCatalog();
      _seedPackages();
      await t.pumpWidget(_wrap(const PicoLandPage()));
      await t.pump(const Duration(seconds: 2));
      await t.tap(find.text('Beat Saber').first);
      await t.pump(const Duration(seconds: 2));
      await expectLater(
        find.byType(PicoLandPage),
        matchesGoldenFile('goldens/picoland_detail.png'),
      );
    });
    testWidgets('empty search', (t) async {
      _seedCatalog();
      await t.pumpWidget(_wrap(const PicoLandPage()));
      await t.pump(const Duration(seconds: 2));
      await t.enterText(find.byType(TextField).first, 'zzzzz nothing');
      await t.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(PicoLandPage),
        matchesGoldenFile('goldens/picoland_empty_search.png'),
      );
    });
  });

  group('stream', () {
    testWidgets('missing tool', (t) async {
      await _snap(t, 'stream_no_scrcpy', const StreamPage());
    });
    testWidgets('device connected', (t) async {
      _seedDevice();
      await _snap(t, 'stream_connected', const StreamPage());
    });
  });

  group('settings', () {
    testWidgets('default', (t) async {
      await _snap(t, 'settings_default', const SettingsPage());
    });
    testWidgets('mcp enabled', (t) async {
      await Settings.instance.set('mcp_enabled', true);
      // bind/close are real async I/O — runAsync lifts them out of the
      // fake-async zone or they deadlock the test clock
      await t.runAsync(() => McpServer.instance.start());
      addTearDown(() async {
        await Settings.instance.set('mcp_enabled', false);
      });
      await _snap(t, 'settings_mcp', const SettingsPage());
      await t.runAsync(() => McpServer.instance.stop());
    });
  });

  group('shell', () {
    testWidgets('main window with device', (t) async {
      _seedDevice();
      _seedPackages();
      await _snap(t, 'shell_main', const MainWindow());
    });
    testGoldens('welcome dialog', (t) async {
      t.view.physicalSize = const Size(1440, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            theme: buildEZTheme(),
            home: const Scaffold(body: Center(child: WelcomeDialog())),
            debugShowCheckedModeBanner: false,
          ),
        ),
      );
      await t.pump(const Duration(seconds: 2));
      // captureImage on the Dialog element drops clipped viewport content —
      // screenshot the whole screen instead.
      await screenMatchesGolden(t, 'welcome');
    });
  });
}
