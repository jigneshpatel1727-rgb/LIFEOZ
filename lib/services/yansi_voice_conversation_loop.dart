import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'yansi_conversation_bridge.dart';
import 'yansi_ambient_voice_service.dart';

/// Voice -> Yansi -> voice loop. UI remains responsible for showing only a
/// compact ambient state; this service owns the conversation pipeline.
class YansiVoiceConversationLoop {
  final stt.SpeechToText speech;
  final YansiConversationBridge bridge;
  final YansiAmbientVoiceService voice;

  bool _ready = false;
  bool _listening = false;

  YansiVoiceConversationLoop({
    required this.bridge,
    required this.voice,
    stt.SpeechToText? speech,
  }) : speech = speech ?? stt.SpeechToText();

  bool get isListening => _listening;
  bool get isReady => _ready;

  Future<bool> initialize() async {
    _ready = await speech.initialize(
      onStatus: (status) {
        _listening = status == 'listening';
      },
      onError: (_) {
        _listening = false;
      },
    );
    return _ready;
  }

  Future<void> start({
    Map<String, dynamic>? lifeosContext,
    String? accessToken,
    String localeId = 'en_IN',
    void Function(String text)? onPartialText,
    void Function(String text)? onFinalText,
  }) async {
    if (!_ready && !await initialize()) return;
    if (_listening) return;

    await speech.listen(
      localeId: localeId,
      partialResults: true,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) async {
        if (result.recognizedWords.trim().isEmpty) return;
        if (!result.finalResult) {
          onPartialText?.call(result.recognizedWords);
          return;
        }

        final text = result.recognizedWords.trim();
        onFinalText?.call(text);
        await speech.stop();
        _listening = false;

        final response = await bridge.ask(
          text: text,
          lifeosContext: lifeosContext,
          accessToken: accessToken,
        );
        await voice.speak(response.answer);
      },
    );
    _listening = true;
  }

  Future<void> stop() async {
    await speech.stop();
    _listening = false;
  }

  Future<void> cancel() async {
    await speech.cancel();
    _listening = false;
  }

  Future<void> dispose() async {
    await speech.cancel();
    await voice.stop();
    _listening = false;
  }
}
