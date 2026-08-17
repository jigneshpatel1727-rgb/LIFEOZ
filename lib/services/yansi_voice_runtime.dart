import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_brain.dart';
import 'yansi_companion_brain.dart';
import 'yansi_canonical_expense_bridge.dart';

/// Unified voice runtime for Yansi.
///
/// Keeps the existing voice listener/TTS lifecycle intact while combining
/// LifeOS command processing with the companion intelligence layer.
/// Voice-created expenses are synchronized into the canonical Expense store
/// before the response is returned.
class YansiVoiceRuntime {
  final SharedPreferences prefs;
  late final YansiBrain lifeBrain;
  late final YansiCompanionBrain companionBrain;
  late final YansiCanonicalExpenseBridge expenseBridge;

  YansiVoiceRuntime({required this.prefs}) {
    lifeBrain = YansiBrain(prefs: prefs);
    companionBrain = YansiCompanionBrain.fromPrefs(prefs);
    expenseBridge = YansiCanonicalExpenseBridge(prefs: prefs);
  }

  Future<YansiVoiceRuntimeResult> process(String transcript) async {
    final text = transcript.trim();
    if (text.isEmpty) {
      return const YansiVoiceRuntimeResult(
        response: '',
        intent: YansiIntent.unknown,
        usedCompanionBrain: false,
        usedExternalKnowledge: false,
        canonicalExpensesAdded: 0,
      );
    }

    final life = await lifeBrain.process(text);

    // YansiBrain remains the authoritative command processor. Immediately
    // bridge any newly created voice expense into the same storage consumed
    // by the Expense core.
    final canonicalExpensesAdded = life.intent == YansiIntent.expense
        ? await expenseBridge.sync()
        : 0;

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
      canonicalExpensesAdded: canonicalExpensesAdded,
    );
  }
}

class YansiVoiceRuntimeResult {
  final String response;
  final YansiIntent intent;
  final bool usedCompanionBrain;
  final bool usedExternalKnowledge;
  final int canonicalExpensesAdded;

  const YansiVoiceRuntimeResult({
    required this.response,
    required this.intent,
    required this.usedCompanionBrain,
    required this.usedExternalKnowledge,
    this.canonicalExpensesAdded = 0,
  });
}
