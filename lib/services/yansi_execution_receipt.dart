/// Immutable-style receipt describing what a core reports after an action.
class YansiExecutionReceipt {
  final String core;
  final String operation;
  final bool success;
  final String? reference;
  final String timestamp;

  const YansiExecutionReceipt({
    required this.core,
    required this.operation,
    required this.success,
    this.reference,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'core': core,
        'operation': operation,
        'success': success,
        'reference': reference,
        'timestamp': timestamp,
      };
}
