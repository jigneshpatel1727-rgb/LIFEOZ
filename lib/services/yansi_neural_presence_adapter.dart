import 'yansi_ambient_surface_controller.dart';
import 'yansi_neural_presence_policy.dart';

/// Safely adapts the existing ambient surface into neural-presence metadata.
/// This is presentation-only and cannot execute LifeOS actions.
class YansiNeuralPresenceAdapter {
  final YansiNeuralPresencePolicy policy;
  const YansiNeuralPresenceAdapter({this.policy = const YansiNeuralPresencePolicy()});

  Map<String, dynamic> adapt(YansiAmbientSurfaceState state) {
    return policy.decide(
      visible: state.visible,
      confidence: state.confidence,
      needsConfirmation: state.needsConfirmation,
    )..['messageText'] = state.message;
  }
}
