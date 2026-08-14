import 'yansi_failure_recovery.dart';

/// Converts action outcomes into bounded learning signals.
/// This layer does not execute actions or rewrite application code.
class YansiClosedLoopLearning {
  const YansiClosedLoopLearning();

  Map<String, dynamic> learn({
    required bool executed,
    required bool userAccepted,
    required bool userDismissed,
    required bool userIgnored,
    required int priorSuccesses,
    required int priorFailures,
  }) {
    final total = priorSuccesses + priorFailures;
    final reliability = total == 0 ? 0.5 : priorSuccesses / total;

    if (executed && userAccepted) {
      return _result('reinforce', 0.08, 'Successful execution followed by user acceptance is positive evidence.');
    }
    if (!executed && userDismissed) {
      return _result('reduce', -0.10, 'A failed or incomplete action followed by dismissal is evidence to reduce proactive intensity.');
    }
    if (userIgnored) {
      return _result('reduce', -0.04, 'Repeated non-response suggests Yansi should become less interruptive.');
    }
    if (priorFailures >= 2 || reliability < 0.35) {
      return _result('caution', -0.08, 'Historical execution reliability is low; stronger evidence or confirmation is preferred.');
    }
    return _result('neutral', 0.0, 'There is not enough outcome evidence to change behavior.');
  }

  Map<String, dynamic> recovery({required Map<String, dynamic> outcome, int priorFailures = 0}) {
    final recovery = const YansiFailureRecovery().decide(
      action: '${outcome['action'] ?? ''}',
      authorized: outcome['authorized'] == true,
      executed: outcome['executed'] == true,
      error: outcome['error'] as String?,
      priorFailures: priorFailures,
      retrySafe: outcome['retrySafe'] == true,
    );
    return recovery;
  }

  Map<String, dynamic> _result(String mode, double adjustment, String reason) => {
        'mode': mode,
        'confidenceAdjustment': adjustment,
        'reason': reason,
      };
}
