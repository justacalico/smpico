import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/legacy.dart';

import 'i18n.dart';
import 'app.dart';
import 'settings.dart';
import 'theme.dart';
import 'core/devices.dart';
import 'core/catalog.dart';
import 'core/downloads.dart';
import 'core/mcp_server.dart';
import 'core/updater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await Settings.instance.init();
  EZColors.applyAccent(Settings.instance.get('accent', 'Green'));

  const opts = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(560, 480),
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
  Downloads.instance.init();
  McpServer.instance.init();
  if (Settings.instance.get('check_updates', true)) {
    Updater.instance.check();
  }

  runApp(TranslationProvider(child: const SMPicoApp()));
}

class SMPicoApp extends StatelessWidget {
  const SMPicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Settings.instance,
      builder: (context, _) => MaterialApp(
        title: 'SMPico',
        debugShowCheckedModeBanner: false,
        locale: TranslationProvider.of(context).locale.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: buildEZTheme(),
        home: const MainWindow(),
      ),
    );
  }
}
