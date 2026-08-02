import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/en.dart';
import '../l10n/fr.dart';
import '../l10n/de.dart';
import '../l10n/es.dart';
import '../l10n/it.dart';

class TranslationService extends ChangeNotifier {
  static const _localeKey = 'app_locale';

  Locale _locale = const Locale('fr');
  Locale get locale => _locale;

  Map<String, String> get _strings {
    switch (_locale.languageCode) {
      case 'en': return en;
      case 'de': return de;
      case 'es': return es;
      case 'it': return it;
      default: return fr;
    }
  }

  String tr(String key, [List<String>? args]) {
    var text = _strings[key] ?? key;
    if (args != null) {
      for (var i = 0; i < args.length; i++) {
        text = text.replaceAll('{$i}', args[i]);
      }
    }
    return text;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null) {
      _locale = Locale(code);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  Locale? localeResolutionCallback(Locale? locale, Iterable<Locale> supported) {
    if (locale == null) return _locale;
    for (final s in supported) {
      if (s.languageCode == locale.languageCode) return s;
    }
    return _locale;
  }

  static final List<Locale> supportedLocales = [
    const Locale('fr'),
    const Locale('en'),
    const Locale('de'),
    const Locale('es'),
    const Locale('it'),
  ];
}
