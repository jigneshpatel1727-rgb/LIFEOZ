import 'package:flutter/foundation.dart';

enum YansiAmbientState { idle, listening, thinking, acting, speaking }

/// Central state for Yansi's ambient presence across LifeOS.
class YansiAmbientStateMachine extends ChangeNotifier {
  YansiAmbientState _state = YansiAmbientState.idle;
  String _context = '';

  YansiAmbientState get state => _state;
  String get context => _context;
  bool get isActive => _state != YansiAmbientState.idle;

  void setListening([String context = '']) => _set(YansiAmbientState.listening, context);
  void setThinking([String context = '']) => _set(YansiAmbientState.thinking, context);
  void setActing([String context = '']) => _set(YansiAmbientState.acting, context);
  void setSpeaking([String context = '']) => _set(YansiAmbientState.speaking, context);
  void setIdle() => _set(YansiAmbientState.idle, '');

  void _set(YansiAmbientState next, String context) {
    _state = next;
    _context = context.trim();
    notifyListeners();
  }
}
