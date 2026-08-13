/// Adds time-aware context to LifeOS intelligence without performing external access.
class YansiTemporalContextEngine {
  const YansiTemporalContextEngine();

  Map<String, dynamic> now({DateTime? value}) {
    final current = value ?? DateTime.now();
    return {
      'iso': current.toIso8601String(),
      'hour': current.hour,
      'weekday': current.weekday,
      'isWeekend': current.weekday >= DateTime.saturday,
      'partOfDay': _partOfDay(current.hour),
    };
  }

  String _partOfDay(int hour) {
    if (hour < 6) return 'night';
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }
}
