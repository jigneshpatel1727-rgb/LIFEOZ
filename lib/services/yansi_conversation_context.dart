import '../models/life_memory.dart';
import 'yansi_memory.dart';
import 'yansi_life_coordinator.dart';

/// ============================================================
/// YANSI CONVERSATION CONTEXT ENGINE
/// ============================================================
///
/// Gives Yansi contextual understanding of the user's LifeOS.
///
/// It combines:
///
/// - Current user message
/// - Recent LifeOS memories
/// - Relevant memories
/// - Five-core status
/// - Financial status
/// - Household information
/// - Important warnings
/// - Suggested actions
///
/// This layer prepares CONTEXT.
/// It does not itself call an external AI service.
///
/// Later:
///
/// Voice
///   ↓
/// Speech-to-text
///   ↓
/// ConversationContext
///   ↓
/// AI Brain
///   ↓
/// Response
///   ↓
/// Text + Voice
///   ↓
/// LifeOS Memory
/// ============================================================

class YansiConversationContext {
  final String userMessage;

  final DateTime createdAt;

  final List<LifeMemory> recentMemories;

  final List<LifeMemory> relevantMemories;

  final YansiLifeSnapshot lifeSnapshot;

  final List<String> crossCoreInsights;

  final List<String> dailyBriefing;

  final List<String> suggestedTopics;

  const YansiConversationContext({
    required this.userMessage,
    required this.createdAt,
    required this.recentMemories,
    required this.relevantMemories,
    required this.lifeSnapshot,
    required this.crossCoreInsights,
    required this.dailyBriefing,
    required this.suggestedTopics,
  });

  /// ==========================================================
  /// SHORT AI CONTEXT
  /// ==========================================================
  ///
  /// Creates compact context for an AI model.
  ///
  /// We deliberately avoid sending the entire LifeOS history
  /// every time.
  ///
  /// This keeps responses faster and reduces unnecessary
  /// exposure of personal information.
  /// ==========================================================

  String toPromptContext() {
    final buffer =
        StringBuffer();

    buffer.writeln(
      'USER MESSAGE:',
    );

    buffer.writeln(
      userMessage,
    );

    buffer.writeln();

    buffer.writeln(
      'LIFEOS STATUS:',
    );

    buffer.writeln(
      'Total memories: '
      '${lifeSnapshot.totalMemories}',
    );

    buffer.writeln(
      'Finance records: '
      '${lifeSnapshot.financeMemories}',
    );

    buffer.writeln(
      'Goal records: '
      '${lifeSnapshot.goalMemories}',
    );

    buffer.writeln(
      'Productivity records: '
      '${lifeSnapshot.productivityMemories}',
    );

    buffer.writeln(
      'Household records: '
      '${lifeSnapshot.householdMemories}',
    );

    buffer.writeln(
      'Diary records: '
      '${lifeSnapshot.diaryMemories}',
    );

    buffer.writeln(
      'Calendar records: '
      '${lifeSnapshot.calendarMemories}',
    );

    buffer.writeln();

    buffer.writeln(
      'FINANCIAL CONTEXT:',
    );

    buffer.writeln(
      'Monthly income: '
      '${lifeSnapshot.monthlyIncome}',
    );

    buffer.writeln(
      'Monthly commitments: '
      '${lifeSnapshot.monthlyCommitments}',
    );

    buffer.writeln(
      'Planned savings: '
      '${lifeSnapshot.plannedSavings}',
    );

    buffer.writeln(
      'Current month spending: '
      '${lifeSnapshot.currentMonthSpending}',
    );

    buffer.writeln(
      'Projected month spending: '
      '${lifeSnapshot.projectedMonthSpending}',
    );

    buffer.writeln();

    if (lifeSnapshot.householdRequirements
        .isNotEmpty) {
      buffer.writeln(
        'HOUSEHOLD REQUIREMENTS:',
      );

      for (final item
          in lifeSnapshot
              .householdRequirements
              .take(10)) {
        buffer.writeln(
          '- $item',
        );
      }

      buffer.writeln();
    }

    if (lifeSnapshot.financialWarnings
        .isNotEmpty) {
      buffer.writeln(
        'IMPORTANT WARNINGS:',
      );

      for (final warning
          in lifeSnapshot
              .financialWarnings
              .take(5)) {
        buffer.writeln(
          '- $warning',
        );
      }

      buffer.writeln();
    }

    if (lifeSnapshot.financialSuggestions
        .isNotEmpty) {
      buffer.writeln(
        'SUGGESTIONS:',
      );

      for (final suggestion
          in lifeSnapshot
              .financialSuggestions
              .take(5)) {
        buffer.writeln(
          '- $suggestion',
        );
      }

      buffer.writeln();
    }

    if (relevantMemories
        .isNotEmpty) {
      buffer.writeln(
        'RELEVANT USER MEMORY:',
      );

      for (final memory
          in relevantMemories
              .take(8)) {
        buffer.writeln(
          '- ${memory.originalText}',
        );
      }

      buffer.writeln();
    }

    return buffer.toString();
  }
}

