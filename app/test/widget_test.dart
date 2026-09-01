import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:room_play/core/api/api_client.dart';
import 'package:room_play/core/locale/locale_controller.dart';
import 'package:room_play/features/auth/auth_controller.dart';
import 'package:room_play/features/profile/profile_screen.dart';
import 'package:room_play/main.dart';

const _user = {
  'id': '567185',
  'name': 'Alex',
  'email': 'alex@example.com',
  'level': 1,
};

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

/// A stand-in Laravel that accepts everything.
MockClient _serverThatAccepts() => MockClient((request) async {
  final path = request.url.path;
  if (path.endsWith('/register')) {
    return _json({'token': 'server-token', 'user': _user}, 201);
  }
  if (path.endsWith('/login')) {
    return _json({'token': 'server-token', 'user': _user});
  }
  return _json({'message': 'ok'});
});

/// Builds the app with a known language and session, backed by in-memory
/// preferences.
///
/// [signedIn] defaults to true so the shell tests reach the app; the auth tests
/// pass false to land on the login screen instead.
Future<void> _pumpApp(
  WidgetTester tester, {
  String? languageCode,
  bool signedIn = true,
  MockClient? server,
}) async {
  SharedPreferences.setMockInitialValues({
    'app_locale': ?languageCode,
    if (signedIn) ...{
      'auth_token': 'mock-token',
      'auth_email': 'alex@example.com',
      'auth_name': 'Alex',
    },
  });

  // Render at a realistic phone size — the default 800x600 test surface pushes
  // most of the home screen below the fold.
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final locale = LocaleController();
  await locale.load();
  // Never let a test reach the network: an unstubbed call would either hang or
  // fail depending on the machine it runs on.
  final auth = AuthController(
    api: ApiClient(
      httpClient: server ?? _serverThatAccepts(),
      baseUrl: 'http://test.local',
    ),
  );
  await auth.restore();

  await tester.pumpWidget(
    RoomPlayApp(localeController: locale, authController: auth),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows the game rail and the room list', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Popular Games'), findsOneWidget);
    expect(find.text('Recommended Rooms'), findsOneWidget);
    expect(find.text('Chill & Talk'), findsOneWidget);
  });

  testWidgets('tapping a room opens the voice room', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Chill & Talk'));
    await tester.pumpAndSettle();

    expect(find.text('ID: 102938'), findsOneWidget);
    expect(find.text('Open'), findsWidgets);
    // Princess appears twice: once on her seat, once as a chat author.
    expect(find.text('Princess'), findsNWidgets(2));
  });

  testWidgets('mic button toggles the seat mute badge', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Chill & Talk'));
    await tester.pumpAndSettle();

    // "You" starts muted, so a mic_off badge is on the seat.
    expect(find.byIcon(Icons.mic_off_rounded), findsWidgets);

    await tester.tap(find.text('Mic'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.mic_rounded), findsWidgets);
  });

  testWidgets('bottom nav reaches the profile tab', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Gold balance'), findsOneWidget);
  });

  testWidgets('see all opens the games catalogue', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('See All'));
    await tester.pumpAndSettle();

    expect(find.text('Games'), findsWidgets);
    expect(find.text('Play'), findsWidgets);
  });

  // ------------------------------------------------------------ localisation

  testWidgets('saved Arabic preference renders Arabic strings', (tester) async {
    await _pumpApp(tester, languageCode: 'ar');

    expect(find.text('الألعاب الشائعة'), findsOneWidget);
    expect(find.text('غرف مقترحة'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
  });

  testWidgets('Arabic flips the layout to right-to-left', (tester) async {
    await _pumpApp(tester, languageCode: 'ar');

    final direction = Directionality.of(tester.element(find.text('الرئيسية')));
    expect(direction, TextDirection.rtl);
  });

  testWidgets('English stays left-to-right', (tester) async {
    await _pumpApp(tester, languageCode: 'en');

    final direction = Directionality.of(tester.element(find.text('Home')));
    expect(direction, TextDirection.ltr);
  });

  testWidgets('picking a language switches the UI live', (tester) async {
    await _pumpApp(tester, languageCode: 'en');

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    // Each language names itself in its own script.
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(find.text('حسابي'), findsWidgets);
    expect(find.text('رصيد الذهب'), findsOneWidget);
  });

  testWidgets('language choice is written to preferences', (tester) async {
    await _pumpApp(tester, languageCode: 'en');

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'ar');
  });

  // -------------------------------------------------------------------- auth

  testWidgets('no session lands on the login screen', (tester) async {
    await _pumpApp(tester, signedIn: false);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    // The shell must not be reachable behind it.
    expect(find.text('Popular Games'), findsNothing);
  });

  testWidgets('a saved session skips login', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('Popular Games'), findsOneWidget);
  });

  testWidgets('empty login shows both field errors', (tester) async {
    await _pumpApp(tester, signedIn: false);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('a malformed email is rejected', (tester) async {
    await _pumpApp(tester, signedIn: false);

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(
      find.text("That doesn't look like an email address"),
      findsOneWidget,
    );
  });

  testWidgets('a short password is rejected', (tester) async {
    await _pumpApp(tester, signedIn: false);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'alex@example.com');
    await tester.enterText(fields.last, 'short');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('At least 8 characters'), findsOneWidget);
  });

  testWidgets('valid credentials sign in and reveal the app', (tester) async {
    await _pumpApp(tester, signedIn: false);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'alex@example.com');
    await tester.enterText(fields.last, 'correct-horse');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Popular Games'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNotNull);
  });

  testWidgets('signup requires the terms checkbox', (tester) async {
    await _pumpApp(tester, signedIn: false);

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'alex');
    await tester.enterText(fields.at(1), 'alex@example.com');
    await tester.enterText(fields.at(2), 'correct-horse');
    await tester.enterText(fields.at(3), 'correct-horse');
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Please accept the terms to continue'), findsOneWidget);
    expect(find.text('Popular Games'), findsNothing);
  });

  testWidgets('mismatched passwords are caught', (tester) async {
    await _pumpApp(tester, signedIn: false);

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(2), 'correct-horse');
    await tester.enterText(fields.at(3), 'different-horse');
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text("Passwords don't match"), findsOneWidget);
  });

  testWidgets('sign out returns to the login screen', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Sign out sits at the bottom of a long list. Scope the scroll to the
    // profile tab's own Scrollable — the other tabs stay alive in the
    // IndexedStack, so an unscoped finder picks the wrong one.
    final signOut = find.text('Sign out');
    await tester.scrollUntilVisible(
      signOut,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ProfileScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(signOut);
    await tester.pumpAndSettle();
    await tester.tap(signOut);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
  });

  testWidgets('auth screens translate to Arabic', (tester) async {
    await _pumpApp(tester, languageCode: 'ar', signedIn: false);

    expect(find.text('مرحباً بعودتك'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsWidgets);

    final direction = Directionality.of(
      tester.element(find.text('مرحباً بعودتك')),
    );
    expect(direction, TextDirection.rtl);
  });

  // ------------------------------------------------------- server responses

  testWidgets('stores the token the server issued', (tester) async {
    await _pumpApp(tester, signedIn: false);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'alex@example.com');
    await tester.enterText(fields.last, 'correct-horse');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), 'server-token');
    // The public id from the server, not a locally invented one.
    expect(prefs.getString('auth_public_id'), '567185');
  });

  testWidgets('shows the server message when credentials are rejected', (
    tester,
  ) async {
    final rejecting = MockClient(
      (_) async => _json({
        'message': 'These credentials do not match our records.',
        'errors': {
          'email': ['These credentials do not match our records.'],
        },
      }, 422),
    );

    await _pumpApp(tester, signedIn: false, server: rejecting);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'alex@example.com');
    await tester.enterText(fields.last, 'wrong-horse');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(
      find.text('These credentials do not match our records.'),
      findsOneWidget,
    );
    // Still on the login screen.
    expect(find.text('Popular Games'), findsNothing);
  });

  testWidgets('shows a translated message when the server is unreachable', (
    tester,
  ) async {
    final dead = MockClient((_) async => throw const SocketFailure());

    await _pumpApp(tester, signedIn: false, server: dead);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'alex@example.com');
    await tester.enterText(fields.last, 'correct-horse');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(
      find.text("Can't reach the server. Check your connection and try again."),
      findsOneWidget,
    );
  });

  testWidgets('a network failure on sign out still signs the user out', (
    tester,
  ) async {
    final dead = MockClient((_) async => throw const SocketFailure());

    await _pumpApp(tester, server: dead);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    final signOut = find.text('Sign out');
    await tester.scrollUntilVisible(
      signOut,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ProfileScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(signOut);
    await tester.pumpAndSettle();
    await tester.tap(signOut);
    await tester.pumpAndSettle();

    // Refusing to sign out because the server is down would trap the user.
    expect(find.text('Welcome back'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
  });

  testWidgets('profile shows the account the server returned', (tester) async {
    await _pumpApp(tester, signedIn: false);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'alex@example.com');
    await tester.enterText(fields.last, 'correct-horse');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('ID: 567185'), findsOneWidget);
  });
}

/// Stands in for the socket errors `package:http` throws when nothing is
/// listening. The client treats any transport-level throw the same way.
class SocketFailure implements Exception {
  const SocketFailure();
}
