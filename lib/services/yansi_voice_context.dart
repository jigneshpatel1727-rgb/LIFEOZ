import 'yansi_voice_memory.dart';
import 'yansi_proactive_suggestions.dart';

/// Converts stored voice memories into lightweight intelligence signals.
/// It does not infer sensitive facts or execute actions.
class YansiVoiceContext {
  const YansiVoiceContext();

  List<YansiProactiveSuggestion> suggestionsFrom(
    List<YansiVoiceMemoryEntry> entries,
  ) {
    final suggestions = <YansiProactiveSuggestion>[];
    for (final entry in entries.take(20)) {
      final text = entry.transcript.trim();
      if (text.isEmpty) continue;
      final lower = text.toLowerCase();

      String? core;
      if (RegExp(r'\b(budget|expense|spent|spend|money|bill|payment)\b').hasMatch(lower)) {
        core = 'money';
      } else if (RegExp(r'\b(grocery|groceries|shopping|milk|vegetable|household)\b').hasMatch(lower)) {
        core = 'household';
      } else if (RegExp(r'\b(task|todo|work|office|meeting|job)\b').hasMatch(lower)) {
        core = 'productivity';
      } else if (RegExp(r'\b(calendar|date|appointment|renewal|birthday|anniversary)\b').hasMatch(lower)) {
        core = 'calendar';
      }

      if (core == null) continue;
      suggestions.add(YansiProactiveSuggestion(
        title: 'Voice context',
        message: text,
        core: core,
        priority: 62,
        speakable: false,
      ));
    }
    return suggestions;
  }
}
