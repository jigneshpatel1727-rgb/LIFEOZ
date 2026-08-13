/// Safe Yansi proactive pipeline.
/// Produces a presentation decision only; it never executes actions.
class YansiProactivePipeline {
  final dynamic priorityEngine;

  const YansiProactivePipeline({required this.priorityEngine});

  Map<String, dynamic> evaluate({
    required Map<String, dynamic> fusedSignals,
    String? insight,
    bool repeated = false,
    bool quietHours = false,
  }) {
    final priority = priorityEngine.rank(fusedSignals);
    final score = _number(priority['score']);
    final confidence = _number(priority['confidence']);
    final core = priority['core']?.toString();

    if (core == null ||
        core.isEmpty ||
        score < 70 ||
        confidence < 70 ||
        repeated) {
      return const {
        'surface': false,
        'speak': false,
        'requiresConfirmation': false,
        'core': null,
        'priority': 0,
        'confidence': 0,
        'insight': null,
      };
    }

    final critical = score >= 90 && confidence >= 85;

    return {
      'surface': true,
      'speak': !quietHours || critical,
      'requiresConfirmation': critical,
      'core': core,
      'priority': score,
      'confidence': confidence,
      'insight': insight,
    };
  }

  int _number(dynamic value) {
    if (value is num) return value.clamp(0, 100).toInt();
    return 0;
  }
}
