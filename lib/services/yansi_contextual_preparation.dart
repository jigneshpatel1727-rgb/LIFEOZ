/// Prioritizes safe preparation using current context without executing actions.
class YansiContextualPreparation {
  const YansiContextualPreparation();

  Map<String, dynamic> prioritize({
    required Map<String, dynamic> preparation,
    required List<Map<String, dynamic>> activeSignals,
    required bool userActive,
  }) {
    final basePriority = ((preparation['priority'] as num?)?.toInt() ?? 0).clamp(0, 100);
    final confidence = ((preparation['confidence'] as num?)?.toInt() ?? 0).clamp(0, 100);
    var boost = 0;
    final reasons = <String>[];

    for (final signal in activeSignals.take(8)) {
      final relevance = ((signal['relevance'] as num?)?.toInt() ?? 0).clamp(0, 100);
      if (relevance >= 70) {
        boost += 5;
        final label = '${signal['label'] ?? signal['core'] ?? 'related signal'}'.trim();
        if (label.isNotEmpty) reasons.add(label);
      }
    }

    final priority = (basePriority + boost.clamp(0, 20)).clamp(0, 100);
    final mode = priority >= 80 && confidence >= 70
        ? (userActive ? 'prepare_now' : 'prepare_next_active_window')
        : priority >= 60
            ? 'prepare_soon'
            : 'prepare_when_relevant';

    return {
      ...preparation,
      'priority': priority,
      'mode': mode,
      'contextBoost': boost.clamp(0, 20),
      'contextReasons': reasons,
      'readOnly': true,
      'requiresConfirmationForAction': true,
    };
  }
}
