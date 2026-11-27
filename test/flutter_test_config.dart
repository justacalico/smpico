import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  // The app requests Segoe UI, which doesn't exist in the test font set —
  // register Roboto under that name so goldens show real glyphs instead
  // of Ahem blocks.
  for (final family in ['Segoe UI', 'Courier New', 'Consolas']) {
    final loader = FontLoader(family)
      ..addFont(
        rootBundle.load('packages/golden_toolkit/fonts/Roboto-Regular.ttf'),
      );
    await loader.load();
  }
  return testMain();
}
