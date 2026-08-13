/// Prioritizes whole-Life signals so Yansi can remain proactive without becoming noisy.
class YansiAttentionPriorityEngine {
  const YansiAttentionPriorityEngine();

  List<Map<String, dynamic>> rank(Map<String, List<String>> signals) {
    final ranked = <Map<String, dynamic>>[];
    signals.forEach((core, values) {
      for (final signal in values) {
        final text = signal.trim();
        if (text.isEmpty) continue;
        var priority = 0.5;
        final lower = text.toLowerCase();
        if (lower.contains('due') || lower.contains('overdue')) priority += 0.3;
        if (lower.contains('urgent') || lower.contains('critical')) priority += 0.2;
        ranked.add({
          'core': core,
          'signal': text,
          'priority': priority.clamp(0.0, 1.0),
        });
      }
    });
    ranked.sort((a, b) =>
        (b['priority'] as double).compareTo(a['priority'] as double));
    return List.unmodifiable(ranked);
  }
}
