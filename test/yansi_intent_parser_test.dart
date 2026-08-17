import 'package:flutter_test/flutter_test.dart';
import 'package:lifeoz/services/yansi_intent_parser.dart';

void main() {
  final parser = YansiIntentParser();

  test('parses rupee expense and category', () {
    final result = parser.parse('I spent ₹600 on fuel today');
    expect(result.type, YansiIntentType.expense);
    expect(result.amount, 600);
    expect(result.category, 'fuel');
    expect(result.needsConfirmation, isFalse);
  });

  test('parses income', () {
    final result = parser.parse('I received ₹5000 salary');
    expect(result.type, YansiIntentType.income);
    expect(result.amount, 5000);
  });

  test('parses task', () {
    final result = parser.parse('I need to finish the report today');
    expect(result.type, YansiIntentType.task);
  });

  test('parses reminder', () {
    final result = parser.parse('Remind me about the electricity bill');
    expect(result.type, YansiIntentType.reminder);
    expect(result.category, 'bills');
  });

  test('requires confirmation for sensitive action', () {
    final result = parser.parse('Delete my last expense');
    expect(result.type, YansiIntentType.sensitiveAction);
    expect(result.needsConfirmation, isTrue);
  });

  test('unknown input stays unknown', () {
    final result = parser.parse('Tell me a joke');
    expect(result.type, YansiIntentType.unknown);
  });
}
