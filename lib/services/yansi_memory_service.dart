import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'lifeos_data_store.dart';

/// Structured, user-controlled memory for Yansi.
///
/// Memory distinguishes recorded facts, inferred patterns, predictions and
/// suggestions. This is important for a trustworthy Jarvis-like experience:
/// Yansi must not present an inference as if the user explicitly told it.
class YansiMemoryService {
  final LifeOSDataStore store;

  const YansiMemoryService(this.store);

  Future<void> remember({
    required String text,
    required String kind,
    String source = 'conversation',
    Map<String, dynamic> context = const {},
  }) async {
    await store.append('yansi_memory', {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'text': text,
      'kind': kind,
      'source': source,
      'createdAt': DateTime.now().toIso8601String(),
      'context': context,
    });
  }

  List<Map<String, dynamic>> all() => store.read('yansi_memory');

  List<Map<String, dynamic>> byKind(String kind) =>
      all().where((item) => item['kind'] == kind).toList();

  Future<void> clearAll() => store.clear('yansi_memory');

  /// Exports structured memory as JSON for backup/debug tooling.
  String exportJson() => jsonEncode(all());

  /// Keeps the public API ready for future remote sync without coupling
  /// Yansi to a specific cloud provider.
  Future<void> importJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! List) return;

    final records = decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    await store.replace('yansi_memory', records);
  }
}
