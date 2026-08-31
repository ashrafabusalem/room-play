import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

/// Thin JSON wrapper over `package:http`.
///
/// Its job is to turn every possible outcome — success, validation failure,
/// expired token, dead network, HTML error page — into either a decoded map or
/// an [ApiException]. Callers never see a raw status code or an unparsed body.
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
    : _http = httpClient ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _http;
  final String _baseUrl;

  /// Bearer token for authenticated calls. Set on sign-in, cleared on sign-out.
  String? authToken;

  /// Sent as `Accept-Language` so the server can answer in the user's language.
  ///
  /// Laravel returns English until its own translations are added; sending the
  /// header now means that switch needs no app change.
  String? languageCode;

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic> body = const {},
  }) => _send(
    () => _http.post(_uri(path), headers: _headers(), body: jsonEncode(body)),
  );

  Future<Map<String, dynamic>> get(String path) =>
      _send(() => _http.get(_uri(path), headers: _headers()));

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic> body = const {},
  }) => _send(
    () => _http.put(_uri(path), headers: _headers(), body: jsonEncode(body)),
  );

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic> body = const {},
  }) => _send(
    () => _http.patch(_uri(path), headers: _headers(), body: jsonEncode(body)),
  );

  Future<Map<String, dynamic>> delete(String path) =>
      _send(() => _http.delete(_uri(path), headers: _headers()));

  Uri _uri(String path) => Uri.parse('$_baseUrl/api$path');

  String? get _bearer => authToken == null ? null : 'Bearer $authToken';

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    // Without this Laravel answers validation failures with an HTML redirect
    // instead of JSON, and the app sees an unparseable body.
    'Accept': 'application/json',
    'Authorization': ?_bearer,
    'Accept-Language': ?languageCode,
  };

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    final http.Response response;
    try {
      response = await request().timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw const ApiException(kind: ApiErrorKind.timeout);
    } catch (_) {
      // SocketException, HandshakeException, ClientException — from the user's
      // point of view these are all "it didn't get there".
      throw const ApiException(kind: ApiErrorKind.network);
    }

    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic>? json;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) json = decoded;
      } on FormatException {
        // Left null — handled below as a server error.
      }
    }

    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      if (json == null) {
        throw ApiException(kind: ApiErrorKind.server, statusCode: status);
      }
      return json;
    }

    throw ApiException(
      kind: switch (status) {
        401 || 403 => ApiErrorKind.unauthorized,
        422 => ApiErrorKind.validation,
        429 => ApiErrorKind.tooManyRequests,
        _ => ApiErrorKind.server,
      },
      statusCode: status,
      serverMessage: json?['message'] as String?,
      fieldErrors: _fieldErrors(json?['errors']),
    );
  }

  /// Laravel sends `{"errors": {"email": ["...", "..."]}}`. Anything else in
  /// that slot is ignored rather than trusted.
  static Map<String, List<String>> _fieldErrors(Object? raw) {
    if (raw is! Map) return const {};

    final result = <String, List<String>>{};
    raw.forEach((key, value) {
      if (key is! String) return;
      if (value is List) {
        result[key] = value.whereType<String>().toList();
      } else if (value is String) {
        result[key] = [value];
      }
    });
    return result;
  }

  void close() => _http.close();
}
