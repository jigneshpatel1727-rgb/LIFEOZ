import 'package:flutter/foundation.dart';
import 'yansi_ambient_voice_bridge.dart';
import 'yansi_privacy_center.dart';
import 'yansi_tts_state.dart';
import 'yansi_brain.dart';

/// The central orchestration layer for the hyper-futuristic LifeOS experience.
///
/// Yansi is intentionally not a screen or a button. This core coordinates
/// voice, intelligence, permissions and ambient state so the five LifeOS
/// worlds can behave as one intelligent operating environment.
enum YansiPresenceState { idle, listening, thinking, acting, speaking }

class YansiIntelligenceCore extends ChangeNotifier {
  final YansiBrain brain;
  final YansiAmbientVoiceBridge voice;
  final YansiTtsState tts;

  YansiPrivacyCenter privacy;
  YansiPresenceState _state = YansiPresenceState.idle;
  YansiResult? _lastResult;
  String _ambientMessage = '';

  YansiIntelligenceCore({
    required this.brain,
    required this.voice,
    required this.tts,
    this.privacy = const YansiPrivacyCenter(),
  });

  YansiPresenceState get state => _state;
  YansiResult? get lastResult => _lastResult;
  String get ambientMessage => _ambientMessage;

  bool get canUseMicrophone => privacy.microphone && privacy.speechRecognition;
  bool get canUseWeb => privacy.webAccess;

  /// Updates permission state without giving Yansi permission to bypass it.
  void setPrivacy(YansiPrivacyCenter value) {
    privacy = value;
    notifyListeners();
  }

  /// Called by the platform voice layer when speech activity begins.
  void onSpeechActivityStarted() {
    if (!canUseMicrophone) return;
    _setState(YansiPresenceState.listening);
    voice.beginListening();
  }

  void onPartialSpeech(String transcript) {
    if (_state != YansiPresenceState.listening) return;
    voice.updateTranscript(transcript);
    notifyListeners();
  }

  /// Sends naturally captured speech through the same Yansi brain used by
  /// every LifeOS capability. No tap-to-talk controller is required here.
  Future<YansiResult?> onSpeechCompleted(String transcript) async {
    if (!canUseMicrophone || transcript.trim().isEmpty) {
      _setState(YansiPresenceState.idle);
      return null;
    }

    _setState(YansiPresenceState.thinking);

    final result = await brain.process(transcript);
    _lastResult = result;
    voice.finishListening(response: result.response);

    _setState(YansiPresenceState.acting);
    _ambientMessage = _actionMessage(result);
    notifyListeners();

    // The TTS adapter subscribes to this state. The core never owns the UI.
    _setState(YansiPresenceState.speaking);
    tts.begin(result.response);
    notifyListeners();

    return result;
  }

  void onSpeechCancelled() {
    voice.reset();
    _setState(YansiPresenceState.idle);
  }

  void onSpeechFinished() {
    tts.finish();
    _setState(YansiPresenceState.idle);
  }

  /// Allows LifeOS sensors/notification adapters to surface a useful event
  /// without turning Yansi into a noisy chatbot.
  void surfaceInsight(String message) {
    final value = message.trim();
    if (value.isEmpty) return;
    _ambientMessage = value;
    notifyListeners();
  }

  void clearInsight() {
    _ambientMessage = '';
    notifyListeners();
  }

  String _actionMessage(YansiResult result) {
    switch (result.intent) {
      case YansiIntent.expense:
        return 'Money intelligence updated';
      case YansiIntent.income:
        return 'Income intelligence updated';
      case YansiIntent.task:
        return 'Productivity intelligence updated';
      case YansiIntent.reminder:
        return 'Calendar intelligence updated';
      case YansiIntent.household:
        return 'Household intelligence updated';
      case YansiIntent.goal:
        return 'Goal intelligence updated';
      case YansiIntent.diary:
        return 'Personal memory updated';
      case YansiIntent.question:
        return 'LifeOS intelligence ready';
      case YansiIntent.unknown:
        return 'Yansi is listening';
    }
  }

  void _setState(YansiPresenceState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }
}
