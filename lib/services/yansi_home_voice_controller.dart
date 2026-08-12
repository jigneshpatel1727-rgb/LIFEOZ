import 'package:flutter/foundation.dart';
import 'yansi_ambient_command_router.dart';
import 'yansi_ambient_voice_bridge.dart';

/// UI-safe controller that exposes one tap-to-talk action and forwards the
/// resulting speech lifecycle to Yansi's existing voice pipeline.
class YansiHomeVoiceController extends ChangeNotifier {
  final YansiAmbientVoiceBridge bridge;
  late final YansiAmbientCommandRouter router = YansiAmbientCommandRouter(bridge);

  bool _busy = false;
  String _lastResponse = '';

  YansiHomeVoiceController(this.bridge);

  bool get busy => _busy;
  bool get listening => bridge.listening;
  String get transcript => bridge.transcript;
  String get lastResponse => _lastResponse;

  void start() {
    if (_busy) return;
    _busy = true;
    router.onListeningStarted();
    notifyListeners();
  }

  void updateSpeech(String text) {
    if (!_busy) return;
    router.onPartialSpeech(text);
    notifyListeners();
  }

  void complete(String response) {
    _lastResponse = response.trim();
    router.onCommandCompleted(_lastResponse);
    _busy = false;
    notifyListeners();
  }

  void cancel() {
    router.onListeningCancelled();
    _busy = false;
    notifyListeners();
  }
}
