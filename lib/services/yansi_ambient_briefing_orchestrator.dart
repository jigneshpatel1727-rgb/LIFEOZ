import 'yansi_next_phase_orchestrator.dart';

/// Converts the highest-value Yansi priority into a compact ambient payload.
/// The UI can surface this without exposing the internal intelligence graph.
class YansiAmbientBriefingOrchestrator {
  final YansiNextPhaseOrchestrator orchestrator;

  const YansiAmbientBriefingOrchestrator(this.orchestrator);

  Map<String, dynamic> buildSurface({
    bool quietMode = false,
    bool userActive = true,
    bool screenVisible = true,
  }) {
    if (quietMode || !userActive || !screenVisible) {
      return _hiddenSurface();
    }

    final priority = orchestrator.topPriority();
    if (priority == null) return _hiddenSurface();

    final requiresConfirmation = priority.needsConfirmation || priority.priority >= 90;

    return {
      'visible': true,
      'title': priority.title,
      'message': priority.message,
      'priority': priority.priority,
      'needs_confirmation': requiresConfirmation,
      'ambient_only': true,
    };
  }

  String toSpeech({
    bool quietMode = false,
    bool userActive = true,
    bool screenVisible = true,
  }) {
    final surface = buildSurface(
      quietMode: quietMode,
      userActive: userActive,
      screenVisible: screenVisible,
    );
    if (surface['visible'] != true) return '';

    final title = surface['title'] as String? ?? '';
    final message = surface['message'] as String? ?? '';
    final confirmation = surface['needs_confirmation'] == true;

    if (confirmation) {
      return '$title. $message. I need your confirmation before taking any action.';
    }
    return '$title. $message';
  }

  Map<String, dynamic> _hiddenSurface() => {
        'visible': false,
        'title': '',
        'message': '',
        'priority': 0,
        'needs_confirmation': false,
        'ambient_only': true,
      };
}
