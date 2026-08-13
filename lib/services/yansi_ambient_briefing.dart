/// Safe ambient briefing produced from the proactive Yansi runtime.
/// Presentation only: it never executes a LifeOS action.
class YansiAmbientBriefing {
  final String headline;
  final String message;
  final int priority;
  final int confidence;
  final bool speak;
  final bool requiresConfirmation;

  const YansiAmbientBriefing({
    required this.headline,
    required this.message,
    required this.priority,
    required this.confidence,
    required this.speak,
    required this.requiresConfirmation,
  });

  bool get visible => priority >= 70 && confidence >= 70;

  bool get voiceEligible => visible && speak && !requiresConfirmation;
}
