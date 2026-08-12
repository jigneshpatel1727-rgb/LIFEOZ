import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// ============================================================
/// YANSI VOICE ENGINE
/// ============================================================
///
/// Yansi's voice interface.
///
/// Flow:
///
/// USER SPEAKS
///      ↓
/// Android microphone permission
///      ↓
/// Speech-to-text
///      ↓
/// Yansi receives text
///      ↓
/// Yansi brain
///      ↓
/// Text response
///      ↓
/// Text-to-speech
///      ↓
/// YANSI SPEAKS
///
/// IMPORTANT:
/// - Microphone is NOT continuously active.
/// - Listening starts only when explicitly activated.
/// - The application must have the required Android permission.
/// - This class does not secretly record conversations.
/// ============================================================

enum YansiVoiceState {
  idle,
  initializing,
  listening,
  processing,
  speaking,
  error,
}

class YansiVoiceEngine {
  final SpeechToText speech;

  final FlutterTts tts;

  YansiVoiceState _state =
      YansiVoiceState.idle;

  bool _initialized = false;

  bool _isListening = false;

  String _currentText = '';

  String _lastError = '';

  final StreamController<
      YansiVoiceState> _stateController =
      StreamController<
          YansiVoiceState>.broadcast();

  final StreamController<
      String> _textController =
      StreamController<
          String>.broadcast();

  final StreamController<
      String> _finalTextController =
      StreamController<
          String>.broadcast();

  YansiVoiceEngine({
    SpeechToText? speechToText,
    FlutterTts? textToSpeech,
  })  : speech =
            speechToText ??
                SpeechToText(),
        tts =
            textToSpeech ??
                FlutterTts();

  // ==========================================================
  // GETTERS
  // ==========================================================

  YansiVoiceState get state =>
      _state;

  bool get isListening =>
      _isListening;

  bool get isInitialized =>
      _initialized;

  String get currentText =>
      _currentText;

  String get lastError =>
      _lastError;

  Stream<YansiVoiceState>
      get stateStream =>
          _stateController.stream;

  Stream<String>
      get partialTextStream =>
          _textController.stream;

  Stream<String>
      get finalTextStream =>
          _finalTextController.stream;

  // ==========================================================
  // INITIALIZE
  // ==========================================================

  Future<bool> initialize({
    String languageCode = 'en-IN',
  }) async {
    try {
      _setState(
        YansiVoiceState.initializing,
      );

      await _configureTts();

      final available =
          await speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      _initialized =
          available;

      if (!available) {
        _lastError =
            'Speech recognition is not available on this device.';
        _setState(
          YansiVoiceState.error,
        );
        return false;
      }

      await setLanguage(
        languageCode,
      );

      _setState(
        YansiVoiceState.idle,
      );

      return true;
    } catch (error) {
      _lastError =
          error.toString();

      _setState(
        YansiVoiceState.error,
      );

      return false;
    }
  }

  // ==========================================================
  // TEXT TO SPEECH CONFIGURATION
  // ==========================================================

  Future<void> _configureTts() async {
    await tts.setSpeechRate(
      0.48,
    );

    await tts.setVolume(
      1.0,
    );

    await tts.setPitch(
      1.0,
    );

    tts.setStartHandler(() {
      _setState(
        YansiVoiceState.speaking,
      );
    });

    tts.setCompletionHandler(() {
      _setState(
        YansiVoiceState.idle,
      );
    });

    tts.setCancelHandler(() {
      _setState(
        YansiVoiceState.idle,
      );
    });

    tts.setErrorHandler(
      (message) {
        _lastError =
            message.toString();

        _setState(
          YansiVoiceState.error,
        );
      },
    );
  }

  // ==========================================================
  // SET LANGUAGE
  // ==========================================================

  Future<bool> setLanguage(
    String languageCode,
  ) async {
    try {
      final result =
          await tts.setLanguage(
        languageCode,
      );

      return result !=
          0;
    } catch (_) {
      return false;
    }
  }

  // ==========================================================
  // START LISTENING
  // ==========================================================
  //
  // IMPORTANT:
  //
  // This is explicitly activated.
  // Yansi does not keep the microphone running forever.
  //
  // ==========================================================

