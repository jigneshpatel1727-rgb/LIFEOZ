/// Chooses a quiet intervention style from situational awareness.
class YansiInterventionOrchestrator {
  const YansiInterventionOrchestrator();

  Map<String, dynamic> choose({
    required Map<String, dynamic> situation,
    required bool quietHours,
    required bool critical,
  }) {
    final attention = situation['attentionRequired'] == true;
    if (!attention) return {'mode': 'silent', 'reason': 'no_attention_needed'};
    if (quietHours && !critical) {
      return {'mode': 'ambient', 'reason': 'quiet_hours'};
    }
    if (critical) return {'mode': 'urgent', 'reason': 'critical_signal'};
    return {'mode': 'ambient', 'reason': 'proactive_signal'};
  }
}
