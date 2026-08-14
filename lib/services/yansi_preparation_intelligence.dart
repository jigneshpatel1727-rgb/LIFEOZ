/// Determines useful, non-destructive preparation from a predicted situation.
/// It never executes actions, sends messages, or changes user data.
class YansiPreparationIntelligence {
  const YansiPreparationIntelligence();

  Map<String, dynamic> prepare({
    required String core,
    required String horizon,
    required int priority,
    required int confidence,
    List<String> context = const [],
  }) {
    final safePriority = priority.clamp(0, 100);
    final safeConfidence = confidence.clamp(0, 100);
    final normalized = core.trim().toLowerCase();

    final steps = <String>[];
    switch (normalized) {
      case 'calendar':
        steps.add('Review the upcoming commitment and required preparation.');
        steps.add('Check for related tasks, documents, or payment dates.');
        break;
      case 'expense':
        steps.add('Review recent spending connected to the predicted situation.');
        steps.add('Prepare a concise spending summary for review.');
        break;
      case 'tasks':
        steps.add('Identify the highest-impact pending task.');
        steps.add('Check whether an existing task can be carried forward or reordered.');
        break;
      case 'goals':
        steps.add('Review the next concrete milestone.');
        steps.add('Identify blockers from connected LifeOS signals.');
        break;
      case 'household':
        steps.add('Review recurring household requirements.');
        steps.add('Check whether the item already appears in recent records.');
        break;
      default:
        steps.add('Review the strongest connected LifeOS signals.');
        steps.add('Gather only the context needed for a clearer recommendation.');
    }

    if (context.isNotEmpty) {
      steps.add('Use existing context: ${context.take(3).join(', ')}.');
    }

    final mode = safeConfidence >= 75 && safePriority >= 70
        ? 'prepare_now'
        : horizon == 'within_24_hours'
            ? 'prepare_soon'
            : 'prepare';

    return {
      'mode': mode,
      'core': core,
      'horizon': horizon,
      'priority': safePriority,
      'confidence': safeConfidence,
      'steps': steps,
      'readOnly': true,
      'requiresConfirmationForAction': true,
    };
  }
}
