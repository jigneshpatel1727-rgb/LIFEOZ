import 'iamyansi_capability_policy.dart';

/// Central confirmation gate for actions that can create consequential changes.
/// UI and AI layers can use this before invoking a real capability.
class IamyansiConfirmationGate {
  const IamyansiConfirmationGate();

  bool needsConfirmation(IamyansiCapability capability) {
    switch (capability) {
      case IamyansiCapability.notificationRead:
      case IamyansiCapability.investmentAction:
      case IamyansiCapability.externalMessage:
      case IamyansiCapability.deleteData:
      case IamyansiCapability.deviceControl:
      case IamyansiCapability.backgroundListening:
        return true;
      default:
        return false;
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
