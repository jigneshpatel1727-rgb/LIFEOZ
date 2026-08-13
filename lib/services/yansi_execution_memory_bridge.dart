import 'dart:convert';

import 'yansi_execution_receipt.dart';

/// Converts verified execution outcomes into permanent memory records.
class YansiExecutionMemoryBridge {
  const YansiExecutionMemoryBridge();

  Map<String, dynamic> toMemory({
    required YansiExecutionReceipt receipt,
    String? userIntent,
  }) {
    return {
      'type': 'execution_outcome',
      'core': receipt.core,
      'operation': receipt.operation,
      'success': receipt.success,
      'reference': receipt.reference,
      'timestamp': receipt.timestamp,
      'userIntent': userIntent,
      'memoryPolicy': 'permanent',
    };
  }

  String encode(Map<String, dynamic> memory) => jsonEncode(memory);
}
