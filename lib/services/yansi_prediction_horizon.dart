/// Learns when a verified pattern tends to matter without scheduling or executing actions.
/// Uses bounded historical timing evidence only.
class YansiPredictionHorizon {
  const YansiPredictionHorizon();

  Map<String, dynamic> estimate({
    required List<DateTime> occurrences,
    DateTime? now,
  }) {
    final dates = occurrences.map((e) => e.toUtc()).toList()..sort();
    final current = (now ?? DateTime.now()).toUtc();
    if (dates.length < 3) {
      return _result('unknown', null, 0.0, 'insufficient_timing_evidence');
    }

    final gaps = <int>[];
    for (var i = 1; i < dates.length; i++) {
      final gap = dates[i].difference(dates[i - 1]).inHours;
      if (gap > 0) gaps.add(gap);
    }
    if (gaps.length < 2) {
      return _result('unknown', null, 0.0, 'insufficient_interval_evidence');
    }

    final average = gaps.reduce((a, b) => a + b) / gaps.length;
    final variance = gaps
            .map((g) => (g - average) * (g - average))
            .reduce((a, b) => a + b) /
        gaps.length;
    final deviation = variance > 0 ? variance.sqrtApprox() : 0.0;
    final regularity = (1.0 - (deviation / (average + 1.0))).clamp(0.0, 1.0);
    final last = dates.last;
    final expected = last.add(Duration(hours: average.round()));
    final deltaHours = expected.difference(current).inHours;

    String horizon;
    if (deltaHours <= 0) {
      horizon = 'now';
    } else if (deltaHours <= 24) {
      horizon = 'within_24_hours';
    } else if (deltaHours <= 72) {
      horizon = 'within_3_days';
    } else if (deltaHours <= 168) {
      horizon = 'within_7_days';
    } else {
      horizon = 'beyond_7_days';
    }

    return _result(horizon, expected, regularity, 'repeated_timing_pattern');
  }

  Map<String, dynamic> _result(String horizon, DateTime? expected, double confidence, String source) => {
        'horizon': horizon,
        'expectedAt': expected?.toIso8601String(),
        'confidence': confidence.clamp(0.0, 1.0),
        'source': source,
        'bounded': true,
      };
}

extension on double {
  double sqrtApprox() {
    if (this <= 0) return 0.0;
    var x = this;
    var guess = x < 1 ? 1.0 : x;
    for (var i = 0; i < 12; i++) {
      guess = 0.5 * (guess + x / guess);
    }
    return guess;
  }
}
