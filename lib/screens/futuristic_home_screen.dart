import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/yansi_brain.dart';
import '../services/core_router.dart';
import '../services/yansi_actions.dart';
import '../services/yansi_voice.dart';
class FuturisticHomeScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final String userName;
  final String country;
  final String currency;
  final int themeIndex;
  final Future<void> Function(int index) onThemeChanged;

  const FuturisticHomeScreen({
    super.key,
    required this.prefs,
    required this.userName,
    required this.country,
    required this.currency,
    required this.themeIndex,
    required this.onThemeChanged,
  });

  @override
  State<FuturisticHomeScreen> createState() =>
      _FuturisticHomeScreenState();
}

class _FuturisticHomeScreenState
    extends State<FuturisticHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animation;

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _listening = false;
  bool _menuOpen = false;
  bool _welcomeDone = false;

  String _heardText = '';

  late int _themeIndex;

  @override
  void initState() {
    super.initState();

    _themeIndex = widget.themeIndex;

    _animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _welcomeYansi();
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  // ==========================================================
  // YANSI WELCOME
  // ==========================================================

  Future<void> _welcomeYansi() async {
    if (_welcomeDone) return;

    _welcomeDone = true;

    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    final name = widget.userName.trim();

    final message = name.isEmpty
        ? 'Welcome. I am Yansi, your personal LifeOS AI friend. How can I help you?'
        : 'Welcome, $name. I am Yansi, your personal LifeOS AI friend. How can I help you?';

    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.speak(message);
    } catch (_) {}
  }

  // ==========================================================
  // VOICE
  // ==========================================================

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();

      if (mounted) {
        setState(() {
          _listening = false;
        });
      }

      return;
    }

    final available = await _speech.initialize();

    if (!available) {
      await _tts.speak(
        'Voice recognition is not available on this device.',
      );
      return;
    }

    await _tts.stop();

    if (!mounted) return;

    setState(() {
      _listening = true;
      _heardText = '';
    });

    await _speech.listen(
      localeId: 'en_IN',
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      onResult: (result) async {
        if (!mounted) return;

        setState(() {
          _heardText = result.recognizedWords;
        });

        if (result.finalResult) {
          setState(() {
            _listening = false;
          });

          await _speech.stop();

          await _processVoiceCommand(
            result.recognizedWords,
          );
        }
      },
    );
  }

  // ==========================================================
  // YANSI BRAIN
  // ==========================================================

  Future<void> _processVoiceCommand(
    String text,
  ) async {
    final value = text.trim();

    if (value.isEmpty) return;

    try {
      final brain = YansiBrain(
        prefs: widget.prefs,
      );

      final result = await brain.process(
        value,
      );

      if (!mounted) return;

      setState(() {
        _heardText = value;
      });

      await _tts.stop();

      await _tts.speak(
        result.response,
      );

      await widget.prefs.setString(
        'last_yansi_voice_text',
        value,
      );

      await widget.prefs.setString(
        'last_yansi_response',
        result.response,
      );
    } catch (_) {
      await _tts.speak(
        'I understood you, but I could not save that yet.',
      );
    }
  }

  // ==========================================================
  // FIVE CORE ROUTER
  // ==========================================================

  void _openCore(
    BuildContext context,
    int core,
  ) {
    CoreRouter.open(
      context,
      core,
      widget.currency,
    );
  }

  // ==========================================================
  // CONTROL CENTER
  // ==========================================================

  void _openControlCenter() {
    setState(() {
      _menuOpen = !_menuOpen;
    });
  }

  Future<void> _changeTheme(
    int index,
  ) async {
    setState(() {
      _themeIndex = index;
      _menuOpen = false;
    });

    await widget.onThemeChanged(index);
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final colors =
        _themeColors(_themeIndex);

    return Scaffold(
      backgroundColor:
          colors.background,

      body: Stack(
        children: [
          // ----------------------------------------------------
          // FUTURISTIC BACKGROUND
          // ----------------------------------------------------

          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (
                context,
                child,
              ) {
                return CustomPaint(
                  painter:
                      _NeuralPainter(
                    progress:
                        _animation.value,
                    primary:
                        colors.primary,
                    secondary:
                        colors.secondary,
                  ),
                );
              },
            ),
          ),

          // ----------------------------------------------------
          // TOP BAR
          // ----------------------------------------------------

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _glassIcon(
                    Icons.menu_rounded,
                    colors,
                    _openControlCenter,
                  ),
                  _glassIcon(
                    Icons.notifications_none_rounded,
                    colors,
                    () {
                      _tts.speak(
                        'There are no new important notifications.',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ----------------------------------------------------
          // GREETING
          // ----------------------------------------------------

          Positioned(
            top: 82,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  widget.userName.isEmpty
                      ? 'WELCOME'
                      : widget.userName.toUpperCase(),
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13,
                    letterSpacing: 3,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  'LifeOS',
                  style: TextStyle(
                    color:
                        colors.muted,
                    fontSize: 10,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),

          // ----------------------------------------------------
          // YANSI
          // ----------------------------------------------------

          Positioned(
            top:
                MediaQuery.of(context).size.height *
                    .22,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap:
                    _toggleListening,
                child: AnimatedBuilder(
                  animation:
                      _animation,
                  builder: (
                    context,
                    child,
                  ) {
                    return _YansiFace(
                      progress:
                          _animation.value,
                      listening:
                          _listening,
                      primary:
                          colors.primary,
                      secondary:
                          colors.secondary,
                    );
                  },
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // FIVE CORE ICONS
          // ----------------------------------------------------

          Positioned.fill(
            top:
                MediaQuery.of(context).size.height *
                    .47,
            bottom: 90,
            child: Stack(
              children: [
                _core(
                  context,
                  0,
                  Icons.account_balance_wallet_outlined,
                  0.12,
                  0.02,
                  colors,
                ),

                _core(
                  context,
                  1,
                  Icons.auto_awesome_outlined,
                  0.68,
                  0.02,
                  colors,
                ),

                _core(
                  context,
                  2,
                  Icons.bolt_outlined,
                  0.04,
                  0.43,
                  colors,
                ),

                _core(
                  context,
                  3,
                  Icons.home_work_outlined,
                  0.76,
                  0.43,
                  colors,
                ),

                _core(
                  context,
                  4,
                  Icons.timeline_rounded,
                  0.43,
                  0.70,
                  colors,
                ),
              ],
            ),
          ),

          // ----------------------------------------------------
          // VOICE TEXT
          // ----------------------------------------------------

          if (_heardText.isNotEmpty)
            Positioned(
              left: 35,
              right: 35,
              bottom: 55,
              child: Text(
                _heardText,
                textAlign:
                    TextAlign.center,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      colors.primary,
                  fontSize: 12,
                ),
              ),
            ),

          // ----------------------------------------------------
          // CONTROL CENTER
          // ----------------------------------------------------

          if (_menuOpen)
            Positioned(
              top: 66,
              left: 12,
              child:
                  _controlPanel(colors),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // CORE BUTTON
  // ==========================================================

  Widget _core(
    BuildContext context,
    int index,
    IconData icon,
    double left,
    double top,
    _ThemeColors colors,
  ) {
    return Positioned(
      left:
          MediaQuery.of(context).size.width *
              left,

      top:
          MediaQuery.of(context).size.height *
              top,

      child: GestureDetector(
        onTap: () {
          _openCore(
            context,
            index,
          );
        },

        child: Container(
          width: 64,
          height: 64,

          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,

            color:
                colors.background
                    .withOpacity(.75),

            border:
                Border.all(
              color:
                  colors.primary
                      .withOpacity(.55),
              width: 1,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    colors.primary
                        .withOpacity(.15),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),

          child: Icon(
            icon,
            size: 25,
            color:
                colors.primary,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // GLASS ICON
  // ==========================================================

  Widget _glassIcon(
    IconData icon,
    _ThemeColors colors,
    VoidCallback action,
  ) {
    return GestureDetector(
      onTap: action,

      child: Container(
        width: 40,
        height: 40,

        decoration:
            BoxDecoration(
          shape:
              BoxShape.circle,

          color:
              colors.text
                  .withOpacity(.035),

          border:
              Border.all(
            color:
                colors.text
                    .withOpacity(.10),
          ),
        ),

        child: Icon(
          icon,
          size: 19,
          color:
              colors.text
                  .withOpacity(.75),
        ),
      ),
    );
  }

  // ==========================================================
  // CONTROL PANEL
  // ==========================================================

  Widget _controlPanel(
    _ThemeColors colors,
  ) {
    return Container(
      width: 225,

      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color:
            colors.background
                .withOpacity(.96),

        borderRadius:
            BorderRadius.circular(22),

        border:
            Border.all(
          color:
              colors.primary
                  .withOpacity(.25),
        ),

        boxShadow: [
          BoxShadow(
            color:
                colors.primary
                    .withOpacity(.12),
            blurRadius: 30,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            'CONTROL CENTER',
            style: TextStyle(
              color:
                  colors.primary,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            widget.userName,
            style: TextStyle(
              color:
                  colors.text,
              fontSize: 16,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            '${widget.country} • ${widget.currency}',
            style: TextStyle(
              color:
                  colors.muted,
              fontSize: 11,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            'DESIGN',
            style: TextStyle(
              color:
                  colors.muted,
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          ...List.generate(
            5,
            (index) {
              final selected =
                  index == _themeIndex;

              return GestureDetector(
                onTap: () =>
                    _changeTheme(index),

                child: Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 6,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),

                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                    color: selected
                        ? colors.primary
                            .withOpacity(.10)
                        : Colors.transparent,
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color:
                            selected
                                ? colors.primary
                                : colors.muted,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        _designName(index),
                        style:
                            TextStyle(
                          color:
                              selected
                                  ? colors.primary
                                  : colors.text,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _designName(
    int index,
  ) {
    const names = [
      'Aurora Nexus',
      'Void Matrix',
      'Quantum Purple',
      'Solaris Prime',
      'Frost Minimal',
    ];

    return names[index];
  }

  // ==========================================================
  // COLORS
  // ==========================================================

  _ThemeColors _themeColors(
    int index,
  ) {
    const themes = [
      _ThemeColors(
        background:
            Color(0xFF020B0B),
        primary:
            Color(0xFF00FFD5),
        secondary:
            Color(0xFF35FF72),
        text:
            Color(0xFFE9FFFF),
        muted:
            Color(0xFF83AAA7),
      ),

      _ThemeColors(
        background:
            Color(0xFF020611),
        primary:
            Color(0xFF168CFF),
        secondary:
            Color(0xFF52C7FF),
        text:
            Color(0xFFEAF5FF),
        muted:
            Color(0xFF7690A8),
      ),

      _ThemeColors(
        background:
            Color(0xFF0A0310),
        primary:
            Color(0xFFD24CFF),
        secondary:
            Color(0xFFFF54C8),
        text:
            Color(0xFFFFEEFF),
        muted:
            Color(0xFFA98EAE),
      ),

      _ThemeColors(
        background:
            Color(0xFF0B0802),
        primary:
            Color(0xFFFFC928),
        secondary:
            Color(0xFFFF8A00),
        text:
            Color(0xFFFFF7D9),
        muted:
            Color(0xFFAA9866),
      ),

      _ThemeColors(
        background:
            Color(0xFFF4FAFF),
        primary:
            Color(0xFF147BFF),
        secondary:
            Color(0xFF5AC8FF),
        text:
            Color(0xFF08244A),
        muted:
            Color(0xFF68819B),
      ),
    ];

    return themes[
        index.clamp(
      0,
      themes.length - 1,
    )];
  }
}

// ============================================================
// THEME COLORS
// ============================================================

class _ThemeColors {
  final Color background;
  final Color primary;
  final Color secondary;
  final Color text;
  final Color muted;

  const _ThemeColors({
    required this.background,
    required this.primary,
    required this.secondary,
    required this.text,
    required this.muted,
  });
}

// ============================================================
// YANSI FACE
// ============================================================

class _YansiFace
    extends StatelessWidget {
  final double progress;
  final bool listening;
  final Color primary;
  final Color secondary;

  const _YansiFace({
    required this.progress,
    required this.listening,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final rotation =
        progress *
        math.pi *
        2;

    return SizedBox(
      width: 190,
      height: 190,

      child: Stack(
        alignment:
            Alignment.center,

        children: [
          Transform.rotate(
            angle: rotation,

            child: Container(
              width: 184,
              height: 184,

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                border:
                    Border.all(
                  color:
                      primary.withOpacity(
                    .14,
                  ),
                ),
              ),
            ),
          ),

          Container(
            width: 160,
            height: 160,

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color:
                      primary.withOpacity(
                    listening
                        ? .35
                        : .18,
                  ),

                  blurRadius:
                      listening
                          ? 55
                          : 38,

                  spreadRadius:
                      listening
                          ? 8
                          : 3,
                ),
              ],
            ),
          ),

          Container(
            width: 128,
            height: 128,

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              gradient:
                  RadialGradient(
                colors: [
                  primary
                      .withOpacity(.30),
                  const Color(
                      0xFF071218),
                  const Color(
                      0xFF02070B),
                ],
              ),

              border:
                  Border.all(
                color:
                    primary.withOpacity(
                  listening
                      ? .85
                      : .48,
                ),

                width:
                    listening
                        ? 1.7
                        : 1,
              ),
            ),

            child:
                CustomPaint(
              painter:
                  _FacePainter(
                primary:
                    primary,
                secondary:
                    secondary,
                listening:
                    listening,
              ),
            ),
          ),

          if (listening)
            Positioned(
              bottom: 4,

              child: Text(
                'LISTENING',
                style:
                    TextStyle(
                  color:
                      primary,
                  fontSize: 8,
                  letterSpacing: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// FACE PAINTER
// ============================================================

class _FacePainter
    extends CustomPainter {
  final Color primary;
  final Color secondary;
  final bool listening;

  _FacePainter({
    required this.primary,
    required this.secondary,
    required this.listening,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center =
        Offset(
      size.width / 2,
      size.height / 2,
    );

    final paint =
        Paint()
          ..style =
              PaintingStyle.fill;

    paint.color =
        primary.withOpacity(.12);

    canvas.drawCircle(
      center,
      43,
      paint,
    );

    paint.color =
        primary;

    canvas.drawCircle(
      Offset(
        center.dx - 20,
        center.dy - 8,
      ),
      listening ? 6 : 4,
      paint,
    );

    canvas.drawCircle(
      Offset(
        center.dx + 20,
        center.dy - 8,
      ),
      listening ? 6 : 4,
      paint,
    );

    final mouth =
        Paint()
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap =
              StrokeCap.round
          ..color =
              secondary.withOpacity(.8);

    final path =
        Path();

    path.moveTo(
      center.dx - 18,
      center.dy + 20,
    );

    path.quadraticBezierTo(
      center.dx,
      center.dy + 29,
      center.dx + 18,
      center.dy + 20,
    );

    canvas.drawPath(
      path,
      mouth,
    );

    final outline =
        Paint()
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 1
          ..color =
              primary.withOpacity(.18);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: 78,
        height: 94,
      ),
      outline,
    );
  }

  @override
  bool shouldRepaint(
    covariant _FacePainter oldDelegate,
  ) {
    return oldDelegate.listening !=
            listening ||
        oldDelegate.primary !=
            primary;
  }
}

// ============================================================
// NEURAL BACKGROUND
// ============================================================

class _NeuralPainter
    extends CustomPainter {
  final double progress;
  final Color primary;
  final Color secondary;

  _NeuralPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final bg =
        Paint()
          ..color =
              const Color(
        0xFF02070B,
      );

    canvas.drawRect(
      Offset.zero & size,
      bg,
    );

    final glow =
        Paint()
          ..shader =
              RadialGradient(
            colors: [
              primary.withOpacity(.16),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center:
                  Offset(
                size.width / 2,
                size.height * .37,
              ),
              radius:
                  size.width * .65,
            ),
          );

    canvas.drawCircle(
      Offset(
        size.width / 2,
        size.height * .37,
      ),
      size.width * .65,
      glow,
    );

    final nodes = <Offset>[
      Offset(
        size.width * .08,
        size.height * .20,
      ),
      Offset(
        size.width * .24,
        size.height * .12,
      ),
      Offset(
        size.width * .82,
        size.height * .18,
      ),
      Offset(
        size.width * .92,
        size.height * .42,
      ),
      Offset(
        size.width * .10,
        size.height * .54,
      ),
      Offset(
        size.width * .30,
        size.height * .78,
      ),
      Offset(
        size.width * .73,
        size.height * .76,
      ),
      Offset(
        size.width * .88,
        size.height * .62,
      ),
    ];

    final lines =
        Paint()
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = .6
          ..color =
              primary.withOpacity(.07);

    for (int i = 0;
        i < nodes.length;
        i++) {
      for (int j = i + 1;
          j < nodes.length;
          j++) {
        if ((nodes[i] - nodes[j])
                .distance <
            size.width * .45) {
          canvas.drawLine(
            nodes[i],
            nodes[j],
            lines,
          );
        }
      }
    }

    final dots =
        Paint()
          ..color =
              secondary.withOpacity(.28);

    for (final node in nodes) {
      canvas.drawCircle(
        node,
        1.8,
        dots,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _NeuralPainter oldDelegate,
  ) {
    return true;
  }
}
