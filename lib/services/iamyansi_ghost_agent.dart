import 'iamyansi_capability_policy.dart';
import 'iamyansi_command_engine.dart';
import 'iamyansi_context_engine.dart';

/// Ambient/ghost orchestration layer for iAmYansi.
/// Presentation is intentionally separate: the future 3D orb can subscribe
/// to these state changes without changing the intelligence layer.
class IamyansiGhostAgent {
  final IamyansiCommandEngine commands;
  final IamyansiCapabilityPolicy policy;
  final IamyansiContextEngine context;

  const IamyansiGhostAgent({
    required this.commands,
    required this.policy,
    required this.context,
  });

  Future<IamyansiAgentDecision> understand(String input) async {
    final text = input.trim();
    if (text.isEmpty) {
      return const IamyansiAgentDecision(
        kind: IamyansiDecisionKind.conversation,
        response: 'I’m here.',
        requiresConfirmation: false,
      );
    }

    final command = commands.interpret(text);
    final capability = _capabilityFor(command.kind);
    final allowed = capability == null || policy.canExecute(capability);
    final confirmation = capability != null &&
        policy.requiresConfirmation(capability);

    await context.addSignal(type: command.kind.name, value: text);

    if (!allowed) {
      return IamyansiAgentDecision(
        kind: command.kind,
        response: 'I can help with that after you grant the required permission.',
        requiresConfirmation: false,
        blockedByPermission: true,
      );
    }

    return IamyansiAgentDecision(
      kind: command.kind,
      response: _responseFor(command.kind),
      requiresConfirmation: confirmation,
    );
  }

  IamyansiCapability? _capabilityFor(IamyansiCommandKind kind) => switch (kind) {
        IamyansiCommandKind.expense => IamyansiCapability.expenseWrite,
        IamyansiCommandKind.task => IamyansiCapability.taskWrite,
        IamyansiCommandKind.shopping => IamyansiCapability.shoppingWrite,
        IamyansiCommandKind.calendar => IamyansiCapability.calendarWrite,
        IamyansiCommandKind.diary => IamyansiCapability.diaryWrite,
        IamyansiCommandKind.investment => IamyansiCapability.investmentAction,
        IamyansiCommandKind.research => IamyansiCapability.webResearch,
        IamyansiCommandKind.coding => null,
        IamyansiCommandKind.conversation => null,
      };

  String _responseFor(IamyansiCommandKind kind) => switch (kind) {
        IamyansiCommandKind.expense => 'I understood the expense. I can categorize it for you.',
        IamyansiCommandKind.task => 'I understood the task. I can organize the next action.',
        IamyansiCommandKind.shopping => 'I understood the household requirement. I can add it to your list.',
        IamyansiCommandKind.calendar => 'I understood the date or reminder request.',
        IamyansiCommandKind.diary => 'I’m ready to turn your words into a diary entry.',
        IamyansiCommandKind.investment => 'I understood the investment request. I will keep actions confirmation-controlled.',
        IamyansiCommandKind.research => 'I understood the research request and can prepare a current-information workflow.',
        IamyansiCommandKind.coding => 'I understood the coding request and can break it into executable steps.',
        IamyansiCommandKind.conversation => 'I’m listening.',
      };
}

class IamyansiAgentDecision {
  final IamyansiDecisionKind kind;
  final String response;
  final bool requiresConfirmation;
  final bool blockedByPermission;

  const IamyansiAgentDecision({
    required this.kind,
    required this.response,
    required this.requiresConfirmation,
    this.blockedByPermission = false,
  });
}

enum IamyansiDecisionKind {
  expense,
  task,
  shopping,
  calendar,
  diary,
  investment,
  research,
  coding,
  conversation,
}
