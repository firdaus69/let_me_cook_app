import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Where the Let Me Cook API runs.
///
/// Set it with `--dart-define=API_URL=http://192.168.0.8:3000` (needed on a real
/// phone, which can't see your computer's `localhost`). Without it, the Android
/// emulator uses 10.0.2.2 (its alias for the host machine) and everything else
/// uses localhost.
String defaultApiUrl() {
  const fromEnv = String.fromEnvironment('API_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  /// `null` when the server couldn't be reached at all.
  final int? statusCode;
  final String message;

  @override
  String toString() => message;
}

/// Thin JSON-over-HTTP client. Errors come back as [ApiException] with a
/// message that is safe to show to the user.
class ApiClient {
  ApiClient(this._http, {String? baseUrl})
    : baseUrl = baseUrl ?? defaultApiUrl();

  final http.Client _http;
  final String baseUrl;

  static const _timeout = Duration(seconds: 10);

  Future<dynamic> get(String path, {String? token}) =>
      _send('GET', path, token: token);

  Future<dynamic> post(String path, {Object? body, String? token}) =>
      _send('POST', path, body: body, token: token);

  Future<dynamic> put(String path, {String? token}) =>
      _send('PUT', path, token: token);

  Future<dynamic> delete(String path, {String? token}) =>
      _send('DELETE', path, token: token);

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    String? token,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    if (token != null) request.headers['authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['content-type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _http.send(request).timeout(_timeout),
      );
    } on Exception {
      throw const ApiException(
        null,
        "Can't reach the server. Check your connection and try again.",
      );
    }

    Object? data;
    try {
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException {
      data = null;
    }

    if (response.statusCode >= 400) {
      final error = data is Map ? data['error'] : null;
      throw ApiException(
        response.statusCode,
        error is String && error != 'Bad request'
            ? error
            : 'Something went wrong (${response.statusCode}). Please try again.',
      );
    }
    return data;
  }
}

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(httpClientProvider)),
);
