import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:room_play/core/locale/locale_controller.dart';
import 'package:room_play/core/theme/app_theme.dart';
import 'package:room_play/features/auth/auth_controller.dart';
import 'package:room_play/features/auth/forgot_password_screen.dart';
import 'package:room_play/features/auth/login_screen.dart';
import 'package:room_play/features/auth/signup_screen.dart';
import 'package:room_play/l10n/gen/app_localizations.dart';
import 'package:room_play/data/mock_data.dart';
import 'package:room_play/features/create/create_screen.dart';
import 'package:room_play/features/games/games_screen.dart';
import 'package:room_play/features/messages/messages_screen.dart';
import 'package:room_play/features/profile/profile_screen.dart';
import 'package:room_play/features/rooms/room_screen.dart';
import 'package:room_play/features/rooms/rooms_screen.dart';
import 'package:room_play/features/shell/main_shell.dart';

/// Renders each screen to `test/goldens/*.png` for visual review against the
/// mockup. Regenerate with:
///
///     flutter test test/screenshots.dart --update-goldens
///
/// These are review artefacts, not assertions. The filename deliberately does
/// NOT end in `_test.dart`, so a plain `flutter test` skips it — otherwise
/// every intentional layout tweak would fail the suite as a golden mismatch.
Future<void> _shoot(
  WidgetTester tester,
  String name,
  Widget child, {
  Size size = const Size(390, 844),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = Size(size.width * 3, size.height * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    'app_locale': locale.languageCode,
    'auth_token': 'mock-token',
    'auth_email': 'alex@example.com',
    'auth_name': 'Alex',
  });
  final localeController = LocaleController();
  await localeController.load();
  final authController = AuthController();
  await authController.restore();

  await tester.pumpWidget(
    // Both scopes sit above MaterialApp: the profile screen reads the locale
    // controller to show and change the language, and the auth screens read the
    // auth controller.
    LocaleScope(
      controller: localeController,
      child: AuthScope(
        controller: authController,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Asset images decode asynchronously and pumpAndSettle does not wait for
  // them, so without this every Image renders blank in the capture.
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// `flutter_test` renders with a placeholder font by default, which turns every
/// glyph into a box. Load the real faces so the goldens show what ships.
Future<void> _loadRealFonts() async {
  Future<void> load(String family, String path) async {
    final file = File(path);
    if (!file.existsSync()) return;
    final bytes = await file.readAsBytes();
    await (FontLoader(family)..addFont(
          Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
        ))
        .load();
  }

  await load('Inter', 'assets/fonts/Inter-Variable.ttf');
  // Without Cairo the Arabic captures are nothing but boxes.
  await load('Cairo', 'assets/fonts/Cairo-Variable.ttf');
  await load(
    'MaterialIcons',
    r'C:\src\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
  );
  await load('Segoe UI Emoji', r'C:\Windows\Fonts\seguiemj.ttf');
}

void main() {
  const repo = MockRepository();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadRealFonts();
  });

  testWidgets('shot login', (t) async {
    await _shoot(t, '00_login', const LoginScreen());
  });

  testWidgets('shot signup', (t) async {
    await _shoot(t, '00b_signup', const SignUpScreen());
  });

  testWidgets('shot forgot password', (t) async {
    await _shoot(t, '00c_forgot', const ForgotPasswordScreen());
  });

  testWidgets('shot home', (t) async {
    await _shoot(t, '01_home', const MainShell());
  });

  testWidgets('shot room', (t) async {
    await _shoot(t, '02_room', RoomScreen(room: repo.rooms().first));
  });

  testWidgets('shot games', (t) async {
    await _shoot(t, '03_games', const GamesScreen());
  });

  testWidgets('shot create', (t) async {
    await _shoot(
      t,
      '04_create',
      const Scaffold(body: SafeArea(child: CreateScreen())),
    );
  });

  testWidgets('shot messages', (t) async {
    await _shoot(t, '05_messages', const Scaffold(body: MessagesScreen()));
  });

  testWidgets('shot rooms tab', (t) async {
    await _shoot(t, '06_rooms', const Scaffold(body: RoomsScreen()));
  });

  testWidgets('shot profile', (t) async {
    await _shoot(t, '07_profile', const Scaffold(body: ProfileScreen()));
  });

  // Arabic captures double as the RTL review: everything below should read
  // right-to-left, with the nav, chevrons and seat grid mirrored.
  const ar = Locale('ar');

  testWidgets('shot login ar', (t) async {
    await _shoot(t, '10_login_ar', const LoginScreen(), locale: ar);
  });

  testWidgets('shot signup ar', (t) async {
    await _shoot(t, '10b_signup_ar', const SignUpScreen(), locale: ar);
  });

  testWidgets('shot home ar', (t) async {
    await _shoot(t, '11_home_ar', const MainShell(), locale: ar);
  });

  testWidgets('shot room ar', (t) async {
    await _shoot(
      t,
      '12_room_ar',
      RoomScreen(room: repo.rooms().first),
      locale: ar,
    );
  });

  testWidgets('shot games ar', (t) async {
    await _shoot(t, '13_games_ar', const GamesScreen(), locale: ar);
  });

  testWidgets('shot create ar', (t) async {
    await _shoot(
      t,
      '14_create_ar',
      const Scaffold(body: SafeArea(child: CreateScreen())),
      locale: ar,
    );
  });

  testWidgets('shot messages ar', (t) async {
    await _shoot(
      t,
      '15_messages_ar',
      const Scaffold(body: MessagesScreen()),
      locale: ar,
    );
  });

  testWidgets('shot profile ar', (t) async {
    await _shoot(
      t,
      '17_profile_ar',
      const Scaffold(body: ProfileScreen()),
      locale: ar,
    );
  });
}
