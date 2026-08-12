import 'dart:convert';

import 'lifeos_data_store.dart';

/// Structured, user-controlled memory for Yansi.
///
/// Memory separates explicit facts from conversations, observations,
/// predictions and suggestions. Yansi can therefore learn patterns without
/// presenting an inference as something the user explicitly said.
class YansiMemoryService {
  final LifeOSDataStore store;

  const YansiMemoryService(this.store);

  Future<void> remember({
    required String text,
    required String kind,
    String source = 'conversation',
    Map<String, dynamic> context = const {},
  }) async {
    await _append('yansi_memory', {
      'text': text,
      'kind': kind,
      'source': source,
      'createdAt': DateTime.now().toIso8601String(),
      'context': context,
    });
  }

  Future<void> rememberFact({
    required String key,
    required dynamic value,
    String source = 'user',
  }) async {
    final rows = byKind('fact');
    rows.removeWhere((item) => item['key'] == key);
    rows.add(_record({
      'kind': 'fact',
      'key': key,
      'value': value,
      'source': source,
    }));
    await store.replace('yansi_memory', [
      ...all().where((item) => item['kind'] != 'fact'),
      ...rows,
    ]);
  }

  dynamic fact(String key) {
    for (final item in byKind('fact').reversed) {
      if (item['key'] == key) return item['value'];
    }
    return null;
  }

  Future<void> observe({
    required String pattern,
    required double confidence,
    String? evidence,
  }) async {
    await remember(
      text: pattern,
      kind: 'observation',
      source: 'yansi_analysis',
      context: {
        'confidence': confidence.clamp(0, 1),
        if (evidence != null) 'evidence': evidence,
      },
    );
  }

  Future<void> predict({
    required String type,
    required dynamic value,
    String basis = 'history',
  }) async {
    await remember(
      text: type,
      kind: 'prediction',
      source: 'yansi_prediction',
      context: {'value': value, 'basis': basis},
    );
  }

  Future<void> suggest({
    required String text,
    String reason = 'lifeos_pattern',
  }) async {
    await remember(
      text: text,
      kind: 'suggestion',
      source: 'yansi_advice',
      context: {'reason': reason},
    );
  }

  List<Map<String, dynamic>> all() => store.read('yansi_memory');

  List<Map<String, dynamic>> byKind(String kind) =>
      all().where((item) => item['kind'] == kind).toList();

  List<Map<String, dynamic>> recent({int limit = 50}) {
    final rows = all();
    rows.sort((a, b) => (b['createdAt'] ?? '').toString().compareTo((a['createdAt'] ?? '').toString()));
    return rows.take(limit).toList();
  }

  Future<void> recordConversation(String role, String text) =>
      remember(text: text, kind: 'conversation', source: role);

  Future<void> recordVoiceReference({
    required String transcript,
    required String path,
    required bool enabled,
  }) async {
    if (!enabled) return;
    await remember(
      text: transcript,
      kind: 'voice_reference',
      source: 'voice',
      context: {'path': path},
    );
  }

  Future<void> clearAll() => store.clear('yansi_memory');

  String exportJson() => jsonEncode(all());

  Future<void> importJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! List) return;
    final records = decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    await store.replace('yansi_memory', records);
  }

  Map<String, int> counts() {
    final result = <String, int>{};
    for (final item in all()) {
      final kind = item['kind']?.toString() ?? 'unknown';
      result[kind] = (result[kind] ?? 0) + 1;
    }
    return result;
  }

  Map<String, dynamic> _record(Map<String, dynamic> data) => {
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'createdAt': DateTime.now().toIso8601String(),
        ...data,
      };

  Future<void> _append(String collection, Map<String, dynamic> data) =>
      store.append(collection, _record(data));
}
