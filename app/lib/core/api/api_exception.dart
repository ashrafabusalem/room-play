/// Anything that stopped a request from succeeding.
///
/// Deliberately one type with a [kind], rather than a hierarchy: every screen
/// handles these the same way — show [message] — and only the localisation of
/// the message differs between a network failure and a rejected password.
class ApiException implements Exception {
  const ApiException({
    required this.kind,
    this.statusCode,
    this.serverMessage,
    this.fieldErrors = const {},
  });

  final ApiErrorKind kind;
  final int? statusCode;

  /// The message Laravel sent, if any. Present for validation and auth
  /// failures; absent when the request never arrived.
  final String? serverMessage;

  /// Field name to the messages for it, straight from Laravel's `errors` bag.
  /// e.g. `{'email': ['The email has already been taken.']}`
  final Map<String, List<String>> fieldErrors;

  /// First error for [field], if the server flagged it.
  String? errorFor(String field) => fieldErrors[field]?.firstOrNull;

  @override
  String toString() => 'ApiException($kind, $statusCode, $serverMessage)';
}

enum ApiErrorKind {
  /// The request never reached the server — no connection, wrong address,
  /// server not running.
  network,

  /// It reached the server and took too long to answer.
  timeout,

  /// 422. The server rejected the input; [ApiException.fieldErrors] says why.
  validation,

  /// 401 or 403. The token is missing, expired, or revoked.
  unauthorized,

  /// 429. Rate limited.
  tooManyRequests,

  /// 5xx, or a response that wasn't the JSON we expected.
  server,
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
