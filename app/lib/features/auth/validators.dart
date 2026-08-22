import '../../l10n/gen/app_localizations.dart';

/// Form validation, kept out of the widgets so the rules are in one place and
/// the messages stay translated.
///
/// These mirror what the server will enforce; they are a courtesy to the user,
/// not a security boundary. The server validates again regardless — a client
/// check is trivially bypassed.
class Validators {
  const Validators(this.l10n);

  final AppLocalizations l10n;

  /// Deliberately loose. Strict email regexes reject valid addresses far more
  /// often than they catch typos; the confirmation email is the real check.
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.valUsernameRequired;
    if (v.length < 3) return l10n.valUsernameShort;
    return null;
  }

  String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.valEmailRequired;
    if (!_email.hasMatch(v)) return l10n.valEmailInvalid;
    return null;
  }

  String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return l10n.valPasswordRequired;
    if (v.length < 8) return l10n.valPasswordShort;
    return null;
  }

  /// Only checks the two entries match — the length rule already ran on the
  /// first field, and repeating it here just double-reports one mistake.
  String? confirmPassword(String? value, String original) {
    if ((value ?? '') != original) return l10n.valPasswordMismatch;
    return null;
  }
}
