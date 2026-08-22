import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/gen/app_localizations.dart';

/// Holds the user's language choice and persists it across launches.
///
/// A null [locale] means "follow the phone", which is the default and what most
/// users want. Only an explicit pick is stored.
///
/// Adding a language is a two-step job and touches nothing here:
///   1. drop `lib/l10n/app_<code>.arb` next to the others
///   2. run `flutter gen-l10n`
/// [AppLocalizations.supportedLocales] picks it up and the picker lists it.
class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'app_locale';

  Locale? _locale;

  /// null = follow the system language.
  Locale? get locale => _locale;

  bool get followsSystem => _locale == null;

  /// Every locale with an ARB file, in declaration order.
  static List<Locale> get supported => AppLocalizations.supportedLocales;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (_locale?.languageCode == locale?.languageCode) return;
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}

/// Makes the controller reachable from any screen, and rebuilds dependents when
/// the language changes.
class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'No LocaleScope above this widget');
    return scope!.notifier!;
  }
}

/// A language's own name, in its own script — "English", "العربية".
///
/// Read from that locale's own ARB rather than a hardcoded map, so a new
/// language needs no edit here. Falls back to the raw code if a translator
/// forgot the key.
String languageNameFor(Locale locale) =>
    lookupAppLocalizations(locale).languageName;
