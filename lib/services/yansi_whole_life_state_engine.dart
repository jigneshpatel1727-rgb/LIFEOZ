/// Builds a compact whole-Life state from cross-core signals.
class YansiWholeLifeStateEngine {
  const YansiWholeLifeStateEngine();

  Map<String, dynamic> build(Map<String, List<String>> coreSignals) {
    final activeCores = coreSignals.entries
        .where((entry) => entry.value.any((signal) => signal.trim().isNotEmpty))
        .map((entry) => entry.key)
        .toList(growable: false);

    final totalSignals = coreSignals.values.fold<int>(
      0,
      (sum, values) => sum + values.where((v) => v.trim().isNotEmpty).length,
    );

    return {
      'activeCores': List.unmodifiable(activeCores),
      'activeCoreCount': activeCores.length,
      'totalSignals': totalSignals,
      'state': totalSignals == 0 ? 'quiet' : 'active',
    };
  }
}
