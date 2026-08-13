/// Controls how often Yansi may surface the same ambient signal.
/// Presentation-only: this policy never executes actions or changes data.
class YansiAmbientCadencePolicy {
  final String? _lastKey;
  final DateTime? _lastShownAt;
  final int _lastPriority;

  const YansiAmbientCadencePolicy({
    String? lastKey,
    DateTime? lastShownAt,
    int lastPriority = 0,
  })  : _lastKey = lastKey,
        _lastShownAt = lastShownAt,
        _lastPriority = lastPriority;

  bool shouldSurface({
    required String signalKey,
    required int priority,
    DateTime? now,
    Duration repeatAfter = const Duration(minutes: 30),
    int priorityJump = 20,
  }) {
    if (signalKey.isEmpty) return false;
    if (_lastKey == null || _lastShownAt == null) return true;

    final current = now ?? DateTime.now();
    final elapsed = current.difference(_lastShownAt!);
    if (_lastKey != signalKey) return true;

    // Only a materially higher priority may interrupt the repeat window.
    if (priorityJump > 0 && priority >= _lastPriority + priorityJump) {
      return true;
    }

    return elapsed >= repeatAfter;
  }

  YansiAmbientCadencePolicy record(
    String signalKey, {
    int priority = 0,
    DateTime? shownAt,
  }) {
    return YansiAmbientCadencePolicy(
      lastKey: signalKey,
      lastShownAt: shownAt ?? DateTime.now(),
      lastPriority: priority,
    );
  }

  String? get lastKey => _lastKey;
  DateTime? get lastShownAt => _lastShownAt;
  int get lastPriority => _lastPriority;
}
