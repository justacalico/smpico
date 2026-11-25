import 'package:flutter/foundation.dart';

import 'i18n/strings.g.dart';

export 'i18n/strings.g.dart';

typedef AppLang = AppLocale;

/// Bridges slang's LocaleSettings onto the app's ChangeNotifier plumbing.
/// Locale changes still rebuild via [TranslationProvider]; this exists so
/// listeners (welcome docs, window) can subscribe without a context.
class I18n extends ChangeNotifier {
  static final I18n instance = I18n._();

  I18n._() {
    LocaleSettings.instance.getLocaleStream().listen((_) => notifyListeners());
  }

  AppLang get lang => LocaleSettings.instance.currentLocale;

  void setLang(AppLang l) => LocaleSettings.setLocaleSync(l);
}
