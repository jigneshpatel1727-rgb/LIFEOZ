import 'dart:convert';

enum MemoryCore {
  finance,
  goals,
  productivity,
  household,
  diary,
  calendar,
  general,
}

enum MemorySource {
  voice,
  text,
  camera,
  notification,
  email,
  manual,
  system,
}

class LifeMemory {
  final String id;
  final DateTime createdAt;

  // What the user originally said or what Yansi captured.
  final String originalText;

  // Clean text written by Yansi.
  final String transcript;

  // Where the information came from.
  final MemorySource source;

  // Which LifeOS area it belongs to.
  final MemoryCore core;

  // Optional category.
  final String category;

  // Optional amount.
  final double? amount;

  // Optional currency.
  final String currency;

  // Optional merchant/person/title.
  final String? entity;

  // Optional date referred to by the user.
  final DateTime? relatedDate;

  // AI interpretation.
  final String aiSummary;

  // Whether Yansi has already taken an action.
  final bool actionTaken;

  // Human-readable action.
  final String? actionDescription;

  // Optional voice recording path.
  final String? audioPath;

  const LifeMemory({
    required this.id,
    required this.createdAt,
    required this.originalText,
    required this.transcript,
    required this.source,
    required this.core,
    required this.category,
    required this.currency,
    required this.aiSummary,
    required this.actionTaken,
    this.amount,
    this.entity,
    this.relatedDate,
    this.actionDescription,
    this.audioPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'originalText': originalText,
      'transcript': transcript,
      'source': source.name,
      'core': core.name,
      'category': category,
      'amount': amount,
      'currency': currency,
      'entity': entity,
      'relatedDate': relatedDate?.toIso8601String(),
      'aiSummary': aiSummary,
      'actionTaken': actionTaken,
      'actionDescription': actionDescription,
      'audioPath': audioPath,
    };
  }

  factory LifeMemory.fromMap(
    Map<String, dynamic> map,
  ) {
    return LifeMemory(
      id: map['id'] as String,
      createdAt: DateTime.parse(
        map['createdAt'] as String,
      ),
      originalText:
          map['originalText'] as String? ?? '',
      transcript:
          map['transcript'] as String? ?? '',
      source: MemorySource.values.firstWhere(
        (item) => item.name == map['source'],
        orElse: () => MemorySource.text,
      ),
      core: MemoryCore.values.firstWhere(
        (item) => item.name == map['core'],
        orElse: () => MemoryCore.general,
      ),
      category:
          map['category'] as String? ?? 'General',
      amount: map['amount'] == null
          ? null
          : (map['amount'] as num).toDouble(),
      currency:
          map['currency'] as String? ?? '',
      entity: map['entity'] as String?,
      relatedDate: map['relatedDate'] == null
          ? null
          : DateTime.parse(
              map['relatedDate'] as String,
            ),
      aiSummary:
          map['aiSummary'] as String? ?? '',
      actionTaken:
          map['actionTaken'] as bool? ?? false,
      actionDescription:
          map['actionDescription'] as String?,
      audioPath:
          map['audioPath'] as String?,
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory LifeMemory.fromJson(String value) {
    return LifeMemory.fromMap(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}