  Future<bool> startListening({
    String localeId = 'en_IN',
    Duration listenFor =
        const Duration(
      seconds: 30,
    ),
  }) async {
    try {
      if (!_initialized) {
        final ready =
            await initialize();

        if (!ready) {
          return false;
        }
      }

      if (_isListening) {
        return true;
      }

      _currentText = '';

      _lastError = '';

      await tts.stop();

      final available =
          await speech
              .hasPermission;

      if (!available) {
        _lastError =
            'Microphone permission is required for Yansi voice interaction.';

        _setState(
          YansiVoiceState.error,
        );

        return false;
      }

      _isListening = true;

      _setState(
        YansiVoiceState.listening,
      );

      await speech.listen(
        onResult:
            _onSpeechResult,

        localeId:
            localeId,

        listenFor:
            listenFor,

        partialResults:
            true,

        cancelOnError:
            true,

        listenMode:
            ListenMode.confirmation,
      );

      return true;
    } catch (error) {
      _lastError =
          error.toString();

      _isListening = false;

      _setState(
        YansiVoiceState.error,
      );

      return false;
    }
  }

  // ==========================================================
  // STOP LISTENING
  // ==========================================================

  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }

    try {
      await speech.stop();
    } catch (_) {}

    _isListening = false;

    _setState(
      YansiVoiceState.idle,
    );
  }

  // ==========================================================
  // CANCEL LISTENING
  // ==========================================================

  Future<void> cancelListening() async {
    try {
      await speech.cancel();
    } catch (_) {}

    _isListening = false;

    _currentText = '';

    _setState(
      YansiVoiceState.idle,
    );
  }

  // ==========================================================
  // SPEECH RESULT
  // ==========================================================

  void _onSpeechResult(
    dynamic result,
  ) {
    try {
      final recognized =
          result.recognizedWords
              .toString()
              .trim();

      _currentText =
          recognized;

      if (recognized.isNotEmpty) {
        _textController.add(
          recognized,
        );
      }

      if (result.finalResult ==
          true) {
        _isListening = false;

        if (recognized.isNotEmpty) {
          _finalTextController
              .add(
            recognized,
          );
        }

        _setState(
          YansiVoiceState.processing,
        );
      }
    } catch (error) {
      _lastError =
          error.toString();
    }
  }

  // ==========================================================
  // SPEECH STATUS
  // ==========================================================

  void _onSpeechStatus(
    String status,
  ) {
    final lower =
        status.toLowerCase();

    if (lower.contains(
          'done',
        ) ||
        lower.contains(
          'notlistening',
        )) {
      _isListening = false;

      if (_state ==
          YansiVoiceState.listening) {
        _setState(
          YansiVoiceState.idle,
        );
      }
    }
  }

  // ==========================================================
  // SPEECH ERROR
  // ==========================================================

  void _onSpeechError(
    dynamic error,
  ) {
    _lastError =
        error.toString();

    _isListening = false;

    _setState(
      YansiVoiceState.error,
    );
  }

  // ==========================================================
  // YANSI SPEAK
  // ==========================================================

  Future<void> speak(
    String text, {
    bool stopListeningFirst = true,
  }) async {
    final message =
        text.trim();

    if (message.isEmpty) {
      return;
    }

    try {
      if (stopListeningFirst) {
        await stopListening();
      }

      _setState(
        YansiVoiceState.speaking,
      );

      await tts.stop();

      await tts.speak(
        message,
      );
    } catch (error) {
      _lastError =
          error.toString();

      _setState(
        YansiVoiceState.error,
      );
    }
  }

  // ==========================================================
  // STOP SPEAKING
  // ==========================================================

  Future<void> stopSpeaking() async {
    try {
      await tts.stop();

      _setState(
        YansiVoiceState.idle,
      );
    } catch (_) {}
  }

  // ==========================================================
  // WELCOME MESSAGE
  // ==========================================================

  Future<void> speakWelcome(
    String userName,
  ) async {
    final name =
        userName.trim();

    if (name.isEmpty) {
      await speak(
        'Welcome. I am Yansi, your personal LifeOS AI friend. How can I help you?',
      );

      return;
    }

    await speak(
      'Welcome, $name. I am Yansi, your personal LifeOS AI friend. How can I help you?',
    );
  }

  // ==========================================================
  // QUICK RESPONSE
  // ==========================================================

  Future<void> acknowledge(
    String message,
  ) async {
    await speak(
      message,
    );
  }

  // ==========================================================
  // STATE
  // ==========================================================

  void _setState(
    YansiVoiceState value,
  ) {
    _state =
        value;

    if (!_stateController
        .isClosed) {
      _stateController.add(
        value,
      );
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  Future<void> dispose() async {
    try {
      await speech.cancel();
    } catch (_) {}

    try {
      await tts.stop();
    } catch (_) {}

    await _stateController
        .close();

    await _textController
        .close();

    await _finalTextController
        .close();
  }
}
