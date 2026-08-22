import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/locale/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/auth_gate.dart';
import 'l10n/gen/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0E131D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Load the saved language before the first frame, so the app never flashes
  // the wrong language (or the wrong text direction) on launch.
  final localeController = LocaleController();
  await localeController.load();

  // The session is restored asynchronously; AuthGate holds a blank screen until
  // it resolves rather than flashing the login form at a signed-in user.
  final authController = AuthController();
  unawaited(authController.restore());

  // Tell the API which language to answer in, and keep telling it when the user
  // changes language. Falls back to the device locale when the app is following
  // the system rather than holding an explicit choice.
  void syncApiLanguage() {
    authController.languageCode =
        localeController.locale?.languageCode ??
        PlatformDispatcher.instance.locale.languageCode;
  }

  syncApiLanguage();
  localeController.addListener(syncApiLanguage);

  runApp(
    RoomPlayApp(
      localeController: localeController,
      authController: authController,
    ),
  );
}

class RoomPlayApp extends StatelessWidget {
  const RoomPlayApp({
    super.key,
    required this.localeController,
    required this.authController,
  });

  final LocaleController localeController;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: localeController,
      child: AuthScope(
        controller: authController,
        child: ListenableBuilder(
          listenable: Listenable.merge([localeController, authController]),
          builder: (context, _) => MaterialApp(
            title: 'Room Play',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            // The app is dark-only by design; there is no light mockup.
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.dark,
            // null locale = follow the device. Flutter resolves RTL from the
            // locale itself, so Arabic flips the whole layout with no extra
            // work.
            locale: localeController.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AuthGate(),
          ),
        ),
      ),
    );
  }
}
