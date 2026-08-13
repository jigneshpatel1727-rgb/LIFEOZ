import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'yansi_self_diagnostic.dart';

/// Quiet runtime guardian for Yansi.
/// Runs safe diagnostics periodically and only performs predefined local
/// recovery. It never changes application code or deploys updates.
class YansiRuntimeGuardian {
  final SharedPreferences prefs;
  Timer? _timer;
  bool _running = false;
  YansiRuntimeGuardian({required this.prefs});

  void start() {
    if (_running) return;
    _running = true;
    _check();
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => _check());
  }

  Future<void> _check() async {
    if (!_running) return;
    try {
      final diagnostic = YansiSelfDiagnostic(prefs: prefs);
      final result = diagnostic.run();
      await prefs.setBool('yansi_runtime_healthy', result.healthy);
      await prefs.setInt('yansi_last_diagnostic_ms', DateTime.now().millisecondsSinceEpoch);
      if (!result.healthy) {
        await diagnostic.recoverSafe(result);
        await prefs.setStringList('yansi_last_diagnostic_issues', result.issues);
        await prefs.setStringList('yansi_last_recovery_actions', result.recoveryActions);
      } else {
        await prefs.remove('yansi_last_diagnostic_issues');
        await prefs.remove('yansi_last_recovery_actions');
      }
    } catch (_) {
      await prefs.setBool('yansi_runtime_healthy', false);
    }
  }

  void dispose() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }
}
