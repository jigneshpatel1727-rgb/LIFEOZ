import '../models/life_memory.dart';

class YansiDecision {
  final MemoryCore core;
  final MemorySource source;
  final String category;
  final double? amount;
  final String? entity;
  final String summary;
  final String response;
  final bool actionRequired;

  const YansiDecision({
    required this.core,
    required this.source,
    required this.category,
    required this.summary,
    required this.response,
    required this.actionRequired,
    this.amount,
    this.entity,
  });
}

class YansiBrain {
  YansiDecision understand({
    required String text,
    required String currency,
  }) {
    final lower = text.toLowerCase().trim();

    final amount = _extractAmount(lower);

    // ==========================================================
    // FINANCE
    // ==========================================================

    if (_containsAny(lower, [
      'spent',
      'spend',
      'paid',
      'pay',
      'bought',
      'purchase',
      'cost',
      'expense',
      'income',
      'salary',
      'received',
      'earned',
      'money',
      'saving',
      'savings',
    ])) {
      final category = _financeCategory(lower);

      return YansiDecision(
        core: MemoryCore.finance,
        source: MemorySource.voice,
        category: category,
        amount: amount,
        entity: _extractEntity(lower, category),
        summary: amount == null
            ? 'Financial information detected.'
            : '$currency${amount.toStringAsFixed(0)} $category transaction.',
        response: amount == null
            ? 'I understood that this is related to your finances. I have saved it in your Financial Life.'
            : 'Got it. I recorded $currency${amount.toStringAsFixed(0)} under $category.',
        actionRequired: false,
      );
    }

    // ==========================================================
    // HOUSEHOLD
    // ==========================================================

    if (_containsAny(lower, [
      'grocery',
      'groceries',
      'rice',
      'oil',
      'milk',
      'vegetables',
      'vegetable',
      'bread',
      'shopping',
      'household',
      'kitchen',
      'detergent',
      'soap',
      'toothpaste',
      'shampoo',
      'buy',
      'need',
      'out of',
      'finished',
    ])) {
      return YansiDecision(
        core: MemoryCore.household,
        source: MemorySource.voice,
        category: 'Household',
        amount: amount,
        entity: _extractHouseholdItem(lower),
        summary: 'Household requirement detected.',
        response:
            'Got it. I have added this to your Household intelligence.',
        actionRequired: false,
      );
    }

    // ==========================================================
    // PRODUCTIVITY
    // ==========================================================

    if (_containsAny(lower, [
      'task',
      'todo',
      'to do',
      'need to',
      'have to',
      'must',
      'finish',
      'complete',
      'call',
      'send',
      'meet',
      'meeting',
      'work',
      'job',
      'tomorrow',
      'today',
      'remind me',
      'remember to',
    ])) {
      return YansiDecision(
        core: MemoryCore.productivity,
        source: MemorySource.voice,
        category: 'Task',
        summary: 'Task or commitment detected.',
        response:
            'Got it. I have saved this as a task for you.',
        actionRequired: false,
      );
    }

    // ==========================================================
    // GOALS
    // ==========================================================

    if (_containsAny(lower, [
      'goal',
      'target',
      'achieve',
      'plan',
      'dream',
      'save for',
      'want to buy',
      'want to build',
      'want to start',
      'my future',
    ])) {
      return YansiDecision(
        core: MemoryCore.goals,
        source: MemorySource.voice,
        category: 'Goal',
        summary: 'Personal goal detected.',
        response:
            'I understand. I have saved this as part of your goals.',
        actionRequired: false,
      );
    }

    // ==========================================================
    // DIARY / EMOTIONAL CONVERSATION
    // ==========================================================

    if (_containsAny(lower, [
      'happy',
      'sad',
      'angry',
      'worried',
      'stress',
      'stressed',
      'tired',
      'exhausted',
      'frustrated',
      'excited',
      'afraid',
      'scared',
      'feeling',
      'today was',
      'my day',
      'i feel',
      'i am feeling',
    ])) {
      return YansiDecision(
        core: MemoryCore.diary,
        source: MemorySource.voice,
        category: 'Personal Reflection',
        summary:
            'A personal or emotional reflection was detected.',
        response:
            'I understand. I have saved this in your Life Diary so I can understand your journey better.',
        actionRequired: false,
      );
    }

    // ==========================================================
    // GENERAL CONVERSATION
    // ==========================================================

    return YansiDecision(
      core: MemoryCore.general,
      source: MemorySource.voice,
      category: 'Conversation',
      summary: 'General conversation with Yansi.',
      response:
          'I understand. I have remembered this conversation.',
      actionRequired: false,
    );
  }

  // ==========================================================
  // AMOUNT
  // ==========================================================

  double? _extractAmount(String text) {
    final patterns = [
      RegExp(
        r'(?:₹|rs\.?|rupees?)\s*([0-9]+(?:\.[0-9]+)?)',
        caseSensitive: false,
      ),
      RegExp(
        r'([0-9]+(?:\.[0-9]+)?)\s*(?:rupees|rs)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);

      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }

    return null;
  }

  // ==========================================================
  // FINANCE CATEGORY
  // ==========================================================

  String _financeCategory(String text) {
    if (_containsAny(text, [
      'petrol',
      'fuel',
      'diesel',
      'gas',
    ])) {
      return 'Fuel';
    }

    if (_containsAny(text, [
      'food',
      'restaurant',
      'lunch',
      'dinner',
      'breakfast',
      'coffee',
      'tea',
    ])) {
      return 'Food';
    }

    if (_containsAny(text, [
      'grocery',
      'groceries',
      'vegetables',
      'rice',
      'oil',
      'milk',
    ])) {
      return 'Grocery';
    }

    if (_containsAny(text, [
      'shirt',
      'clothes',
      'clothing',
      'dress',
      'jeans',
      'shoes',
      'mall',
    ])) {
      return 'Clothing';
    }

    if (_containsAny(text, [
      'electricity',
      'electric',
      'water bill',
      'gas bill',
      'mobile bill',
      'internet bill',
      'bill',
    ])) {
      return 'Bills';
    }

    if (_containsAny(text, [
      'salary',
      'income',
      'earned',
      'received',
    ])) {
      return 'Income';
    }

    if (_containsAny(text, [
      'investment',
      'mutual fund',
      'share',
      'stock',
      'sip',
    ])) {
      return 'Investment';
    }

    return 'Other';
  }

  String? _extractEntity(
    String text,
    String category,
  ) {
    switch (category) {
      case 'Fuel':
        return 'Fuel';

      case 'Food':
        return 'Food';

      case 'Grocery':
        return 'Grocery';

      case 'Clothing':
        return 'Clothing';

      case 'Bills':
        return 'Bill';

      case 'Investment':
        return 'Investment';

      default:
        return null;
    }
  }

  String? _extractHouseholdItem(String text) {
    const items = [
      'rice',
      'oil',
      'milk',
      'vegetables',
      'bread',
      'detergent',
      'soap',
      'toothpaste',
      'shampoo',
      'groceries',
    ];

    for (final item in items) {
      if (text.contains(item)) {
        return item;
      }
    }

    return null;
  }

  bool _containsAny(
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
