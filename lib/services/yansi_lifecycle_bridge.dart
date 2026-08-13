import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_companion_orchestrator.dart';
import 'yansi_proactive_runtime.dart';

/// App-lifecycle adapter for Yansi.
///
/// LifeOS refreshes the complete companion context when it becomes active.
/// The refresh is silent: it prepares intelligence but does not speak or
/// execute sensitive actions automatically.
class YansiLifecycleBridge {
  final SharedPreferences prefs;
  const YansiLifecycleBridge({required this.prefs});

  Future<void> onAppResumed() async {
    final quiet = prefs.getBool('yansi_quiet_mode') == true;
    if (quiet) return;

    await YansiCompanionOrchestrator(prefs: prefs).refresh(userIsActive: true);
    await YansiProactiveRuntime(prefs: prefs).prepare(
      userIsActive: true,
      quietMode: false,
    );
  }

  Future<void> onAppPaused() async {
    // Do not speak or perform actions while LifeOS is backgrounded.
    // Background processing, when enabled, is handled by the runtime layer.
  }
}
