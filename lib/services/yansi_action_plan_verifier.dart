/// Tracks completion of a multi-step Yansi plan using explicit verification.
class YansiActionPlanVerifier {
  const YansiActionPlanVerifier();

  Map<String, dynamic> verify({
    required List<Map<String, dynamic>> steps,
    required Set<int> verifiedSteps,
  }) {
    final total = steps.length;
    final verified = verifiedSteps.where((step) => step >= 1 && step <= total).length;
    return {
      'totalSteps': total,
      'verifiedSteps': verified,
      'complete': total > 0 && verified == total,
      'state': total == 0
          ? 'empty'
          : verified == total
              ? 'verified_complete'
              : 'in_progress',
    };
  }
}
