import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores useful Yansi insights separately from raw conversation history.
/// This gives later intelligence layers a compact, durable signal source.
class YansiInsightMemory {
  static const _key = 'yansi_insight_memory_v1';
  final SharedPreferences prefs;

  const YansiInsightMemory(this.prefs);

  List<Map<String, dynamic>> load() {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> remember({
    required String title,
    required String message,
    required String core,
    required int priority,
    String source = 'proactive',
  }) async {
    final entry = <String, dynamic>{
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'createdAt': DateTime.now().toIso8601String(),
      'title': title.trim(),
      'message': message.trim(),
      'core': core,
      'priority': priority.clamp(0, 100),
      'source': source,
    };

    final entries = <Map<String, dynamic>>[entry, ...load()];
    final unique = <String, Map<String, dynamic>>{};
    for (final item in entries) {
      final signature = '${item['core']}|${item['title']}|${item['message']}';
      unique.putIfAbsent(signature, () => item);
    }

    await prefs.setString(
      _key,
      jsonEncode(unique.values.take(100).toList()),
    );
  }

  Future<void> rememberSuggestions(
    Iterable<Map<String, dynamic>> suggestions,
  ) async {
    for (final suggestion in suggestions) {
      final title = '${suggestion['title'] ?? ''}'.trim();
      final message = '${suggestion['message'] ?? ''}'.trim();
      if (title.isEmpty || message.isEmpty) continue;
      await remember(
        title: title,
        message: message,
        core: '${suggestion['core'] ?? 'yansi'}',
        priority: int.tryParse('${suggestion['priority'] ?? 0}') ?? 0,
        source: '${suggestion['source'] ?? 'proactive'}',
      );
    }
  }
}
