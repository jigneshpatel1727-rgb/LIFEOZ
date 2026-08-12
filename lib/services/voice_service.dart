import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText speech =
      SpeechToText();

  final FlutterTts tts =
      FlutterTts();

  Future<bool> initialize() async {
    return await speech.initialize();
  }

  Future<void> speak(
    String text,
  ) async {
    await tts.setLanguage(
      'en-IN',
    );

    await tts.setSpeechRate(
      0.48,
    );

    await tts.speak(text);
  }

  Future<String?> listen() async {
    final available =
        await speech.initialize();

    if (!available) {
      return null;
    }

    String result = '';

    await speech.listen(
      onResult: (value) {
        result =
            value.recognizedWords;
      },
    );

    await Future.delayed(
      const Duration(seconds: 5),
    );

    await speech.stop();

    return result.isEmpty
        ? null
        : result;
  }

  Future<void> stop() async {
    await speech.stop();
  }

  Future<void> dispose() async {
    await speech.stop();
    await tts.stop();
  }
}
