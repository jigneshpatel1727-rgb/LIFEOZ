/// Fail-closed guard for the futuristic Yansi orb presentation layer.
/// If the visual layer receives invalid state, it renders nothing rather than
/// affecting the rest of LifeOS.
class YansiNeuralOrbAccessGuard {
  const YansiNeuralOrbAccessGuard();

  bool allow({required bool visible, required int confidence}) {
    if (!visible) return false;
    if (confidence < 0 || confidence > 100) return false;
    return confidence >= 60;
  }

  Map<String, dynamic> safeState({
    required bool visible,
    required int confidence,
  }) {
    final allowed = allow(visible: visible, confidence: confidence);
    return {
      'visible': allowed,
      'intensity': allowed ? confidence : 0,
      'isolated': true,
    };
  }
}
