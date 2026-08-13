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

  const YansiAmbientSurfaceState({
    this.title,
    this.message,
    this.confidence = 0,
    this.visible = false,
    this.needsConfirmation = false,
    this.ambientOnly = true,
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

  /// Refreshes the ambient surface from the real proactive runtime.
  ///
  /// This only prepares/displays intelligence. It does not execute an action.
  Future<YansiAmbientSurfaceState> refreshFromRuntime(
    YansiProactiveRuntime runtime, {
    bool quietMode = false,
  }) async {
    final plan = await runtime.prepare(
      quietMode: quietMode,
    );

    if (plan == null || !runtime.isReady) {
      return const YansiAmbientSurfaceState();
    }

    final confidence = runtime.confidence.clamp(0, 100).toInt();

    return YansiAmbientSurfaceState(
      title: runtime.headline,
      message: plan.items.isEmpty ? null : plan.items.first.reason,
      confidence: confidence,
      visible: confidence >= 60,
      needsConfirmation: runtime.priority >= 90,
    );
  }
}
