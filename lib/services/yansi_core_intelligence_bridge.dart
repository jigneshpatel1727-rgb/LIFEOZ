/// Unifies the five LifeOS core signals into one Yansi intelligence context.
class YansiCoreIntelligenceBridge {
  const YansiCoreIntelligenceBridge();

  Map<String, dynamic> build({
    required List<Map<String, dynamic>> expenses,
    required List<Map<String, dynamic>> tasks,
    required List<Map<String, dynamic>> calendar,
    required List<Map<String, dynamic>> household,
    required List<Map<String, dynamic>> goals,
  }) {
    return {
      'expense': _summary(expenses),
      'productivity': _summary(tasks),
      'calendar': _summary(calendar),
      'household': _summary(household),
      'goals': _summary(goals),
      'coreCount': 5,
      'intelligenceMode': 'unified_context',
    };
  }

  Map<String, dynamic> _summary(List<Map<String, dynamic>> records) {
    return {
      'count': records.length,
      'hasData': records.isNotEmpty,
    };
  }
}
