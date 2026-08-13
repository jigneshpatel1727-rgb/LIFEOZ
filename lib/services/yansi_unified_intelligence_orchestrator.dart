/// Combines major Yansi intelligence signals into one prioritized context.
class YansiUnifiedIntelligenceOrchestrator {
  const YansiUnifiedIntelligenceOrchestrator();

  Map<String, dynamic> orchestrate({
    required Map<String, dynamic> coreContext,
    required List<Map<String, dynamic>> memorySignals,
    required List<Map<String, dynamic>> predictiveSignals,
    required List<Map<String, dynamic>> webSignals,
    required List<Map<String, dynamic>> healthSignals,
  }) {
    final signals = <Map<String, dynamic>>[
      ...memorySignals.map((s) => {...s, 'domain': 'memory'}),
      ...predictiveSignals.map((s) => {...s, 'domain': 'prediction'}),
      ...webSignals.map((s) => {...s, 'domain': 'web'}),
      ...healthSignals.map((s) => {...s, 'domain': 'health'}),
    ];

    return {
      'coreContext': Map<String, dynamic>.from(coreContext),
      'signals': List.unmodifiable(signals),
      'signalCount': signals.length,
      'mode': 'unified_yansi_intelligence',
      'requiresGuardedAction': true,
    };
  }
}
