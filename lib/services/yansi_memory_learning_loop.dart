/// Converts outcomes of prior Yansi reasoning into bounded learning signals.
/// It records what happened; it does not rewrite code or silently change authority.
class YansiMemoryLearningLoop {
  const YansiMemoryLearningLoop();

  Map<String, dynamic> learn({
    required Map<String, dynamic> judgment,
    Map<String, dynamic> outcome = const {},
    DateTime? observedAt,
    String? userFeedback,
  }) {
    final confidence = ((judgment['confidence'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0);
    final success = outcome['success'];
    final adjustment = success == true
        ? 0.05
        : success == false
            ? -0.05
            : 0.0;

    return {
      'type': 'reasoning_learning_signal',
      'observedAt': (observedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'judgment': judgment,
      'outcome': outcome,
      'userFeedback': userFeedback,
      'priorConfidence': confidence,
      'learningAdjustment': adjustment,
      'learnedConfidence': (confidence + adjustment).clamp(0.0, 1.0),
      'learningMode': success == null ? 'await_outcome' : 'outcome_update',
      'bounded': true,
      'doesNotRewriteCoreBehavior': true,
      'doesNotExpandAuthority': true,
    };
  }

  List<Map<String, dynamic>> usefulHistory(List<Map<String, dynamic>> signals, {int limit = 20}) {
    final result = signals.where((signal) {
      final type = '${signal['type'] ?? ''}';
      return type == 'reasoning_learning_signal';
    }).toList();
    result.sort((a, b) => '${b['observedAt'] ?? ''}'.compareTo('${a['observedAt'] ?? ''}'));
    return result.take(limit.clamp(1, 100)).toList();
  }
}
