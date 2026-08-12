import 'package:flutter_tts/flutter_tts.dart';

/// Lightweight ambient TTS surface for Yansi.
/// Keeps voice configuration out of the conversation loop and reuses the
/// existing Flutter TTS dependency. It never records audio by itself.
class YansiAmbientVoiceService {
  final FlutterTts _tts;
  bool _initialized = false;

  YansiAmbientVoiceService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  bool get isInitialized => _initialized;

  Future<void> initialize({String language = 'en-IN'}) async {
    if (_initialized) return;
    try {
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(0.43);
      await _tts.setPitch(0.96);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
    } finally {
      _initialized = true;
    }
  }

  Future<void> speak(String text) async {
    final value = text.trim();
    if (value.isEmpty) return;

    await initialize();
    try {
      await _tts.stop();
      await _tts.speak(value);
    } catch (_) {
      // Voice failure must not crash the LifeOS conversation layer.
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
