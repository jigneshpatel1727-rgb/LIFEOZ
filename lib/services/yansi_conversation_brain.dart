import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_companion_memory.dart';
import 'yansi_web_knowledge.dart';

/// The orchestration layer for Yansi's day-to-day companion behavior.
/// It deliberately separates local LifeOS context, approved learning and
/// external knowledge so the UI can remain an ambient AI presence.
class YansiConversationBrain {
  final SharedPreferences prefs;
  late final YansiCompanionMemory memory;
  late final YansiWebKnowledge web;

  YansiConversationBrain({required this.prefs}) {
    memory = YansiCompanionMemory(prefs: prefs);
    web = YansiWebKnowledge(prefs: prefs);
  }

  Future<YansiResponse> think(String userMessage) async {
    final message = userMessage.trim();
    if (message.isEmpty) {
      return const YansiResponse(text: 'I’m listening.', intent: 'empty');
    }

    final intent = _classify(message);
    final context = memory.recent(limit: 8);

    if (_looksLikePersonalObservation(message)) {
      await memory.remember(intent, message, source: 'conversation');
    }

    String? external;
    if (_needsExternalKnowledge(message) && web.enabled) {
      external = await web.ask(message);
    }

    final text = _compose(message, intent, context, external);
    return YansiResponse(
      text: text,
      intent: intent,
      usedExternalKnowledge: external != null,
    );
  }

  String _classify(String text) {
    final s = text.toLowerCase();
    if (_hasAny(s, ['expense', 'spent', 'paid', '₹', 'rupee', 'money'])) return 'expense';
    if (_hasAny(s, ['task', 'todo', 'work', 'complete', 'pending', 'finish'])) return 'productivity';
    if (_hasAny(s, ['bill', 'renewal', 'birthday', 'anniversary', 'due', 'calendar'])) return 'calendar';
    if (_hasAny(s, ['buy', 'grocery', 'groceries', 'shopping', 'kitchen'])) return 'household';
    if (_hasAny(s, ['goal', 'target', 'dream', 'achieve'])) return 'goal';
    if (_hasAny(s, ['invest', 'share', 'mutual fund', 'sip', 'stock'])) return 'investment';
    if (_hasAny(s, ['diary', 'journal', 'today i', 'feeling'])) return 'diary';
    if (_hasAny(s, ['health', 'sleep', 'steps', 'exercise', 'fitness'])) return 'health';
    if (_hasAny(s, ['why', 'how', 'what is', 'latest', 'news', 'compare', 'research'])) return 'knowledge';
    return 'companion';
  }

  bool _needsExternalKnowledge(String text) {
    final s = text.toLowerCase();
    return _hasAny(s, [
      'latest', 'today', 'current', 'news', 'research', 'search', 'google',
      'compare', 'price', 'weather', 'market', 'who is', 'what happened',
    ]);
  }

  bool _looksLikePersonalObservation(String text) {
    final s = text.toLowerCase();
    return _hasAny(s, [
      'i feel', 'i think', 'i like', 'i dislike', 'i prefer', 'i want',
      'i need', 'i usually', 'i always', 'i never', 'i am', 'i’m',
      'my goal', 'my problem', 'today i',
    ]);
  }

  String _compose(String message, String intent, List<Map<String, dynamic>> context, String? external) {
    if (external != null && external.trim().isNotEmpty) {
      return 'I checked the approved external knowledge source.\n\n${external.trim()}';
    }

    switch (intent) {
      case 'expense':
        return 'Got it. I can organize that under your expenses and help you see the pattern.';
      case 'productivity':
        return 'Got it. Let’s turn that into a clear next action and keep unfinished work visible.';
      case 'calendar':
        return 'I can help organize that as a date-based reminder and connect it with your LifeOS timeline.';
      case 'household':
        return 'Got it. I can keep that requirement in your household flow and look for recurring patterns.';
      case 'goal':
        return 'Let’s connect that goal to progress, timing and the next practical step.';
      case 'investment':
        return 'I can organize the investment information and help you compare it with your goals and timeline.';
      case 'diary':
        return 'I’m listening. I can keep this as part of your private diary when personal learning is enabled.';
      case 'health':
        return 'I can organize permitted health information and point out patterns, without treating observations as a medical diagnosis.';
      case 'knowledge':
        return web.enabled
            ? 'I can use the approved external knowledge connection for this question.'
            : 'I can answer from LifeOS context. If you permit web knowledge, I can also research current information.';
      default:
        return context.isEmpty
            ? 'I’m here. Tell me what is happening, and we’ll work through it together.'
            : 'I’m here. I’ll use the relevant context you have allowed me to remember and help you work through it.';
    }
  }

  bool _hasAny(String value, List<String> terms) => terms.any(value.contains);
}

class YansiResponse {
  final String text;
  final String intent;
  final bool usedExternalKnowledge;

  const YansiResponse({
    required this.text,
    required this.intent,
    this.usedExternalKnowledge = false,
  });
}
