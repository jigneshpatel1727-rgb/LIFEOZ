/// Classifies whether a Yansi insight is only informative, ready to prepare,
/// ready to ask for approval, or explicitly authorized to act.
/// This layer never executes an action; it only produces a safe decision state.
class YansiActionReadiness {
  const YansiActionReadiness();

  Map<String, dynamic> classify({
    required int score,
    required double confidence,
    required bool permissionGranted,
    required bool userActive,
    required bool sensitiveAction,
    required bool hasConcreteAction,
  }) {
    final safeScore = score.clamp(0, 100);
    final safeConfidence = confidence.clamp(0.0, 1.0);

    if (!hasConcreteAction || safeScore < 45 || safeConfidence < 0.45) {
      return _result('observing', 'Evidence is still being gathered.');
    }
    if (safeScore < 65 || safeConfidence < 0.60) {
      return _result('advising', 'The situation is relevant, but more evidence is useful.');
    }
    if (!userActive || !permissionGranted) {
      return _result('preparing', 'Yansi can prepare the next step but will not interrupt or act without permission.');
    }
    if (sensitiveAction) {
      return _result('ready_to_ask', 'The next step requires explicit user confirmation.');
    }
    if (safeScore >= 82 && safeConfidence >= 0.78) {
      return _result('ready_to_ask', 'Evidence is strong enough to present a clear approval request.');
    }
    return _result('preparing', 'The next step can be prepared while Yansi remains non-destructive.');
  }

  Map<String, dynamic> _result(String state, String reason) => {
        'state': state,
        'reason': reason,
        'canExecute': false,
        'requiresConfirmation': state == 'ready_to_ask',
      };
}
