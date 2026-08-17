import 'iamyansi_agent_memory.dart';
import 'iamyansi_agent_tools.dart';
import 'iamyansi_permission_engine.dart';
import 'iamyansi_core_bridge.dart';
import 'iamyansi_intent_parser.dart';

/// Deterministic orchestration boundary for iamyansi.
///
/// The language/voice layer may produce an intent, but execution always
/// passes through this controlled boundary so permissions, persistence and
/// verification remain predictable.
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

  Future<IamyansiAgentResult> handle(
    IamyansiIntent intent, {
    bool confirmed = false,
  }) async {
    await memory.remember('user', intent.text);

    if (intent.type == IamyansiIntentType.unknown) {
      return const IamyansiAgentResult.needsClarification();
    }

    if (intent.type == IamyansiIntentType.sensitiveAction && !confirmed) {
      return const IamyansiAgentResult.confirmationRequired();
    }

    if (!permissions.canWrite()) {
      return const IamyansiAgentResult.permissionRequired();
    }

    final write = await bridge.apply(intent);
    if (!write.written && !write.alreadyExists) {
      return const IamyansiAgentResult.failed('Action was not written.');
    }

    if (write.alreadyExists) {
      const response = 'That information is already recorded.';
      await memory.remember('iamyansi', response);
      return const IamyansiAgentResult.completed(
        response: response,
        verified: true,
      );
    }

    final verification = await tools.readCore(write.core ?? 'none');
    final records = verification['records'];
    final verified = records is List &&
        records.any(
          (record) => record is Map && record['id'] == write.id,
        );

    if (verified) {
      final response = 'Done. I saved it to your ${write.core} core.';
      await memory.remember('iamyansi', response);
      return IamyansiAgentResult.completed(
        response: response,
        verified: true,
      );
    }

    return const IamyansiAgentResult.failed(
      'I could not verify the saved record.',
    );
  }
}

class IamyansiAgentResult {
  final String status;
  final String? message;
  final bool verified;

  const IamyansiAgentResult._(
    this.status, {
    this.message,
    this.verified = false,
  });

  const IamyansiAgentResult.needsClarification()
      : this._('needs_clarification');

  const IamyansiAgentResult.confirmationRequired()
      : this._('confirmation_required');

  const IamyansiAgentResult.permissionRequired()
      : this._('permission_required');

  const IamyansiAgentResult.failed(String message)
      : this._('failed', message: message);

  const IamyansiAgentResult.completed({
    required String response,
    required bool verified,
  }) : this._(
          'completed',
          message: response,
          verified: verified,
        );
}
