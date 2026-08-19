import 'iamyansi_capability_policy.dart';
import 'iamyansi_command_engine.dart';
import 'iamyansi_context_engine.dart';
import 'lifeos_core_router.dart';

/// Connects the personal iAmYansi agent to LifeOS capabilities without
/// coupling the agent to the UI. The future 3D/ghost presentation can sit
/// above this bridge without changing the underlying application logic.
class IamyansiLifeOsBridge {
  final IamyansiCommandEngine commandEngine;
  final IamyansiCapabilityPolicy policy;
  final IamyansiContextEngine contextEngine;
  final LifeOsCoreRouter coreRouter;

  const IamyansiLifeOsBridge({
    required this.commandEngine,
    required this.policy,
    required this.contextEngine,
    this.coreRouter = const LifeOsCoreRouter(),
  });

  Future<IamyansiBridgeResult> understand(String input) async {
    final command = commandEngine.parse(input);
    await contextEngine.addSignal(type: 'command', value: input);

    final capability = _capabilityFor(command.intent);
    final allowed = capability == null || policy.canExecute(capability);
    final confirmation = capability != null && policy.requiresConfirmation(capability);

    return IamyansiBridgeResult(
      intent: command.intent,
      capability: capability,
      allowed: allowed,
      requiresConfirmation: confirmation,
      contextSummary: await contextEngine.buildSituationSummary(),
    );
  }

  IamyansiCapability? _capabilityFor(String intent) {
    switch (intent) {
      case 'expense':
        return IamyansiCapability.expenseWrite;
      case 'task':
        return IamyansiCapability.taskWrite;
      case 'shopping':
        return IamyansiCapability.shoppingWrite;
      case 'calendar':
        return IamyansiCapability.calendarWrite;
      case 'diary':
        return IamyansiCapability.diaryWrite;
      case 'investment':
        return IamyansiCapability.investmentAction;
      case 'web_research':
        return IamyansiCapability.webResearch;
      default:
        return null;
    }
  }
}

class IamyansiBridgeResult {
  final String intent;
  final IamyansiCapability? capability;
  final bool allowed;
  final bool requiresConfirmation;
  final String contextSummary;

  const IamyansiBridgeResult({
    required this.intent,
    required this.capability,
    required this.allowed,
    required this.requiresConfirmation,
    required this.contextSummary,
  });
}
