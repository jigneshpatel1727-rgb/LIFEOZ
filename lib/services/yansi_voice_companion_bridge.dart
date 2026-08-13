import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_companion_brain.dart';

/// Connects finalized speech transcripts to Yansi's companion brain without
/// owning speech recognition or TTS.
class YansiVoiceCompanionBridge {
  final SharedPreferences prefs;
  late final YansiCompanionBrain brain;

  YansiVoiceCompanionBridge({required this.prefs}) {
    brain = YansiCompanionBrain.fromPrefs(prefs);
  }

  /// Processes one finalized speech transcript.
  Future<String> process(String transcript) async {
    final text = transcript.trim();
    if (text.isEmpty) return '';
    final result = await brain.respond(text);
    return result.text;
  }

  Future<void> dispose() async {}
}
