import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_companion_memory.dart';
import 'yansi_web_knowledge.dart';

/// Lightweight orchestration layer for Yansi.
///
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

  /// Uses approved external knowledge as a fallback. Private memory is never
  /// appended to the external request.
  Future<String?> externalAnswer(String question) {
    return web.ask(question.trim());
  }

  Future<void> learn(String topic, String observation, {String source = 'conversation'}) {
    return memory.remember(topic, observation, source: source);
  }
}
