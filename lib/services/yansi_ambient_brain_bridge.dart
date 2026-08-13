import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_ambient_command_router.dart';
import 'yansi_brain.dart';
import 'yansi_proactive_runtime.dart';
import 'yansi_proactive_planner.dart';

/// Connects the ambient voice command lifecycle to YansiBrain and the
/// read-only proactive intelligence runtime.
class YansiAmbientBrainBridge {
  final YansiBrain brain;
  final YansiAmbientCommandRouter router;
  final YansiProactiveRuntime proactiveRuntime;

  const YansiAmbientBrainBridge({
    required this.brain,
    required this.router,
    required this.proactiveRuntime,
  });

  Future<YansiResult?> processFinalSpeech(String text) async {
    final value = text.trim();
    if (value.isEmpty) {
      router.onListeningCancelled();
      return null;
    }

    try {
      final result = await brain.process(value);
      router.onCommandCompleted(result.response);
      return result;
    } catch (_) {
      router.onCommandCompleted('I could not complete that request yet.');
      rethrow;
    }
  }

  /// Prepares the highest-value ambient insight without executing any action.
  Future<YansiProactivePlan?> prepareProactiveInsight({
    bool userIsActive = true,
    bool quietMode = false,
  }) {
    return proactiveRuntime.prepare(
      userIsActive: userIsActive,
      quietMode: quietMode,
    );
  }

  static Future<YansiAmbientBrainBridge> create(
    YansiAmbientCommandRouter router,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    return YansiAmbientBrainBridge(
      brain: YansiBrain(prefs: prefs),
      router: router,
      proactiveRuntime: YansiProactiveRuntime(prefs: prefs),
    );
  }
}
