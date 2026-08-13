import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_brain.dart';
import 'yansi_companion_brain.dart';

/// Unified voice runtime for Yansi.
///
/// Keeps the existing voice listener/TTS lifecycle intact while combining
/// LifeOS command processing with the newer companion intelligence layer.
class YansiVoiceRuntime {
  final SharedPreferences prefs;
  late final YansiBrain lifeBrain;
  late final YansiCompanionBrain companionBrain;

  YansiVoiceRuntime({required this.prefs}) {
    lifeBrain = YansiBrain(prefs: prefs);
    companionBrain = YansiCompanionBrain.fromPrefs(prefs);
  }

  Future<YansiVoiceRuntimeResult> process(String transcript) async {
    final text = transcript.trim();
    if (text.isEmpty) {
      return const YansiVoiceRuntimeResult(
        response: '',
        intent: YansiIntent.unknown,
        usedCompanionBrain: false,
        usedExternalKnowledge: false,
      );
    }

    final life = await lifeBrain.process(text);
    var response = life.response;
    var usedCompanion = false;
    var usedExternal = false;

    // Structured LifeOS commands remain authoritative. For conversational
    // questions, let the companion layer add memory/web-aware intelligence.
    if (life.intent == YansiIntent.question) {
      final companion = await companionBrain.respond(text);
      if (companion.text.trim().isNotEmpty) {
        response = companion.text.trim();
        usedCompanion = true;
        usedExternal = companion.usedExternalKnowledge;
      }
    }

    return YansiVoiceRuntimeResult(
      response: response,
      intent: life.intent,
      usedCompanionBrain: usedCompanion,
      usedExternalKnowledge: usedExternal,
    );
  }
}

class YansiVoiceRuntimeResult {
  final String response;
  final YansiIntent intent;
  final bool usedCompanionBrain;
  final bool usedExternalKnowledge;

  const YansiVoiceRuntimeResult({
    required this.response,
    required this.intent,
    required this.usedCompanionBrain,
    required this.usedExternalKnowledge,
  });
}
