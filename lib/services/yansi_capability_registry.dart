/// Central registry for optional Yansi capabilities and future premium modules.
/// Entitlements are data only; billing providers and activation UI can be connected later.
class YansiCapabilityRegistry {
  const YansiCapabilityRegistry();

  static const Map<String, Map<String, dynamic>> capabilities = {
    'core_ai': {'tier': 'core', 'enabledByDefault': true},
    'advanced_memory': {'tier': 'plus', 'enabledByDefault': false},
    'web_intelligence': {'tier': 'plus', 'enabledByDefault': false},
    'world_intelligence': {'tier': 'world', 'enabledByDefault': false},
    'live_maps': {'tier': 'world', 'enabledByDefault': false},
    'travel_intelligence': {'tier': 'world', 'enabledByDefault': false},
    'spatial_3d': {'tier': 'holo', 'enabledByDefault': false},
    'city_hologram': {'tier': 'holo', 'enabledByDefault': false},
    'future_ar_vr': {'tier': 'holo', 'enabledByDefault': false},
  };

  Map<String, dynamic> resolve({
    required String capability,
    Set<String> activeEntitlements = const {},
  }) {
    final definition = capabilities[capability];
    if (definition == null) {
      return {'available': false, 'reason': 'unknown_capability'};
    }
    final tier = '${definition['tier']}';
    final enabled = definition['enabledByDefault'] == true ||
        activeEntitlements.contains(capability) ||
        activeEntitlements.contains(tier) ||
        activeEntitlements.contains('all_access');
    return {
      'capability': capability,
      'tier': tier,
      'available': enabled,
      'premium': tier != 'core',
      'activationRequired': !enabled,
      'adaptive': true,
    };
  }
}
