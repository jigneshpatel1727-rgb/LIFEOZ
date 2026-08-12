import '../models/life_memory.dart';

/// ============================================================
/// YANSI BRAIN V2
/// ============================================================
///
/// Local intelligence layer for LifeOS.
///
/// Responsibilities:
/// - Understand natural language
/// - Identify LifeOS core
/// - Detect category
/// - Extract money
/// - Detect common household items
/// - Detect tasks
/// - Detect goals
/// - Detect diary/emotional signals
/// - Detect calendar/date signals
/// - Produce a natural Yansi response
///
/// This is intentionally a local foundation.
/// Later, a real AI model will be connected above this layer
/// for deeper reasoning and complex conversations.
/// ============================================================

class YansiDecision {
  final MemoryCore core;
  final MemorySource source;

  final String category;

  final double? amount;

  final String? entity;

  final DateTime? relatedDate;

  final String summary;

  final String response;

  final bool actionRequired;

  final Map<String, dynamic> extractedData;

  const YansiDecision({
    required this.core,
    required this.source,
    required this.category,
    required this.summary,
    required this.response,
    required this.actionRequired,
    required this.extractedData,
    this.amount,
    this.entity,
    this.relatedDate,
  });
}

class YansiBrain {
  // ==========================================================
  // MAIN UNDERSTANDING FUNCTION
  // ==========================================================

  YansiDecision understand({
    required String text,
    required String currency,
    MemorySource source = MemorySource.voice,
  }) {
    final original = text.trim();

    final lower = original.toLowerCase();

    if (lower.isEmpty) {
      return const YansiDecision(
        core: MemoryCore.general,
        source: MemorySource.voice,
        category: 'Conversation',
        summary: 'Empty input.',
        response: 'I am listening.',
        actionRequired: false,
        extractedData: {},
      );
    }

    // ========================================================
    // EXTRACT COMMON INFORMATION
    // ========================================================

    final amount = _extractAmount(lower);

    final relatedDate =
        _extractRelatedDate(lower);

    // ========================================================
    // FINANCE
    // ========================================================

    if (_isFinance(lower)) {
      return _financeDecision(
        text: original,
        lower: lower,
        currency: currency,
        amount: amount,
        relatedDate: relatedDate,
        source: source,
      );
    }

    // ========================================================
    // HOUSEHOLD
    // ========================================================

    if (_isHousehold(lower)) {
      return _householdDecision(
        text: original,
        lower: lower,
        currency: currency,
        amount: amount,
        relatedDate: relatedDate,
        source: source,
      );
    }

    // ========================================================
    // PRODUCTIVITY
    // ========================================================

    if (_isProductivity(lower)) {
      return _productivityDecision(
        text: original,
        lower: lower,
        relatedDate: relatedDate,
        source: source,
      );
    }

    // ========================================================
    // GOALS
    // ========================================================

    if (_isGoal(lower)) {
      return _goalDecision(
        text: original,
        lower: lower,
        amount: amount,
        source: source,
      );
    }

    // ========================================================
    // CALENDAR
    // ========================================================

    if (_isCalendar(lower)) {
      return _calendarDecision(
        text: original,
        lower: lower,
        relatedDate: relatedDate,
        source: source,
      );
    }

    // ========================================================
    // EMOTIONAL / DIARY
    // ========================================================

    if (_isDiary(lower)) {
      return _diaryDecision(
        text: original,
        lower: lower,
        source: source,
      );
    }

    // ========================================================
    // GENERAL CONVERSATION
    // ========================================================

    return YansiDecision(
      core: MemoryCore.general,
      source: source,
      category: 'Conversation',
      summary:
          'General conversation with Yansi.',
      response:
          _generalResponse(original),
      actionRequired: false,
      extractedData: {
        'type': 'conversation',
        'originalText': original,
      },
    );
  }

  // ==========================================================
  // FINANCE
  // ==========================================================

