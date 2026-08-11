import 'yansi_brain_service.dart';

/// Yansi Connector
///
/// This is the bridge between the futuristic Yansi interface
/// and the Yansi intelligence layer.
///
/// We keep this separate so the existing LifeOS UI is not
/// disturbed while we upgrade Yansi step-by-step.
class YansiConnector {
  static final YansiConnector instance =
      YansiConnector._internal();

  YansiConnector._internal();

  factory YansiConnector() {
    return instance;
  }

  final YansiBrainService brain =
      YansiBrainService();

  /// Sends natural language to Yansi's brain.
  Future<YansiDecision> process(
    String text,
  ) async {
    return await brain.think(text);
  }

  /// Convenience method for checking whether
  /// Yansi understood something.
  Future<bool> understands(
    String text,
  ) async {
    final decision =
        await brain.think(text);

    return decision.intent !=
        YansiIntent.unknown;
  }

  /// Returns Yansi's response without
  /// performing an action.
  Future<String> ask(
    String text,
  ) async {
    final decision =
        await brain.think(text);

    return decision.response;
  }
}
