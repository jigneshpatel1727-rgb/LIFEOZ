/// Safe Yansi proactive pipeline.
/// Produces a presentation decision only; it never executes actions.
class YansiProactivePipeline {
  final dynamic priorityEngine;
  final dynamic decisionBridge;

  const YansiProactivePipeline({
    required this.priorityEngine,
    required this.decisionBridge,
  });

  Map<String, dynamic> evaluate({
    required Map<String, dynamic> fusedSignals,
    String? insight,
    bool repeated = false,
    bool quietHours = false,
  }) {
    final priority = priorityEngine.rank(fusedSignals);
    return decisionBridge.decide(
      priority: priority,
      insight: insight,
      repeated: repeated,
      quietHours: quietHours,
    );
  }
}
