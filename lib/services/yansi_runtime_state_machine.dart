/// Explicit lifecycle state machine for Yansi's ambient runtime.
class YansiRuntimeStateMachine {
  const YansiRuntimeStateMachine();

  static const states = <String>[
    'idle',
    'listening',
    'thinking',
    'acting',
    'speaking',
  ];

  bool canTransition(String from, String to) {
    if (!states.contains(from) || !states.contains(to)) {
      return false;
    }

    if (from == to) {
      return true;
    }

    const transitions = <String, Set<String>>{
      'idle': {
        'listening',
        'thinking',
      },
      'listening': {
        'thinking',
        'idle',
      },
      'thinking': {
        'acting',
        'speaking',
        'idle',
      },
      'acting': {
        'speaking',
        'idle',
      },
      'speaking': {
        'idle',
        'listening',
      },
    };

    return transitions[from]?.contains(to) ?? false;
  }

  Map<String, dynamic> transition({
    required String from,
    required String to,
  }) {
    final allowed = canTransition(from, to);

    return {
      'from': from,
      'to': allowed ? to : from,
      'allowed': allowed,
      'state': allowed ? to : from,
    };
  }
}
