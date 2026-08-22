import 'package:flutter/material.dart';

import '../../core/api/api_error_messages.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import 'auth_controller.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import 'validators.dart';
import 'widgets/auth_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _error = null);
    final l10n = AppLocalizations.of(context);

    try {
      await AuthScope.of(context)
          .signIn(email: _email.text.trim(), password: _password.text);
      // No navigation here — the gate swaps to the shell once the token lands.
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.localized(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final v = Validators(l10n);
    final auth = AuthScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(),
                    const SizedBox(height: 28),
                    Text(
                      l10n.authWelcomeTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.authWelcomeSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 32),
                    AuthErrorBanner(message: _error),
                    AuthField(
                      label: l10n.authEmail,
                      controller: _email,
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: v.email,
                    ),
                    const SizedBox(height: 16),
                    AuthField(
                      label: l10n.authPassword,
                      controller: _password,
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: v.password,
                      onSubmitted: _submit,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            l10n.authForgotPassword,
                            style: const TextStyle(
                              fontFamily: kFontFamily,
                              fontFamilyFallback: kFontFallback,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    AuthButton(
                      label: l10n.authSignIn,
                      busy: auth.isBusy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 28),
                    AuthFooterLink(
                      question: l10n.authNoAccount,
                      action: l10n.authSignUpLink,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SignUpScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The logo badge, sized so the lockup inside it is still legible — this is the
/// one screen where the full mark earns the space.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/brand/logo.png',
        width: 96,
        height: 96,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
