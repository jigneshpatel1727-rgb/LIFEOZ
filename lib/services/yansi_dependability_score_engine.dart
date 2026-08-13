/// Produces a simple operational dependability signal from verified outcomes.
class YansiDependabilityScoreEngine {
  const YansiDependabilityScoreEngine();

  double score({required int verified, required int attempted}) {
    if (attempted <= 0) return 1.0;
    if (verified <= 0) return 0.0;
    return (verified / attempted).clamp(0.0, 1.0).toDouble();
  }

  String label(double value) {
    if (value >= 0.95) return 'excellent';
    if (value >= 0.80) return 'strong';
    if (value >= 0.60) return 'needs_attention';
    return 'unreliable';
  }
}
