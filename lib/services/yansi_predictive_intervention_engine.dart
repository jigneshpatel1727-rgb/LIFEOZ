/// Decides whether a predictive signal deserves proactive attention.
class YansiPredictiveInterventionEngine {
  const YansiPredictiveInterventionEngine();

  Map<String, dynamic> decide({
    required Map<String, dynamic> signal,
    required bool userActive,
    required bool quietHours,
  }) {
    final confidence = (signal['confidence'] ?? '').toString();
    final repeated = (signal['observations'] as num?)?.toInt() ?? 0;
    final meaningful = confidence == 'moderate' || repeated >= 5;

    if (!meaningful) {
      return {'decision': 'silent', 'reason': 'signal_not_strong_enough'};
    }
    if (quietHours) {
      return {'decision': 'defer', 'reason': 'quiet_hours'};
    }
    if (userActive) {
      return {'decision': 'surface', 'reason': 'meaningful_signal_and_user_active'};
    }
    return {'decision': 'ambient', 'reason': 'meaningful_signal_but_user_inactive'};
  }
}
