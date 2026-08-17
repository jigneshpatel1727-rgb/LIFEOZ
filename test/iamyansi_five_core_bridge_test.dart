import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifeoz/services/iamyansi_core_bridge.dart';
import 'package:lifeoz/services/iamyansi_intent_parser.dart';

void main() {
  late SharedPreferences prefs;
  late IamyansiCoreBridge bridge;
  final parser = IamyansiIntentParser();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    bridge = IamyansiCoreBridge(prefs: prefs);
  });

  Future<void> writes(String phrase, String core) async {
    final result = await bridge.apply(parser.parse(phrase));
    expect(result.written, isTrue);
    expect(result.core, core);
  }

  test('expense routes to expense core', () async {
    await writes('I spent ₹600 on fuel', 'expense');
  });

  test('task routes to productivity core', () async {
    await writes('I need to finish the report today', 'productivity');
  });

  test('reminder routes to calendar core', () async {
    await writes('Remind me about the electricity bill', 'calendar');
  });

  test('shopping routes to household core', () async {
    await writes('Add milk to my shopping list', 'household');
  });

  test('goal routes to goal core', () async {
    await writes('I want to save ₹200000 for a car', 'goal');
  });

  test('sensitive action never writes', () async {
    final result = await bridge.apply(parser.parse('Delete my last expense'));
    expect(result.written, isFalse);
    expect(result.alreadyExists, isFalse);
  });

  test('same utterance on same day is idempotent', () async {
    final intent = parser.parse('I need to finish the report today');
    final first = await bridge.apply(intent);
    final second = await bridge.apply(intent);
    expect(first.written, isTrue);
    expect(second.alreadyExists, isTrue);
  });
}
