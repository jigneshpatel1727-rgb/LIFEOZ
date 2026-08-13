import 'yansi_next_phase_orchestrator.dart';
import 'yansi_proactive_runtime.dart';

/// Small ambient presentation state for Yansi.
/// The controller exposes one useful signal at a time and never executes
/// actions.
class YansiAmbientSurfaceState {
  final String? title;
  final String? message;
  final int confidence;
  final bool visible;
  final bool needsConfirmation;
  final bool ambientOnly;
  final bool voiceEligible;

  const YansiAmbientSurfaceState({
    this.title,
    this.message,
    this.confidence = 0,
    this.visible = false,
    this.needsConfirmation = false,
    this.ambientOnly = true,
    this.voiceEligible = false,
  });

  bool get highConfidence => confidence >= 80;
}

class YansiAmbientSurfaceController {
  final YansiNextPhaseOrchestrator orchestrator;

  const YansiAmbientSurfaceController(this.orchestrator);

  YansiAmbientSurfaceState refresh() {
    final signal = orchestrator.topPriority();
    if (signal == null) return const YansiAmbientSurfaceState();

    final score = signal.priority.clamp(0, 100).toInt();
    return YansiAmbientSurfaceState(
      title: signal.title,
      message: signal.message,
      confidence: score,
      visible: score >= 60,
      needsConfirmation: signal.needsConfirmation,
    );
  }

  Future<YansiAmbientSurfaceState> refreshFromRuntime(
    YansiProactiveRuntime runtime, {
    bool quietMode = false,
    bool userActive = true,
    bool screenVisible = true,
    bool voiceAvailable = true,
  }) async {
    if (quietMode || !screenVisible) {
      return const YansiAmbientSurfaceState();
    }

    final plan = await runtime.prepare(
      userIsActive: userActive,
      quietMode: quietMode,
    );

    if (plan == null || !runtime.isReady) {
      return const YansiAmbientSurfaceState();
    }

    final confidence = runtime.confidence.clamp(0, 100).toInt();
    final shouldSurface = userActive && confidence >= 60;
    final voiceEligible = voiceAvailable && userActive && runtime.shouldSpeak;

    return YansiAmbientSurfaceState(
      title: runtime.headline,
      message: plan.items.isEmpty ? null : plan.items.first.reason,
      confidence: confidence,
      visible: shouldSurface,
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
    if (quietMode || !userActive || !voiceAvailable) return false;
    return runtime.isReady && runtime.shouldSpeak;
  }

  /// Produces a short, speakable ambient line without executing anything.
  String? ambientVoiceText(YansiAmbientSurfaceState state) {
    if (!state.voiceEligible || state.message == null) return null;
    final text = state.message!.trim();
    if (text.isEmpty) return null;
    return state.needsConfirmation
        ? 'I noticed something important. $text Please confirm before I act.'
        : text;
  }
}
