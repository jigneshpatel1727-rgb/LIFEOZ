/// Combines signals from multiple LifeOS cores into one prioritized view.
class YansiCrossCoreSignalEngine {
  const YansiCrossCoreSignalEngine();

  List<Map<String, dynamic>> combine(Map<String, List<String>> signals) {
    final result = <Map<String, dynamic>>[];
    signals.forEach((core, values) {
      for (final value in values) {
        if (value.trim().isEmpty) continue;
        result.add({
          'core': core,
          'signal': value,
          'crossCore': signals.length > 1,
        });
      }
    });
    return List.unmodifiable(result);
  }
}
