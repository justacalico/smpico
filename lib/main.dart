import 'package:flutter/material.dart';
import 'package:window_manager/legacy.dart';
import 'app.dart';
import 'settings.dart';
import 'theme.dart';
import 'core/devices.dart';
import 'core/catalog.dart';
import 'core/updater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Settings.instance.init();

  const opts = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1024, 640),
    center: true,
    backgroundColor: Color(0xFF1F1F1F),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'SMPico',
  );
  await windowManager.waitUntilReadyToShow(opts, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  Devices.instance.start();
  Catalog.instance.init();
  if (Settings.instance.get('check_updates', true)) {
    Updater.instance.check();
  }

  runApp(const SMPicoApp());
}

class SMPicoApp extends StatelessWidget {
  const SMPicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMPico',
      debugShowCheckedModeBanner: false,
      theme: buildEZTheme(),
      home: const MainWindow(),
    );
  }
}
