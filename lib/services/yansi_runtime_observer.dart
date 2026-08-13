/// Observes Yansi runtime transitions and emits a compact runtime snapshot.
class YansiRuntimeObserver {
  const YansiRuntimeObserver();

  Map<String, dynamic> snapshot({
    required String state,
    required String event,
    required bool active,
  }) {
    return {
      'state': state,
      'event': event,
      'active': active,
      'ambient': true,
      'timestampSource': 'runtime',
    };
  }
}
