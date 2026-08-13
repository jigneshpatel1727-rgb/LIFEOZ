import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Turns Yansi's permanent interaction ledger into compact, explainable
/// personal context. It does not delete or rewrite history.
class YansiPersonalContextEngine {
  static const _ledgerKey = 'yansi_personal_memory_ledger';
  final SharedPreferences prefs;

  const YansiPersonalContextEngine({required this.prefs});

  List<Map<String, dynamic>> allMemories() {
    return (prefs.getStringList(_ledgerKey) ?? const <String>[]).map((raw) {
      try {
        final value = jsonDecode(raw);
        return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((entry) => entry.isNotEmpty).toList(growable: false);
  }

  Map<String, dynamic> buildContext({String? topic}) {
    final memories = allMemories();
    final normalized = topic?.trim().toLowerCase();
    final relevant = normalized == null || normalized.isEmpty
        ? memories
        : memories.where((memory) {
            final text = jsonEncode(memory).toLowerCase();
            return text.contains(normalized);
          }).toList(growable: false);

    final types = <String, int>{};
    for (final memory in relevant) {
      final type = (memory['type'] ?? 'unknown').toString();
      types[type] = (types[type] ?? 0) + 1;
    }

    return {
      'memoryCount': memories.length,
      'relevantCount': relevant.length,
      'topic': topic,
      'memoryTypes': types,
      'recentRelevant': relevant.length <= 20
          ? relevant
          : relevant.sublist(relevant.length - 20),
    };
  }

  String explainContext({String? topic}) {
    final context = buildContext(topic: topic);
    return 'Yansi has ${context['memoryCount']} permanent personal memory entries and '
        '${context['relevantCount']} relevant entries for this context.';
  }
}
