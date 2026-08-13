/// Ranks cross-core Yansi insights for the quiet ambient experience.
///
/// This layer never executes actions. It only selects the most useful signal
/// and suppresses empty or duplicate candidates.
class YansiAmbientInsightRanker {
  const YansiAmbientInsightRanker();

  Map<String, dynamic>? select(
    List<Map<String, dynamic>> candidates, {
    String? lastMessage,
  }) {
    final valid = candidates.where((candidate) {
      final message = candidate['message']?.toString().trim() ?? '';
      final priority = candidate['priority'];
      return message.isNotEmpty && priority is num;
    }).toList();

    valid.sort(
      (a, b) => (b['priority'] as num).compareTo(a['priority'] as num),
    );

    for (final candidate in valid) {
      final message = candidate['message'].toString();
      if (lastMessage == null || message != lastMessage) {
        return Map<String, dynamic>.from(candidate);
      }
    }

    return null;
  }
}
