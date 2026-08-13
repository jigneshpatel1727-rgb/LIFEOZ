import 'lifeos_data_store.dart';
import 'yansi_predictive_intelligence.dart';
import 'yansi_proactive_priority_engine.dart';

/// Adapts predictive cross-core intelligence into Yansi's existing priority
/// model. It is read-only and never executes an action.
class YansiPredictivePriorityAdapter {
  final LifeOSDataStore store;
  const YansiPredictivePriorityAdapter(this.store);

  List<YansiPrioritySignal> signals() {
    final insight = YansiPredictiveIntelligence(store).ambientInsight();
    final raw = insight['candidates'];
    if (raw is! List) return const <YansiPrioritySignal>[];

    return raw.whereType<Map<String, dynamic>>().map((item) {
      final priority = ((item['priority'] as num?) ?? 0).clamp(0.0, 1.0);
      return YansiPrioritySignal(
        title: _title(item['type']?.toString()),
        message: item['message']?.toString() ?? '',
        priority: (priority * 100).round(),
      );
    }).where((signal) => signal.message.isNotEmpty).toList();
  }

  String _title(String? type) {
    switch (type) {
      case 'task_load':
        return 'Task pressure';
      case 'goal_alignment':
        return 'Goal alignment';
      case 'calendar_awareness':
        return 'Calendar awareness';
      case 'household_awareness':
        return 'Household insight';
      case 'spending_awareness':
        return 'Spending insight';
      default:
        return 'LifeOS insight';
    }
  }
}
