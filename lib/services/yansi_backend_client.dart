import 'dart:convert';
import 'dart:io';

/// Thin client for the secure Yansi backend.
/// No provider API key is stored in the LifeOS APK.
class YansiBackendClient {
  final Uri baseUri;
  final Future<String?> Function()? accessTokenProvider;

  const YansiBackendClient({
    required this.baseUri,
    this.accessTokenProvider,
  });

  Future<YansiBackendResult> ask({
    required String message,
    Map<String, dynamic>? lifeosContext,
    bool allowWeb = false,
  }) async {
    final token = await accessTokenProvider?.call();
    final client = HttpClient();
    try {
      final request = await client.postUrl(baseUri.resolve('/v1/yansi/respond'));
      request.headers.contentType = ContentType.json;
      request.headers.set('Accept', 'application/json');
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      request.write(jsonEncode({
        'message': message,
        'context': lifeosContext ?? const <String, dynamic>{},
        'permissions': {'webAccess': allowWeb},
      }));

      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return YansiBackendResult.failure(
          'Yansi backend returned HTTP ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        return YansiBackendResult.failure('Invalid Yansi backend response.');
      }
      return YansiBackendResult.success(
        decoded['answer']?.toString() ?? '',
        requestId: decoded['requestId']?.toString(),
      );
    } on SocketException {
      return const YansiBackendResult.failure('Yansi backend is unavailable.');
    } on FormatException {
      return const YansiBackendResult.failure('Yansi returned invalid data.');
    } finally {
      client.close(force: true);
    }
  }
}

class YansiBackendResult {
  final bool ok;
  final String answer;
  final String? requestId;
  final String? error;

  const YansiBackendResult._({
    required this.ok,
    required this.answer,
    this.requestId,
    this.error,
  });

  const YansiBackendResult.success(String answer, {String? requestId})
      : this._(ok: true, answer: answer, requestId: requestId);

  const YansiBackendResult.failure(String error)
      : this._(ok: false, answer: '', error: error);
}
