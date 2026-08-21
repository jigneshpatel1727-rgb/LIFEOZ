import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allinmyday/services/iamyansi_action_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('records a fuel expense from natural language', () async {
    final prefs = await SharedPreferences.getInstance();
    final engine = IamyansiActionEngine(prefs: prefs);

    final result = await engine.process('I spent ₹600 on fuel');

    expect(result.handled, isTrue);
    expect(result.record?['type'], 'expense');
    expect(result.record?['amount'], 600);
    expect(result.record?['category'], 'Fuel');
    expect(prefs.getStringList('iamyansi_core_records'), hasLength(1));
  });

  test('records a task from a reminder command', () async {
    final prefs = await SharedPreferences.getInstance();
    final engine = IamyansiActionEngine(prefs: prefs);

    final result = await engine.process('remind me to call the insurance customer');

    expect(result.handled, isTrue);
    expect(result.record?['type'], 'task');
    expect(result.record?['task'], 'call the insurance customer');
  });

  test('does not create a record for unrelated speech', () async {
    final prefs = await SharedPreferences.getInstance();
    final engine = IamyansiActionEngine(prefs: prefs);

    final result = await engine.process('the weather is nice today');

    expect(result.handled, isFalse);
    expect(prefs.getStringList('iamyansi_core_records'), isNull);
  });
}
