/// Durable policy for deciding what approved context may become memory.
///
/// Yansi should not turn every observation into permanent memory. Memory is
/// explicit, bounded and explainable so future intelligence can improve
/// without uncontrolled accumulation.
enum YansiMemoryClass { transient, useful, preference, recurring, outcome }

class YansiMemoryCandidate {
  final String source;
  final String content;
  final YansiMemoryClass memoryClass;
  final bool userApproved;
  final double confidence;
  final DateTime observedAt;

  const YansiMemoryCandidate({
    required this.source,
    required this.content,
    this.memoryClass = YansiMemoryClass.transient,
    this.userApproved = false,
    this.confidence = 1,
    required this.observedAt,
  });
}

class YansiMemoryDecision {
  final bool retain;
  final Duration retention;
  final String reason;

  const YansiMemoryDecision({
    required this.retain,
    required this.retention,
    required this.reason,
  });
}

class YansiMemoryPolicy {
  const YansiMemoryPolicy();

  YansiMemoryDecision evaluate(YansiMemoryCandidate candidate) {
    if (!candidate.userApproved) {
      return const YansiMemoryDecision(
        retain: false,
        retention: Duration.zero,
        reason: 'Memory retention requires user approval.',
      );
    }

    if (candidate.content.trim().isEmpty || candidate.confidence < 0.5) {
      return const YansiMemoryDecision(
        retain: false,
        retention: Duration.zero,
        reason: 'Insufficient content or confidence.',
      );
    }

    switch (candidate.memoryClass) {
      case YansiMemoryClass.transient:
        return const YansiMemoryDecision(
          retain: false,
          retention: Duration.zero,
          reason: 'Transient context should not become long-term memory.',
        );
      case YansiMemoryClass.useful:
        return const YansiMemoryDecision(
          retain: true,
          retention: Duration(days: 90),
          reason: 'Approved useful context has bounded retention.',
        );
      case YansiMemoryClass.preference:
        return const YansiMemoryDecision(
          retain: true,
          retention: Duration(days: 365),
          reason: 'Approved user preference may persist longer.',
        );
      case YansiMemoryClass.recurring:
        return const YansiMemoryDecision(
          retain: true,
          retention: Duration(days: 365),
          reason: 'Approved recurring pattern supports future planning.',
        );
      case YansiMemoryClass.outcome:
        return const YansiMemoryDecision(
          retain: true,
          retention: Duration(days: 180),
          reason: 'Capability outcomes can support bounded adaptation.',
        );
    }
  }
}
