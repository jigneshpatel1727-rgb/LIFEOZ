/// Voice-diary domain layer. Speech recognition remains a platform concern;
/// this class turns approved transcription into a date-stamped diary entry.
class YansiDiaryEntry {
  final String id;
  final String text;
  final DateTime createdAt;
  final String source;

  const YansiDiaryEntry({
    required this.id,
    required this.text,
    required this.createdAt,
    this.source = 'voice',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'source': source,
      };
}

class YansiVoiceDiary {
  const YansiVoiceDiary();

  YansiDiaryEntry createEntry(String transcript, {DateTime? now}) {
    final clean = transcript.trim();
    if (clean.isEmpty) {
      throw ArgumentError('Diary transcript cannot be empty.');
    }
    final created = now ?? DateTime.now();
    return YansiDiaryEntry(
      id: 'diary_${created.microsecondsSinceEpoch}',
      text: clean,
      createdAt: created,
    );
  }
}
