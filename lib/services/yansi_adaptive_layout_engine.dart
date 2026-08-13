/// Chooses a compact, balanced, or spacious layout from context and preference.
class YansiAdaptiveLayoutEngine {
  const YansiAdaptiveLayoutEngine();

  Map<String, dynamic> choose({
    required String density,
    required int informationCount,
    required bool focusMode,
  }) {
    var resolved = density;
    if (focusMode) resolved = 'minimal';
    if (informationCount > 12 && density == 'balanced') resolved = 'compact';
    if (informationCount <= 3 && density == 'balanced') resolved = 'spacious';

    return {
      'density': resolved,
      'focusMode': focusMode,
      'informationCount': informationCount,
    };
  }
}
