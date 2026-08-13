import 'lifeos_data_store.dart';

/// Persists an already-authorized Yansi core action into the local LifeOS store.
///
/// This class is intentionally the final write boundary: callers must provide
/// an execution guard result with `executionAllowed == true`.
class YansiCorePersistenceExecutor {
  final LifeOSDataStore store;

  const YansiCorePersistenceExecutor(this.store);

  Future<Map<String, dynamic>> execute({
    required Map<String, dynamic> executionGuard,
    required Map<String, dynamic> plan,
  }) async {
    if (executionGuard['executionAllowed'] != true) {
      return {
        'executed': false,
        'reason': 'execution_guard_blocked',
      };
    }

    if (plan['valid'] != true || plan['mutatesData'] != true) {
      return {
        'executed': false,
        'reason': 'invalid_or_non_mutating_plan',
      };
    }

    final core = (plan['core'] ?? '').toString();
    final payload = plan['payload'];
    if (payload is! Map<String, dynamic>) {
      return {
        'executed': false,
        'reason': 'invalid_payload',
      };
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final record = <String, dynamic>{
      'id': id,
      'type': core,
      'createdAt': DateTime.now().toIso8601String(),
      ...payload,
    };

    await store.append(core, record);

    return {
      'executed': true,
      'core': core,
      'id': id,
      'record': record,
    };
  }
}
