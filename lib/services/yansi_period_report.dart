import 'lifeos_data_store.dart';

/// Builds date-bucketed read-only summaries for Yansi.
class YansiPeriodReport {
  final LifeOSDataStore store;
  const YansiPeriodReport(this.store);

  Map<String, dynamic> forRange(DateTime from, DateTime to) {
    final collections = <String>['money', 'tasks', 'household', 'calendar', 'goals'];
    final result = <String, dynamic>{};
    for (final collection in collections) {
      final rows = store.read(collection).where((row) {
        final raw = row['timestamp']?.toString();
        final parsed = raw == null ? null : DateTime.tryParse(raw);
        return parsed != null && !parsed.isBefore(from) && parsed.isBefore(to);
      }).toList();
      result[collection] = {
        'count': rows.length,
        'records': rows,
      };
    }
    result['from'] = from.toUtc().toIso8601String();
    result['to'] = to.toUtc().toIso8601String();
    return result;
  }

  Map<String, dynamic> month(int year, int month) =>
      forRange(DateTime.utc(year, month), DateTime.utc(year, month + 1));

  Map<String, dynamic> year(int year) =>
      forRange(DateTime.utc(year), DateTime.utc(year + 1));
}
