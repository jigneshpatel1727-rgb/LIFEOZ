/// Provides runtime icon configuration from natural user preferences.
class YansiIconPersonalizationEngine {
  const YansiIconPersonalizationEngine();

  Map<String, dynamic> configure({
    required String style,
    double scale = 1.0,
    bool glow = false,
  }) {
    return {
      'style': style.trim().isEmpty ? 'default' : style.trim(),
      'scale': scale.clamp(0.75, 1.5),
      'glow': glow,
      'runtime': true,
    };
  }
}
