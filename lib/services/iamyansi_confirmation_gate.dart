import 'iamyansi_capability_policy.dart';

/// Central confirmation gate for actions that can create consequential changes.
/// The gate mirrors the policy so the orchestration layer has one safe check
/// before an executor is allowed to act.
class IamyansiConfirmationGate {
  const IamyansiConfirmationGate();

  bool needsConfirmation(IamyansiCapability capability) {
    switch (capability) {
      case IamyansiCapability.expenseWrite:
      case IamyansiCapability.taskWrite:
      case IamyansiCapability.shoppingWrite:
      case IamyansiCapability.calendarWrite:
      case IamyansiCapability.diaryWrite:
      case IamyansiCapability.webResearch:
      case IamyansiCapability.voiceTranscription:
        return false;
      case IamyansiCapability.notificationRead:
      case IamyansiCapability.investmentAction:
      case IamyansiCapability.externalMessage:
      case IamyansiCapability.deleteData:
      case IamyansiCapability.deviceControl:
      case IamyansiCapability.backgroundListening:
        return true;
    }
  }

  IamyansiConfirmationRequest createRequest({
    required IamyansiCapability capability,
    required String summary,
  }) {
    return IamyansiConfirmationRequest(
      capability: capability,
      summary: summary.trim(),
      requiresExplicitApproval: needsConfirmation(capability),
    );
  }
}

class IamyansiConfirmationRequest {
  final IamyansiCapability capability;
  final String summary;
  final bool requiresExplicitApproval;

  const IamyansiConfirmationRequest({
    required this.capability,
    required this.summary,
    required this.requiresExplicitApproval,
  });
}
