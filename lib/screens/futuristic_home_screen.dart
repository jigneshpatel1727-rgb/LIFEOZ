import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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

  final stt.SpeechToText _speech = stt.SpeechToText();
  final YansiVoice _yansiVoice = YansiVoice();

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
    _yansiVoice.stop();
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

    await _yansiVoice.speak(message);
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

    final available =
        await _speech.initialize();

    if (!available) {
      await _yansiVoice.speak(
        'Voice recognition is not available on this device.',
      );
      return;
    }

    await _yansiVoice.stop();

    if (!mounted) return;

    setState(() {
      _listening = true;
      _heardText = '';
    });

    await _speech.listen(
      localeId: 'en_IN',
      listenMode:
          stt.ListenMode.confirmation,
      partialResults: true,
      onResult: (result) async {
        if (!mounted) return;

        setState(() {
          _heardText =
              result.recognizedWords;
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
  // YANSI BRAIN + ACTIONS
  // ==========================================================

  Future<void> _processVoiceCommand(
    String text,
  ) async {
    final value = text.trim();

    if (value.isEmpty) return;

    if (YansiActions.isScanRequest(value)) {
      await _yansiVoice.speak(
        'Of course. Show me the bill and I will read it for you.',
      );

      if (!mounted) return;

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      await YansiActions.openBillScanner(
        context,
      );

      return;
    }

    try {
      final brain = YansiBrain(
        prefs: widget.prefs,
      );

      final result =
          await brain.process(value);

      if (!mounted) return;

      setState(() {
        _heardText = value;
      });

      await _yansiVoice.stop();

      await _yansiVoice.speak(
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
      await _yansiVoice.speak(
        'I understood you, but I could not save that yet.',
      );
    }
  }

  // ==========================================================
  // CORE ROUTER
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

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
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
                      _yansiVoice.speak(
                        'There are no new important notifications.',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 82,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  widget.userName.isEmpty
                      ? 'WELCOME'
                      : widget.userName
                          .toUpperCase(),
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
                    color: colors.muted,
                    fontSize: 10,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top:
                MediaQuery.of(context)
                        .size
                        .height *
                    .22,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap:
                    _toggleListening,
                child: AnimatedBuilder(
                  animation: _animation,
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

          Positioned.fill(
            top:
                MediaQuery.of(context)
                        .size
                        .height *
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
          MediaQuery.of(context)
                  .size
                  .width *
              left,
      top:
          MediaQuery.of(context)
                  .size
                  .height *
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
            shape: BoxShape.circle,
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
  // TOP ICON
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
          shape: BoxShape.circle,
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
                        color: selected
                            ? colors.primary
                            : colors.muted,
                      ),
                      const SizedBox(
                        width
