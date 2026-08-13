import 'lifeos_intelligence_bus.dart';
import 'lifeos_signal_store.dart';

/// Converts Yansi's understood utterances into LifeOS signals while keeping
/// the UI independent from individual core implementations.
class YansiResponseRouter {
  final LifeOSSignalStore store;
  const YansiResponseRouter(this.store);

  bool route(String text) {
    final value = text.trim();
    if (value.isEmpty) return false;
    final lower = value.toLowerCase();

    final expense = RegExp(r'(?:₹|rs\.?|inr\s*)\s*([0-9]+(?:\.[0-9]+)?)').firstMatch(lower);
    if (expense != null) {
      final amount = double.tryParse(expense.group(1)!);
      if (amount != null) {
        final category = _category(lower);
        store.expense(amount, value, category: category);
        return true;
      }
    }

    if (_looksLikeTask(lower)) {
      store.task(value);
      return true;
    }

    if (_looksLikeCalendar(lower)) {
      store.calendar(value);
      return true;
    }

    store.record(LifeOSSignalType.voice, value);
    return true;
  }

  String _category(String text) {
    if (text.contains('fuel') || text.contains('petrol') || text.contains('diesel')) return 'Fuel';
    if (text.contains('grocery') || text.contains('vegetable') || text.contains('milk')) return 'Household';
    if (text.contains('medicine') || text.contains('hospital') || text.contains('doctor')) return 'Health';
    if (text.contains('bill') || text.contains('electricity') || text.contains('recharge')) return 'Bills';
    return 'Other';
  }

  bool _looksLikeTask(String text) =>
      text.startsWith('remind me to ') ||
      text.startsWith('i need to ') ||
      text.startsWith('todo ') ||
      text.contains('task is ');

  bool _looksLikeCalendar(String text) =>
      text.contains('tomorrow') ||
      text.contains('next week') ||
      text.contains('appointment') ||
      text.contains('birthday') ||
      text.contains('anniversary') ||
      text.contains('due date');
}
