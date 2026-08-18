import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local command/intention layer for iAmYansi.
///
/// This deliberately does not execute sensitive actions. It classifies a
/// user's request, records the intent, and marks actions that require an
/// explicit confirmation before a future executor can perform them.
class IamyansiCommandEngine {
  static const _historyKey = 'iamyansi_command_history_v1';

  final SharedPreferences prefs;

  const IamyansiCommandEngine({required this.prefs});

  IamyansiIntent classify(String input) {
    final text = input.trim().toLowerCase();
    if (text.isEmpty) {
      return const IamyansiIntent(type: IamyansiIntentType.unknown);
    }

    if (_matches(text, const ['add expense', 'spent ', 'paid ', 'expense'])) {
      return const IamyansiIntent(type: IamyansiIntentType.expense);
    }
    if (_matches(text, const ['task', 'todo', 'to-do', 'remind me', 'finish'])) {
      return const IamyansiIntent(type: IamyansiIntentType.task);
    }
    if (_matches(text, const ['shopping', 'grocery', 'buy ', 'purchase'])) {
      return const IamyansiIntent(type: IamyansiIntentType.shopping);
    }
    if (_matches(text, const ['calendar', 'bill due', 'renewal', 'birthday', 'anniversary'])) {
      return const IamyansiIntent(type: IamyansiIntentType.calendar);
    }
    if (_matches(text, const ['diary', 'journal', 'write this down'])) {
      return const IamyansiIntent(type: IamyansiIntentType.diary);
    }
    if (_matches(text, const ['invest', 'investment', 'mutual fund', 'share'])) {
      return IamyansiIntent(
        type: IamyansiIntentType.investment,
        requiresConfirmation: true,
      );
    }
    if (_matches(text, const ['delete', 'remove all', 'erase'])) {
      return IamyansiIntent(
        type: IamyansiIntentType.destructive,
        requiresConfirmation: true,
      );
    }
    if (_matches(text, const ['send ', 'message ', 'email ', 'call '])) {
      return IamyansiIntent(
        type: IamyansiIntentType.externalAction,
        requiresConfirmation: true,
      );
    }
    if (_matches(text, const ['search ', 'look up', 'find out', 'latest '])) {
      return const IamyansiIntent(type: IamyansiIntentType.webResearch);
    }
    if (_matches(text, const ['code ', 'build ', 'create app', 'make website', 'program'])) {
      return const IamyansiIntent(type: IamyansiIntentType.coding);
    }

    return const IamyansiIntent(type: IamyansiIntentType.conversation);
  }

  Future<IamyansiIntent> record(String input) async {
    final intent = classify(input);
    final raw = prefs.getStringList(_historyKey) ?? <String>[];
    raw.add(jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'input': input.trim(),
      'type': intent.type.name,
      'requiresConfirmation': intent.requiresConfirmation,
    }));
    if (raw.length > 100) raw.removeRange(0, raw.length - 100);
    await prefs.setStringList(_historyKey, raw);
    return intent;
  }

  bool _matches(String text, List<String> phrases) =>
      phrases.any(text.contains);
}

enum IamyansiIntentType {
  unknown,
  conversation,
  expense,
  task,
  shopping,
  calendar,
  diary,
  investment,
  destructive,
  externalAction,
  webResearch,
  coding,
}

class IamyansiIntent {
  final IamyansiIntentType type;
  final bool requiresConfirmation;

  const IamyansiIntent({
    required this.type,
    this.requiresConfirmation = false,
  });
}
