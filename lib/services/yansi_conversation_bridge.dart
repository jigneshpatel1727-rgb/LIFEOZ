import 'yansi_backend_client.dart';
import 'yansi_privacy_guard.dart';

/// Connects the voice/text conversation layer to the secure Yansi backend.
/// The bridge intentionally keeps UI, speech, permissions and networking separate.
class YansiConversationBridge {
  final YansiBackendClient client;
  final YansiPrivacyGuard privacy;

  const YansiConversationBridge({
    required this.client,
    required this.privacy,
  });

  Future<YansiConversationResult> ask({
    required String text,
    Map<String, dynamic>? lifeosContext,
    String? accessToken,
  }) async {
    if (text.trim().isEmpty) {
      return const YansiConversationResult(
        ok: false,
        answer: 'I am listening. Tell me what you need.',
      );
    }

    try {
      // YansiBackendClient exposes `ask()`, not `respond()`.
      // Authentication is handled by the client's accessTokenProvider.
      final response = await client.ask(
        message: text.trim(),
        lifeosContext: lifeosContext ?? const <String, dynamic>{},
        allowWeb: privacy.canUseWeb(),
      );

      if (!response.ok) {
        return YansiConversationResult(
          ok: false,
          answer: response.error ?? 'I could not reach my intelligence service right now. I am still here.',
          requestId: response.requestId,
        );
      }

      return YansiConversationResult(
        ok: true,
        answer: response.answer.isNotEmpty ? response.answer : 'I am here.',
        requestId: response.requestId,
      );
    } catch (_) {
      return const YansiConversationResult(
        ok: false,
        answer: 'I had trouble connecting just now. Please try again.',
      );
    }
  }
}

class YansiConversationResult {
  final bool ok;
  final String answer;
  final String? requestId;
  final Map<String, dynamic>? raw;

  const YansiConversationResult({
    required this.ok,
    required this.answer,
    this.requestId,
    this.raw,
  });
}
