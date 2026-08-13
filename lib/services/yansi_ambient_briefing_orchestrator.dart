import 'yansi_next_phase_orchestrator.dart';

/// Converts the highest-value Yansi priority into a compact ambient payload.
/// The UI can surface this without exposing the internal intelligence graph.
class YansiAmbientBriefingOrchestrator {
  final YansiNextPhaseOrchestrator orchestrator;

  const YansiAmbientBriefingOrchestrator(this.orchestrator);

  Map<String, dynamic> buildSurface() {
    final priority = orchestrator.topPriority();
    if (priority == null) {
      return {
        'visible': false,
        'title': '',
        'message': '',
        'priority': 0,
        'needs_confirmation': false,
      };
    }

    return {
      'visible': true,
      'title': priority.title,
      'message': priority.message,
      'priority': priority.priority,
      'needs_confirmation': priority.needsConfirmation,
    };
  }

  String toSpeech() {
    final surface = buildSurface();
    if (surface['visible'] != true) return '';
    final title = surface['title'] as String;
    final message = surface['message'] as String;
    return '$title. $message';
  }
}
