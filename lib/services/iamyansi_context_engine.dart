import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local context engine for iAmYansi.
///
/// It stores explicit user-approved context signals and produces a compact
/// situation summary for future response/action layers. It does not claim to
/// read a person's mind or infer sensitive traits.
class IamyansiContextEngine {
  static const _eventsKey = 'iamyansi_context_events_v1';
  static const _summaryKey = 'iamyansi_context_summary_v1';

  final SharedPreferences prefs;

  const IamyansiContextEngine({required this.prefs});

  Future<void> addSignal({
    required String type,
    required String value,
    DateTime? at,
  }) async {
    final cleanType = type.trim();
    final cleanValue = value.trim();
    if (cleanType.isEmpty || cleanValue.isEmpty) return;

    final raw = prefs.getStringList(_eventsKey) ?? <String>[];
    raw.add(jsonEncode({
      'type': cleanType,
      'value': cleanValue,
      'at': (at ?? DateTime.now()).toIso8601String(),
    }));
    if (raw.length > 200) raw.removeRange(0, raw.length - 200);
    await prefs.setStringList(_eventsKey, raw);
  }

  List<IamyansiContextSignal> recent({int limit = 20}) {
    final raw = prefs.getStringList(_eventsKey) ?? <String>[];
    final values = <IamyansiContextSignal>[];
    for (final item in raw.reversed) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(item) as Map);
        values.add(IamyansiContextSignal(
          type: '${map['type'] ?? ''}',
          value: '${map['value'] ?? ''}',
          at: DateTime.tryParse('${map['at'] ?? ''}') ?? DateTime.now(),
        ));
        if (values.length >= limit) break;
      } catch (_) {
        // Ignore malformed legacy entries.
      }
    }
    return values;
  }

  Future<String> buildSituationSummary() async {
    final signals = recent(limit: 12);
    if (signals.isEmpty) return 'No recent context signals.';

    final grouped = <String, int>{};
    for (final signal in signals) {
      grouped[signal.type] = (grouped[signal.type] ?? 0) + 1;
    }
    final summary = grouped.entries.map((e) => '${e.key}:${e.value}').join(', ');
    await prefs.setString(_summaryKey, summary);
    return summary;
  }
}

class IamyansiContextSignal {
  final String type;
  final String value;
  final DateTime at;

  const IamyansiContextSignal({
    required this.type,
    required this.value,
    required this.at,
  });
}