/// ============================================================
/// CONTEXT BUILDER
/// ============================================================

class YansiConversationContextEngine {
  final YansiMemory yansiMemory;

  final YansiLifeCoordinator
      lifeCoordinator;

  YansiConversationContextEngine({
    required this.yansiMemory,
    required this.lifeCoordinator,
  });

  // ==========================================================
  // BUILD CONTEXT
  // ==========================================================

  YansiConversationContext build(
    String userMessage, {
    int recentLimit = 12,
    int relevantLimit = 10,
  }) {
    final cleanMessage =
        userMessage.trim();

    final allMemories =
        yansiMemory.getAll();

    final recent =
        _recentMemories(
      allMemories,
      recentLimit,
    );

    final relevant =
        _findRelevantMemories(
      cleanMessage,
      allMemories,
      relevantLimit,
    );

    final snapshot =
        lifeCoordinator
            .createSnapshot();

    final crossCore =
        lifeCoordinator
            .crossCoreInsights();

    final briefing =
        lifeCoordinator
            .dailyBriefing();

    final topics =
        _suggestTopics(
      cleanMessage,
      snapshot,
    );

    return YansiConversationContext(
      userMessage:
          cleanMessage,
      createdAt:
          DateTime.now(),
      recentMemories:
          List.unmodifiable(
        recent,
      ),
      relevantMemories:
          List.unmodifiable(
        relevant,
      ),
      lifeSnapshot:
          snapshot,
      crossCoreInsights:
          List.unmodifiable(
        crossCore,
      ),
      dailyBriefing:
          List.unmodifiable(
        briefing,
      ),
      suggestedTopics:
          List.unmodifiable(
        topics,
      ),
    );
  }

  // ==========================================================
  // RECENT MEMORY
  // ==========================================================

