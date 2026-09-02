import 'package:flutter/material.dart';

import '../../core/api/api_error_messages.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import 'auth_controller.dart';
import 'validators.dart';
import 'widgets/auth_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _acceptedTerms = false;
  bool _termsTouched = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _termsTouched = true;
      _error = null;
    });
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk || !_acceptedTerms) return;

    final l10n = AppLocalizations.of(context);

    try {
      await AuthScope.of(context).signUp(
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (error) {
      if (!mounted) return;
      // "The email has already been taken." arrives here, which is the most
      // likely reason a signup is rejected by the server rather than the form.
      setState(() => _error = error.localized(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final v = Validators(l10n);
    final auth = AuthScope.of(context);
    final showTermsError = _termsTouched && !_acceptedTerms;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.authSignUpTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.authSignUpSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 30),
                  AuthErrorBanner(message: _error),
                  AuthField(
                    label: l10n.authUsername,
                    controller: _username,
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newUsername],
                    validator: v.username,
                  ),
                  const SizedBox(height: 16),
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
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: v.password,
                  ),
                  const SizedBox(height: 16),
                  AuthField(
                    label: l10n.authConfirmPassword,
                    controller: _confirm,
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) =>
                        v.confirmPassword(value, _password.text),
                    onSubmitted: _submit,
                  ),
                  const SizedBox(height: 20),
                  _TermsCheckbox(
                    value: _acceptedTerms,
                    label: l10n.authTermsAgree,
                    error: showTermsError ? l10n.valTermsRequired : null,
                    onChanged: (value) => setState(() {
                      _acceptedTerms = value;
                      _termsTouched = true;
                    }),
                  ),
                  const SizedBox(height: 22),
                  AuthButton(
                    label: l10n.authSignUp,
                    busy: auth.isBusy,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 24),
                  AuthFooterLink(
                    question: l10n.authHaveAccount,
                    action: l10n.authSignInLink,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
    this.error,
  });

  final bool value;
  final String label;
  final String? error;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsetsDirectional.only(top: 1),
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value
                        ? AppColors.primary
                        : (error != null ? AppColors.danger : AppColors.line),
                    width: 1.5,
                  ),
                ),
                child: value
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: kFontFamily,
                    fontFamilyFallback: kFontFallback,
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 30),
            child: Text(
              error!,
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontFamilyFallback: kFontFallback,
                fontSize: 11.5,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
