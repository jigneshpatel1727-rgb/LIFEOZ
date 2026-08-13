import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'lifeos_permission_gate.dart';
import 'yansi_ambient_state_machine.dart';

/// Voice-first ambient listener. Permission is required; it never enables
/// microphone access by itself. It also avoids overlapping listen sessions.
class YansiAmbientListener {
  final SpeechToText _speech = SpeechToText();
  final LifeOSPermissionGate permissions;
  final YansiAmbientStateMachine state;
  final Future<void> Function(String text) onUtterance;
  Timer? _restart;
  bool _running = false;
  bool _listening = false;

  YansiAmbientListener({required this.permissions, required this.state, required this.onUtterance});
  bool get running => _running;

  Future<bool> start() async {
    if (_running || !permissions.voiceEnabled) return _running;
    final available = await _speech.initialize(
      onStatus: _onStatus,
      onError: (_) => _scheduleRestart(),
    );
    if (!available || !permissions.voiceEnabled) return false;
    _running = true;
    await _listen();
    return true;
  }

  Future<void> _listen() async {
    if (!_running || _listening || !permissions.voiceEnabled) return;
    _listening = true;
    state.setListening();
    await _speech.listen(
      listenMode: ListenMode.dictation,
      partialResults: true,
      cancelOnError: false,
      onResult: (result) async {
        final text = result.recognizedWords.trim();
        if (text.isEmpty || !result.finalResult) return;
        _listening = false;
        state.setThinking(text);
        await onUtterance(text);
        if (_running) _scheduleRestart();
      },
    );
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _listening = false;
      if (_running) _scheduleRestart();
    }
  }

  void _scheduleRestart() {
    _restart?.cancel();
    if (!_running || !permissions.voiceEnabled) return;
    _restart = Timer(const Duration(milliseconds: 450), () {
      if (_running) _listen();
    });
  }

  Future<void> stop() async {
    _running = false;
    _listening = false;
    _restart?.cancel();
    await _speech.stop();
    state.setIdle();
  }

  Future<void> dispose() async {
    await stop();
    await _speech.cancel();
  }
}
