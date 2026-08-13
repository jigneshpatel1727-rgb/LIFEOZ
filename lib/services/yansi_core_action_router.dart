/// Maps a Yansi action plan to LifeOS core execution intents.
class YansiCoreActionRouter {
  const YansiCoreActionRouter();

  Map<String, dynamic> route({required String request}) {
    final text = request.trim().toLowerCase();
    String core = 'general';

    if (_contains(text, ['expense', 'spent', 'paid', 'money'])) core = 'expenses';
    else if (_contains(text, ['task', 'todo', 'work', 'do'])) core = 'tasks';
    else if (_contains(text, ['goal', 'target', 'milestone'])) core = 'goals';
    else if (_contains(text, ['calendar', 'bill', 'renewal', 'birthday', 'appointment'])) core = 'calendar';
    else if (_contains(text, ['grocery', 'shopping', 'kitchen', 'buy'])) core = 'household';

    return {
      'core': core,
      'request': request,
      'state': 'routed',
      'requiresPermissionCheck': true,
      'requiresVerification': true,
    };
  }

  bool _contains(String text, List<String> values) => values.any(text.contains);
}
