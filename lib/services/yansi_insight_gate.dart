/// Decides whether an insight is worth surfacing aloud.
/// Yansi is not forced to speak on every event; the gate keeps speech
/// contextual, useful and non-mechanical while leaving the final decision
/// to the ambient companion layer.
class YansiInsightGate {
  const YansiInsightGate();

  bool shouldSpeak({
    required int priority,
    required bool userIsActive,
    required bool urgent,
    required bool alreadyPresented,
    bool quietMode = false,
  }) {
    if (alreadyPresented || quietMode) return false;
    if (urgent) return true;
    if (userIsActive) return priority >= 68;
    return priority >= 88;
  }

  String naturalLead({required String insight, required bool urgent}) {
    if (urgent) return insight;
    return insight;
  }
}
