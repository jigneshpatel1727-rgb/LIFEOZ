/// Interprets the combined LifeOS state into a human-readable situation.
class YansiSituationalAwarenessEngine {
  const YansiSituationalAwarenessEngine();

  Map<String, dynamic> assess({
    required Map<String, dynamic> wholeLifeState,
    required List<Map<String, dynamic>> priorities,
  }) {
    final state = (wholeLifeState['state'] ?? 'quiet').toString();
    final top = priorities.isEmpty ? null : priorities.first;
    return {
      'state': state,
      'attentionRequired': top != null,
      'topSignal': top?['signal'],
      'topCore': top?['core'],
      'assessment': top == null
          ? 'No strong LifeOS signal requires attention.'
          : 'A LifeOS signal may deserve attention in ${top['core']}.',
    };
  }
}
