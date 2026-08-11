import 'yansi_brain_service.dart';

/// ============================================================
/// YANSI CONNECTOR
///
/// This is the bridge between the existing LifeOS UI
/// and Yansi's intelligence.
///
/// UI / Voice
///     ↓
/// YansiConnector
///     ↓
/// YansiBrainService
///     ↓
/// YansiDecision
/// ============================================================

class YansiConnector {
  static final YansiConnector instance =
      YansiConnector._internal();

  YansiConnector._internal();

  factory YansiConnector() {
    return instance;
  }

  final YansiBrainService brain =
      YansiBrainService();

  /// Main intelligence entry point.
  Future<YansiDecision> process(
    String text,
  ) async {
    return brain.think(text);
  }

  /// Ask Yansi something without performing
  /// a LifeOS action.
  Future<String> ask(
    String text,
  ) async {
    final decision = await brain.think(text);
    return decision.response;
  }

  /// Check whether Yansi understands the command.
  Future<bool> understands(
    String text,
  ) async {
    final decision = await brain.think(text);

    return decision.intent !=
        YansiIntent.unknown;
  }

  /// Convenience method for expense commands.
  Future<YansiDecision> understandExpense(
    String text,
  ) async {
    return brain.think(text);
  }
}
