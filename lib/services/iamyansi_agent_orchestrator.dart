import 'iamyansi_agent_memory.dart';
import 'iamyansi_agent_tools.dart';
import 'iamyansi_permission_engine.dart';
import 'iamyansi_core_bridge.dart';
import 'iamyansi_intent_parser.dart';

/// Deterministic orchestration boundary for iamyansi.
///
/// The orchestrator does not pretend to be the language model. A model can
/// produce an intent, but execution is always routed through this controlled
/// boundary so permissions, persistence and verification remain predictable.
class IamyansiAgentOrchestrator {
  final IamyansiAgentTools tools;
  final IamyansiPermissionEngine permissions;
  final IamyansiAgentMemory memory;
  final IamyansiCoreBridge bridge;

  const IamyansiAgentOrchestrator({
    required this.tools,
    required this.permissions,
    required this.memory,
    required this.bridge,
  });

  Future<IamyansiAgentResult> handle(IamyansiIntent intent) async {
    await memory.remember('user', intent.text);

    if (intent.type == IamyansiIntentType.unknown) {
      return const IamyansiAgentResult.needsClarification();
    }

    if (intent.type == IamyansiIntentType.sensitiveAction) {
      return const IamyansiAgentResult.confirmationRequired();
    }

    if (!permissions.canWrite()) {
      return const IamyansiAgentResult.permissionRequired();
    }

    final write = await bridge.apply(intent);
    if (!write.written && !write.alreadyExists) {
      return const IamyansiAgentResult.failed('Action was not written.');
    }

    final verification = await tools.readCore(write.core ?? 'none');
    final verified = (verification['records'] as List).any(
      (record) => record is Map && record['id'] == write.id,
    );

    if (write.alreadyExists || verified) {
      final response = write.alreadyExists
          ? 'That information is already recorded.'
          : 'Done. I saved it to your ${write.core} core.';
      await memory.remember('iamyansi', response);
      return IamyansiAgentResult.completed(
        response: response,
        verified: write.alreadyExists || verified,
      );
    }

    return const IamyansiAgentResult.failed('I could not verify the saved record.');
  }
}

class IamyansiAgentResult {
  final String status;
  final String? message;
  final bool verified;
  const IamyansiAgentResult._(this.status, {this.message, this.verified = false});

  const IamyansiAgentResult.needsClarification() : this._('needs_clarification');
  const IamyansiAgentResult.confirmationRequired() : this._('confirmation_required');
  const IamyansiAgentResult.permissionRequired() : this._('permission_required');
  const IamyansiAgentResult.failed(String message) : this._('failed', message: message);
  const IamyansiAgentResult.completed({required String response, required bool verified})
      : this._('completed', message: response, verified: verified);
}
