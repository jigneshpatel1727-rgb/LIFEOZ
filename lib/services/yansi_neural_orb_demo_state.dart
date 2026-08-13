import 'yansi_neural_orb_motion.dart';

/// Provides a neutral initial state for the visual orb integration.
/// It is intentionally inert until real Yansi intelligence supplies a signal.
class YansiNeuralOrbDemoState {
  const YansiNeuralOrbDemoState();

  YansiNeuralOrbMotion get initialMotion =>
      YansiNeuralOrbMotion.fromSignal(visible: false, confidence: 0);
}
