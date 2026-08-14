import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'services/yansi_brain.dart';

class LifeOZFutureShell extends StatefulWidget {
  final SharedPreferences prefs;

  const LifeOZFutureShell({super.key, required this.prefs});

  @override
  State<LifeOZFutureShell> createState() => _LifeOZFutureShellState();
}

class _LifeOZFutureShellState extends State<LifeOZFutureShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  late final YansiBrain _brain;

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _input = TextEditingController();

  String _name = '';
  String _country = 'India';
  String _currency = 'INR';
  String _language = 'English';
  String _design = 'neural_void';
  String _message = 'Yansi is present.';
  String _transcript = '';

  bool _onboarding = true;
  bool _listening = false;
  bool _speaking = false;
  bool _controls = false;
  int _activeCore = -1;

  static const List<_Reality> _realities = <_Reality>[
    _Reality('neural_void', 'NEURAL VOID', 'Living neural space', Color(0xFF00F0FF), Color(0xFF00FF9D)),
    _Reality('quantum_glass', 'QUANTUM GLASS', 'Transparent quantum layers', Color(0xFFB48CFF), Color(0xFF44E7FF)),
    _Reality('holo_prism', 'HOLO PRISM', 'Volumetric light geometry', Color(0xFFFF4FD8), Color(0xFF52F7FF)),
    _Reality('aurora_intelligence', 'AURORA INTELLIGENCE', 'Organic adaptive field', Color(0xFFB4FF58), Color(0xFF00E5FF)),
    _Reality('singularity', 'SINGULARITY', 'Deep-space minimalism', Color(0xFFEAF8FF), Color(0xFF4DE7FF)),
    _Reality('terra_flux', 'TERRA FLUX', 'Bio-energy life topology', Color(0xFFFFB15C), Color(0xFF58FFD2)),
  ];

  static const List<String> _coreMeanings = <String>[
    'Money, income, bills and investments.',
    'Work, tasks and execution.',
    'Calendar, renewals and commitments.',
    'Home, shopping and household.',
    'Goals, diary and personal growth.',
  ];

  _Reality get _reality => _realities.firstWhere(
        (_Reality item) => item.id == _design,
        orElse: () => _realities.first,
      );

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _brain = YansiBrain(prefs: widget.prefs);

    _name = widget.prefs.getString('user_name') ?? '';
    _country = widget.prefs.getString('user_country') ?? 'India';
    _currency = widget.prefs.getString('user_currency') ?? 'INR';
    _language = widget.prefs.getString('user_language') ?? 'English';
    _design = widget.prefs.getString('lifeoz_reality') ?? 'neural_void';
    _onboarding = widget.prefs.getBool('lifeoz_master_ready') != true;

    _tts.setSpeechRate(0.44);
    _tts.setStartHandler(() {
      if (mounted) setState(() => _speaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _speech.stop();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _process(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    await _speech.stop();
    if (mounted) setState(() => _listening = false);

    final result = await _brain.process(clean);
    if (!mounted) return;
    setState(() {
      _message = result.response;
      _transcript = '';
    });
    await _speak(result.response);
  }

  Future<void> _listen() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (String status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );

    if (!available) {
      _toast('Microphone permission is required for Yansi.');
      return;
    }

    setState(() {
      _listening = true;
      _transcript = '';
    });

    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      onResult: (result) {
        if (!mounted) return;
        setState(() => _transcript = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _process(result.recognizedWords);
        }
      },
    );
  }

  Future<void> _enter() async {
    if (_name.trim().isEmpty) {
      _toast('Enter your name so Yansi knows who she is assisting.');
      return;
    }

    await widget.prefs.setString('user_name', _name.trim());
    await widget.prefs.setString('user_country', _country);
    await widget.prefs.setString('user_currency', _currency);
    await widget.prefs.setString('user_language', _language);
    await widget.prefs.setString('lifeoz_reality', _design);
    await widget.prefs.setBool('lifeoz_master_ready', true);

    if (!mounted) return;
    setState(() => _onboarding = false);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _speak(
      'Welcome, $_name. I am Yansi. Your life is now connected. Tell me what you need.',
    );
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _chooseReality(String id) {
    setState(() => _design = id);
    widget.prefs.setString('lifeoz_reality', id);
  }

  @override
  void dispose() {
    _motion.dispose();
    _tts.stop();
    _speech.stop();
    _input.dispose();
    super.dispose();
  }
}