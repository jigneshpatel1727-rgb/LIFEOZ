import 'package:flutter/material.dart';

import '../services/yansi_neural_orb_motion.dart';
import '../services/yansi_neural_orb_render_policy.dart';

/// Futuristic Yansi orb widget.
/// Presentation-only: it does not read or mutate LifeOS data.
class YansiNeuralOrb extends StatelessWidget {
  final YansiNeuralOrbMotion motion;
  const YansiNeuralOrb({super.key, required this.motion});

  @override
  Widget build(BuildContext context) {
    final policy = const YansiNeuralOrbRenderPolicy().render(
      visible: motion.glowIntensity > 0,
      intensity: motion.priority,
    );

    if (policy['visible'] != true) return const SizedBox.shrink();

    final opacity = (policy['opacity'] as num).toDouble();
    final scale = (policy['scale'] as num).toDouble();
    final active = policy['motion'] == 'active';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: scale),
      duration: Duration(milliseconds: active ? 420 : 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 122,
          height: 122,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF8DFFFF).withOpacity(.30),
                const Color(0xFF00E5FF).withOpacity(.12),
                Colors.transparent,
              ],
            ),
            border: Border.all(
              color: const Color(0xFF00E5FF).withOpacity(.34),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(.18),
                blurRadius: active ? 42 : 30,
                spreadRadius: active ? 2 : 0,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 38,
              color: Color(0xFFBFFFFF),
            ),
          ),
        ),
      ),
    );
  }
}
