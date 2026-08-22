import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';

/// Who is signed in, and how that survives a restart.
///
/// Talks to the Laravel API: `/api/register`, `/api/login`, `/api/logout`,
/// `/api/forgot-password`. Every method throws [ApiException] on failure — the
/// screens catch it and decide what to show.
class AuthController extends ChangeNotifier {
  AuthController({ApiClient? api}) : _api = api ?? ApiClient();

  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';
  static const _nameKey = 'auth_name';
  static const _publicIdKey = 'auth_public_id';
  static const _levelKey = 'auth_level';

  final ApiClient _api;

  String? _token;
  String? _email;
  String? _name;
  String? _publicId;
  int _level = 1;
  bool _busy = false;
  bool _restored = false;

  bool get isSignedIn => _token != null;
  bool get isBusy => _busy;

  /// False until the saved session has been read, so the gate can hold a blank
  /// screen instead of flashing the login form at an already-signed-in user.
  bool get isRestored => _restored;

  String? get email => _email;
  String? get name => _name;
  String? get publicId => _publicId;
  int get level => _level;

  /// Forwarded to the API client so the server can answer in the user's
  /// language once its own translations exist.
  set languageCode(String? code) => _api.languageCode = code;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _email = prefs.getString(_emailKey);
    _name = prefs.getString(_nameKey);
    _publicId = prefs.getString(_publicIdKey);
    _level = prefs.getInt(_levelKey) ?? 1;
    _api.authToken = _token;
    _restored = true;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) =>
      _authenticate('/login', {'email': email, 'password': password});

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) => _authenticate('/register', {
    'name': username,
    'email': email,
    'password': password,
  });

  Future<void> sendPasswordReset(String email) async {
    await _run(() => _api.post('/forgot-password', body: {'email': email}));
  }

  /// Revokes the token server-side, then clears it locally.
  ///
  /// The local clear happens even if the network call fails: the user asked to
  /// be signed out, and refusing because the server is unreachable would trap
  /// them in the app. The stale token expires or gets revoked later.
  Future<void> signOut() async {
    try {
      await _run(() => _api.post('/logout'));
    } on ApiException {
      // Intentionally swallowed — see above.
    }
    await _clearSession();
  }

  Future<void> _authenticate(String path, Map<String, dynamic> body) async {
    final json = await _run(
      () => _api.post(path, body: {...body, 'device_name': _deviceName}),
    );

    final token = json['token'] as String?;
    final user = json['user'];
    if (token == null || user is! Map<String, dynamic>) {
      throw const ApiException(kind: ApiErrorKind.server);
    }

    await _persist(token: token, user: user);
  }

  /// Wraps a call with the busy flag so the button spinner is always in sync,
  /// including when the call throws.
  Future<Map<String, dynamic>> _run(
    Future<Map<String, dynamic>> Function() call,
  ) async {
    _busy = true;
    notifyListeners();
    try {
      return await call();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _persist({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, (user['email'] ?? '') as String);
    await prefs.setString(_nameKey, (user['name'] ?? '') as String);
    await prefs.setString(_publicIdKey, (user['id'] ?? '') as String);
    await prefs.setInt(_levelKey, (user['level'] as num?)?.toInt() ?? 1);

    _token = token;
    _email = user['email'] as String?;
    _name = user['name'] as String?;
    _publicId = user['id'] as String?;
    _level = (user['level'] as num?)?.toInt() ?? 1;
    _api.authToken = token;
    notifyListeners();
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_publicIdKey);
    await prefs.remove(_levelKey);

    _token = null;
    _email = null;
    _name = null;
    _publicId = null;
    _level = 1;
    _api.authToken = null;
    notifyListeners();
  }

  /// Labels the Sanctum token so a user can recognise and revoke this device
  /// later. Purely cosmetic — never used for authorisation.
  static String get _deviceName {
    final platform = defaultTargetPlatform.name;
    return '${platform[0].toUpperCase()}${platform.substring(1)} device';
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope above this widget');
    return scope!.notifier!;
  }
}
