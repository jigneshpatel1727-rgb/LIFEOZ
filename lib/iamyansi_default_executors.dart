import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'iamyansi_action_context.dart';
import 'iamyansi_executor_router.dart';

/// Built-in Allinmyday executors for the first real Iamyansi integration.
///
/// These actions intentionally use the app's local persistence layer and do
/// not expose arbitrary code execution to the AI layer.
class IamyansiDefaultExecutors {
  static void register(IamyansiExecutorRouter router) {
    router.register('add_expense', _addExpense);
    router.register('add_task', _addTask);
    router.register('complete_task', _completeTask);
  }

  static Future<IamyansiActionResult> _addExpense(
    IamyansiActionContext context,
  ) async {
    final amount = double.tryParse(context.metadata['amount'] ?? '');
    final category = (context.metadata['category'] ?? '').trim();
    final note = (context.metadata['note'] ?? context.userInput).trim();

    if (amount == null || amount < 0) {
      return IamyansiActionResult.failure('A valid expense amount is required.');
    }
    if (category.isEmpty) {
      return IamyansiActionResult.failure('An expense category is required.');
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('lifeos_expenses');
    final expenses = _decodeList(raw);
    final id = '${context.requestId}-${DateTime.now().microsecondsSinceEpoch}';

    expenses.insert(0, {
      'id': id,
      'amount': amount,
      'category': category,
      'note': note,
      'date': DateTime.now().toIso8601String(),
      'source': 'iamyansi',
    });

    await prefs.setString('lifeos_expenses', jsonEncode(expenses));

    return IamyansiActionResult.ok(
      'Added ₹${amount.toStringAsFixed(0)} to $category.',
      data: {'id': id, 'amount': amount, 'category': category},
    );
  }

  static Future<IamyansiActionResult> _addTask(
    IamyansiActionContext context,
  ) async {
    final title = (context.metadata['title'] ?? context.userInput).trim();
    if (title.isEmpty) {
      return IamyansiActionResult.failure('A task title is required.');
    }

    final prefs = await SharedPreferences.getInstance();
    final tasks = _decodeList(prefs.getString('iamyansi_tasks'));
    final id = '${context.requestId}-${DateTime.now().microsecondsSinceEpoch}';

    tasks.insert(0, {
      'id': id,
      'title': title,
      'completed': false,
      'createdAt': DateTime.now().toIso8601String(),
      'source': 'iamyansi',
    });

    await prefs.setString('iamyansi_tasks', jsonEncode(tasks));
    return IamyansiActionResult.ok(
      'Added task: $title.',
      data: {'id': id, 'title': title},
    );
  }

  static Future<IamyansiActionResult> _completeTask(
    IamyansiActionContext context,
  ) async {
    final taskId = (context.metadata['taskId'] ?? '').trim();
    if (taskId.isEmpty) {
      return IamyansiActionResult.failure('A task id is required.');
    }

    final prefs = await SharedPreferences.getInstance();
    final tasks = _decodeList(prefs.getString('iamyansi_tasks'));
    var found = false;

    for (final task in tasks) {
      if (task['id'].toString() == taskId) {
        task['completed'] = true;
        task['completedAt'] = DateTime.now().toIso8601String();
        found = true;
        break;
      }
    }

    if (!found) {
      return IamyansiActionResult.failure('Task not found: $taskId');
    }

    await prefs.setString('iamyansi_tasks', jsonEncode(tasks));
    return IamyansiActionResult.ok('Task completed.', data: {'id': taskId});
  }

  static List<Map<String, dynamic>> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    } catch (_) {
      // Recover with an empty local store rather than crashing the app.
    }
    return <Map<String, dynamic>>[];
  }
}
