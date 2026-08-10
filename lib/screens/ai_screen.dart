import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../lifeos_ai_service.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final LifeOSAIService _ai = LifeOSAIService();

  final TextEditingController _categoryController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();

  String _result = 'Yansi is ready to help you.';

  bool _loading = false;
  bool _speechAvailable = false;
  bool _listening = false;

  String _activeField = '';

  List<stt.LocaleName> _locales = [];
  String? _selectedLocaleId;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      final microphoneStatus =
          await Permission.microphone.request();

      if (!microphoneStatus.isGranted) {
        if (!mounted) return;

        setState(() {
          _speechAvailable = false;
        });

        return;
      }

      final available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _listening = false;
            _activeField = '';
          });
        },
      );

      if (!mounted) return;

      if (!available) {
        setState(() {
          _speechAvailable = false;
        });
        return;
      }

      final locales = await _speech.locales();

      String? defaultLocale;

      for (final locale in locales) {
        final id = locale.localeId.toLowerCase();

        if (id == 'en_in' || id == 'en-in') {
          defaultLocale = locale.localeId;
          break;
        }
      }

      defaultLocale ??=
          locales.isNotEmpty ? locales.first.localeId : null;

      setState(() {
        _speechAvailable = true;
        _locales = locales;
        _selectedLocaleId = defaultLocale;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _speechAvailable = false;
      });
    }
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;

    if (status == 'done' || status == 'notListening') {
      setState(() {
        _listening = false;
        _activeField = '';
      });
    }
  }

  void _onSpeechResult(
    SpeechRecognitionResult result,
  ) {
    if (!mounted) return;

    final text = result.recognizedWords;

    if (text.isEmpty) return;

    setState(() {
      if (_activeField == 'category') {
        _categoryController.text = text;

        _categoryController.selection =
            TextSelection.fromPosition(
          TextPosition(
            offset: _categoryController.text.length,
          ),
        );
      } else if (_activeField == 'amount') {
        _amountController.text = text;

        _amountController.selection =
            TextSelection.fromPosition(
          TextPosition(
            offset: _amountController.text.length,
          ),
        );
      } else if (_activeField == 'description') {
        _descriptionController.text = text;

        _descriptionController.selection =
            TextSelection.fromPosition(
          TextPosition(
            offset: _descriptionController.text.length,
          ),
        );
      }
    });
  }

  Future<void> _toggleListening(String field) async {
    if (!_speechAvailable) {
      await _showMicrophoneMessage();
      return;
    }

    if (_listening) {
      await _speech.stop();

      if (!mounted) return;

      setState(() {
        _listening = false;
        _activeField = '';
      });

      return;
    }

    _activeField = field;

    setState(() {
      _listening = true;
    });

    try {
      await _speech.listen(
        onResult: _onSpeechResult,

        // IMPORTANT:
        // These are direct parameters because the installed
        // speech_to_text package does not support the
        // SpeechListenOptions "options:" parameter used before.
        localeId: _selectedLocaleId,
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _listening = false;
        _activeField = '';
      });

      await _showMicrophoneMessage();
    }
  }

  Future<void> _showMicrophoneMessage() async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Microphone permission is required for voice typing. '
          'You can continue using manual typing.',
        ),
      ),
    );
  }

  Future<void> _analyze() async {
    final category =
        _categoryController.text.trim();

    final amount =
        double.tryParse(
      _amountController.text.trim(),
    );

    final description =
        _descriptionController.text.trim();

    if (category.isEmpty) {
      setState(() {
        _result =
            'Please enter an expense category.';
      });
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() {
        _result =
            'Please enter a valid amount.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _result =
          'Yansi is analysing your expense...';
    });

    try {
      final result = await _ai.analyze(
        category: category,
        amount: amount,
        description: description,
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _result = result;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _result =
            'Yansi could not analyse this expense. '
            'Please try again.';
      });
    }
  }

  void _clearForm() {
    _categoryController.clear();
    _amountController.clear();
    _descriptionController.clear();

    setState(() {
      _result = 'Yansi is ready to help you.';
    });
  }

  Widget _voiceButton(String field) {
    final isActive =
        _listening && _activeField == field;

    return IconButton(
      tooltip: isActive
          ? 'Stop listening'
          : 'Voice input',
      onPressed:
          _loading ? null : () => _toggleListening(field),
      icon: Icon(
        isActive
            ? Icons.stop_circle
            : Icons.mic_none,
        color: isActive
            ? Colors.red
            : Theme.of(context)
                .colorScheme
                .primary,
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
    required String field,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: _voiceButton(field),
      border: const OutlineInputBorder(),
    );
  }

  @override
  void dispose() {
    _speech.stop();

    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yansi AI'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            const SizedBox(height: 10),

            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
              ),

              child: Icon(
                Icons.auto_awesome,
                size: 48,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Yansi',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your LifeOS AI Agent',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Speak or type your expense and Yansi '
              'will help you understand it.',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            if (_speechAvailable &&
                _locales.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedLocaleId,

                decoration:
                    const InputDecoration(
                  labelText: 'Voice Language',
                  prefixIcon:
                      Icon(Icons.language),
                  border:
                      OutlineInputBorder(),
                ),

                items: _locales
                    .map(
                      (locale) =>
                          DropdownMenuItem<String>(
                        value:
                            locale.localeId,
                        child:
                            Text(locale.name),
                      ),
                    )
                    .toList(),

                onChanged: (value) {
                  setState(() {
                    _selectedLocaleId =
                        value;
                  });
                },
              ),

            if (_speechAvailable)
              const Padding(
                padding:
                    EdgeInsets.only(top: 8),

                child: Text(
                  '🎙️ Tap the microphone to speak.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            TextField(
              controller:
                  _categoryController,

              textInputAction:
                  TextInputAction.next,

              decoration: _decoration(
                label:
                    'Expense Category',

                hint:
                    'Fuel, Food, Shopping, EMI...',

                icon:
                    Icons.category_outlined,

                field:
                    'category',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  _amountController,

              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),

              textInputAction:
                  TextInputAction.next,

              decoration: _decoration(
                label: 'Amount',
                hint: 'Enter amount',
                icon:
                    Icons.currency_rupee,
                field: 'amount',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  _descriptionController,

              maxLines: 3,

              decoration: _decoration(
                label: 'Description',

                hint:
                    'What was this expense for?',

                icon:
                    Icons.notes_outlined,

                field:
                    'description',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 52,

              child: FilledButton.icon(
                onPressed:
                    _loading
                        ? null
                        : _analyze,

                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.psychology,
                      ),

                label: Text(
                  _loading
                      ? 'Analysing...'
                      : 'ASK YANSI',
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed:
                  _loading
                      ? null
                      : _clearForm,

              icon: const Icon(
                Icons.refresh,
              ),

              label:
                  const Text('Clear'),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 2,

              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,

                          color:
                              Theme.of(context)
                                  .colorScheme
                                  .primary,
                        ),

                        const SizedBox(
                            width: 10),

                        const Text(
                          'Yansi Recommendation',

                          style: TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 15),

                    Text(
                      _result,

                      style:
                          const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,

              child: const Padding(
                padding:
                    EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'LifeOS Principle',

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Track → Understand → '
                      'Improve → Save',

                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'LifeOS is designed to reduce '
                      'unnecessary manual work and help '
                      'you make better daily decisions.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
