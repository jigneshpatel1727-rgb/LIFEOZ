/// Normalizes speech/text into a structured Yansi intent for downstream planning.
class YansiVoiceIntentEngine {
  const YansiVoiceIntentEngine();

  Map<String, dynamic> interpret(String transcript) {
    final text = transcript.trim();
    return {
      'transcript': text,
      'intent': text.isEmpty ? 'none' : 'lifeos_request',
      'source': 'voice_or_text',
      'confidenceHint': text.isEmpty ? 0.0 : 1.0,
      'requiresPlanning': text.isNotEmpty,
    };
  }
}
