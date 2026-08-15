import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'lifeoz_design_home.dart';
import 'services/yansi_brain.dart';

class YansiVoiceIntegratedHome extends StatefulWidget {
  final SharedPreferences prefs;
  const YansiVoiceIntegratedHome({super.key, required this.prefs});

  @override
  State<YansiVoiceIntegratedHome> createState() => _YansiVoiceIntegratedHomeState();
}

class _YansiVoiceIntegratedHomeState extends State<YansiVoiceIntegratedHome> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool listening = false;
  bool processing = false;
  String transcript = '';

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

  Future<void> listen() async {
    if (processing) return;
    if (listening) {
      await _speech.stop();
      if (mounted) setState(() => listening = false);
      return;
    }

    final ok = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && mounted) setState(() => listening = false);
      },
      onError: (_) {
        if (mounted) setState(() => listening = false);
      },
    );

    if (!ok) {
      await say('Please allow microphone access for Yansi.');
      return;
    }

    if (mounted) {
      setState(() {
        listening = true;
        transcript = '';
      });
    }

    await _speech.listen(
      localeId: widget.prefs.getString('yansi_locale') ?? 'en_IN',
      listenMode: stt.ListenMode.dictation,
      onResult: (result) async {
        if (mounted) setState(() => transcript = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          await _speech.stop();
          if (mounted) setState(() => listening = false);
          await process(result.recognizedWords);
        }
      },
    );
  }

  Future<void> process(String text) async {
    if (mounted) setState(() => processing = true);
    try {
      final result = await YansiBrain(prefs: widget.prefs).process(text);
      await say(result.response);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.response), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {
      await say('I could not save that. Please try again.');
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  Future<void> say(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LifeOZDesignHome(prefs: widget.prefs),
        if (listening && transcript.isNotEmpty)
          Positioned(
            left: 26,
            right: 26,
            bottom: 92,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFF06111D).withOpacity(.94),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF42E1FF).withOpacity(.35)),
                ),
                child: Text(
                  transcript,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        Positioned(
          right: 20,
          bottom: 28,
          child: GestureDetector(
            onTap: listen,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: listening ? const Color(0xFFFF5F68) : const Color(0xFF071D2A),
                border: Border.all(
                  color: listening ? Colors.white70 : const Color(0xFF42E1FF).withOpacity(.75),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (listening ? const Color(0xFFFF5F68) : const Color(0xFF42E1FF)).withOpacity(.4),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                processing
                    ? Icons.hourglass_top_rounded
                    : listening
                        ? Icons.stop_rounded
                        : Icons.mic_none_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
