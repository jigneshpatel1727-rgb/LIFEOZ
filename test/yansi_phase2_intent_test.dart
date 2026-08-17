import 'package:flutter_test/flutter_test.dart';

import '../lib/services/yansi_phase2_intent.dart';

void main() {
  const parser = YansiPhase2IntentParser();

  test('recognises an expense and category', () {
    final intent = parser.parse('I spent ₹600 on fuel');
    expect(intent.type, 'expense');
    expect(intent.fields['amount'], 600);
    expect(intent.fields['category'], 'fuel');
    expect(intent.requiresConfirmation, isFalse);
  });

  test('recognises a task', () {
    final intent = parser.parse('Finish the office report today');
    expect(intent.type, 'task');
    expect(intent.fields['task'], contains('office report'));
  });

  test('reminders require confirmation', () {
    final intent = parser.parse('Remind me tomorrow to pay the electricity bill');
    expect(intent.type, 'reminder');
    expect(intent.fields['dateHint'], 'tomorrow');
    expect(intent.requiresConfirmation, isTrue);
  });

  test('unknown input is not actionable', () {
    final intent = parser.parse('Tell me something interesting');
    expect(intent.type, 'unknown');
    expect(intent.isActionable, isFalse);
  });
}
