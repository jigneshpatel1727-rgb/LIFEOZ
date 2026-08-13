/// Synthesizes connected personal signals into an explainable reason for attention.
class YansiPersonalReasoningSynthesisEngine {
  const YansiPersonalReasoningSynthesisEngine();

  Map<String, dynamic> synthesize({
    required List<Map<String, dynamic>> signals,
    required String currentContext,
  }) {
    final relevant = signals.where((signal) {
      final text = signal.values.map((value) => value.toString().toLowerCase()).join(' ');
      return currentContext
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((word) => word.length > 2)
          .any(text.contains);
    }).toList(growable: false);

    return {
      'context': currentContext,
      'relevantSignals': List.unmodifiable(relevant),
      'signalCount': relevant.length,
      'reason': relevant.isEmpty
          ? 'No strong historical connection was found.'
          : 'Historical LifeOS context contains related signals that may explain why this matters now.',
      'explainable': true,
      'confidence': relevant.isEmpty ? 'low' : 'contextual',
    };
  }
}
