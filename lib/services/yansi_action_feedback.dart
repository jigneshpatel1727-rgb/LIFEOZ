/// Durable feedback contract for capability execution.
///
/// Results are fed back to Yansi without coupling the intelligence core to a
/// particular capability implementation. This enables future adaptation,
/// auditing and memory reinforcement while keeping execution separate.
enum YansiActionOutcome { success, partial, failed, cancelled, unavailable }

class YansiActionResult {
  final String capabilityId;
  final String actionId;
  final YansiActionOutcome outcome;
  final String summary;
  final Map<String, dynamic> data;
  final DateTime completedAt;
  final bool userVisible;

  const YansiActionResult({
    required this.capabilityId,
    required this.actionId,
    required this.outcome,
    required this.summary,
    this.data = const <String, dynamic>{},
    required this.completedAt,
    this.userVisible = true,
  });

  bool get succeeded => outcome == YansiActionOutcome.success;
}

class YansiFeedbackSignal {
  final String capabilityId;
  final String actionId;
  final YansiActionOutcome outcome;
  final String summary;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const YansiFeedbackSignal({
    required this.capabilityId,
    required this.actionId,
    required this.outcome,
    required this.summary,
    required this.timestamp,
    this.metadata = const <String, dynamic>{},
  });

  static YansiFeedbackSignal fromResult(YansiActionResult result) {
    return YansiFeedbackSignal(
      capabilityId: result.capabilityId,
      actionId: result.actionId,
      outcome: result.outcome,
      summary: result.summary,
      timestamp: result.completedAt,
      metadata: result.data,
    );
  }
}
