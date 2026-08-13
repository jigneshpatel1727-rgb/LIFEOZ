/// Scores how strongly Yansi can rely on an inferred personal signal.
class YansiContextConfidenceEngine {
  const YansiContextConfidenceEngine();

  double score({required int relevantMemories, required bool hasRecentEvidence}) {
    if (relevantMemories <= 0) return 0.0;
    var value = relevantMemories >= 10 ? 0.85 : relevantMemories / 10.0;
    if (hasRecentEvidence) value += 0.10;
    return value.clamp(0.0, 0.95).toDouble();
  }

  String label(double confidence) {
    if (confidence >= 0.80) return 'high';
    if (confidence >= 0.50) return 'medium';
    if (confidence > 0.0) return 'low';
    return 'unknown';
  }
}
