/// Activates the unified Yansi runtime through a single safe bridge.
class YansiRuntimeActivationBridge {
  const YansiRuntimeActivationBridge();

  Map<String, dynamic> activate({
    required Map<String, dynamic> runtimeResult,
    required bool enabled,
  }) {
    if (!enabled) {
      return {
        'active': false,
        'mode': 'disabled',
        'runtime': null,
      };
    }

    return {
      'active': true,
      'mode': 'ambient_runtime',
      'runtime': Map<String, dynamic>.from(runtimeResult),
      'guardedActions': true,
      'userControlRequired': true,
    };
  }
}
