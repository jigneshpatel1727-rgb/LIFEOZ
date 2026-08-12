import 'package:flutter_tts/flutter_tts.dart';

class YansiVoice {
  final FlutterTts _tts = FlutterTts();

  bool _ready = false;

  Future<void> initialize() async {
    if (_ready) return;

    try {
      await _tts.setLanguage('en-IN');

      // Natural conversational speed.
      await _tts.setSpeechRate(0.43);

      // Slightly warm, human-like pitch.
      await _tts.setPitch(0.96);

      await _tts.setVolume(1.0);

      // Try to select a good installed English voice.
      final voices = await _tts.getVoices;

      if (voices is List) {
        Map<dynamic, dynamic>? bestVoice;

        for (final item in voices) {
          if (item is! Map) continue;

          final language =
              item['locale']?.toString().toLowerCase() ?? '';

          final name =
              item['name']?.toString().toLowerCase() ?? '';

          if (language.contains('en-in')) {
            bestVoice = item;

            // Prefer a natural/premium voice if the
            // Android TTS engine exposes one.
            if (name.contains('natural') ||
                name.contains('premium') ||
                name.contains('enhanced')) {
              break;
            }
          }
        }

        if (bestVoice != null) {
          await _tts.setVoice({
            'name': bestVoice['name'].toString(),
            'locale': bestVoice['locale'].toString(),
          });
        }
      }

      // Helps avoid overlapping speech.
      await _tts.awaitSpeakCompletion(true);

      _ready = true;
    } catch (_) {
      // Keep the default Android voice if configuration fails.
      _ready = true;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> speak(
    String text, {
    bool conversational = true,
  }) async {
    if (text.trim().isEmpty) return;

    await initialize();

    try {
      await _tts.stop();

      final naturalText =
          _makeNatural(text);

      await _tts.speak(
        naturalText,
      );
    } catch (_) {}
  }

  String _makeNatural(
    String text,
  ) {
    var value =
        text.trim();

    // Small natural pauses.
    value = value.replaceAll(
      '... ',
      '... ',
    );

    value = value.replaceAll(
      '. ',
      '.  ',
    );

    value = value.replaceAll(
      '? ',
      '?  ',
    );

    value = value.replaceAll(
      '! ',
      '!  ',
    );

    return value;
  }
}
