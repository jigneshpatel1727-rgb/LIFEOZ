import 'package:shared_preferences/shared_preferences.dart';

/// Tiny local memory used to recognize meaningful priority escalation.
/// It stores presentation metadata only and never performs actions.
class YansiPriorityMemory {
  final SharedPreferences prefs;
  const YansiPriorityMemory({required this.prefs});

  int get lastPriority => prefs.getInt('yansi_last_briefing_priority') ?? 0;

  bool isEscalation(int priority, {int threshold = 20}) {
    return priority >= lastPriority + threshold;
  }

  Future<void> remember(int priority) async {
    await prefs.setInt('yansi_last_briefing_priority', priority.clamp(0, 100));
  }
}
