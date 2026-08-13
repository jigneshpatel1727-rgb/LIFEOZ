import 'yansi_ambient_surface_controller.dart';

/// Keeps ambient notifications selective. Yansi should surface only useful
/// changes and never behave like a conventional notification feed.
class YansiAmbientNotificationPolicy {
  final int minimumPriority;
  final int criticalPriority;

  const YansiAmbientNotificationPolicy({
    this.minimumPriority = 70,
    this.criticalPriority = 90,
  });

  bool shouldNotify(YansiAmbientSurfaceState state) {
    if (!state.visible || state.message == null) return false;
    if (state.confidence >= criticalPriority) return true;
    if (state.needsConfirmation && state.confidence >= minimumPriority) return true;
    return state.confidence >= minimumPriority && _isActionable(state.message!);
  }

  bool _isActionable(String message) {
    final text = message.toLowerCase();
    const signals = <String>[
      'due',
      'overdue',
      'renew',
      'deadline',
      'payment',
      'remind',
      'urgent',
      'risk',
      'confirm',
    ];
    return signals.any(text.contains);
  }
}
