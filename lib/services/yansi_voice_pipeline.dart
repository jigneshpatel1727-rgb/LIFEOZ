import 'yansi_action_router.dart';
import 'yansi_brain.dart';

/// Connects speech-to-text output to Yansi without coupling the microphone UI
/// to LifeOS domain logic. The UI can pass each final transcript here.
class YansiVoicePipeline {
  final YansiBrain brain;
  final YansiActionRouter actions;

  const YansiVoicePipeline({required this.brain, required this.actions});

  Future<YansiVoiceResponse> handleTranscript(
    String transcript, {
    String? voicePath,
  }) async {
    final intent = actions.classify(transcript);
    final result = await brain.process(transcript, voicePath: voicePath);

    return YansiVoiceResponse(
      transcript: transcript,
      intent: intent,
      result: result,
      spokenText: result.response,
    );
  }
}

class YansiVoiceResponse {
  final String transcript;
  final YansiActionIntent intent;
  final YansiResult result;
  final String spokenText;

  const YansiVoiceResponse({
    required this.transcript,
    required this.intent,
    required this.result,
    required this.spokenText,
  });

  bool get needsConfirmation => intent.requiresConfirmation;
}
