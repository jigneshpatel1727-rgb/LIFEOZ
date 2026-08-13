import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_companion_memory.dart';
import 'yansi_web_knowledge.dart';

class YansiCompanionResponse {
  final String text;
  final bool usedExternalKnowledge;
  const YansiCompanionResponse({required this.text, this.usedExternalKnowledge = false});
}

/// Lightweight orchestration layer for Yansi.
/// Keeps private LifeOS context local and only sends the explicit question to
/// the approved external knowledge gateway when the user has enabled it.
class YansiCompanionBrain {
  final YansiCompanionMemory memory;
  final YansiWebKnowledge web;

  const YansiCompanionBrain({required this.memory, required this.web});

  factory YansiCompanionBrain.fromPrefs(SharedPreferences prefs) {
    return YansiCompanionBrain(
      memory: YansiCompanionMemory(prefs: prefs),
      web: YansiWebKnowledge(prefs: prefs),
    );
  }

  List<Map<String, dynamic>> get recentContext => memory.recent(limit: 12);

  Future<String?> externalAnswer(String question) => web.ask(question.trim());

  Future<void> learn(String topic, String observation, {String source = 'conversation'}) {
    return memory.remember(topic, observation, source: source);
  }

  /// Produces a safe companion response. External knowledge is only used when
  /// explicitly permitted and available; private memory is never sent outside.
  Future<YansiCompanionResponse> respond(String question) async {
    final text = question.trim();
    if (text.isEmpty) return const YansiCompanionResponse(text: '');

    final external = await externalAnswer(text);
    if (external != null && external.trim().isNotEmpty) {
      return YansiCompanionResponse(
        text: external.trim(),
        usedExternalKnowledge: true,
      );
    }

    final context = recentContext;
    if (context.isNotEmpty) {
      final latest = context.first;
      final topic = (latest['topic'] ?? '').toString().trim();
      if (topic.isNotEmpty) {
        return YansiCompanionResponse(
          text: 'I understand. I’ll keep your recent $topic context in mind while we work through this.',
        );
      }
    }

    return const YansiCompanionResponse(
      text: 'I understand. Tell me a little more, and I’ll help you work through it.',
    );
  }
}
