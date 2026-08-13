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
    final visible = metadata['orbVisible'] == true;
    final rawIntensity = (metadata['intensity'] as num?)?.toInt() ?? 0;
    final confidence = rawIntensity.clamp(0, 100).toInt();

    // Fail closed: malformed presentation state produces an inert orb.
    if (!visible || confidence < 60) {
      return YansiNeuralOrbMotion.fromSignal(
        visible: false,
        confidence: 0,
      );
    }

    return YansiNeuralOrbMotion.fromSignal(
      visible: true,
      confidence: confidence,
    );
  }
}
