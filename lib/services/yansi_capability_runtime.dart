import 'package:shared_preferences/shared_preferences.dart';
import 'lifeos_permission_gate.dart';
import 'lifeos_intelligence_bus.dart';
import 'yansi_intelligence_runtime.dart';

/// Permission-aware runtime boundary for Yansi capabilities.
/// A capability is never silently enabled: it must be explicitly allowed in
/// LifeOSPermissionGate before the runtime exposes it to Yansi.
class YansiCapabilityRuntime {
  final LifeOSPermissionGate permissions;
  final YansiIntelligenceRuntime intelligence;

  const YansiCapabilityRuntime({
    required this.permissions,
    required this.intelligence,
  });

  factory YansiCapabilityRuntime.fromPreferences(
    SharedPreferences prefs,
    LifeOSIntelligenceBus bus,
  ) {
    return YansiCapabilityRuntime(
      permissions: LifeOSPermissionGate(prefs),
      intelligence: YansiIntelligenceRuntime(
        // The runtime facade is supplied by the application's composition root.
        // This constructor is intentionally not used for creating a second bus.
        throw StateError('Use YansiCapabilityRuntime.withRuntime for composition.'),
      ),
    );
  }

  const YansiCapabilityRuntime.withRuntime({
    required this.permissions,
    required this.intelligence,
  });

  bool canListen() => permissions.voiceEnabled;
  bool canReadNotifications() => permissions.notificationEnabled;
  bool canUseWeb() => permissions.webEnabled;
  bool canUseHealth() => permissions.healthEnabled;
  bool canRunInBackground() => permissions.backgroundEnabled;

  String capabilityStatus() {
    final enabled = <String>[];
    if (canListen()) enabled.add('voice');
    if (canReadNotifications()) enabled.add('notifications');
    if (canUseWeb()) enabled.add('web');
    if (canUseHealth()) enabled.add('health');
    if (canRunInBackground()) enabled.add('background');
    return enabled.isEmpty ? 'No optional Yansi capabilities enabled.' : 'Enabled: ${enabled.join(', ')}.';
  }
}
