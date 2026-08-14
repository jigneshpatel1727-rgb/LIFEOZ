/// Decides whether a useful Yansi insight is worth speaking.
///
/// This deliberately avoids rigid scripted voice prompts. Yansi may remain
/// silent when an insight is low-value, while urgent/high-value information
/// can be surfaced when the runtime permits speech.
class YansiSpeechDecision {
  final bool shouldSpeak;
  final String reason;

  const YansiSpeechDecision({
    required this.shouldSpeak,
    required this.reason,
  });

  static YansiSpeechDecision evaluate({
    required int priority,
    required bool voicePermission,
    required bool quietMode,
    required bool userIsActive,
    bool urgent = false,
  }) {
    if (!voicePermission) {
      return const YansiSpeechDecision(
        shouldSpeak: false,
        reason: 'voice_permission_unavailable',
      );
    }
    if (quietMode && !urgent) {
      return const YansiSpeechDecision(
        shouldSpeak: false,
        reason: 'quiet_mode',
      );
    }
    if (urgent) {
      return const YansiSpeechDecision(
        shouldSpeak: true,
        reason: 'urgent_signal',
      );
    }
    if (userIsActive && priority >= 70) {
      return const YansiSpeechDecision(
        shouldSpeak: true,
        reason: 'active_high_value_insight',
      );
    }
    if (!userIsActive && priority >= 90) {
      return const YansiSpeechDecision(
        shouldSpeak: true,
        reason: 'ambient_high_value_insight',
      );
    }
    return const YansiSpeechDecision(
      shouldSpeak: false,
      reason: 'not_speech_worthy',
    );
  }
}
