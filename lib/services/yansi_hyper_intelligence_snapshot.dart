import 'lifeos_data_store.dart';
import 'yansi_predictive_priority_adapter.dart';

/// Immutable snapshot for the ambient Yansi experience.
/// The snapshot contains insight only; it cannot execute actions.
class YansiHyperIntelligenceSnapshot {
  final DateTime createdAt;
  final List<Map<String, dynamic>> signals;
  final Map<String, dynamic>? highestPriority;

  const YansiHyperIntelligenceSnapshot({
    required this.createdAt,
    required this.signals,
    required this.highestPriority,
  });

  bool get hasSignal => highestPriority != null;

  String? get message => highestPriority?['message']?.toString();

  int get confidence => (highestPriority?['priority'] as num?)?.toInt() ?? 0;
}

class YansiHyperIntelligenceEngine {
  final LifeOSDataStore store;
  const YansiHyperIntelligenceEngine(this.store);

  YansiHyperIntelligenceSnapshot capture() {
    final signals = YansiPredictivePriorityAdapter(store).signals();
    final ranked = [...signals]..sort((a, b) => b.priority.compareTo(a.priority));
    final maps = ranked.map((signal) => <String, dynamic>{
      'title': signal.title,
      'message': signal.message,
      'priority': signal.priority,
      'needsConfirmation': signal.needsConfirmation,
    }).toList();

    return YansiHyperIntelligenceSnapshot(
      createdAt: DateTime.now(),
      signals: maps,
      highestPriority: maps.isEmpty ? null : maps.first,
    );
  }
}
