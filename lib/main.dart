import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const LifeOSApp());
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF06131A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5A0),
          brightness: Brightness.dark,
        ),
      ),
      home: const LifeOSHome(),
    );
  }
}

class Expense {
  final String category;
  final double amount;
  final String description;

  Expense({
    required this.category,
    required this.amount,
    required this.description,
  });
}

class LifeOSHome extends StatefulWidget {
  const LifeOSHome({super.key});

  @override
  State<LifeOSHome> createState() => _LifeOSHomeState();
}

class _LifeOSHomeState extends State<LifeOSHome> {
  final stt.SpeechToText speech = stt.SpeechToText();

  bool menuOpen = false;
  bool listening = false;
  bool speechAvailable = false;

  String recognizedText = '';
  String yansiMessage =
      'Hello 👋 I am Yansi. Tell me what is happening in your life.';

  final List<Expense> expenses = [];

  final List<Map<String, dynamic>> cores = [
    {'icon': Icons.account_balance_wallet_rounded, 'title': 'Money'},
    {'icon': Icons.favorite_rounded, 'title': 'Health'},
    {'icon': Icons.work_rounded, 'title': 'Work'},
    {'icon': Icons.home_rounded, 'title': 'Home'},
    {'icon': Icons.track_changes_rounded, 'title': 'Goals'},
  ];

  @override
  void initState() {
    super.initState();
    initializeSpeech();
  }

  Future<void> initializeSpeech() async {
    speechAvailable = await speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            listening = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          listening = false;
          yansiMessage =
              'I could not hear you. Please try speaking again.';
        });
      },
    );

    setState(() {});
  }

  Future<void> startListening() async {
    if (!speechAvailable) {
      yansiMessage =
          'Speech recognition is not available on this device.';
      setState(() {});
      return;
    }

    setState(() {
      listening = true;
      recognizedText = '';
      yansiMessage = 'I am listening... 🎧';
    });

    await speech.listen(
      onResult: (result) {
        setState(() {
          recognizedText = result.recognizedWords;
        });

        if (result.finalResult) {
          processCommand(result.recognizedWords);
        }
      },
    );
  }

  Future<void> stopListening() async {
    await speech.stop();

    setState(() {
      listening = false;
    });

    if (recognizedText.isNotEmpty) {
      processCommand(recognizedText);
    }
  }

  void processCommand(String text) {
    final command = text.toLowerCase().trim();

    final amount = extractAmount(command);

    if (amount != null) {
      String category = detectCategory(command);

      String description = command;

      expenses.add(
        Expense(
          category: category,
          amount: amount,
          description: description,
        ),
      );

      setState(() {
        yansiMessage =
            'Got it 👍 ₹${amount.toStringAsFixed(0)} added to $category.';
      });

      return;
    }

    setState(() {
      yansiMessage =
          'I heard: "$text". Tell me an amount if you want me to record an expense.';
    });
  }

  double? extractAmount(String text) {
    final numberPattern = RegExp(
      r'(?:₹|rs\.?|rupees?)?\s*(\d+(?:\.\d+)?)',
      caseSensitive: false,
    );

    final match = numberPattern.firstMatch(text);

    if (match != null) {
      return double.tryParse(match.group(1)!);
    }

    return null;
  }

  String detectCategory(String text) {
    if (text.contains('petrol') ||
        text.contains('fuel') ||
        text.contains('diesel')) {
      return 'Fuel';
    }

    if (text.contains('milk')) {
      return 'Milk';
    }

    if (text.contains('electricity') ||
        text.contains('light bill') ||
        text.contains('power')) {
      return 'Electricity';
    }

    if (text.contains('rent')) {
      return 'Rent';
    }

    if (text.contains('emi') ||
        text.contains('loan') ||
        text.contains('installment')) {
      return 'EMI';
    }

    if (text.contains('food') ||
        text.contains('restaurant') ||
        text.contains('lunch') ||
        text.contains('dinner')) {
      return 'Food';
    }

    if (text.contains('medicine') ||
        text.contains('medical') ||
        text.contains('doctor')) {
      return 'Medical';
    }

    if (text.contains('shopping') ||
        text.contains('clothes') ||
        text.contains('shirt') ||
        text.contains('dress')) {
      return 'Shopping';
    }

    if (text.contains('travel') ||
        text.contains('bus') ||
        text.contains('train') ||
        text.contains('taxi')) {
      return 'Travel';
    }

    return 'Other';
  }

  double get totalExpenses {
    double total = 0;

    for (final expense in expenses) {
      total += expense.amount;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E5A0).withOpacity(0.08),
                ),
              ),
            ),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            menuOpen = !menuOpen;
                          });
                        },
                        icon: Icon(
                          menuOpen
                              ? Icons.close_rounded
                              : Icons.menu_rounded,
                          color: const Color(0xFF00E5A0),
                          size: 30,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'LifeOS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),

                        Container(
                          width: 145,
                          height: 145,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF00E5A0),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5A0)
                                    .withOpacity(0.35),
                                blurRadius: 35,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 65,
                              color: Color(0xFF00E5A0),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Yansi',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00E5A0),
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Your LifeOS AI',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFF00E5A0)
                                  .withOpacity(0.25),
                            ),
                            color: const Color(0xFF0B2028),
                          ),
                          child: Text(
                            yansiMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.4,
                            ),
                          ),
                        ),

                        if (recognizedText.isNotEmpty) ...[
                          const SizedBox(height: 15),
                          Text(
                            'You said:',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            recognizedText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF00E5A0),
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        GestureDetector(
                          onTap: listening
                              ? stopListening
                              : startListening,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00E5A0),
                                  Color(0xFF00AFC4),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  listening
                                      ? Icons.stop_rounded
                                      : Icons.mic_rounded,
                                  color: Colors.black,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  listening
                                      ? 'Stop Listening'
                                      : 'Talk to Yansi',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF0B2028),
                            border: Border.all(
                              color: const Color(0xFF00E5A0)
                                  .withOpacity(0.25),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Today's Expenses",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                '₹${totalExpenses.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00E5A0),
                                ),
                              ),

                              const SizedBox(height: 15),

                              if (expenses.isEmpty)
                                const Text(
                                  'No expenses recorded yet.',
                                  style: TextStyle(
                                    color: Colors.white60,
                                  ),
                                ),

                              ...expenses.map(
                                (expense) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: Color(0xFF00E5A0),
                                  ),
                                  title: Text(expense.category),
                                  subtitle: Text(expense.description),
                                  trailing: Text(
                                    '₹${expense.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: cores.map((core) {
                            return _coreIcon(
                              core['icon'],
                              core['title'],
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (menuOpen)
              Positioned(
                top: 68,
                left: 12,
                child: Container(
                  width: 230,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2028),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF00E5A0)
                          .withOpacity(0.4),
                    ),
                  ),
                  child: Column(
                    children: cores.map((core) {
                      return ListTile(
                        leading: Icon(
                          core['icon'],
                          color: const Color(0xFF00E5A0),
                        ),
                        title: Text(core['title']),
                        onTap: () {
                          setState(() {
                            menuOpen = false;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _coreIcon(IconData icon, String title) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0B2028),
          border: Border.all(
            color: const Color(0xFF00E5A0).withOpacity(0.45),
          ),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF00E5A0),
          size: 25,
        ),
      ),
    );
  }
}
