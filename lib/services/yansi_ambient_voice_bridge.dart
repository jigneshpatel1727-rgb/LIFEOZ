import 'package:flutter/foundation.dart';

/// Connects the ambient UI state to the existing voice layer without making
/// the UI responsible for speech-recognition implementation details.
class YansiAmbientVoiceBridge extends ChangeNotifier {
  bool _listening = false;
  String _transcript = '';
  String _lastResponse = '';

  bool get listening => _listening;
  String get transcript => _transcript;
  String get lastResponse => _lastResponse;

  void beginListening() {
    _listening = true;
    _transcript = '';
    notifyListeners();
  }

  void updateTranscript(String value) {
    _transcript = value.trim();
    notifyListeners();
  }

  void finishListening({String response = ''}) {
    _listening = false;
    _lastResponse = response;
    notifyListeners();
  }

  void reset() {
    _listening = false;
    _transcript = '';
    _lastResponse = '';
    notifyListeners();
  }
}