  YansiDecision _financeDecision({
    required String text,
    required String lower,
    required String currency,
    required double? amount,
    required DateTime? relatedDate,
    required MemorySource source,
  }) {
    final category =
        _financeCategory(lower);

    final entity =
        _financeEntity(lower, category);

    final isIncome =
        _isIncome(lower);

    final action =
        amount != null;

    String response;

    if (amount != null) {
      final formatted =
          '$currency${amount.toStringAsFixed(0)}';

      if (isIncome) {
        response =
            'Got it. I recorded $formatted as $category income.';
      } else {
        response =
            'Got it. I recorded $formatted under $category.';
      }
    } else {
      response =
          'I understood that this is related to your finances. I have saved it in your Financial Life.';
    }

    return YansiDecision(
      core: MemoryCore.finance,
      source: source,
      category: category,
      amount: amount,
      entity: entity,
      relatedDate: relatedDate,
      summary: amount == null
          ? 'Financial information detected.'
          : '${isIncome ? 'Income' : 'Expense'} of '
              '$currency${amount.toStringAsFixed(0)} '
              'under $category.',
      response: response,
      actionRequired: false,
      extractedData: {
        'type':
            isIncome ? 'income' : 'expense',
        'amount': amount,
        'category': category,
        'entity': entity,
        'date':
            relatedDate?.toIso8601String(),
        'originalText': text,
      },
    );
  }

  // ==========================================================
  // HOUSEHOLD
  // ==========================================================

  YansiDecision _householdDecision({
    required String text,
    required String lower,
    required String currency,
    required double? amount,
    required DateTime? relatedDate,
    required MemorySource source,
  }) {
    final item =
        _householdItem(lower);

    final category =
        item == null
            ? 'Household'
            : 'Household Requirement';

    String response;

    if (item != null) {
      response =
          'Got it. I added $item to your Household intelligence.';
    } else {
      response =
          'Got it. I saved this as a household requirement.';
    }

    return YansiDecision(
      core: MemoryCore.household,
      source: source,
      category: category,
      amount: amount,
      entity: item,
      relatedDate: relatedDate,
      summary: item == null
          ? 'Household requirement detected.'
          : 'Household requirement: $item.',
      response: response,
      actionRequired: false,
      extractedData: {
        'type': 'household',
        'item': item,
        'amount': amount,
        'date':
            relatedDate?.toIso8601String(),
        'originalText': text,
      },
    );
  }

  // ==========================================================
  // PRODUCTIVITY
  // ==========================================================

  YansiDecision _productivityDecision({
    required String text,
    required String lower,
    required DateTime? relatedDate,
    required MemorySource source,
  }) {
    final task =
        _cleanTask(text);

    final response =
        relatedDate == null
            ? 'Got it. I saved this as a task.'
            : 'Got it. I saved this as a task for ${_dateName(relatedDate)}.';

    return YansiDecision(
      core: MemoryCore.productivity,
      source: source,
      category: 'Task',
      entity: task,
      relatedDate: relatedDate,
      summary:
          'Productivity task detected.',
      response: response,
      actionRequired: false,
      extractedData: {
        'type': 'task',
        'task': task,
        'date':
            relatedDate?.toIso8601String(),
        'originalText': text,
      },
    );
  }

  // ==========================================================
  // GOAL
  // ==========================================================

  YansiDecision _goalDecision({
    required String text,
    required String lower,
    required double? amount,
    required MemorySource source,
  }) {
    final goal =
        text.trim();

    final response =
        amount == null
            ? 'I understand. I have saved this as one of your goals.'
            : 'I understand. I have saved this goal with a target of ${amount.toStringAsFixed(0)}.';

    return YansiDecision(
      core: MemoryCore.goals,
      source: source,
      category: 'Goal',
      amount: amount,
      entity: goal,
      summary:
          'Personal goal or future target detected.',
      response: response,
      actionRequired: false,
      extractedData: {
        'type': 'goal',
        'goal': goal,
        'targetAmount': amount,
        'originalText': text,
      },
    );
  }

  // ==========================================================
  // CALENDAR
  // ==========================================================

  YansiDecision _calendarDecision({
    required String text,
    required String lower,
    required DateTime? relatedDate,
    required MemorySource source,
  }) {
    final response =
        relatedDate == null
            ? 'Got it. I saved this for your Life Calendar.'
            : 'Got it. I saved this for ${_dateName(relatedDate)}.';

    return YansiDecision(
      core: MemoryCore.calendar,
      source: source,
      category: 'Event',
      entity: text,
      relatedDate: relatedDate,
      summary:
          'Calendar or important date detected.',
      response: response,
      actionRequired: false,
      extractedData: {
        'type': 'calendar',
        'event': text,
        'date':
            relatedDate?.toIso8601String(),
        'originalText': text,
      },
    );
  }

  // ==========================================================
  // DIARY
  // ==========================================================

