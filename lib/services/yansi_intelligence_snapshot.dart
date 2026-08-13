/// Immutable snapshot boundary for Yansi's intelligence pipeline.
/// Keeps cross-core context separate from execution and persistence.
class YansiIntelligenceSnapshot {
  final String? core;
  final int priority;
  final int confidence;
  final String? insight;
  final bool surface;
  final bool speak;

  const YansiIntelligenceSnapshot({
    required this.core,
    required this.priority,
    required this.confidence,
    required this.insight,
    required this.surface,
    required this.speak,
  });

  bool get actionable => surface && priority >= 70;

  bool get requiresConfirmation => actionable && priority >= 80;

  Map<String, dynamic> toMap() => {
        'core': core,
        'priority': priority.clamp(0, 100),
        'confidence': confidence.clamp(0, 100),
        'insight': insight,
        'surface': surface,
        'speak': speak,
        'actionable': actionable,
        'requiresConfirmation': requiresConfirmation,
      };
}
