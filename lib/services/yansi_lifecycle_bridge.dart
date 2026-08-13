import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_proactive_runtime.dart';

/// App-lifecycle adapter for Yansi. It prepares proactive intelligence when
/// LifeOS becomes active, without speaking or executing actions automatically.
class YansiLifecycleBridge {
  final SharedPreferences prefs;
  const YansiLifecycleBridge({required this.prefs});

  Future<void> onAppResumed() async {
    final quiet=prefs.getBool('yansi_quiet_mode')==true;
    if(quiet) return;
    await YansiProactiveRuntime(prefs:prefs).prepare(userIsActive:true,quietMode:false);
  }

  Future<void> onAppPaused() async {}
}
