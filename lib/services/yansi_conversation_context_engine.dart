/// Maintains a compact multi-turn task context for Yansi without deleting history.
class YansiConversationContextEngine {
  const YansiConversationContextEngine();

  Map<String, dynamic> update({
    required Map<String, dynamic> current,
    required String userMessage,
    String? lastIntent,
    String? lastCore,
  }) {
    final next = Map<String, dynamic>.from(current);
    next['lastUserMessage'] = userMessage;
    if (lastIntent != null) next['lastIntent'] = lastIntent;
    if (lastCore != null) next['lastCore'] = lastCore;
    next['active'] = userMessage.trim().isNotEmpty;
    next['updatedAt'] = DateTime.now().toIso8601String();
    return Map.unmodifiable(next);
  }
}
