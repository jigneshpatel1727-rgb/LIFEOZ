import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'lifeoz_final_home.dart';
import 'services/yansi_brain.dart';

class YansiVoiceHome extends StatefulWidget {
  final SharedPreferences prefs;
  const YansiVoiceHome({super.key, required this.prefs});

  @override
  State<YansiVoiceHome> createState() => _YansiVoiceHomeState();
}

class _YansiVoiceHomeState extends State<YansiVoiceHome> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _listening = false;
  bool _busy = false;
  String _heard = '';

  @override
  void initState() {
    super.initState();
    _tts.setSpeechRate(.44);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_busy) return;
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && mounted) setState(() => _listening = false);
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!available) {
      await _say('Microphone access is not available yet. Please check permissions.');
      return;
    }

    if (mounted) setState(() { _listening = true; _heard = ''; });
    await _speech.listen(
      localeId: widget.prefs.getString('yansi_locale') ?? 'en_IN',
      listenMode: stt.ListenMode.dictation,
      onResult: (result) async {
        if (mounted) setState(() => _heard = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          await _speech.stop();
          if (mounted) setState(() => _listening = false);
          await _process(result.recognizedWords);
        }
      },
    );
  }

  Future<void> _process(String text) async {
    if (mounted) setState(() => _busy = true);
    try {
      final brain = YansiBrain(prefs: widget.prefs);
      final result = await brain.process(text);
      await _say(result.response);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.response), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {
      await _say('I could not save that yet. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _say(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LifeOZFinalHome(prefs: widget.prefs),
        if (_heard.isNotEmpty && _listening)
          Positioned(
            left: 28,
            right: 28,
            bottom: 92,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF06111D).withOpacity(.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF42E1FF).withOpacity(.35)),
                ),
                child: Text(_heard, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
          ),
        Positioned(
          right: 22,
          bottom: 34,
          child: GestureDetector(
            onTap: _toggleListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _listening ? const Color(0xFFFF5F68) : const Color(0xFF0A2231),
                boxShadow: [BoxShadow(color: (_listening ? const Color(0xFFFF5F68) : const Color(0xFF42E1FF)).withOpacity(.45), blurRadius: 22, spreadRadius: 3)],
                border: Border.all(color: _listening ? Colors.white70 : const Color(0xFF42E1FF).withOpacity(.7)),
              ),
              child: Icon(_busy ? Icons.hourglass_top_rounded : (_listening ? Icons.stop_rounded : Icons.mic_none_rounded), color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}
