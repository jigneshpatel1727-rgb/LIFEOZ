import 'yansi_capability_registry.dart';

/// Stable envelope passed between LifeOS capability adapters and Yansi.
/// It lets the intelligence layer see capability availability without
/// coupling itself to individual feature implementations.
class YansiCapabilityContext {
  final Map<String, dynamic> lifeContext;
  final Set<String> activeEntitlements;
  final Set<String> grantedPermissions;

  const YansiCapabilityContext({
    this.lifeContext = const <String, dynamic>{},
    this.activeEntitlements = const <String>{},
    this.grantedPermissions = const <String>{},
  });

  Map<String, Map<String, dynamic>> availability(
    Iterable<String> capabilityIds,
  ) {
    final registry = const YansiCapabilityRegistry();
    return {
      for (final id in capabilityIds)
        id: registry.resolve(
          capability: id,
          activeEntitlements: activeEntitlements,
          grantedPermissions: grantedPermissions,
        ),
    };
  }

  bool canUse(String capability) {
    final result = const YansiCapabilityRegistry().resolve(
      capability: capability,
      activeEntitlements: activeEntitlements,
      grantedPermissions: grantedPermissions,
    );
    return result['available'] == true;
  }
}