  List<LifeMemory> _recentMemories(
    List<LifeMemory> memories,
    int limit,
  ) {
    final result =
        memories.toList();

    result.sort(
      (a, b) =>
          b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    if (result.length <= limit) {
      return result;
    }

    return result.sublist(
      0,
      limit,
    );
  }

  // ==========================================================
  // RELEVANT MEMORY
  // ==========================================================
  ///
  /// Simple local relevance search.
  ///
  /// Later this can be upgraded to embeddings/vector search.
  /// ==========================================================

  List<LifeMemory> _findRelevantMemories(
    String message,
    List<LifeMemory> memories,
    int limit,
  ) {
    if (message.trim().isEmpty) {
      return [];
    }

    final words =
        _keywords(message);

    if (words.isEmpty) {
      return [];
    }

    final scored =
        <_ScoredMemory>[];

    for (final memory
        in memories) {
      final searchable =
          _memorySearchText(
        memory,
      );

      int score = 0;

      for (final word
          in words) {
        if (searchable.contains(
          word,
        )) {
          score++;
        }
      }

      if (score > 0) {
        scored.add(
          _ScoredMemory(
            memory: memory,
            score: score,
          ),
        );
      }
    }

    scored.sort(
      (a, b) {
        final scoreCompare =
            b.score.compareTo(
          a.score,
        );

        if (scoreCompare != 0) {
          return scoreCompare;
        }

        return b.memory.createdAt
            .compareTo(
          a.memory.createdAt,
        );
      },
    );

    return scored
        .take(limit)
        .map(
          (item) => item.memory,
        )
        .toList();
  }

  // ==========================================================
  // MEMORY SEARCH TEXT
  // ==========================================================

  String _memorySearchText(
    LifeMemory memory,
  ) {
    return [
      memory.originalText,
      memory.entity ?? '',
      memory.category,
      memory.core.name,
    ].join(' ').toLowerCase();
  }

  // ==========================================================
  // KEYWORDS
  // ==========================================================

  List<String> _keywords(
    String message,
  ) {
    final stopWords = <String>{
      'the',
      'and',
      'for',
      'with',
      'that',
      'this',
      'what',
      'when',
      'where',
      'how',
      'can',
      'you',
      'are',
      'is',
      'my',
      'me',
      'i',
      'a',
      'an',
      'to',
      'of',
      'in',
      'on',
      'it',
      'do',
      'please',
      'tell',
    };

    final words =
        message
            .toLowerCase()
            .replaceAll(
              RegExp(r'[^a-zA-Z0-9₹ ]'),
              ' ',
            )
            .split(
              RegExp(r'\s+'),
            )
            .where(
              (word) =>
                  word.length >= 3 &&
                  !stopWords.contains(
                    word,
                  ),
            )
            .toSet()
            .toList();

    return words;
  }

  // ==========================================================
  // SUGGESTED TOPICS
  // ==========================================================

  List<String> _suggestTopics(
    String message,
    YansiLifeSnapshot snapshot,
  ) {
    final lower =
        message.toLowerCase();

    final topics =
        <String>[];

    if (_containsAny(
      lower,
      [
        'money',
        'expense',
        'spent',
        'salary',
        'saving',
        'budget',
      ],
    )) {
      topics.add(
        'financial planning',
      );
    }

    if (_containsAny(
      lower,
      [
        'shopping',
        'grocery',
        'household',
        'milk',
        'rice',
      ],
    )) {
      topics.add(
        'household planning',
      );
    }

    if (_containsAny(
      lower,
      [
        'task',
        'work',
        'finish',
        'todo',
        'productivity',
      ],
    )) {
      topics.add(
        'productivity',
      );
    }

    if (_containsAny(
      lower,
      [
        'goal',
        'future',
        'dream',
        'target',
      ],
    )) {
      topics.add(
        'goals',
      );
    }

    if (_containsAny(
      lower,
      [
        'feel',
        'feeling',
        'sad',
        'happy',
        'stress',
        'worried',
        'problem',
      ],
    )) {
      topics.add(
        'personal wellbeing',
      );
    }

    if (snapshot
        .financialWarnings
        .isNotEmpty) {
      topics.add(
        'financial warning',
      );
    }

    return _unique(
      topics,
    );
  }

  // ==========================================================
  // STRING HELPER
  // ==========================================================

  bool _containsAny(
    String text,
    List<String> values,
  ) {
    for (final value
        in values) {
      if (text.contains(value)) {
        return true;
      }
    }

    return false;
  }

  // ==========================================================
  // UNIQUE
  // ==========================================================

  List<String> _unique(
    List<String> values,
  ) {
    final result =
        <String>[];

    for (final value
        in values) {
      if (!result.contains(value)) {
        result.add(value);
      }
    }

    return result;
  }
}

/// ============================================================
/// INTERNAL SCORING
/// ============================================================

class _ScoredMemory {
  final LifeMemory memory;

  final int score;

  const _ScoredMemory({
    required this.memory,
    required this.score,
  });
}
