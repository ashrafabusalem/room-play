import '../../l10n/gen/app_localizations.dart';
import 'api_exception.dart';

extension ApiExceptionMessage on ApiException {
  /// What to actually put in front of the user.
  ///
  /// Failures the app caused or understands get a translated message. Failures
  /// the *server* decided — a rejected password, a taken email — use the
  /// server's own wording, because it is the only place that knows the reason.
  ///
  /// That does mean those arrive in English until Laravel carries Arabic
  /// translations; the app already sends `Accept-Language`, so that is a
  /// server-side change with nothing to do here.
  String localized(AppLocalizations l10n) => switch (kind) {
    ApiErrorKind.network => l10n.errorNetwork,
    ApiErrorKind.timeout => l10n.errorTimeout,
    ApiErrorKind.tooManyRequests => serverMessage ?? l10n.errorTooManyRequests,
    ApiErrorKind.validation ||
    ApiErrorKind.unauthorized => serverMessage ?? l10n.errorUnexpected,
    ApiErrorKind.server => l10n.errorUnexpected,
  };
}
