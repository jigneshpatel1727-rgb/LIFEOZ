/// Selects an adaptive presentation mode from current Yansi context.
class YansiAdaptiveUiIntelligenceEngine {
  const YansiAdaptiveUiIntelligenceEngine();

  Map<String, dynamic> select({
    required Map<String, dynamic> priority,
    required bool userActive,
    required bool quietHours,
  }) {
    if (quietHours) {
      return {'surface': 'ambient', 'density': 'minimal', 'voice': false};
    }

    final decision = (priority['decision'] ?? 'silent').toString();
    if (decision == 'silent') {
      return {'surface': 'orb', 'density': 'minimal', 'voice': false};
    }

    if (userActive) {
      return {
        'surface': 'context_panel',
        'density': 'focused',
        'voice': true,
        'selectedSignal': priority['selectedSignal'],
      };
    }

    return {
      'surface': 'ambient_orb',
      'density': 'minimal',
      'voice': false,
      'selectedSignal': priority['selectedSignal'],
    };
  }
}
