/// Plans concise ambient responses from Yansi decisions.
class YansiConversationalResponsePlanner {
  const YansiConversationalResponsePlanner();

  Map<String, dynamic> plan({
    required Map<String, dynamic> decision,
    required bool userActive,
  }) {
    final mode = (decision['mode'] ?? 'silent').toString();

    if (mode == 'silent') {
      return {
        'channel': 'none',
        'text': null,
        'speak': false,
      };
    }

    final recommendation = decision['recommendation'];

    final text = recommendation == null
        ? 'I have nothing important to interrupt you about right now.'
        : 'I noticed something that may be useful. I am ready when you are.';

    return {
      'channel': userActive
          ? 'ambient_voice'
          : 'ambient_signal',
      'text': text,
      'speak': userActive,
      'concise': true,
      'chatbotMode': false,
      'requiresConfirmationForAction':
          decision['requiresConfirmation'] == true,
    };
  }
}
