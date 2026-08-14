/// Learns when a verified pattern tends to matter without pretending weak evidence is certain.
/// Uses bounded historical timing evidence only.
class YansiPredictionHorizon {
  const YansiPredictionHorizon();

  Map<String, dynamic> estimate({required List<DateTime> occurrences, DateTime? now}) {
    final dates = occurrences.map((e) => e.toUtc()).toList()..sort();
    final current = (now ?? DateTime.now()).toUtc();
    if (dates.length < 3) {
      return _fallback(dates, current, 'limited_history');
    }

    final gaps = <int>[];
    for (var i = 1; i < dates.length; i++) {
      final gap = dates[i].difference(dates[i - 1]).inHours;
      if (gap > 0) gaps.add(gap);
    }
    if (gaps.length < 2) return _fallback(dates, current, 'limited_intervals');

    final average = gaps.reduce((a, b) => a + b) / gaps.length;
    final variance = gaps.map((g) => (g - average) * (g - average)).reduce((a, b) => a + b) / gaps.length;
    final deviation = variance > 0 ? variance.sqrtApprox() : 0.0;
    final regularity = (1.0 - (deviation / (average + 1.0))).clamp(0.0, 1.0);
    final expected = dates.last.add(Duration(hours: average.round()));
    return _classify(expected, current, regularity, 'repeated_timing_pattern');
  }

  Map<String, dynamic> _fallback(List<DateTime> dates, DateTime current, String source) {
    if (dates.isEmpty) return _result('observe', null, 0.15, source, 'Keep watching for a repeatable pattern.');
    final last = dates.last;
    final ageHours = current.difference(last).inHours;
    if (ageHours <= 24) {
      return _result('watch_24h', last.add(const Duration(hours: 24)), 0.30, source, 'Recent evidence exists; Yansi should watch for supporting signals.');
    }
    return _result('observe', null, 0.20, source, 'Evidence is not yet regular enough for a time prediction; continue learning quietly.');
  }

  Map<String, dynamic> _classify(DateTime expected, DateTime current, double confidence, String source) {
    final deltaHours = expected.difference(current).inHours;
    String horizon;
    if (deltaHours <= 0) horizon = 'now';
    else if (deltaHours <= 24) horizon = 'within_24_hours';
    else if (deltaHours <= 72) horizon = 'within_3_days';
    else if (deltaHours <= 168) horizon = 'within_7_days';
    else horizon = 'beyond_7_days';
    return _result(horizon, expected, confidence, source, 'A recurring timing pattern supports this estimate.');
  }

  Map<String, dynamic> _result(String horizon, DateTime? expected, double confidence, String source, String guidance) => {
    'horizon': horizon,
    'expectedAt': expected?.toIso8601String(),
    'confidence': confidence.clamp(0.0, 1.0),
    'source': source,
    'guidance': guidance,
    'bounded': true,
  };
}

extension on double {
  double sqrtApprox() {
    if (this <= 0) return 0.0;
    var guess = this < 1 ? 1.0 : this;
    for (var i = 0; i < 12; i++) guess = 0.5 * (guess + this / guess);
    return guess;
  }
}
