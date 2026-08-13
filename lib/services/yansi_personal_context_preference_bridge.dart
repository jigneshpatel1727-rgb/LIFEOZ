/// Bridges retained preferences into a compact personalization context.
class YansiPersonalContextPreferenceBridge {
  const YansiPersonalContextPreferenceBridge();

  Map<String, dynamic> build({
    required Map<String, dynamic> preferenceMemory,
    required Map<String, dynamic> currentContext,
  }) {
    return {
      'preferences': Map<String, dynamic>.from(
        preferenceMemory['preferences'] as Map? ?? const {},
      ),
      'context': Map<String, dynamic>.from(currentContext),
      'personalizationEnabled': true,
      'source': 'retained_user_preferences',
      'requiresUserControl': true,
    };
  }
}
