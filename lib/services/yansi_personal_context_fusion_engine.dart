/// Fuses retained preferences with current LifeOS context for personalization.
class YansiPersonalContextFusionEngine {
  const YansiPersonalContextFusionEngine();

  Map<String, dynamic> fuse({
    required Map<String, dynamic> personalContext,
    required Map<String, dynamic> lifeosContext,
    required List<Map<String, dynamic>> priorities,
  }) {
    return {
      'personalContext': Map<String, dynamic>.from(personalContext),
      'lifeosContext': Map<String, dynamic>.from(lifeosContext),
      'preferences': List.unmodifiable(priorities),
      'fusionMode': 'personal_context_plus_current_context',
      'personalizationEnabled': true,
      'requiresUserControl': true,
    };
  }
}
