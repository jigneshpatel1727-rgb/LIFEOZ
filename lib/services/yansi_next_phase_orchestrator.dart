import 'yansi_proactive_priority_engine.dart';

/// Coordinates the proactive Yansi phase without exposing internal
/// intelligence details to the UI. Execution remains behind existing guards.
class YansiNextPhaseOrchestrator {
  final YansiProactivePriorityEngine priorityEngine;

  const YansiNextPhaseOrchestrator(this.priorityEngine);

  List<YansiPrioritySignal> buildPriorities() => priorityEngine.prioritize();

  YansiPrioritySignal? topPriority() => priorityEngine.top();
}
