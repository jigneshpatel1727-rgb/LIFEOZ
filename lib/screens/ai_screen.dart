import 'package:flutter/material.dart';
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

  String _result = 'LifeOS AI is ready.';

  bool _loading = false;

  Future<void> _analyze() async {
    final category = _categoryController.text.trim();
    final amount =
        double.tryParse(_amountController.text.trim());
    final description =
        _descriptionController.text.trim();

    if (category.isEmpty) {
      setState(() {
        _result = 'Please enter an expense category.';
      });
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() {
        _result = 'Please enter a valid amount.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _result = 'LifeOS AI is analysing...';
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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _result =
            'LifeOS AI could not analyse this expense. Please try again.';
      });
    }
  }

  void _clearForm() {
    _categoryController.clear();
    _amountController.clear();
    _descriptionController.clear();

    setState(() {
      _result = 'LifeOS AI is ready.';
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeOS AI'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const SizedBox(height: 10),

            // AI ICON
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
              'LifeOS AI Agent',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'One tap to understand your expense '
              'and get a simple recommendation.',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 28),

            // CATEGORY
            TextField(
              controller: _categoryController,

              textInputAction:
                  TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Expense Category',
                hintText:
                    'Fuel, Food, Shopping, EMI...',
                prefixIcon:
                    Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // AMOUNT
            TextField(
              controller: _amountController,

              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),

              textInputAction:
                  TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount',
                prefixText: '₹ ',
                prefixIcon:
                    Icon(Icons.currency_rupee),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // DESCRIPTION
            TextField(
              controller: _descriptionController,

              maxLines: 3,

              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:
                    'What was this expense for?',
                prefixIcon:
                    Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ASK AI BUTTON
            SizedBox(
              height: 52,

              child: FilledButton.icon(
                onPressed:
                    _loading ? null : _analyze,

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
                      : 'ASK LIFEOS AI',
                ),
              ),
            ),

            const SizedBox(height: 10),

            // CLEAR BUTTON
            TextButton.icon(
              onPressed:
                  _loading ? null : _clearForm,

              icon: const Icon(
                Icons.refresh,
              ),

              label: const Text(
                'Clear',
              ),
            ),

            const SizedBox(height: 20),

            // RESULT CARD
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
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          'AI Recommendation',

                          style: TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      _result,

                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // LIFEOS PRINCIPLE
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
                      'Track → Understand → Improve → Save',
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
