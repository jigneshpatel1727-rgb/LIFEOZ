/// Filters Yansi insights before they reach the ambient experience.
/// This is deliberately read-only and never performs an action.
class YansiProactiveSignalFilter {
  const YansiProactiveSignalFilter();

  Map<String, dynamic> filter({
    required bool available,
    required int priority,
    bool repeated = false,
    bool quietHours = false,
  }) {
    final score = priority.clamp(0, 100).toInt();

    if (!available || repeated || score < 70) {
      return const {
        'surface': false,
        'voice': false,
        'priority': 0,
      };
    }

    final critical = score >= 90;
    return {
      'surface': true,
      'voice': critical && !quietHours,
      'priority': score,
    };
  }
}
