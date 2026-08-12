import 'package:flutter/foundation.dart';

enum LifeOSSignalType { voice, notification, calendar, expense, task, household, goal, diary, investment, health }

class LifeOSSignal {
  final LifeOSSignalType type;
  final String text;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  const LifeOSSignal({required this.type, required this.text, required this.timestamp, this.data = const {}});
}

class LifeOSIntelligenceBus extends ChangeNotifier {
  final List<LifeOSSignal> _signals = <LifeOSSignal>[];
  List<LifeOSSignal> get signals => List.unmodifiable(_signals);

  void publish(LifeOSSignal signal) {
    _signals.add(signal);
    if (_signals.length > 200) _signals.removeAt(0);
    notifyListeners();
  }

  List<LifeOSSignal> recent({int limit = 20}) {
    final start = _signals.length > limit ? _signals.length - limit : 0;
    return List.unmodifiable(_signals.sublist(start).reversed);
  }

  void clear() {
    _signals.clear();
    notifyListeners();
  }
}
