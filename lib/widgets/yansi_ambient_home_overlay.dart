import 'package:flutter/material.dart';
import '../services/yansi_ambient_ui.dart';

/// Drop-in ambient layer for the LifeOS home screen.
/// It adds the futuristic presence without adding a chatbot panel.
class YansiAmbientHomeOverlay extends StatelessWidget {
  final Animation<double> animation;
  final bool listening;
  final VoidCallback onTap;

  const YansiAmbientHomeOverlay({
    super.key,
    required this.animation,
    required this.onTap,
    this.listening = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = listening ? YansiAmbientUi.green : YansiAmbientUi.cyan;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: YansiAmbientPulse(
          animation: animation,
          color: accent,
          size: listening ? 94 : 82,
        ),
      ),
    );
  }
}
