/// Records an explicit user-approved learning signal for Yansi.
/// This is an in-memory/read-only model; persistence and model updates remain
/// behind the application's existing permission and confirmation boundaries.
class YansiLearningSignal {
  final String category;
  final String signal;
  final int confidence;
  final DateTime createdAt;

  const YansiLearningSignal({
    required this.category,
    required this.signal,
    required this.confidence,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'category': category,
        'signal': signal,
        'confidence': confidence.clamp(0, 100),
        'createdAt': createdAt.toIso8601String(),
      };
}
