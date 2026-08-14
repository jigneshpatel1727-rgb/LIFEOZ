import 'yansi_memory_record.dart';

/// Selects only memories relevant to the current Yansi context.
///
/// Retrieval is deterministic and bounded; it does not expose expired
/// memories and does not mutate the memory store.
class YansiMemoryRetrieval {
  const YansiMemoryRetrieval();

  List<YansiMemoryRecord> relevant({
    required Iterable<YansiMemoryRecord> memories,
    Set<String> topics = const <String>{},
    String? source,
    int limit = 12,
  }) {
    final now = DateTime.now();
    final normalizedTopics = topics
        .map((topic) => topic.trim().toLowerCase())
        .where((topic) => topic.isNotEmpty)
        .toSet();
    final normalizedSource = source?.trim().toLowerCase();

    final candidates = memories.where((memory) {
      if (memory.isExpired(now)) return false;
      if (normalizedSource != null &&
          memory.source.toLowerCase() != normalizedSource) {
        return false;
      }
      if (normalizedTopics.isEmpty) return true;
      return memory.tags
          .map((tag) => tag.toLowerCase())
          .any(normalizedTopics.contains);
    }).toList();

    candidates.sort((a, b) {
      final confidence = b.confidence.compareTo(a.confidence);
      if (confidence != 0) return confidence;
      return b.observedAt.compareTo(a.observedAt);
    });

    return List<YansiMemoryRecord>.unmodifiable(
      candidates.take(limit < 1 ? 1 : limit),
    );
  }
}
