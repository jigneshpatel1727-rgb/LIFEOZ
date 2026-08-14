/// Converts only sufficiently observed behavioral patterns into bounded prediction boosts.
/// Weak patterns are ignored; this layer never executes actions or changes permissions.
class YansiPatternPredictionBridge {
  const YansiPatternPredictionBridge();

  Map<String, dynamic> evaluate({
    required int observations,
    required bool positive,
    required bool negative,
    required double baseConfidence,
  }) {
    final safeBase = baseConfidence.clamp(0.0, 1.0).toDouble();
    if (observations < 3) {
      return _result(0.0, safeBase, 'insufficient_evidence');
    }

    final consistency = positive == negative ? 0.0 : 1.0;
    final strength = (observations / 10.0).clamp(0.0, 1.0).toDouble();
    var adjustment = positive && !negative ? 0.10 * strength : 0.0;
    if (negative && !positive) adjustment = -0.10 * strength;
    if (positive && negative) adjustment *= 0.25;

    final confidence = (safeBase + adjustment * consistency).clamp(0.0, 1.0).toDouble();
    return _result(adjustment * consistency, confidence, 'verified_pattern');
  }

  Map<String, dynamic> _result(double adjustment, double confidence, String source) => {
        'confidenceAdjustment': adjustment,
        'confidence': confidence,
        'source': source,
        'bounded': true,
      };
}
