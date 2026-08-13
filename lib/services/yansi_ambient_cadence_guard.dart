import 'yansi_ambient_surface_controller.dart';

/// Keeps Yansi ambient output quiet unless a new or materially stronger
/// priority deserves attention. This supports the ghost/ambient UX.
class YansiAmbientCadenceGuard {
  final int minimumPriority;
  final int escalationDelta;
  int _lastPriority = -1;
  String _lastMessage = '';

  YansiAmbientCadenceGuard({this.minimumPriority = 60, this.escalationDelta = 15});

  bool shouldSurface(YansiAmbientSurfaceState state) {
    if (!state.visible || state.message == null) return false;
    final priority = state.confidence;
    if (priority < minimumPriority) return false;
    final changed = state.message != _lastMessage;
    final escalated = priority >= _lastPriority + escalationDelta;
    if (!changed && !escalated) return false;
    _lastPriority = priority;
    _lastMessage = state.message!;
    return true;
  }

  void reset() {
    _lastPriority = -1;
    _lastMessage = '';
  }
}
