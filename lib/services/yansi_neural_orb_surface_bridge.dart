import 'yansi_neural_orb_motion.dart';
import 'yansi_neural_presence_adapter.dart';
import 'yansi_ambient_surface_controller.dart';

/// Final presentation-only bridge from Yansi ambient intelligence to orb
/// motion. It does not touch the action executor or mutate LifeOS data.
class YansiNeuralOrbSurfaceBridge {
  final YansiNeuralPresenceAdapter presence;

  const YansiNeuralOrbSurfaceBridge({
    this.presence = const YansiNeuralPresenceAdapter(),
  });

  YansiNeuralOrbMotion motion(YansiAmbientSurfaceState state) {
    final metadata = presence.adapt(state);
    return YansiNeuralOrbMotion.fromSignal(
      visible: metadata['orbVisible'] == true,
      confidence: (metadata['intensity'] as num?)?.toInt() ?? 0,
    );
  }
}
