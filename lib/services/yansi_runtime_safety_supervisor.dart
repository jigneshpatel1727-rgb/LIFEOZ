/// Validates Yansi runtime conditions before allowing a transition or action.
class YansiRuntimeSafetySupervisor {
  const YansiRuntimeSafetySupervisor();

  Map<String, dynamic> validate({
    required String state,
    required String requestedState,
    required bool runtimeActive,
    required bool actionApproved,
  }) {
    final actionState = requestedState == 'acting';
    final allowed = runtimeActive &&
        (!actionState || actionApproved) &&
        state != 'speaking' || requestedState == 'idle';

    return {
      'allowed': allowed,
      'state': state,
      'requestedState': requestedState,
      'runtimeActive': runtimeActive,
      'actionApproved': actionApproved,
      'requiresApproval': actionState,
      'safeToProceed': allowed,
    };
  }
}
