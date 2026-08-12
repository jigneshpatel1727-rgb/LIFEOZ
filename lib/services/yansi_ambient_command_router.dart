import 'yansi_ambient_voice_bridge.dart';

/// Small command-state adapter for the ambient Yansi surface.
/// The actual speech recognizer and Yansi brain remain outside this class.
class YansiAmbientCommandRouter {
  final YansiAmbientVoiceBridge bridge;
  const YansiAmbientCommandRouter(this.bridge);

  void onListeningStarted() => bridge.beginListening();

  void onPartialSpeech(String text) => bridge.updateTranscript(text);

  void onCommandCompleted(String response) =>
      bridge.finishListening(response: response);

  void onListeningCancelled() => bridge.reset();
}
