import 'package:flutter/material.dart';

/// Lightweight visual presence for Yansi. It is intentionally an ambient
/// component rather than a chatbot panel: it can listen, react and disappear.
class YansiAmbientPresence extends StatefulWidget {
  final bool listening;
  final bool thinking;
  final bool speaking;
  final VoidCallback? onTap;
  final double size;

  const YansiAmbientPresence({
    super.key,
    this.listening = false,
    this.thinking = false,
    this.speaking = false,
    this.onTap,
    this.size = 72,
  });

  @override
  State<YansiAmbientPresence> createState() => _YansiAmbientPresenceState();
}

class _YansiAmbientPresenceState extends State<YansiAmbientPresence>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.listening || widget.thinking || widget.speaking;
    return Semantics(
      label: 'Yansi ambient assistant',
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final pulse = active ? 1 + (_controller.value * .08) : 1.0;
            return Transform.scale(
              scale: pulse,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFB9FFFF), Color(0xFF00E5FF), Color(0xFF006A78)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: active ? .55 : .25),
                      blurRadius: active ? 26 : 16,
                      spreadRadius: active ? 4 : 1,
                    ),
                  ],
                ),
                child: Icon(
                  widget.listening
                      ? Icons.graphic_eq_rounded
                      : widget.thinking
                          ? Icons.auto_awesome_rounded
                          : widget.speaking
                              ? Icons.volume_up_rounded
                              : Icons.circle,
                  color: const Color(0xFF001116),
                  size: widget.size * .38,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
