/// Normalized request passed from Yansi into a LifeOS core handler.
class YansiCoreExecutionRequest {
  const YansiCoreExecutionRequest({
    required this.core,
    required this.operation,
    required this.payload,
    required this.executionAllowed,
  });

  final String core;
  final String operation;
  final Map<String, dynamic> payload;
  final bool executionAllowed;

  Map<String, dynamic> toMap() {
    return {
      'core': core,
      'operation': operation,
      'payload': Map<String, dynamic>.from(payload),
      'executionAllowed': executionAllowed,
      'source': 'yansi',
    };
  }
}
