import 'lifeos_intelligence_bus.dart';

/// Context layer that turns the shared LifeOS signal stream into a compact
/// snapshot for Yansi. It is intentionally deterministic and local-first.
class LifeOSContextEngine {
  final LifeOSIntelligenceBus bus;
  const LifeOSContextEngine(this.bus);

  Map<String, dynamic> snapshot({int recentLimit = 12}) {
    final recent = bus.recent(limit: recentLimit);
    final byType = <String, int>{};
    for (final signal in recent) {
      final key = signal.type.name;
      byType[key] = (byType[key] ?? 0) + 1;
    }
    return {
      'recentCount': recent.length,
      'signalsByType': byType,
      'recent': recent.map((s) => {
        'type': s.type.name,
        'text': s.text,
        'timestamp': s.timestamp.toIso8601String(),
        'data': s.data,
      }).toList(growable: false),
    };
  }

  String conciseSummary({int recentLimit = 8}) {
    final recent = bus.recent(limit: recentLimit);
    if (recent.isEmpty) return 'No recent LifeOS activity.';
    return recent.map((s) => '${s.type.name}: ${s.text}').join(' | ');
  }
}
