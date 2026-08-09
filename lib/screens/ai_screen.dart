import 'package:flutter/material.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _controller =
      TextEditingController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Hello! I am your LifeOS AI. You can tell me about expenses, income, savings, bills, or ask me for a report.',
      isUser: false,
    ),
  ];

  bool _isThinking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isEmpty || _isThinking) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _controller.clear();
      _isThinking = true;
    });

    // Temporary local AI engine.
    // The real AI model will be connected in the next stage.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      final response = _generateLocalResponse(text);

      setState(() {
        _messages.add(
          _ChatMessage(
            text: response,
            isUser: false,
          ),
        );

        _isThinking = false;
      });
    });
  }

  String _generateLocalResponse(String text) {
    final message = text.toLowerCase();

    if (message.contains('spent') ||
        message.contains('expense') ||
        message.contains('₹')) {
      return 'I understand. In the next AI integration step, I will identify the amount, category and date, and can save the expense automatically.';
    }

    if (message.contains('saving') ||
        message.contains('save')) {
      return 'I can analyze your income and expenses and identify opportunities to improve your savings.';
    }

    if (message.contains('report')) {
      return 'Your LifeOS AI will generate a simple report showing income, expenses, savings, major categories and areas that may be reduced.';
    }

    if (message.contains('hello') ||
        message.contains('hi')) {
      return 'Hello! 👋 Tell me what happened today and I will help organize it in LifeOS.';
    }

    return 'I understand your request. My AI engine will be connected next so I can understand your information, work with your LifeOS data and take appropriate actions.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome),
            SizedBox(width: 8),
            Text(
              'LifeOS AI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                return _MessageBubble(
                  message: message,
                );
              },
            ),
          ),

          if (_isThinking)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('LifeOS AI is thinking...'),
                  ],
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) =>
                          _sendMessage(),
                      decoration: InputDecoration(
                        hintText:
                            'Ask LifeOS anything...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(24),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  CircleAvatar(
                    radius: 25,
                    child: IconButton(
                      onPressed: _isThinking
                          ? null
                          : _sendMessage,
                      icon: const Icon(
                        Icons.send,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 330,
        ),
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? const LinearGradient(
                  colors: [
                    Color(0xFF00D4FF),
                    Color(0xFF00E676),
                  ],
                )
              : null,
          color: message.isUser
              ? null
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Colors.black87
                : null,
          ),
        ),
      ),
    );
  }
}
