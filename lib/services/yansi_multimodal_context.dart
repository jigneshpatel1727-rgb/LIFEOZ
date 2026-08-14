/// Unified, renderer/provider-neutral context for Yansi inputs.
///
/// Every modality uses the same envelope so future voice, image, receipt,
/// document, map, web and spatial providers can feed the same intelligence
/// fabric without creating separate reasoning paths.
class YansiModalityObservation {
  final String modality;
  final String source;
  final String content;
  final double confidence;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const YansiModalityObservation({
    required this.modality,
    required this.source,
    required this.content,
    this.confidence = 1,
    required this.timestamp,
    this.metadata = const <String, dynamic>{},
  });

  Map<String, dynamic> toMap() => {
        'modality': modality,
        'source': source,
        'content': content,
        'confidence': confidence.clamp(0, 1),
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };
}

class YansiMultimodalContext {
  final List<YansiModalityObservation> observations;

  const YansiMultimodalContext({
    this.observations = const <YansiModalityObservation>[],
  });

  YansiMultimodalContext add(YansiModalityObservation observation) {
    return YansiMultimodalContext(
      observations: List<YansiModalityObservation>.unmodifiable(
        <YansiModalityObservation>[...observations, observation],
      ),
    );
  }

  List<YansiModalityObservation> forModality(String modality) {
    final target = modality.trim().toLowerCase();
    return observations
        .where((item) => item.modality.toLowerCase() == target)
        .toList(growable: false);
  }

  List<YansiModalityObservation> reliable({double minimum = 0.6}) {
    return observations
        .where((item) => item.confidence >= minimum)
        .toList(growable: false);
  }
}
