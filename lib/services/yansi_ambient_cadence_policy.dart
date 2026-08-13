/// Controls how often Yansi may surface the same ambient signal.
/// Presentation-only: this policy never executes actions or changes data.
class YansiAmbientCadencePolicy {
  final String? _lastKey;
  final DateTime? _lastShownAt;

  const YansiAmbientCadencePolicy({
    String? lastKey,
    DateTime? lastShownAt,
  })  : _lastKey = lastKey,
        _lastShownAt = lastShownAt;

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
    if (priorityJump > 0 && priority >= priorityJump) return true;

    return elapsed >= repeatAfter;
  }

  YansiAmbientCadencePolicy record(
    String signalKey, {
    DateTime? shownAt,
  }) {
    return YansiAmbientCadencePolicy(
      lastKey: signalKey,
      lastShownAt: shownAt ?? DateTime.now(),
    );
  }

  String? get lastKey => _lastKey;
  DateTime? get lastShownAt => _lastShownAt;
}
