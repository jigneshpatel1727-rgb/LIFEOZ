/// Verifies that an important Yansi action has actually completed before
/// presenting it as completed.
class YansiActionVerificationEngine {
  const YansiActionVerificationEngine();

  Map<String, dynamic> verify({
    required String action,
    required bool requested,
    required bool completed,
  }) {
    return {
      'action': action,
      'requested': requested,
      'completed': completed,
      'verified': requested && completed,
      'message': requested && completed
          ? 'Action verified as completed.'
          : 'Action has not been verified as completed.',
    };
  }
}
