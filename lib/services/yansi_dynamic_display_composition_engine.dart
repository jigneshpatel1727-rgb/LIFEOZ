/// Composes a safe display plan from Yansi's visual identity and UI intelligence.
class YansiDynamicDisplayCompositionEngine {
  const YansiDynamicDisplayCompositionEngine();

  Map<String, dynamic> compose({
    required Map<String, dynamic> visualIdentity,
    required Map<String, dynamic> uiDecision,
  }) {
    final surface = (uiDecision['surface'] ?? 'orb').toString();
    final density = (uiDecision['density'] ?? visualIdentity['density'] ?? 'minimal').toString();

    return {
      'surface': surface,
      'density': density,
      'theme': visualIdentity['theme'] ?? 'default',
      'orbStyle': visualIdentity['orbStyle'] ?? 'neural',
      'iconStyle': visualIdentity['iconStyle'] ?? 'futuristic',
      'voiceEnabled': uiDecision['voice'] == true,
      'userControlled': visualIdentity['userControlled'] == true,
      'compositionMode': 'adaptive',
    };
  }
}
