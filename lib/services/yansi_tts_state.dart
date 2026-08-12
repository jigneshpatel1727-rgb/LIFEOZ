import 'package:flutter/foundation.dart';

/// Presentation state for Yansi's spoken response.
/// The concrete flutter_tts adapter can subscribe to this state.
class YansiTtsState extends ChangeNotifier {
  bool _speaking = false;
  String _text = '';

  bool get speaking => _speaking;
  String get text => _text;

  void begin(String text) {
    _text = text.trim();
    _speaking = _text.isNotEmpty;
    notifyListeners();
  }

  void finish() {
    _speaking = false;
    notifyListeners();
  }

  void clear() {
    _text = '';
    _speaking = false;
    notifyListeners();
  }
}
