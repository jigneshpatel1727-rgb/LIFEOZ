/// Safe presentation policy for Yansi's futuristic neural presence.
/// It is deliberately independent from LifeOS actions and data mutation.
class YansiNeuralPresencePolicy {
  const YansiNeuralPresencePolicy();

  Map<String, dynamic> decide({
    required bool visible,
    required int confidence,
    required bool needsConfirmation,
  }) {
    final score = confidence.clamp(0, 100).toInt();
    if (!visible || score < 60) {
      return const {
        'orbVisible': false,
        'pulse': false,
        'speak': false,
        'message': false,
      };
    }

    return {
      'orbVisible': true,
      'pulse': score >= 60,
      'speak': score >= 85 && !needsConfirmation,
      'message': score >= 70,
      'intensity': score,
    };
  }
}
