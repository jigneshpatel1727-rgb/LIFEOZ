import 'lifeos_intelligence_bus.dart';
import 'yansi_cross_core_memory.dart';

class YansiCrossCoreInsight {
  final String title;
  final String message;
  final List<LifeOSSignalType> sources;
  final int confidence;
  const YansiCrossCoreInsight({required this.title, required this.message, required this.sources, required this.confidence});
}

/// Finds simple, explainable relationships across LifeOS cores.
class YansiCrossCoreInsightEngine {
  final YansiCrossCoreMemory memory;
  const YansiCrossCoreInsightEngine(this.memory);

  List<YansiCrossCoreInsight> evaluate() {
    final groups = memory.grouped(limitPerCore: 20);
    final results = <YansiCrossCoreInsight>[];
    final expense = groups['expense'] ?? const <LifeOSSignal>[];
    final task = groups['task'] ?? const <LifeOSSignal>[];
    final calendar = groups['calendar'] ?? const <LifeOSSignal>[];
    final household = groups['household'] ?? const <LifeOSSignal>[];

    if (expense.isNotEmpty && task.isNotEmpty) {
      results.add(const YansiCrossCoreInsight(title: 'Money + productivity', message: 'Yansi sees activity in both spending and tasks. These can be connected to help explain how daily priorities affect spending.', sources: [LifeOSSignalType.expense, LifeOSSignalType.task], confidence: 60));
    }
    if (calendar.isNotEmpty && task.isNotEmpty) {
      results.add(const YansiCrossCoreInsight(title: 'Schedule + action', message: 'Yansi sees calendar and task activity. Upcoming dates can be used to prioritize unfinished work.', sources: [LifeOSSignalType.calendar, LifeOSSignalType.task], confidence: 75));
    }
    if (household.isNotEmpty && expense.isNotEmpty) {
      results.add(const YansiCrossCoreInsight(title: 'Household + spending', message: 'Yansi can compare household purchases with expense history to identify recurring requirements and spending patterns.', sources: [LifeOSSignalType.household, LifeOSSignalType.expense], confidence: 70));
    }
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results;
  }
}
