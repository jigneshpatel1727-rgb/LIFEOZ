/// Extracts structured LifeOS candidates from OCR/document text.
/// Actual OCR is supplied by the camera/document layer.
class YansiDocumentIntelligenceEngine {
  const YansiDocumentIntelligenceEngine();

  Map<String, dynamic> analyze(String text) {
    final source = text.trim();
    final lower = source.toLowerCase();
    String category = 'document';
    if (_has(lower, ['receipt', 'subtotal', 'total'])) category = 'receipt';
    else if (_has(lower, ['invoice', 'invoice no'])) category = 'invoice';
    else if (_has(lower, ['premium', 'policy', 'renewal'])) category = 'insurance';
    else if (_has(lower, ['bill', 'due date', 'amount due'])) category = 'bill';

    return {
      'category': category,
      'rawText': source,
      'candidates': _candidates(source),
      'requiresReview': true,
      'source': 'permitted_document',
    };
  }

  List<String> _candidates(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .take(20)
        .toList(growable: false);
    return List.unmodifiable(lines);
  }

  bool _has(String text, List<String> values) => values.any(text.contains);
}
