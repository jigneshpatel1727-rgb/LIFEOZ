import 'lifeos_intelligence_coordinator.dart';
import 'lifeos_intelligence_bus.dart';

/// Runtime facade for Yansi. UI layers call this facade rather than wiring
/// individual LifeOS intelligence services together.
class YansiIntelligenceRuntime {
  final LifeOSIntelligenceCoordinator coordinator;
  const YansiIntelligenceRuntime(this.coordinator);

  LifeOSIntelligenceDecision observe() => coordinator.evaluate();

  LifeOSIntelligenceDecision prepareAction({
    required String action,
    required LifeOSSignalType source,
  }) => coordinator.evaluate(proposedAction: action, source: source);

  String ambientBrief() {
    final decision = observe();
    if (decision.insights.isEmpty) return 'Yansi has no priority signal right now.';
    return decision.insights
        .take(3)
        .map((i) => '${i.title}: ${i.message}')
        .join(' | ');
  }
}
