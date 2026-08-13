import 'yansi_next_phase_orchestrator.dart';

/// Converts Yansi's internal priorities into a small ambient surface payload.
/// The UI can show one useful signal without turning Yansi into a chatbot.
class YansiAmbientSurfaceState {
  final String? title;
  final String? message;
  final int confidence;
  final bool visible;
  final bool needsConfirmation;

  const YansiAmbientSurfaceState({
    this.title,
    this.message,
    this.confidence = 0,
    this.visible = false,
    this.needsConfirmation = false,
  });
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
}
