import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_ambient_command_router.dart';
import 'yansi_brain.dart';

/// Connects the ambient voice command lifecycle to YansiBrain.
class YansiAmbientBrainBridge {
  final YansiBrain brain;
  final YansiAmbientCommandRouter router;

  const YansiAmbientBrainBridge({required this.brain, required this.router});

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

  static Future<YansiAmbientBrainBridge> create(
    YansiAmbientCommandRouter router,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return YansiAmbientBrainBridge(
      brain: YansiBrain(prefs: prefs),
      router: router,
    );
  }
}
