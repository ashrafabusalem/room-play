import 'package:flutter/material.dart';

import '../../core/api/api_error_messages.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/gen/app_localizations.dart';
import 'auth_controller.dart';
import 'validators.dart';
import 'widgets/auth_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _error = null);
    final l10n = AppLocalizations.of(context);

    try {
      await AuthScope.of(context).sendPasswordReset(_email.text.trim());
      if (!mounted) return;
      // Success regardless of whether the address has an account — the server
      // deliberately does not say, so neither does this screen.
      setState(() => _sent = true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.localized(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = AuthScope.of(context);

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: _sent
              ? _SentState(email: _email.text.trim())
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.authResetTitle,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.authResetBody,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      AuthErrorBanner(message: _error),
                      AuthField(
                        label: l10n.authEmail,
                        controller: _email,
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: Validators(l10n).email,
                        onSubmitted: _submit,
                      ),
                      const SizedBox(height: 24),
                      AuthButton(
                        label: l10n.authResetSend,
                        busy: auth.isBusy,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SentState extends StatelessWidget {
  const _SentState({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 32,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          l10n.authResetSentTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.authResetSentBody(email),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        AuthButton(
          label: l10n.authResetBackToSignIn,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
