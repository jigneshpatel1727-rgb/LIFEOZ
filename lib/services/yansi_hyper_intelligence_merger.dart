import 'yansi_hyper_intelligence_snapshot.dart';
import 'yansi_proactive_priority_engine.dart';

/// Merges predictive signals with the existing cross-core priority stream.
/// The merger is read-only and intentionally keeps execution out of the
/// intelligence layer.
class YansiHyperIntelligenceMerger {
  const YansiHyperIntelligenceMerger();

  List<YansiPrioritySignal> merge(
    YansiHyperIntelligenceSnapshot snapshot,
    List<YansiPrioritySignal> existing,
  ) {
    final merged = <YansiPrioritySignal>[...existing];
    for (final signal in snapshot.signals) {
      final message = signal['message']?.toString() ?? '';
      if (message.isEmpty) continue;
      final duplicate = merged.any((item) => item.message == message);
      if (duplicate) continue;
      merged.add(YansiPrioritySignal(
        title: signal['title']?.toString() ?? 'LifeOS insight',
        message: message,
        priority: (signal['priority'] as num?)?.toInt() ?? 0,
        needsConfirmation: signal['needsConfirmation'] == true,
      ));
    }
    merged.sort((a, b) => b.priority.compareTo(a.priority));
    return merged;
  }
}
