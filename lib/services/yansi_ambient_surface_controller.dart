import 'yansi_next_phase_orchestrator.dart';

/// Converts Yansi's internal priorities into a small ambient surface payload.
/// The UI can show one useful signal without turning Yansi into a chatbot.
class YansiAmbientSurfaceState {
  final String? title;
  final String? message;
  final int confidence;
  final bool visible;

  const YansiAmbientSurfaceState({
    this.title,
    this.message,
    this.confidence = 0,
    this.visible = false,
  });
}

class YansiAmbientSurfaceController {
  final YansiNextPhaseOrchestrator orchestrator;
  const YansiAmbientSurfaceController(this.orchestrator);

  YansiAmbientSurfaceState refresh() {
    final priority = orchestrator.topPriority();
    if (priority == null) return const YansiAmbientSurfaceState();

    return YansiAmbientSurfaceState(
      title: priority.title,
      message: priority.message,
      confidence: priority.confidence,
      visible: priority.confidence >= 60,
    );
  }
}
