/// Decides how Yansi should surface an insight without becoming intrusive.
/// It only selects an attention mode; it never speaks, sends, or executes anything.
/// Voice is a contextual capability, not an urgency-only rule.
class YansiAttentionOrchestrator {
  const YansiAttentionOrchestrator();

  Map<String, dynamic> decide({
    required int priority,
    required int confidence,
    required bool userActive,
    required bool sensitive,
    required bool urgent,
    required bool recentlyPresented,
    int recentDismissals = 0,
    bool voiceSuitable = false,
    bool userAllowsAmbientSpeech = true,
    int speechRelevance = 0,
  }) {
    final p = priority.clamp(0, 100);
    final c = confidence.clamp(0, 100);
    final dismissals = recentDismissals.clamp(0, 5);
    final relevance = speechRelevance.clamp(0, 100);

    if (dismissals >= 3 && !urgent) {
      return _result('silent', 'Recent non-response suggests Yansi should reduce interruption.');
    }
    if (recentlyPresented && !urgent) {
      return _result('ambient', 'The insight was recently presented; keep Yansi quietly present.');
    }
    if (sensitive) {
      return _result(userActive ? 'orb_attention' : 'ambient', 'Sensitive context should be surfaced discreetly before any confirmation.');
    }

    final shouldSpeak = userAllowsAmbientSpeech && voiceSuitable &&
        userActive && relevance >= 65 && c >= 60 && p >= 55;
    if (shouldSpeak) {
      return _result('speak_when_natural', 'Yansi has enough contextual relevance to speak naturally without requiring urgency.');
    }
    if (urgent && p >= 80 && c >= 70) {
      return _result(userActive ? 'orb_attention' : 'ambient', 'High-priority evidence warrants timely attention; voice remains a contextual choice.');
    }
    if (p >= 70 && c >= 65) {
      return _result(userActive ? 'orb_attention' : 'ambient', 'Relevant evidence supports a non-intrusive attention cue.');
    }
    return _result('silent', 'The evidence does not justify interrupting the user.');
  }

  Map<String, dynamic> _result(String mode, String reason) => {
        'mode': mode,
        'reason': reason,
        'nonIntrusiveByDefault': true,
        'requiresConfirmationForAction': true,
      };
}
