/// Central policy for deciding whether useful intelligence should remain
/// silent, appear visually, or be spoken.
///
/// This keeps proactive behavior separate from individual capabilities and
/// presentation implementations.
enum YansiPresentationMode { silent, ambient, spoken }

class YansiProactiveCandidate {
  final String id;
  final double priority;
  final bool speakable;
  final bool requiresConfirmation;
  final bool userRequested;
  final DateTime createdAt;

  const YansiProactiveCandidate({
    required this.id,
    required this.priority,
    this.speakable = false,
    this.requiresConfirmation = false,
    this.userRequested = false,
    required this.createdAt,
  });
}

class YansiProactiveDecision {
  final YansiPresentationMode mode;
  final String reason;

  const YansiProactiveDecision(this.mode, this.reason);
}

class YansiProactivePolicy {
  const YansiProactivePolicy();

  YansiProactiveDecision decide(YansiProactiveCandidate candidate) {
    if (candidate.userRequested) {
      return YansiProactiveDecision(
        candidate.speakable
            ? YansiPresentationMode.spoken
            : YansiPresentationMode.ambient,
        'User requested this information.',
      );
    }

    if (candidate.requiresConfirmation) {
      return const YansiProactiveDecision(
        YansiPresentationMode.ambient,
        'Confirmation is required before speaking or acting.',
      );
    }

    if (candidate.priority < 45) {
      return const YansiProactiveDecision(
        YansiPresentationMode.silent,
        'Priority is below the proactive surfacing threshold.',
      );
    }

    if (candidate.speakable && candidate.priority >= 82) {
      return const YansiProactiveDecision(
        YansiPresentationMode.spoken,
        'High-priority information is useful enough to speak.',
      );
    }

    return const YansiProactiveDecision(
      YansiPresentationMode.ambient,
      'Useful information should remain ambient.',
    );
  }
}
