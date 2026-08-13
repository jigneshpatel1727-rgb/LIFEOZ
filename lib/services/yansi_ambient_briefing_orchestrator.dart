import 'yansi_ambient_cadence_policy.dart';
import 'yansi_next_phase_orchestrator.dart';

class YansiAmbientBriefingOrchestrator {
  final YansiNextPhaseOrchestrator orchestrator;
  final YansiAmbientCadencePolicy cadence;

  const YansiAmbientBriefingOrchestrator(
    this.orchestrator, {
    this.cadence = const YansiAmbientCadencePolicy(),
  });

  Map<String, dynamic> buildSurface({
    bool quietMode = false,
    bool userActive = true,
    bool screenVisible = true,
    DateTime? now,
  }) {
    if (quietMode || !userActive || !screenVisible) return _hiddenSurface();

    final priority = orchestrator.topPriority();
    if (priority == null) return _hiddenSurface();

    final signalKey =
        '${priority.title.trim().toLowerCase()}|${priority.message.trim().toLowerCase()}';
    if (!cadence.shouldSurface(
      signalKey: signalKey,
      priority: priority.priority,
      now: now,
    )) {
      return _hiddenSurface();
    }

    return {
      'visible': true,
      'title': priority.title,
      'message': priority.message,
      'priority': priority.priority,
      'needs_confirmation':
          priority.needsConfirmation || priority.priority >= 90,
      'ambient_only': true,
      'signal_key': signalKey,
    };
  }

  String toSpeech({
    bool quietMode = false,
    bool userActive = true,
    bool screenVisible = true,
    DateTime? now,
  }) {
    final surface = buildSurface(
      quietMode: quietMode,
      userActive: userActive,
      screenVisible: screenVisible,
      now: now,
    );
    if (surface['visible'] != true) return '';

    final title = surface['title'] as String? ?? '';
    final message = surface['message'] as String? ?? '';
    if (surface['needs_confirmation'] == true) {
      return '$title. $message. I need your confirmation before taking any action.';
    }
    return '$title. $message';
  }

  String notificationPreview({
    bool quietMode = false,
    bool userActive = true,
    bool screenVisible = true,
    DateTime? now,
    int maxLength = 140,
  }) {
    final speech = toSpeech(
      quietMode: quietMode,
      userActive: userActive,
      screenVisible: screenVisible,
      now: now,
    ).trim();
    if (speech.isEmpty || maxLength < 1) return '';
    if (speech.length <= maxLength) return speech;
    return '${speech.substring(0, maxLength - 1).trimRight()}…';
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
