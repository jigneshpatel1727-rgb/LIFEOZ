/// Routes guarded Yansi requests to supported LifeOS core domains.
class YansiCoreActionRouterV2 {
  const YansiCoreActionRouterV2();

  static const cores = <String>{
    'expense',
    'task',
    'calendar',
    'goal',
    'shopping',
    'diary',
    'investment',
    'health',
  };

  Map<String, dynamic> route({
    required Map<String, dynamic> request,
  }) {
    final core = (request['actionType'] ?? '').toString();
    final supported = cores.contains(core);
    final executable = request['executionAllowed'] == true;

    return {
      'core': supported ? core : 'unknown',
      'supported': supported,
      'executable': supported && executable,
      'request': Map<String, dynamic>.from(request),
    };
  }
}
