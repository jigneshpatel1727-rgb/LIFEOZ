import 'lifeos_data_store.dart';
import 'yansi_cross_core_insight_engine.dart';
import 'yansi_hyper_intelligence_merger.dart';
import 'yansi_hyper_intelligence_snapshot.dart';

class YansiPrioritySignal {
  final String title;
  final String message;
  final int priority;
  final bool needsConfirmation;
  const YansiPrioritySignal({required this.title, required this.message, required this.priority, this.needsConfirmation = false});
}

/// Turns LifeOS context into a small set of actionable priorities for the
/// ambient Yansi layer. It does not execute sensitive actions by itself.
class YansiProactivePriorityEngine {
  final YansiCrossCoreInsightEngine insights;
  final LifeOSDataStore? store;
  const YansiProactivePriorityEngine(this.insights, {this.store});

  List<YansiPrioritySignal> prioritize() {
    final output = <YansiPrioritySignal>[];
    for (final insight in insights.evaluate()) {
      output.add(YansiPrioritySignal(
        title: insight.title,
        message: insight.message,
        priority: insight.confidence,
      ));
    }

    if (store != null) {
      final snapshot = YansiHyperIntelligenceEngine(store!).capture();
      return const YansiHyperIntelligenceMerger().merge(snapshot, output);
    }

    output.sort((a, b) => b.priority.compareTo(a.priority));
    return output;
  }

  YansiPrioritySignal? top() {
    final all = prioritize();
    return all.isEmpty ? null : all.first;
  }
}
