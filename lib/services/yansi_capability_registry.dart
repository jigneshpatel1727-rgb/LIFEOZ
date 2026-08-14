/// Central registry for Yansi capabilities and future premium modules.
///
/// The registry describes capabilities and entitlements only. Yansi's
/// intelligence remains centralized and decides relevance and priority.
class YansiCapabilityDescriptor {
  final String id;
  final String tier;
  final Set<String> domains;
  final Set<String> requiredPermissions;
  final bool enabledByDefault;
  final bool canExecuteActions;

  const YansiCapabilityDescriptor({
    required this.id,
    required this.tier,
    this.domains = const <String>{},
    this.requiredPermissions = const <String>{},
    this.enabledByDefault = false,
    this.canExecuteActions = false,
  });
}

class YansiCapabilityRegistry {
  const YansiCapabilityRegistry();

  static const Map<String, YansiCapabilityDescriptor> capabilities = {
    'core_ai': YansiCapabilityDescriptor(
      id: 'core_ai', tier: 'core', enabledByDefault: true,
      domains: {'yansi'},
    ),
    'advanced_memory': YansiCapabilityDescriptor(
      id: 'advanced_memory', tier: 'plus', domains: {'memory'},
    ),
    'web_intelligence': YansiCapabilityDescriptor(
      id: 'web_intelligence', tier: 'plus', domains: {'web'},
      requiredPermissions: {'web_access'},
    ),
    'world_intelligence': YansiCapabilityDescriptor(
      id: 'world_intelligence', tier: 'world', domains: {'world'},
    ),
    'live_maps': YansiCapabilityDescriptor(
      id: 'live_maps', tier: 'world', domains: {'maps', 'location'},
      requiredPermissions: {'location'},
    ),
    'travel_intelligence': YansiCapabilityDescriptor(
      id: 'travel_intelligence', tier: 'world', domains: {'travel', 'maps'},
      requiredPermissions: {'location', 'web_access'},
    ),
    'spatial_3d': YansiCapabilityDescriptor(
      id: 'spatial_3d', tier: 'holo', domains: {'spatial', '3d'},
    ),
    'city_hologram': YansiCapabilityDescriptor(
      id: 'city_hologram', tier: 'holo', domains: {'spatial', 'city'},
    ),
    'future_ar_vr': YansiCapabilityDescriptor(
      id: 'future_ar_vr', tier: 'holo', domains: {'spatial', 'ar', 'vr'},
    ),
  };

  Map<String, dynamic> resolve({
    required String capability,
    Set<String> activeEntitlements = const {},
    Set<String> grantedPermissions = const {},
  }) {
    final definition = capabilities[capability];
    if (definition == null) {
      return {'available': false, 'reason': 'unknown_capability'};
    }

    final entitled = definition.enabledByDefault ||
        activeEntitlements.contains(capability) ||
        activeEntitlements.contains(definition.tier) ||
        activeEntitlements.contains('all_access');
    final permissionsMissing = definition.requiredPermissions
        .where((permission) => !grantedPermissions.contains(permission))
        .toList(growable: false);

    return {
      'capability': capability,
      'tier': definition.tier,
      'premium': definition.tier != 'core',
      'entitled': entitled,
      'available': entitled && permissionsMissing.isEmpty,
      'activationRequired': !entitled,
      'missingPermissions': permissionsMissing,
      'adaptive': true,
      'canExecuteActions': definition.canExecuteActions,
    };
  }

  List<YansiCapabilityDescriptor> forDomain(String domain) {
    final value = domain.trim().toLowerCase();
    return capabilities.values
        .where((item) => item.domains.any((d) => d.toLowerCase() == value))
        .toList(growable: false);
  }
}
