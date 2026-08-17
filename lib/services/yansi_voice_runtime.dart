import 'package:shared_preferences/shared_preferences.dart';
import 'iamyansi_core_bridge.dart';
import 'iamyansi_intent_parser.dart';
import 'yansi_brain.dart';
import 'yansi_companion_brain.dart';
import 'yansi_canonical_expense_bridge.dart';

/// Unified ambient voice runtime. iamyansi remains invisible/ghost.
class IamyansiVoiceRuntime {
  final SharedPreferences prefs;
  late final YansiBrain lifeBrain;
  late final YansiCompanionBrain companionBrain;
  late final YansiCanonicalExpenseBridge expenseBridge;
  late final IamyansiIntentParser intentParser;
  late final IamyansiCoreBridge coreBridge;

  IamyansiVoiceRuntime({required this.prefs}) {
    lifeBrain = YansiBrain(prefs: prefs);
    companionBrain = YansiCompanionBrain.fromPrefs(prefs);
    expenseBridge = YansiCanonicalExpenseBridge(prefs: prefs);
    intentParser = IamyansiIntentParser();
    coreBridge = IamyansiCoreBridge(prefs: prefs);
  }

  Future<IamyansiVoiceRuntimeResult> process(String transcript) async {
    final text = transcript.trim();
    if (text.isEmpty) {
      return const IamyansiVoiceRuntimeResult(response: '', intent: YansiIntent.unknown);
    }

    // Keep Phase-1 command processing for compatibility, while the new
    // deterministic iamyansi parser supplies the five-core routing boundary.
    final life = await lifeBrain.process(text);
    final parsed = intentParser.parse(text);

    var response = life.response;
    var usedCompanion = false;
    var usedExternal = false;
    var coreWritten = false;
    String? writtenCore;

    if (!parsed.needsConfirmation && parsed.type != IamyansiIntentType.unknown) {
      final write = await coreBridge.apply(parsed);
      coreWritten = write.written;
      writtenCore = write.core;
    }

    // Preserve the existing Phase-1 expense synchronisation so the Expense
    // core receives exactly the same record format it already understands.
    if (life.intent == YansiIntent.expense) {
      await expenseBridge.sync();
    }

    if (life.intent == YansiIntent.question) {
      final companion = await companionBrain.respond(text);
      if (companion.text.trim().isNotEmpty) {
        response = companion.text.trim();
        usedCompanion = true;
        usedExternal = companion.usedExternalKnowledge;
      }
    }

    return IamyansiVoiceRuntimeResult(
      response: response,
      intent: life.intent,
      parsedIntent: parsed.type,
      usedCompanionBrain: usedCompanion,
      usedExternalKnowledge: usedExternal,
      coreWritten: coreWritten,
      writtenCore: writtenCore,
    );
  }
}

class IamyansiVoiceRuntimeResult {
  final String response;
  final YansiIntent intent;
  final IamyansiIntentType parsedIntent;
  final bool usedCompanionBrain;
  final bool usedExternalKnowledge;
  final bool coreWritten;
  final String? writtenCore;

  const IamyansiVoiceRuntimeResult({
    required this.response,
    required this.intent,
    this.parsedIntent = IamyansiIntentType.unknown,
    this.usedCompanionBrain = false,
    this.usedExternalKnowledge = false,
    this.coreWritten = false,
    this.writtenCore,
  });
}

// Backward-compatible names for existing Phase-1 callers.
typedef YansiVoiceRuntime = IamyansiVoiceRuntime;
typedef YansiVoiceRuntimeResult = IamyansiVoiceRuntimeResult;
