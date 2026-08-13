/// Maintains a compact continuity context across Yansi sessions.
class YansiMemoryContinuityEngine {
  const YansiMemoryContinuityEngine();

  Map<String, dynamic> continueContext({
    required List<Map<String, dynamic>> retainedMemory,
    required Map<String, dynamic> currentContext,
  }) {
    return {
      'retainedMemory': List.unmodifiable(retainedMemory),
      'currentContext': Map<String, dynamic>.from(currentContext),
      'continuityEnabled': true,
      'sessionIndependent': true,
      'source': 'lifeos_retained_context',
    };
  }
}
