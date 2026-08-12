import '../models/life_entry.dart';
import 'life_database.dart';

class YansiResult {
  final String response;
  final LifeEntry? entry;

  YansiResult({
    required this.response,
    this.entry,
  });
}

class YansiEngine {
  static Future<YansiResult> process(
    String input,
  ) async {
    final text =
        input.toLowerCase().trim();

    // -----------------------------------------
    // EXPENSE DETECTION
    // -----------------------------------------

    final expenseWords = [
      'spent',
      'expense',
      'paid',
      'bought',
      'purchase',
    ];

    final isExpense =
        expenseWords.any(
      text.contains,
    );

    if (isExpense) {
      final amount =
          _extractAmount(text);

      final category =
          _detectExpenseCategory(text);

      if (amount > 0) {
        final entry = LifeEntry(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
          type: 'expense',
          title: category,
          description: input,
          amount: amount,
          category: category,
          date: DateTime.now(),
        );

        await LifeDatabase
            .saveEntry(entry);

        return YansiResult(
          response:
              'Got it. I added ₹${amount.toStringAsFixed(0)} to $category for today.',
          entry: entry,
        );
      }
    }

    // -----------------------------------------
    // TASK DETECTION
    // -----------------------------------------

    final taskWords = [
      'task',
      'todo',
      'to do',
      'need to',
      'have to',
      'finish',
    ];

    if (taskWords.any(
      text.contains,
    )) {
      final entry = LifeEntry(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        type: 'task',
        title: input,
        description: input,
        date: DateTime.now(),
      );

      await LifeDatabase.saveEntry(
        entry,
      );

      return YansiResult(
        response:
            'Done. I added that to your productivity list.',
        entry: entry,
      );
    }

    // -----------------------------------------
    // SHOPPING DETECTION
    // -----------------------------------------

    final shoppingWords = [
      'buy',
      'shopping',
      'grocery',
      'milk',
      'vegetables',
      'groceries',
    ];

    if (shoppingWords.any(
      text.contains,
    )) {
      final entry = LifeEntry(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        type: 'household',
        title: input,
        description: input,
        date: DateTime.now(),
      );

      await LifeDatabase.saveEntry(
        entry,
      );

      return YansiResult(
        response:
            'Added that to your household list.',
        entry: entry,
      );
    }

    return YansiResult(
      response:
          'I heard you. Tell me what you would like me to record or analyze.',
    );
  }

  static double _extractAmount(
    String text,
  ) {
    final match = RegExp(
      r'(\d+(?:\.\d+)?)',
    ).firstMatch(text);

    if (match == null) {
      return 0;
    }

    return double.tryParse(
          match.group(1)!,
        ) ??
        0;
  }

  static String _detectExpenseCategory(
    String text,
  ) {
    if (text.contains('petrol') ||
        text.contains('fuel') ||
        text.contains('diesel')) {
      return 'Fuel';
    }

    if (text.contains('food') ||
        text.contains('restaurant') ||
        text.contains('lunch') ||
        text.contains('dinner')) {
      return 'Food';
    }

    if (text.contains('medicine') ||
        text.contains('medical')) {
      return 'Medical';
    }

    if (text.contains('electricity')) {
      return 'Electricity';
    }

    if (text.contains('travel') ||
        text.contains('ticket')) {
      return 'Travel';
    }

    return 'Other';
  }
}
