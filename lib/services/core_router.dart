import 'package:flutter/material.dart';
import '../models/lifeos_core.dart';
import '../screens/futuristic_core_surface.dart';

/// Unified routing boundary for the five permanent LifeOS cores.
/// Every core enters the same futuristic LifeOS environment.
class CoreRouter {
  static void open(BuildContext context, int core, String currency) {
    final definition = coreByIndex(core);
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => FuturisticCoreSurface(
          core: definition.index,
          currency: currency,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }
}
