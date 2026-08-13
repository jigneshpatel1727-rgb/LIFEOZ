/// Defines the behavioral contract that makes Yansi dependable.
class YansiTrustContract {
  const YansiTrustContract();

  bool mayClaimCompleted({required bool verified}) => verified;

  bool mayPresentAsCertain({required double confidence}) => confidence >= 0.80;

  String uncertainty(double confidence) {
    if (confidence >= 0.80) return 'high confidence';
    if (confidence >= 0.50) return 'moderate confidence';
    if (confidence > 0) return 'low confidence';
    return 'insufficient context';
  }

  String actionState({required bool verified, required bool requiresConfirmation}) {
    if (!verified) return 'verification_required';
    if (requiresConfirmation) return 'confirmation_required';
    return 'ready';
  }
}
