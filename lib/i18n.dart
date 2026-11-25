import 'package:flutter/foundation.dart';
import 'strings.g.dart';

enum AppLang { en, ru }

class I18n extends ChangeNotifier {
  static final I18n instance = I18n._();
  I18n._();

  AppLang _lang = AppLang.en;
  AppLang get lang => _lang;

  void setLang(AppLang l) {
    if (_lang == l) return;
    _lang = l;
    notifyListeners();
  }
}

String tr(String source, [List<Object>? args]) {
  var s = source;
  if (I18n.instance.lang == AppLang.ru) {
    s = kRuStrings[source] ?? source;
  }
  if (args != null) {
    for (final a in args) {
      s = s.replaceFirst('{}', '$a');
    }
  }
  return s;
}
