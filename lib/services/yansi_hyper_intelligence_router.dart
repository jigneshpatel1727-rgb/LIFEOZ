/// A safe orchestration boundary for LifeOS hyper-intelligence.
///
/// This layer ranks already-derived signals for presentation. It does not
/// invent facts, call external services, mutate data, or execute actions.
class YansiHyperIntelligenceSignal {
  final String id;
  final String title;
  final String message;
  final int priority;
  final bool needsConfirmation;

  const YansiHyperIntelligenceSignal({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    this.needsConfirmation = false,
  });
}

class YansiHyperIntelligenceRouter {
  const YansiHyperIntelligenceRouter();

  List<YansiHyperIntelligenceSignal> rank(
    Iterable<YansiHyperIntelligenceSignal> signals,
  ) {
    final result = signals
        .where((signal) => signal.id.isNotEmpty && signal.message.isNotEmpty)
        .map((signal) => YansiHyperIntelligenceSignal(
              id: signal.id,
              title: signal.title,
              message: signal.message,
              priority: signal.priority.clamp(0, 100).toInt(),
              needsConfirmation: signal.needsConfirmation,
            ))
        .toList();

    result.sort((a, b) => b.priority.compareTo(a.priority));
    return List.unmodifiable(result);
  }

  YansiHyperIntelligenceSignal? top(
    Iterable<YansiHyperIntelligenceSignal> signals,
  ) {
    final ranked = rank(signals);
    return ranked.isEmpty ? null : ranked.first;
  }
}
