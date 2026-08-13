/// Central orchestration plan across LifeOS domains.
/// Produces recommendations and execution intents; sensitive execution remains guarded.
class YansiLifeOsOrchestrationEngine {
  const YansiLifeOsOrchestrationEngine();

  Map<String, dynamic> plan({
    required List<String> priorities,
    required List<String> availableDomains,
  }) {
    final domains = List<String>.from(availableDomains);
    final actions = <Map<String, dynamic>>[];

    for (final priority in priorities.take(10)) {
      final lower = priority.toLowerCase();
      String? domain;
      if (lower.contains('financial')) domain = 'expenses';
      if (lower.contains('goal')) domain = 'goals';
      if (lower.contains('task') || lower.contains('productivity')) domain = 'tasks';
      if (domain != null && domains.contains(domain)) {
        actions.add({
          'domain': domain,
          'priority': priority,
          'state': 'recommendation',
          'requiresSensitiveActionGuard': true,
        });
      }
    }

    return {
      'actions': List.unmodifiable(actions),
      'domains': List.unmodifiable(domains),
      'executionMode': 'guarded',
    };
  }
}
