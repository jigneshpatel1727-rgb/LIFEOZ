/// Calibrates Yansi signal confidence before an insight is surfaced.
/// Read-only and presentation-safe: it cannot execute actions or mutate data.
class YansiConfidenceCalibrator {
  const YansiConfidenceCalibrator();

  int calibrate({
    required int priority,
    required bool hasContext,
    required bool repeated,
  }) {
    var score = priority.clamp(0, 100).toInt();
    if (!hasContext) score -= 10;
    if (repeated) score -= 20;
    return score.clamp(0, 100).toInt();
  }

  bool isTrusted(int confidence) => confidence.clamp(0, 100) >= 70;
}
