import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'lifeos_permission_gate.dart';
import 'yansi_ambient_state_machine.dart';

/// Voice-first ambient listener. There is deliberately no UI tap requirement.
class YansiAmbientListener {
  final SpeechToText _speech = SpeechToText();
  final LifeOSPermissionGate permissions;
  final YansiAmbientStateMachine state;
  final Future<void> Function(String text) onUtterance;
  Timer? _restart;
  bool _running = false;

  YansiAmbientListener({required this.permissions, required this.state, required this.onUtterance});
  bool get running => _running;

  Future<bool> start() async {
    if (!permissions.voiceEnabled) return false;
    final available = await _speech.initialize(onStatus: _onStatus, onError: (_) => _scheduleRestart());
    if (!available || !permissions.voiceEnabled) return false;
    _running = true;
    await _listen();
    return true;
  }

  Future<void> _listen() async {
    if (!_running || !permissions.voiceEnabled) return;
    state.setListening();
    await _speech.listen(
      listenMode: ListenMode.dictation,
      partialResults: true,
      cancelOnError: false,
      onResult: (result) async {
        final text = result.recognizedWords.trim();
        if (text.isEmpty || !result.finalResult) return;
        state.setThinking(text);
        await onUtterance(text);
        if (_running) _scheduleRestart();
      },
    );
  }

  void _onStatus(String status) {
    if (_running && (status == 'done' || status == 'notListening')) _scheduleRestart();
  }

  void _scheduleRestart() {
    _restart?.cancel();
    if (!_running || !permissions.voiceEnabled) return;
    _restart = Timer(const Duration(milliseconds: 450), () { if (_running) _listen(); });
  }

  Future<void> stop() async {
    _running = false;
    _restart?.cancel();
    await _speech.stop();
    state.setIdle();
  }

  Future<void> dispose() async {
    await stop();
    await _speech.cancel();
  }
}