  YansiDecision _diaryDecision({
    required String text,
    required String lower,
    required MemorySource source,
  }) {
    final emotion =
        _detectEmotion(lower);

    String response;

    if (emotion == null) {
      response =
          'I understand. I have saved this in your Life Diary.';
    } else {
      response =
          'I understand. It sounds like you may be feeling $emotion. I have saved this in your Life Diary.';
    }

    return YansiDecision(
      core: MemoryCore.diary,
      source: source,
      category: 'Personal Reflection',
      entity: emotion,
      summary:
          emotion == null
              ? 'Personal reflection detected.'
              : 'Personal reflection with possible $emotion emotional signal.',
      response: response,
      actionRequired: false,
      extractedData: {
        'type': 'diary',
        'possibleEmotion': emotion,
        'originalText': text,
      },
    );
  }

  // ==========================================================
  // FINANCE DETECTION
  // ==========================================================

  bool _isFinance(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'spent',
        'spend',
        'paid',
        'pay',
        'bought',
        'purchase',
        'purchased',
        'cost',
        'expense',
        'income',
        'salary',
        'received',
        'earned',
        'money',
        'saving',
        'savings',
        'investment',
        'invest',
        'sip',
        'mutual fund',
        'stock',
        'share',
        'petrol',
        'fuel',
        'diesel',
        'electricity bill',
        'water bill',
        'mobile bill',
        'internet bill',
      ],
    );
  }

  bool _isIncome(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'salary',
        'income',
        'earned',
        'received',
        'got paid',
      ],
    );
  }

  String _financeCategory(
    String text,
  ) {
    if (_containsAny(
      text,
      [
        'petrol',
        'fuel',
        'diesel',
        'gas',
      ],
    )) {
      return 'Fuel';
    }

    if (_containsAny(
      text,
      [
        'food',
        'restaurant',
        'lunch',
        'dinner',
        'breakfast',
        'coffee',
        'tea',
      ],
    )) {
      return 'Food';
    }

    if (_containsAny(
      text,
      [
        'grocery',
        'groceries',
        'rice',
        'oil',
        'milk',
        'vegetables',
      ],
    )) {
      return 'Grocery';
    }

    if (_containsAny(
      text,
      [
        'shirt',
        'shirts',
        'clothes',
        'clothing',
        'dress',
        'jeans',
        'shoes',
        'mall',
      ],
    )) {
      return 'Clothing';
    }

    if (_containsAny(
      text,
      [
        'electricity',
        'electric bill',
        'water bill',
        'gas bill',
        'mobile bill',
        'internet bill',
        'bill',
      ],
    )) {
      return 'Bills';
    }

    if (_containsAny(
      text,
      [
        'salary',
        'income',
        'earned',
        'received',
      ],
    )) {
      return 'Income';
    }

    if (_containsAny(
      text,
      [
        'investment',
        'invest',
        'mutual fund',
        'share',
        'stock',
        'sip',
      ],
    )) {
      return 'Investment';
    }

    return 'Other';
  }

  String? _financeEntity(
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

  // ==========================================================
  // HOUSEHOLD DETECTION
  // ==========================================================

  bool _isHousehold(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'household',
        'kitchen',
        'grocery',
        'groceries',
        'rice',
        'cooking oil',
        'milk',
        'vegetables',
        'vegetable',
        'bread',
        'detergent',
        'soap',
        'toothpaste',
        'shampoo',
        'dishwash',
        'cleaning',
        'we need',
        'running out',
        'run out',
        'finished',
      ],
    );
  }

  String? _householdItem(
    String text,
  ) {
    const items = [
      'rice',
      'cooking oil',
      'oil',
      'milk',
      'vegetables',
      'vegetable',
      'bread',
      'detergent',
      'soap',
      'toothpaste',
      'shampoo',
      'dishwash',
      'cleaning',
      'groceries',
    ];

    for (final item in items) {
      if (text.contains(item)) {
        return item;
      }
    }

    return null;
  }

  // ==========================================================
  // PRODUCTIVITY DETECTION
  // ==========================================================

  bool _isProductivity(
    String text,
  ) {
    return _containsAny(
      text,
      [
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
        'remind me',
        'remember to',
        'tomorrow',
        'today',
      ],
    );
  }

  // ==========================================================
  // GOAL DETECTION
  // ==========================================================

  bool _isGoal(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'my goal',
        'goal is',
        'target is',
        'want to achieve',
        'want to save',
        'save for',
        'dream',
        'future goal',
        'long term',
        'long-term',
      ],
    );
  }

  // ==========================================================
  // CALENDAR DETECTION
  // ==========================================================

  bool _isCalendar(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'appointment',
        'birthday',
        'anniversary',
        'renewal',
        'renew',
        'due date',
        'service due',
        'checkup',
        'meeting on',
        'appointment on',
        'on monday',
        'on tuesday',
        'on wednesday',
        'on thursday',
        'on friday',
        'on saturday',
        'on sunday',
      ],
    );
  }

  // ==========================================================
  // DIARY DETECTION
  // ==========================================================

  bool _isDiary(
    String text,
  ) {
    return _containsAny(
      text,
      [
        'i feel',
        'i am feeling',
        'feeling',
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
        'good day',
        'bad day',
        'today was',
        'my day',
      ],
    );
  }

  // ==========================================================
  // EMOTION SIGNAL
  // ==========================================================

  String? _detectEmotion(
    String text,
  ) {
    if (_containsAny(
      text,
      [
        'stressed',
        'stress',
        'worried',
        'anxious',
        'afraid',
        'scared',
      ],
    )) {
      return 'stressed or worried';
    }

    if (_containsAny(
      text,
      [
        'tired',
        'exhausted',
        'drained',
      ],
    )) {
      return 'tired';
    }

    if (_containsAny(
      text,
      [
        'angry',
        'frustrated',
        'annoyed',
      ],
    )) {
      return 'frustrated';
    }

    if (_containsAny(
      text,
      [
        'sad',
        'unhappy',
        'down',
      ],
    )) {
      return 'sad';
    }

    if (_containsAny(
      text,
      [
        'happy',
        'great',
        'excited',
        'good',
      ],
    )) {
      return 'positive';
    }

    return null;
  }

  // ==========================================================
  // AMOUNT EXTRACTION
  // ==========================================================

  double? _extractAmount(
    String text,
  ) {
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
      final match =
          pattern.firstMatch(text);

      if (match != null) {
        return double.tryParse(
          match.group(1)!,
        );
      }
    }

    return null;
  }

  // ==========================================================
  // DATE EXTRACTION
  // ==========================================================

  DateTime? _extractRelatedDate(
    String text,
  ) {
    final now = DateTime.now();

    if (text.contains('today')) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      );
    }

    if (text.contains('tomorrow')) {
      final tomorrow =
          now.add(
        const Duration(days: 1),
      );

      return DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
      );
    }

    if (text.contains('day after tomorrow')) {
      final date =
          now.add(
        const Duration(days: 2),
      );

      return DateTime(
        date.year,
        date.month,
        date.day,
      );
    }

    const weekdays = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };

    for (final entry in weekdays.entries) {
      if (text.contains(
        'on ${entry.key}',
      )) {
        final current =
            DateTime.now();

        int difference =
            entry.value -
                current.weekday;

        if (difference <= 0) {
          difference += 7;
        }

        final date =
            current.add(
          Duration(
            days: difference,
          ),
        );

        return DateTime(
          date.year,
          date.month,
          date.day,
        );
      }
    }

    return null;
  }

  // ==========================================================
  // TASK CLEANING
  // ==========================================================

  String _cleanTask(
    String text,
  ) {
    var task = text.trim();

    final prefixes = [
      'remind me to ',
      'remember to ',
      'i need to ',
      'i have to ',
      'i must ',
    ];

    final lower =
        task.toLowerCase();

    for (final prefix in prefixes) {
      if (lower.startsWith(prefix)) {
        task = task.substring(
          prefix.length,
        );

        break;
      }
    }

    return task.trim();
  }

  // ==========================================================
  // GENERAL RESPONSE
  // ==========================================================

  String _generalResponse(
    String text,
  ) {
    if (_containsAny(
      text.toLowerCase(),
      [
        'how are you',
        'hello',
        'hi yansi',
        'hi',
        'hey',
      ],
    )) {
      return 'I am here with you. What would you like to talk about?';
    }

    if (_containsAny(
      text.toLowerCase(),
      [
        'help me',
        'what should i do',
        'what can i do',
      ],
    )) {
      return 'I am listening. Tell me what is happening and I will help you think through it.';
    }

    return 'I understand. I am here with you. Tell me more.';
  }

  // ==========================================================
  // DATE NAME
  // ==========================================================

  String _dateName(
    DateTime date,
  ) {
    final now =
        DateTime.now();

    final today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final target =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        target.difference(today).inDays;

    if (difference == 0) {
      return 'today';
    }

    if (difference == 1) {
      return 'tomorrow';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  // ==========================================================
  // HELPER
  // ==========================================================

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
