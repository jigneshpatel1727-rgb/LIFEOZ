import 'lifeos_data_store.dart';

/// Builds a compact, privacy-aware snapshot of the five LifeOS cores for Yansi.
/// This keeps the AI context bounded instead of sending the entire local store.
class YansiCoreContextBuilder {
  final LifeOSDataStore store;
  const YansiCoreContextBuilder(this.store);

  Map<String, dynamic> build({int maxRowsPerCore = 20}) {
    return {
      'money': _recent('expenses', maxRowsPerCore),
      'productivity': _recent('tasks', maxRowsPerCore),
      'calendar': _recent('calendar', maxRowsPerCore),
      'household': _recent('household', maxRowsPerCore),
      'goals': _recent('goals', maxRowsPerCore),
      'generated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  List<Map<String, dynamic>> _recent(String collection, int limit) {
    final rows = store.read(collection);
    if (rows.length <= limit) return rows;
    return rows.sublist(rows.length - limit);
  }
}
