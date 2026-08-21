import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'iamyansi_action_engine.dart';

/// Bridges microphone transcription, Yansi action parsing and concise speech.
/// The controller is intentionally UI-agnostic so the orb can remain ambient.
class IamyansiVoiceController {
  final SharedPreferences prefs;
  final stt.SpeechToText speech;
  final FlutterTts tts;
  late final IamyansiActionEngine engine;

  bool _available = false;
  bool _busy = false;

  IamyansiVoiceController({
    required this.prefs,
    stt.SpeechToText? speech,
    FlutterTts? tts,
  })  : speech = speech ?? stt.SpeechToText(),
        tts = tts ?? FlutterTts() {
    engine = IamyansiActionEngine(prefs: prefs);
  }

  bool get isListening => speech.isListening;
  bool get isAvailable => _available;

  Future<bool> initialize() async {
    _available = await speech.initialize(
      onError: (_) => _busy = false,
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') _busy = false;
      },
    );
    await tts.setSpeechRate(.48);
    await tts.setPitch(1.0);
    return _available;
  }

  Future<void> startListening({void Function(String text)? onTranscript}) async {
    if (_busy) return;
    if (!_available) await initialize();
    if (!_available) return;
    _busy = true;
    await speech.listen(
      localeId: 'en_IN',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) async {
        final text = result.recognizedWords.trim();
        if (text.isNotEmpty) onTranscript?.call(text);
        if (!result.finalResult || text.isEmpty) return;
        final action = await engine.process(text);
        if (action.handled) {
          final response = _response(action.record!);
          await tts.speak(response);
        }
        _busy = false;
      },
    );
  }

  Future<void> stopListening() async {
    await speech.stop();
    _busy = false;
  }

  String _response(Map<String, dynamic> record) {
    switch ('${record['type']}') {
      case 'expense':
        final amount = (record['amount'] as num).toStringAsFixed(0);
        return 'Got it. I added rupees $amount to ${record['category']} for today.';
      case 'income':
        final amount = (record['amount'] as num).toStringAsFixed(0);
        return 'Got it. I recorded rupees $amount as income.';
      case 'task':
        return 'Got it. I added that task.';
      case 'household':
        return 'Got it. I added that to your shopping list.';
      case 'diary':
        return 'Got it. I saved that in your diary.';
      default:
        return 'Got it. I saved that.';
    }
  }

  Future<void> dispose() async {
    await speech.stop();
    await tts.stop();
  }
}
