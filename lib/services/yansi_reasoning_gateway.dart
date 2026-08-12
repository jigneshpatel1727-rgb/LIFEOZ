/// Provider-independent reasoning gateway for Yansi.
///
/// The app owns conversation context, permissions and safety. A production
/// deployment can plug an approved AI provider into [reason] without exposing
/// provider credentials in the Flutter client.
abstract class YansiReasoningProvider {
  Future<YansiReasoningResult> reason({
    required String input,
    required Map<String, dynamic> context,
    bool allowWeb = false,
  });
}

class YansiReasoningResult {
  final String text;
  final bool usedWeb;
  final double confidence;
  final List<String> sources;

  const YansiReasoningResult({
    required this.text,
    this.usedWeb = false,
    this.confidence = 0,
    this.sources = const [],
  });
}

/// Safe fallback used when no external reasoning provider is configured.
/// It prevents the UI from pretending that local heuristics are a full LLM.
class LocalYansiReasoningProvider implements YansiReasoningProvider {
  const LocalYansiReasoningProvider();

  @override
  Future<YansiReasoningResult> reason({
    required String input,
    required Map<String, dynamic> context,
    bool allowWeb = false,
  }) async {
    final question = input.trim();
    if (question.isEmpty) {
      return const YansiReasoningResult(text: 'I’m listening. What would you like to do?');
    }

    return YansiReasoningResult(
      text: 'I understand your question. I can use your LifeOS context to help, '
          'and I will use approved web information only when web access is enabled.',
      confidence: .5,
    );
  }
}

class YansiReasoningGateway {
  final YansiReasoningProvider provider;

  const YansiReasoningGateway({YansiReasoningProvider? provider})
      : provider = provider ?? const LocalYansiReasoningProvider();

  Future<YansiReasoningResult> answer({
    required String input,
    Map<String, dynamic> context = const {},
    bool allowWeb = false,
  }) {
    return provider.reason(input: input, context: context, allowWeb: allowWeb);
  }
}
