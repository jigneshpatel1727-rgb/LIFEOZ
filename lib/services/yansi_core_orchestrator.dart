import 'lifeos_data_store.dart';
import 'yansi_action_router.dart';

/// 2.22: single action boundary between Yansi and the five LifeOS cores.
/// It records understood intents locally and never performs sensitive actions
/// without explicit confirmation.
class YansiCoreOrchestrator {
  final LifeOSDataStore store;
  final YansiActionRouter router;

  YansiCoreOrchestrator(this.store) : router = YansiActionRouter(store);

  Future<YansiCoreResult> handle(String input, {bool confirmed = false}) async {
    final intent = router.classify(input);

    if (intent.action == 'none') {
      return const YansiCoreResult(false, 'I am listening. Tell me what you need.');
    }

    if (intent.requiresConfirmation && !confirmed) {
      return YansiCoreResult(
        false,
        'I understand the request, but I need your confirmation before I do that.',
        requiresConfirmation: true,
        action: intent.action,
      );
    }

    final now = DateTime.now().toIso8601String();
    await store.append('yansi_actions', {
      'id': '${DateTime.now().microsecondsSinceEpoch}',
      'action': intent.action,
      'input': input.trim(),
      'timestamp': now,
      'confirmed': confirmed,
    });

    switch (intent.action) {
      case 'money.addExpense':
        return const YansiCoreResult(true, 'Got it. I recorded that as a money action.', action: 'money.addExpense');
      case 'productivity.addTask':
        return const YansiCoreResult(true, 'Got it. I recorded that as a task action.', action: 'productivity.addTask');
      case 'household.addItem':
        return const YansiCoreResult(true, 'Got it. I recorded that as a household action.', action: 'household.addItem');
      case 'money.analyze':
        return const YansiCoreResult(true, 'I can analyze your money data from the LifeOS context.', action: 'money.analyze');
      case 'goals.analyze':
        return const YansiCoreResult(true, 'I can analyze your goals from the LifeOS context.', action: 'goals.analyze');
      case 'productivity.analyze':
        return const YansiCoreResult(true, 'I can analyze your productivity from the LifeOS context.', action: 'productivity.analyze');
      case 'calendar.analyze':
        return const YansiCoreResult(true, 'I can analyze your calendar and upcoming dates.', action: 'calendar.analyze');
      case 'household.analyze':
        return const YansiCoreResult(true, 'I can analyze your household requirements.', action: 'household.analyze');
      default:
        return const YansiCoreResult(true, 'I understand. I will keep that in your LifeOS context.', action: 'conversation');
    }
  }
}

class YansiCoreResult {
  final bool ok;
  final String message;
  final bool requiresConfirmation;
  final String? action;

  const YansiCoreResult(
    this.ok,
    this.message, {
    this.requiresConfirmation = false,
    this.action,
  });
}
