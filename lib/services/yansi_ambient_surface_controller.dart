import 'yansi_ambient_signal_gate.dart';
import 'yansi_next_phase_orchestrator.dart';
import 'yansi_proactive_runtime.dart';

class YansiAmbientSurfaceState {
  final String? title;
  final String? message;
  final int confidence;
  final bool visible;
  final bool needsConfirmation;
  final bool ambientOnly;
  final bool voiceEligible;
  final String? signalKey;

  const YansiAmbientSurfaceState({
    this.title,
    this.message,
    this.confidence = 0,
    this.visible = false,
    this.needsConfirmation = false,
    this.ambientOnly = true,
    this.voiceEligible = false,
    this.signalKey,
  });

  bool get highConfidence => confidence >= 80;
}

class YansiAmbientSurfaceController {
  final YansiNextPhaseOrchestrator orchestrator;
  final YansiAmbientSignalGate gate;

  const YansiAmbientSurfaceController(
    this.orchestrator, {
    this.gate = const YansiAmbientSignalGate(),
  });

  YansiAmbientSurfaceState refresh() {
    final signal = orchestrator.topPriority();
    if (signal == null) return const YansiAmbientSurfaceState();
    final score = signal.priority.clamp(0, 100).toInt();
    final allowed = gate.allow(
      visible: score >= 60,
      userActive: true,
      quietMode: false,
      cadenceAllowed: true,
      priority: score,
    );
    if (!allowed) return const YansiAmbientSurfaceState();
    return YansiAmbientSurfaceState(
      title: signal.title,
      message: signal.message,
      confidence: score,
      visible: true,
      needsConfirmation: signal.needsConfirmation || score >= 90,
    );
  }

  Future<YansiAmbientSurfaceState> refreshFromRuntime(
    YansiProactiveRuntime runtime, {
    bool quietMode = false,
    bool userActive = true,
    bool screenVisible = true,
    bool voiceAvailable = true,
  }) async {
    if (quietMode || !screenVisible) return const YansiAmbientSurfaceState();
    final plan = await runtime.prepare(
      userIsActive: userActive,
      quietMode: quietMode,
    );
    if (plan == null || !runtime.isReady) {
      return const YansiAmbientSurfaceState();
    }

    final confidence = runtime.confidence.clamp(0, 100).toInt();
    final message = plan.items.isEmpty ? null : plan.items.first.reason;
    if (message == null || message.trim().isEmpty) {
      return const YansiAmbientSurfaceState();
    }

    final surfaceAllowed = gate.allow(
      visible: screenVisible && confidence >= 60,
      userActive: userActive,
      quietMode: quietMode,
      cadenceAllowed: true,
      priority: runtime.priority,
    );
    final voiceEligible = gate.allowVoice(
      surfaceAllowed: surfaceAllowed,
      voiceAvailable: voiceAvailable,
      runtimeAllowsSpeech: runtime.shouldSpeak,
    );
    if (!surfaceAllowed) return const YansiAmbientSurfaceState();

    return YansiAmbientSurfaceState(
      title: runtime.headline,
      message: message,
      confidence: confidence,
      visible: true,
      needsConfirmation: runtime.priority >= 90,
      ambientOnly: true,
      voiceEligible: voiceEligible,
    );
  }

  bool shouldAllowAmbientVoice({
    required YansiProactiveRuntime runtime,
    bool quietMode = false,
    bool userActive = true,
    bool voiceAvailable = true,
  }) {
    return gate.allowVoice(
      surfaceAllowed: !quietMode && userActive,
      voiceAvailable: voiceAvailable,
      runtimeAllowsSpeech: runtime.isReady && runtime.shouldSpeak,
    );
  }

  String? ambientVoiceText(YansiAmbientSurfaceState state) {
    if (!state.voiceEligible || state.message == null) return null;
    final text = state.message!.trim();
    if (text.isEmpty) return null;
    return state.needsConfirmation
        ? 'I noticed something important. $text Please confirm before I act.'
        : text;
  }
}
