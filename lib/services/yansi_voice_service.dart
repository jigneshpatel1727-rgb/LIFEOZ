import 'package:flutter_tts/flutter_tts.dart';

/// Ambient voice output for Yansi.
/// Keeps speech separate from the intelligence layer so Yansi can speak
/// without turning the UI into a chatbot screen.
class YansiVoiceService {
  final FlutterTts _tts;
  bool _ready = false;

  YansiVoiceService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  Future<void> initialize({String? language}) async {
    if (language != null && language.trim().isNotEmpty) {
      await _tts.setLanguage(language);
    } else {
      await _tts.setLanguage('en-IN');
    }
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _ready = true;
  }

  Future<void> speak(String text) async {
    final message = text.trim();
    if (message.isEmpty) return;
    if (!_ready) await initialize();
    await _tts.stop();
    await _tts.speak(message);
  }

  Future<void> stop() => _tts.stop();

  Future<void> dispose() async {
    await _tts.stop();
  }
}
