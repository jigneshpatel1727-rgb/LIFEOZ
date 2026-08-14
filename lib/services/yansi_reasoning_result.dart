/// Renderer-neutral result produced by the central Yansi reasoning layer.
///
/// The result can be consumed by voice, ambient UI, reports, spatial
/// renderers, notifications, or future devices without changing the brain.
class YansiReasoningResult {
  final String intent;
  final String summary;
  final List<String> insights;
  final List<YansiProposedAction> proposedActions;
  final int priority;
  final bool shouldSpeak;
  final bool requiresConfirmation;
  final Map<String, dynamic> metadata;

  const YansiReasoningResult({
    required this.intent,
    required this.summary,
    this.insights = const <String>[],
    this.proposedActions = const <YansiProposedAction>[],
    this.priority = 0,
    this.shouldSpeak = false,
    this.requiresConfirmation = false,
    this.metadata = const <String, dynamic>{},
  });
}

class YansiProposedAction {
  final String capabilityId;
  final String description;
  final Map<String, dynamic> parameters;
  final bool requiresConfirmation;

  const YansiProposedAction({
    required this.capabilityId,
    required this.description,
    this.parameters = const <String, dynamic>{},
    this.requiresConfirmation = true,
  });
}
