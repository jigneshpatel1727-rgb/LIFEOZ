import 'yansi_context_reasoner.dart';

/// Converts reasoning results into an ambient presentation state.
/// The UI decides how to render the state; this layer never forces a voice
/// prompt or a navigation action.
class YansiInsightPresentation {
  final YansiReasonedInsight? insight;
  final bool showOrbActivity;
  final bool suggestVoice;

  const YansiInsightPresentation({
    required this.insight,
    required this.showOrbActivity,
    required this.suggestVoice,
  });
}

class YansiInsightPresenter {
  const YansiInsightPresenter();

  YansiInsightPresentation present({
    required List<YansiReasonedInsight> insights,
    required bool userIsActive,
    required bool voiceAllowed,
  }) {
    if (insights.isEmpty) {
      return const YansiInsightPresentation(
        insight: null,
        showOrbActivity: false,
        suggestVoice: false,
      );
    }

    final top = insights.first;
    return YansiInsightPresentation(
      insight: top,
      showOrbActivity: top.priority >= 60,
      suggestVoice: voiceAllowed && userIsActive && top.priority >= 80,
    );
  }
}
