import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_companion_brain.dart';

/// Connects spoken transcripts to Yansi's companion brain without owning
/// speech recognition or TTS. The existing voice layer can call [process].
class YansiVoiceCompanionBridge {
  final SharedPreferences prefs;
  late final YansiCompanionBrain brain;

  YansiVoiceCompanionBridge({required this.prefs}) {
    brain = YansiCompanionBrain(prefs: prefs);
  }

  /// Processes one finalized speech transcript.
  ///
  /// The bridge deliberately does not start/stop the microphone. This keeps
  /// the existing voice lifecycle intact and makes the integration safe.
  Future<String> process(String transcript) async {
    final text = transcript.trim();
    if (text.isEmpty) return '';
    final result = await brain.respond(text);
    return result.text;
  }

  Future<void> dispose() async {
    // Reserved for future voice resources. The brain itself uses no open
    // streams, timers, or microphone handles.
  }
}
