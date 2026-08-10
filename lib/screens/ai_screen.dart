import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final TextEditingController _categoryController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  String _message =
      'Hello! I am Yansi, your LifeOS AI assistant.';

  String _recognizedText = '';

  bool _speechAvailable = false;
  bool _listening = false;
  bool _speaking = false;
  bool _processing = false;
  bool _started = false;

  List<stt.LocaleName> _locales = [];

  String? _selectedLocaleId;

  @override
  void initState() {
    super.initState();

    _setupTts();
    _initializeVoice();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      if (!mounted) return;

      setState(() {
        _speaking = true;
      });
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;

      setState(() {
        _speaking = false;
      });
    });

    _tts.setCancelHandler(() {
      if (!mounted) return;

      setState(() {
        _speaking = false;
      });
    });

    _tts.setErrorHandler((message) {
      if (!mounted) return;

      setState(() {
        _speaking = false;
      });
    });
  }

  Future<void> _initializeVoice() async {
    try {
      final permission =
          await Permission.microphone.request();

      if (!permission.isGranted) {
        if (!mounted) return;

        setState(() {
          _message =
              'Microphone permission is required. '
              'Please allow microphone access.';
        });

        return;
      }

      final available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _listening = false;
          });
        },
      );

      if (!available) {
        if (!mounted) return;

        setState(() {
          _speechAvailable = false;
          _message =
              'Speech recognition is not available on this phone.';
        });

        return;
      }

      final locales = await _speech.locales();

      String? selected;

      for (final locale in locales) {
        final id = locale.localeId.toLowerCase();

        if (id == 'en_in' ||
            id == 'en-in' ||
            id == 'en_us' ||
            id == 'en-us') {
          selected = locale.localeId;
          break;
        }
      }

      selected ??=
          locales.isNotEmpty ? locales.first.localeId : null;

      if (!mounted) return;

      setState(() {
        _speechAvailable = true;
        _locales = locales;
        _selectedLocaleId = selected;
      });

      // Give Android a moment before Yansi starts talking.
      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!_started) {
        _started = true;
        await _greetUser();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _message =
            'Voice setup failed. Please check microphone permission.';
      });
    }
  }

  Future<void> _greetUser() async {
    const greeting =
        'Hello! I am Yansi, your LifeOS AI assistant. '
        'Tell me anything about your expenses and I will organize it for you.';

    if (!mounted) return;

    setState(() {
      _message = greeting;
    });

    await _speak(greeting);

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    await _startListening();
  }

  Future<void> _speak(String text) async {
    try {
      await _speech.stop();

      if (mounted) {
        setState(() {
          _listening = false;
          _speaking = true;
        });
      }

      await _tts.stop();

      await _tts.setLanguage(
        _selectedLocaleId ?? 'en-IN',
      );

      await _tts.speak(text);

      // Wait for speech to finish.
      await Future.delayed(
        Duration(
          milliseconds:
              1200 + (text.length * 45),
        ),
      );

      if (!mounted) return;

      setState(() {
        _speaking = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _speaking = false;
      });
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      await _initializeVoice();
      return;
    }

    if (_speaking || _processing) {
      return;
    }

    try {
      await _tts.stop();

      await _speech.stop();

      if (!mounted) return;

      setState(() {
        _listening = true;
        _recognizedText = '';
        _message =
            'I am listening... Tell me what you spent.';
      });

      await _speech.listen(
        onResult: _onSpeechResult,
        localeId: _selectedLocaleId,
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _listening = false;
        _message =
            'I could not start the microphone. '
            'Please try again.';
      });
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _listening = false;
    });
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;

    if (status == 'done' ||
        status == 'notListening') {
      setState(() {
        _listening = false;
      });

      if (_recognizedText.trim().isNotEmpty &&
          !_processing) {
        _processVoiceCommand(
          _recognizedText.trim(),
        );
      }
    }
  }

  void _onSpeechResult(
    SpeechRecognitionResult result,
  ) {
    if (!mounted) return;

    final text = result.recognizedWords.trim();

    if (text.isEmpty) return;

    setState(() {
      _recognizedText = text;
      _message = text;
    });

    if (result.finalResult) {
      _speech.stop();

      _processVoiceCommand(text);
    }
  }

  Future<void> _processVoiceCommand(
    String text,
  ) async {
    if (_processing) return;

    _processing = true;

    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _listening = false;
      _message =
          'Yansi is understanding: "$text"';
    });

    final lower = text.toLowerCase();

    final amount = _extractAmount(text);

    final category = _extractCategory(lower);

    final description = text;

    if (category != null) {
      _categoryController.text = category;
    } else {
      _categoryController.text = 'Other';
    }

    if (amount != null) {
      _amountController.text =
          amount.toStringAsFixed(0);
    }

    _descriptionController.text = description;

    String response;

    if (amount != null) {
      response = await _ai.analyze(
        category: category ?? 'Other',
        amount: amount,
        description: description,
      );
    } else {
      response =
          'I understood what you said, but I could not '
          'find the expense amount. Please tell me the amount too.';
    }

    if (!mounted) return;

    setState(() {
      _message = response;
    });

    await _speak(response);

    _processing = false;

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    await _startListening();
  }

  double? _extractAmount(String text) {
    final cleaned = text
        .toLowerCase()
        .replaceAll(',', '')
        .replaceAll('₹', '');

    final patterns = [
      RegExp(
        r'(?:rs\.?|rupees?|inr)\s*(\d+(?:\.\d+)?)',
      ),
      RegExp(
        r'(\d+(?:\.\d+)?)\s*(?:rs\.?|rupees?|inr)',
      ),
      RegExp(
        r'(?:spent|paid|cost|costs|amount|for)\s*(?:is|of)?\s*(\d+(?:\.\d+)?)',
      ),
      RegExp(
        r'\b(\d+(?:\.\d+)?)\b',
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleaned);

      if (match != null) {
        final value =
            double.tryParse(match.group(1)!);

        if (value != null && value > 0) {
          return value;
        }
      }
    }

    return null;
  }

  String? _extractCategory(String text) {
    final categories = <String, List<String>>{
      'Fuel': [
        'petrol',
        'diesel',
        'fuel',
        'cng',
        'gas',
      ],
      'Food': [
        'food',
        'restaurant',
        'lunch',
        'dinner',
        'breakfast',
        'snacks',
        'meal',
        'pizza',
        'hotel',
      ],
      'Shopping': [
        'shopping',
        'clothes',
        'shirt',
        'dress',
        'shoes',
        'amazon',
        'flipkart',
      ],
      'Electricity': [
        'electricity',
        'electric bill',
        'light bill',
      ],
      'EMI': [
        'emi',
        'loan',
        'home loan',
        'car loan',
      ],
      'Medicine': [
        'medicine',
        'medical',
        'pharmacy',
        'doctor',
      ],
      'Travel': [
        'travel',
        'bus',
        'train',
        'flight',
        'taxi',
        'uber',
        'ola',
      ],
      'Mobile': [
        'mobile',
        'phone bill',
        'recharge',
        'internet',
        'wifi',
      ],
      'Grocery': [
        'grocery',
        'vegetables',
        'milk',
        'vegetable',
        'supermarket',
      ],
    };

    for (final entry in categories.entries) {
      for (final word in entry.value) {
        if (text.contains(word)) {
          return entry.key;
        }
      }
    }

    return null;
  }

  Future<void> _manualSpeak() async {
    const text =
        'Hello! I am Yansi. '
        'I am ready to listen to you.';

    setState(() {
      _message = text;
    });

    await _speak(text);
  }

  Future<void> _clear() async {
    await _speech.stop();
    await _tts.stop();

    _categoryController.clear();
    _amountController.clear();
    _descriptionController.clear();

    if (!mounted) return;

    setState(() {
      _recognizedText = '';
      _message =
          'Yansi is ready. Tap the microphone and speak.';
      _listening = false;
      _speaking = false;
      _processing = false;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();

    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Widget _statusCard() {
    String status;

    IconData icon;

    if (_speaking) {
      status = 'Yansi is speaking...';
      icon = Icons.volume_up;
    } else if (_listening) {
      status = 'Yansi is listening...';
      icon = Icons.mic;
    } else if (_processing) {
      status = 'Yansi is thinking...';
      icon = Icons.psychology;
    } else {
      status = 'Yansi is ready';
      icon = Icons.auto_awesome;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Icon(icon, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yansi AI'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                ),
                child: Icon(
                  Icons.smart_toy,
                  size: 55,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Yansi',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Your LifeOS AI Agent',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 20),

              _statusCard(),

              const SizedBox(height: 15),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              if (_recognizedText.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What I heard',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(_recognizedText),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              if (_speechAvailable &&
                  _locales.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: _selectedLocaleId,
                  decoration:
                      const InputDecoration(
                    labelText: 'Voice Language',
                    prefixIcon:
                        Icon(Icons.language),
                    border:
                        OutlineInputBorder(),
                  ),
                  items: _locales.map((locale) {
                    return DropdownMenuItem<String>(
                      value: locale.localeId,
                      child: Text(locale.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocaleId = value;
                    });
                  },
                ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 65,
                child: FilledButton.icon(
                  onPressed:
                      _speaking || _processing
                          ? null
                          : _listening
                              ? _stopListening
                              : _startListening,
                  icon: Icon(
                    _listening
                        ? Icons.stop
                        : Icons.mic,
                    size: 30,
                  ),
                  label: Text(
                    _listening
                        ? 'STOP LISTENING'
                        : 'TALK TO YANSI',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _manualSpeak,
                      icon: const Icon(
                        Icons.volume_up,
                      ),
                      label:
                          const Text('Yansi Speak'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clear,
                      icon: const Icon(
                        Icons.clear,
                      ),
                      label:
                          const Text('Clear'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              _field(
                label: 'Expense Category',
                hint:
                    'Yansi will fill this automatically',
                controller:
                    _categoryController,
                icon: Icons.category,
              ),

              const SizedBox(height: 15),

              _field(
                label: 'Amount',
                hint:
                    'Yansi will find the amount',
                controller:
                    _amountController,
                icon: Icons.currency_rupee,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 15),

              _field(
                label: 'Description',
                hint:
                    'Your spoken sentence',
                controller:
                    _descriptionController,
                icon: Icons.notes,
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Example',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Say: "I spent 500 rupees on petrol today."',
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Yansi → Fuel → ₹500 → '
                        'records your description automatically.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
