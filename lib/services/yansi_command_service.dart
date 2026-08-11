class YansiCommand {
  final YansiCommandType type;
  final String originalText;
  final String item;
  final String category;
  final double? amount;

  const YansiCommand({
    required this.type,
    required this.originalText,
    this.item = '',
    this.category = 'Other',
    this.amount,
  });
}

enum YansiCommandType {
  expense,
  task,
  reminder,
  diary,
  unknown,
}

class YansiCommandService {
  static YansiCommand understand(String text) {
    final original = text.trim();
    final command = original.toLowerCase();

    final amount = _extractAmount(command);

    // ----------------------------------------------------------
    // EXPENSE
    // ----------------------------------------------------------

    final isExpense = command.contains('spent') ||
        command.contains('spend') ||
        command.contains('paid') ||
        command.contains('pay') ||
        command.contains('bought') ||
        command.contains('buy') ||
        command.contains('purchase') ||
        command.contains('purchased') ||
        command.contains('expense');

    if (isExpense && amount != null) {
      return YansiCommand(
        type: YansiCommandType.expense,
        originalText: original,
        amount: amount,
        category: _detectCategory(command),
        item: _detectItem(command),
      );
    }

    // ----------------------------------------------------------
    // TASK
    // ----------------------------------------------------------

    final isTask = command.contains('task') ||
        command.contains('todo') ||
        command.contains('to do') ||
        command.contains('need to') ||
        command.contains('have to') ||
        command.contains('remind me to');

    if (isTask) {
      return YansiCommand(
        type: YansiCommandType.task,
        originalText: original,
        item: original,
      );
    }

    // ----------------------------------------------------------
    // REMINDER
    // ----------------------------------------------------------

    final isReminder = command.contains('reminder') ||
        command.contains('remind me') ||
        command.contains('remember to');

    if (isReminder) {
      return YansiCommand(
        type: YansiCommandType.reminder,
        originalText: original,
        item: original,
      );
    }

    // ----------------------------------------------------------
    // DIARY
    // ----------------------------------------------------------

    if (command.contains('diary') ||
        command.contains('journal') ||
        command.contains('today i') ||
        command.contains('today was') ||
        command.contains('i feel') ||
        command.contains('i am feeling')) {
      return YansiCommand(
        type: YansiCommandType.diary,
        originalText: original,
        item: original,
      );
    }

    // ----------------------------------------------------------
    // DEFAULT
    // ----------------------------------------------------------

    return YansiCommand(
      type: YansiCommandType.unknown,
      originalText: original,
      item: original,
    );
  }

  // ============================================================
  // AMOUNT DETECTION
  // ============================================================

  static double? _extractAmount(String text) {
    // ₹500
    final rupeeSymbol = RegExp(
      r'₹\s*(\d+(?:,\d{3})*(?:\.\d+)?)',
    ).firstMatch(text);

    if (rupeeSymbol != null) {
      return _parseNumber(rupeeSymbol.group(1));
    }

    // 500 rupees / 500 rs / 500 INR
    final currencyAmount = RegExp(
      r'(\d+(?:,\d{3})*(?:\.\d+)?)\s*(?:rupees|rs|inr)',
    ).firstMatch(text);

    if (currencyAmount != null) {
      return _parseNumber(currencyAmount.group(1));
    }

    // General number
    final number = RegExp(
      r'\b(\d+(?:,\d{3})*(?:\.\d+)?)\b',
    ).firstMatch(text);

    if (number != null) {
      return _parseNumber(number.group(1));
    }

    return null;
  }

  static double? _parseNumber(String? value) {
    if (value == null) return null;

    return double.tryParse(
      value.replaceAll(',', ''),
    );
  }

  // ============================================================
  // CATEGORY DETECTION
  // ============================================================

  static String _detectCategory(String text) {
    if (_containsAny(text, [
      'petrol',
      'fuel',
      'diesel',
      'cng',
      'gas',
    ])) {
      return 'Fuel';
    }

    if (_containsAny(text, [
      'milk',
      'grocery',
      'groceries',
      'vegetable',
      'vegetables',
      'rice',
      'flour',
      'oil',
      'household',
      'supermarket',
    ])) {
      return 'Household';
    }

    if (_containsAny(text, [
      'electricity',
      'electric bill',
      'water bill',
      'gas bill',
      'mobile bill',
      'phone bill',
      'internet bill',
      'bill',
      'emi',
      'loan',
    ])) {
      return 'Bills';
    }

    if (_containsAny(text, [
      'food',
      'restaurant',
      'hotel',
      'breakfast',
      'lunch',
      'dinner',
      'snacks',
      'snack',
      'tea',
      'coffee',
      'pizza',
    ])) {
      return 'Food';
    }

    if (_containsAny(text, [
      'medicine',
      'medical',
      'doctor',
      'hospital',
      'pharmacy',
    ])) {
      return 'Health';
    }

    if (_containsAny(text, [
      'movie',
      'shopping',
      'clothes',
      'entertainment',
      'game',
    ])) {
      return 'Lifestyle';
    }

    if (_containsAny(text, [
      'school',
      'college',
      'education',
      'book',
      'course',
    ])) {
      return 'Education';
    }

    return 'Other';
  }

  // ============================================================
  // ITEM DETECTION
  // ============================================================

  static String _detectItem(String text) {
    if (_containsAny(text, [
      'petrol',
      'fuel',
      'diesel',
      'cng',
    ])) {
      return 'Fuel';
    }

    if (_containsAny(text, [
      'milk',
    ])) {
      return 'Milk';
    }

    if (_containsAny(text, [
      'grocery',
      'groceries',
      'vegetable',
      'vegetables',
      'supermarket',
    ])) {
      return 'Groceries';
    }

    if (_containsAny(text, [
      'electricity',
      'electric bill',
    ])) {
      return 'Electricity Bill';
    }

    if (_containsAny(text, [
      'water bill',
    ])) {
      return 'Water Bill';
    }

    if (_containsAny(text, [
      'mobile bill',
      'phone bill',
    ])) {
      return 'Mobile Bill';
    }

    if (_containsAny(text, [
      'internet bill',
    ])) {
      return 'Internet Bill';
    }

    if (_containsAny(text, [
      'emi',
      'loan',
    ])) {
      return 'EMI';
    }

    if (_containsAny(text, [
      'medicine',
      'medical',
      'pharmacy',
    ])) {
      return 'Medicine';
    }

    if (_containsAny(text, [
      'restaurant',
      'food',
      'lunch',
      'dinner',
      'breakfast',
    ])) {
      return 'Food';
    }

    return 'Expense';
  }

  static bool _containsAny(
    String text,
    List<String> words,
  ) {
    for (final word in words) {
      if (text.contains(word)) {
        return true;
      }
    }

    return false;
  }
}
