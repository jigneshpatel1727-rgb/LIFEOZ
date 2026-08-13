import 'yansi_cross_core_insight_engine.dart';

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
  const YansiProactivePriorityEngine(this.insights);

  List<YansiPrioritySignal> prioritize() {
    final output = <YansiPrioritySignal>[];
    for (final insight in insights.evaluate()) {
      output.add(YansiPrioritySignal(
        title: insight.title,
        message: insight.message,
        priority: insight.confidence,
      ));
    }
    output.sort((a, b) => b.priority.compareTo(a.priority));
    return output;
  }

  YansiPrioritySignal? top() {
    final all = prioritize();
    return all.isEmpty ? null : all.first;
  }
}
