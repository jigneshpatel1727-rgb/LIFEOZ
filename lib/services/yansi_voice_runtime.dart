import 'package:shared_preferences/shared_preferences.dart';
import 'iamyansi_agent_memory.dart';
import 'iamyansi_agent_orchestrator.dart';
import 'iamyansi_agent_tools.dart';
import 'iamyansi_core_bridge.dart';
import 'iamyansi_intent_parser.dart';
import 'iamyansi_permission_engine.dart';
import 'yansi_brain.dart';
import 'yansi_companion_brain.dart';
import 'yansi_canonical_expense_bridge.dart';

/// Unified ambient voice runtime for iamyansi.
///
/// Phase-1 speech/TTS callers remain compatible, but every actionable
/// transcript now passes through the controlled iamyansi agent boundary.
/// The agent is not a sixth core and does not create a chatbot UI.
class IamyansiVoiceRuntime {
  final SharedPreferences prefs;
  late final YansiBrain lifeBrain;
  late final YansiCompanionBrain companionBrain;
  late final YansiCanonicalExpenseBridge expenseBridge;
  late final IamyansiIntentParser intentParser;
  late final IamyansiCoreBridge coreBridge;
  late final IamyansiAgentOrchestrator agent;

  IamyansiVoiceRuntime({required this.prefs}) {
    lifeBrain = YansiBrain(prefs: prefs);
    companionBrain = YansiCompanionBrain.fromPrefs(prefs);
    expenseBridge = YansiCanonicalExpenseBridge(prefs: prefs);
    intentParser = IamyansiIntentParser();
    coreBridge = IamyansiCoreBridge(prefs: prefs);

    // Normal voice-created records are allowed to write after the user has
    // enabled the app's normal data permission. Sensitive actions still stop
    // at the per-action confirmation gate inside the agent.
    agent = IamyansiAgentOrchestrator(
      tools: IamyansiAgentTools(prefs: prefs),
      permissions: const IamyansiPermissionEngine(
        granted: {
          IamyansiPermission.read,
          IamyansiPermission.write,
        },
      ),
      memory: IamyansiAgentMemory(prefs: prefs),
      bridge: coreBridge,
    );
  }

  Future<IamyansiVoiceRuntimeResult> process(
    String transcript, {
    bool confirmed = false,
  }) async {
    final text = transcript.trim();
    if (text.isEmpty) {
      return const IamyansiVoiceRuntimeResult(
        response: '',
        intent: YansiIntent.unknown,
      );
    }

    // Keep the Phase-1 brain for its existing conversational responses and
    // compatibility, while the iamyansi agent becomes authoritative for
    // structured writes across all five cores.
    final life = await lifeBrain.process(text);
    final parsed = intentParser.parse(text);

    var response = life.response;
    var usedCompanion = false;
    var usedExternal = false;
    var coreWritten = false;
    var verified = false;
    String? writtenCore;
    String? agentStatus;

    if (parsed.type != IamyansiIntentType.unknown) {
      final result = await agent.handle(parsed, confirmed: confirmed);
      agentStatus = result.status;

      if (result.status == 'completed') {
        response = result.message ?? response;
        coreWritten = true;
        verified = result.verified;
        writtenCore = parsed.type == IamyansiIntentType.expense ||
                parsed.type == IamyansiIntentType.income
            ? 'expense'
            : parsed.type == IamyansiIntentType.task ||
                    parsed.type == IamyansiIntentType.diary
                ? 'productivity'
                : parsed.type == IamyansiIntentType.reminder
                    ? 'calendar'
                    : parsed.type == IamyansiIntentType.household
                        ? 'household'
                        : parsed.type == IamyansiIntentType.goal
                            ? 'goal'
                            : null;
      } else if (result.status == 'confirmation_required') {
        response = 'I can do that, but I need your confirmation first.';
      } else if (result.status == 'permission_required') {
        response = 'Please allow iamyansi to save this information.';
      } else if (result.status == 'needs_clarification') {
        response = 'I did not understand what you want me to save.';
      } else if (result.status == 'failed') {
        response = result.message ?? 'I could not save that information.';
      }
    }

    // Preserve the existing Phase-1 expense bridge for compatibility with
    // screens/storage that still consume its legacy expense format. It is a
    // synchronization step, not a second iamyansi write.
    if (life.intent == YansiIntent.expense && coreWritten) {
      await expenseBridge.sync();
    }

    // Conversational questions continue to use the companion layer.
    if (life.intent == YansiIntent.question && parsed.type == IamyansiIntentType.unknown) {
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
      verified: verified,
      agentStatus: agentStatus,
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
  final bool verified;
  final String? agentStatus;

  const IamyansiVoiceRuntimeResult({
    required this.response,
    required this.intent,
    this.parsedIntent = IamyansiIntentType.unknown,
    this.usedCompanionBrain = false,
    this.usedExternalKnowledge = false,
    this.coreWritten = false,
    this.writtenCore,
    this.verified = false,
    this.agentStatus,
  });
}

// Backward-compatible names for existing Phase-1 callers.
typedef YansiVoiceRuntime = IamyansiVoiceRuntime;
typedef YansiVoiceRuntimeResult = IamyansiVoiceRuntimeResult;
