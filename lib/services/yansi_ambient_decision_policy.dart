import 'yansi_ambient_insight_ranker.dart';

/// Decides whether a ranked Yansi insight should become an ambient briefing.
///
/// The policy is intentionally conservative: low-priority signals stay
/// silent, repeated messages are suppressed, and no data-changing action is
/// executed here.
class YansiAmbientDecisionPolicy {
  final YansiAmbientInsightRanker ranker;

  const YansiAmbientDecisionPolicy({
    this.ranker = const YansiAmbientInsightRanker(),
  });

  Map<String, dynamic>? decide(
    List<Map<String, dynamic>> candidates, {
    String? lastMessage,
    double minimumPriority = 0.70,
  }) {
    final selected = ranker.select(
      candidates,
      lastMessage: lastMessage,
    );

    if (selected == null) return null;

    final priority = (selected['priority'] as num).toDouble();
    if (priority < minimumPriority) return null;

    return {
      ...selected,
      'ambient': true,
      'actionable': false,
      'requiresConfirmationForAction': true,
    };
  }
}
