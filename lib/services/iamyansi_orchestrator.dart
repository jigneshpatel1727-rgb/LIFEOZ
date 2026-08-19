import 'iamyansi_action_planner.dart';
import 'iamyansi_confirmation_gate.dart';
import 'iamyansi_event_bus.dart';
import 'iamyansi_lifeos_bridge.dart';

/// Coordinates understanding, planning, safety checks and lifecycle events.
/// It intentionally does not execute external/device actions itself.
class IamyansiOrchestrator {
  final IamyansiLifeOsBridge bridge;
  final IamyansiActionPlanner planner;
  final IamyansiConfirmationGate confirmationGate;
  final IamyansiEventBus eventBus;

  const IamyansiOrchestrator({
    required this.bridge,
    this.planner = const IamyansiActionPlanner(),
    this.confirmationGate = const IamyansiConfirmationGate(),
    required this.eventBus,
  });

  Future<IamyansiOrchestrationResult> process(String input) async {
    final clean = input.trim();
    if (clean.isEmpty) {
      return const IamyansiOrchestrationResult(
        accepted: false,
        message: 'No request was provided.',
        plan: null,
      );
    }

    eventBus.publish(type: 'request.received', data: {'input': clean});
    final bridgeResult = await bridge.understand(clean);
    eventBus.publish(type: 'request.understood', data: {
      'intent': bridgeResult.intent,
      'capability': bridgeResult.capability?.name,
      'allowed': bridgeResult.allowed,
    });

    final plan = planner.plan(bridgeResult);
    if (!bridgeResult.allowed) {
      eventBus.publish(type: 'action.blocked', data: {
        'capability': bridgeResult.capability?.name,
      });
      return IamyansiOrchestrationResult(
        accepted: false,
        message: 'This capability is not enabled. Ask the user to enable it first.',
        plan: plan,
      );
    }

    final capability = bridgeResult.capability;
    if (capability != null && confirmationGate.needsConfirmation(capability)) {
      final request = confirmationGate.createRequest(
        capability: capability,
        summary: 'Iamyansi wants to perform: ${bridgeResult.intent}',
      );
      eventBus.publish(type: 'action.confirmation_required', data: {
        'capability': capability.name,
        'summary': request.summary,
      });
      return IamyansiOrchestrationResult(
        accepted: true,
        message: request.summary,
        plan: plan,
        confirmation: request,
      );
    }

    eventBus.publish(type: 'action.ready', data: {
      'capability': capability?.name,
      'steps': plan.steps,
    });
    return IamyansiOrchestrationResult(
      accepted: true,
      message: 'Request understood and ready for the appropriate executor.',
      plan: plan,
    );
  }
}

class IamyansiOrchestrationResult {
  final bool accepted;
  final String message;
  final IamyansiActionPlan? plan;
  final IamyansiConfirmationRequest? confirmation;

  const IamyansiOrchestrationResult({
    required this.accepted,
    required this.message,
    required this.plan,
    this.confirmation,
  });
}
