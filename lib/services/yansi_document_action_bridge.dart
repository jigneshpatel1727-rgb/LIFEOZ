import 'yansi_document_intelligence_engine.dart';

/// Routes document findings into reviewable LifeOS candidates.
class YansiDocumentActionBridge {
  final YansiDocumentIntelligenceEngine intelligence;

  const YansiDocumentActionBridge({
    this.intelligence = const YansiDocumentIntelligenceEngine(),
  });

  Map<String, dynamic> process(String extractedText) {
    final result = intelligence.analyze(extractedText);
    return {
      'analysis': result,
      'nextState': 'review_and_confirm',
      'autoCommit': false,
      'requiresVerification': true,
    };
  }
}
