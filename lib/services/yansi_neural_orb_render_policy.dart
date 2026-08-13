/// Keeps Yansi's futuristic orb visually rich without making it intrusive.
/// Presentation-only; it cannot execute actions or mutate LifeOS data.
class YansiNeuralOrbRenderPolicy {
  const YansiNeuralOrbRenderPolicy();

  Map<String, dynamic> render({required bool visible, required int intensity}) {
    final score = intensity.clamp(0, 100).toInt();
    if (!visible || score < 60) {
      return const {
        'visible': false,
        'opacity': 0.0,
        'scale': 1.0,
        'motion': 'idle',
      };
    }

    return {
      'visible': true,
      'opacity': 0.55 + (score / 100) * 0.45,
      'scale': 1.0 + (score / 1000),
      'motion': score >= 85 ? 'active' : 'breathe',
    };
  }
}
