import 'lifeos_intelligence_bus.dart';

class LifeOSInsight {
  final String title;
  final String message;
  final LifeOSSignalType? source;
  final int priority;
  const LifeOSInsight({required this.title, required this.message, this.source, this.priority = 1});
}

/// Local-first proactive layer for explainable, low-noise LifeOS insights.
class LifeOSProactiveEngine {
  final LifeOSIntelligenceBus bus;
  const LifeOSProactiveEngine(this.bus);

  List<LifeOSInsight> evaluate() {
    final recent = bus.recent(limit: 40);
    if (recent.isEmpty) return const [];
    final insights = <LifeOSInsight>[];
    final openTasks = recent.where((s) => s.type == LifeOSSignalType.task && s.data['completed'] != true).length;
    if (openTasks >= 3) {
      insights.add(const LifeOSInsight(title: 'Focus signal', message: 'Several tasks are still open. Yansi can help prioritize what matters today.', source: LifeOSSignalType.task, priority: 3));
    }
    final expenses = recent.where((s) => s.type == LifeOSSignalType.expense);
    final total = expenses.fold<double>(0, (sum, s) => sum + ((s.data['amount'] as num?)?.toDouble() ?? 0));
    if (total > 0) {
      insights.add(LifeOSInsight(title: 'Money awareness', message: 'You have ${expenses.length} recent expense signals totaling ${total.toStringAsFixed(2)} in the available context.', source: LifeOSSignalType.expense, priority: 2));
    }
    final reminders = recent.where((s) => s.type == LifeOSSignalType.calendar).length;
    if (reminders > 0) {
      insights.add(const LifeOSInsight(title: 'Upcoming attention', message: 'Your calendar has recent activity. Yansi can connect it with tasks and other LifeOS context.', source: LifeOSSignalType.calendar, priority: 2));
    }
    insights.sort((a, b) => b.priority.compareTo(a.priority));
    return insights;
  }
}
