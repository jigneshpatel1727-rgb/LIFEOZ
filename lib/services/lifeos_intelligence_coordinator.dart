import 'lifeos_action_guard.dart';
import 'lifeos_context_engine.dart';
import 'lifeos_intelligence_bus.dart';
import 'lifeos_proactive_engine.dart';

class LifeOSIntelligenceDecision {
  final Map<String, dynamic> context;
  final List<LifeOSInsight> insights;
  final LifeOSActionDecision? action;
  const LifeOSIntelligenceDecision({required this.context, required this.insights, this.action});
}

/// Coordinates context, proactive intelligence and action safety into one
/// decision surface for Yansi and the futuristic LifeOS experience.
class LifeOSIntelligenceCoordinator {
  final LifeOSIntelligenceBus bus;
  final LifeOSContextEngine contextEngine;
  final LifeOSProactiveEngine proactiveEngine;
  final LifeOSActionGuard actionGuard;

  LifeOSIntelligenceCoordinator(this.bus)
      : contextEngine = LifeOSContextEngine(bus),
        proactiveEngine = LifeOSProactiveEngine(bus),
        actionGuard = const LifeOSActionGuard();

  LifeOSIntelligenceDecision evaluate({String? proposedAction, LifeOSSignalType? source}) {
    final action = proposedAction == null || source == null
        ? null
        : actionGuard.evaluate(action: proposedAction, source: source);
    return LifeOSIntelligenceDecision(
      context: contextEngine.snapshot(),
      insights: proactiveEngine.evaluate(),
      action: action,
    );
  }
}
