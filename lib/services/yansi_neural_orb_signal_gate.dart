import 'yansi_neural_orb_motion.dart';

/// Converts trusted Yansi presentation signals into an inert visual motion
/// model. It never invokes speech, actions, storage, or network operations.
class YansiNeuralOrbSignalGate {
  const YansiNeuralOrbSignalGate();

  YansiNeuralOrbMotion gate({
    required bool visible,
    required int confidence,
    bool confirmationRequired = false,
  }) {
    final score = confidence.clamp(0, 100).toInt();
    if (!visible || score < 60) {
      return YansiNeuralOrbMotion.fromSignal(visible: false, confidence: 0);
    }

    // A confirmation-required signal may still be visualized, but never
    // becomes an automatic execution/speaking trigger through this layer.
    final visualScore = confirmationRequired && score > 85 ? 85 : score;
    return YansiNeuralOrbMotion.fromSignal(
      visible: true,
      confidence: visualScore,
    );
  }
}
