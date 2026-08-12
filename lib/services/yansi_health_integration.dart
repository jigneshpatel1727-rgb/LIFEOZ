/// Permission-controlled health integration boundary for Yansi.
/// Platform adapters (Health Connect/watch providers) can feed approved data
/// into this model without exposing credentials or requiring a vendor here.
class YansiHealthSample {
  final String metric;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String source;

  const YansiHealthSample({
    required this.metric,
    required this.value,
    required this.unit,
    required this.recordedAt,
    required this.source,
  });

  Map<String, dynamic> toMap() => {
        'metric': metric,
        'value': value,
        'unit': unit,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
        'source': source,
      };
}

class YansiHealthSummary {
  final int sampleCount;
  final Map<String, double> latest;

  const YansiHealthSummary({required this.sampleCount, required this.latest});
}

class YansiHealthIntegration {
  const YansiHealthIntegration();

  YansiHealthSummary summarize(Iterable<YansiHealthSample> samples) {
    final latest = <String, YansiHealthSample>{};
    var count = 0;
    for (final sample in samples) {
      count++;
      final previous = latest[sample.metric];
      if (previous == null || sample.recordedAt.isAfter(previous.recordedAt)) {
        latest[sample.metric] = sample;
      }
    }
    return YansiHealthSummary(
      sampleCount: count,
      latest: {
        for (final entry in latest.entries) entry.key: entry.value.value,
      },
    );
  }
}
