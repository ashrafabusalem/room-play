import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shell/main_shell.dart';
import 'auth_controller.dart';
import 'login_screen.dart';

/// Decides between the login screen and the app, and holds a neutral screen
/// while the saved session is being read.
///
/// The hold matters: without it a returning user sees the login form flash for
/// a frame before being replaced, which reads as a bug.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);

    if (!auth.isRestored) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: SizedBox.expand(),
      );
    }

    return auth.isSignedIn ? const MainShell() : const LoginScreen();
  }
}
