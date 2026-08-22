import 'package:flutter/foundation.dart';

/// Where the Laravel API lives.
///
/// Override at build time for a real device or a deployed server:
///
///     flutter run --dart-define=API_BASE_URL=http://192.168.0.104:8000
///
/// The default is the loopback address that reaches the *host machine* from
/// wherever the app is running — which is not the same address on every
/// platform, and getting it wrong looks exactly like the server being down.
class ApiConfig {
  ApiConfig._();

  static const _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;

    // The Android emulator runs behind its own NAT: 127.0.0.1 is the emulator
    // itself, and 10.0.2.2 is the machine hosting it.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    // iOS simulator, desktop and web all share the host's loopback.
    return 'http://127.0.0.1:8000';
  }

  /// Nothing in the UI should hang on a dead server for longer than this.
  static const timeout = Duration(seconds: 15);
}
