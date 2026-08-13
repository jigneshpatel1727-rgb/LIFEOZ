/// Pure presentation model for Yansi's futuristic neural/orb motion.
/// No LifeOS data or action execution is accessed here.
class YansiNeuralOrbMotion {
  final double pulseScale;
  final double glowIntensity;
  final bool breathe;
  final bool rotate;
  final int priority;

  const YansiNeuralOrbMotion({
    required this.pulseScale,
    required this.glowIntensity,
    required this.breathe,
    required this.rotate,
    required this.priority,
  });

  factory YansiNeuralOrbMotion.fromSignal({
    required bool visible,
    required int confidence,
  }) {
    if (!visible) {
      return const YansiNeuralOrbMotion(
        pulseScale: 1.0,
        glowIntensity: 0.0,
        breathe: false,
        rotate: false,
        priority: 0,
      );
    }

    final score = confidence.clamp(0, 100).toInt();
    return YansiNeuralOrbMotion(
      pulseScale: 1.0 + (score / 1000.0),
      glowIntensity: score / 100.0,
      breathe: true,
      rotate: score >= 70,
      priority: score,
    );
  }
}
