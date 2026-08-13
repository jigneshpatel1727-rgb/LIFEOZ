import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// Permission-controlled external knowledge gateway for Yansi.
///
/// The app does not silently scrape Google or send personal LifeOS history.
/// A future approved search/AI endpoint can be configured here. Only the
/// user's explicit question is sent, and external knowledge is kept separate
/// from Yansi's private memory.
class YansiWebKnowledge {
  final SharedPreferences prefs;
  const YansiWebKnowledge({required this.prefs});

  bool get enabled => prefs.getBool('permission_web_knowledge') == true;
  String get endpoint => prefs.getString('yansi_web_endpoint')?.trim() ?? '';

  Future<String?> ask(String question) async {
    if (!enabled || question.trim().isEmpty || endpoint.isEmpty) return null;
    final uri = Uri.tryParse(endpoint);
    if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) return null;
    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonEncode({'query': question.trim()})));
      final response = await request.close().timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final body = await response.transform(utf8.decoder).join();
      if (body.trim().isEmpty) return null;
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['answer'] is String) return decoded['answer'].toString();
        if (decoded is Map && decoded['text'] is String) return decoded['text'].toString();
      } catch (_) {}
      return body.trim();
    } catch (_) {
      return null;
    } finally {
      client?.close(force: true);
    }
  }
}
