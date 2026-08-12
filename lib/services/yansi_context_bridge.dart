import 'lifeos_context_engine.dart';
import 'yansi_brain.dart';

/// Keeps Yansi's existing local-first brain intact while giving it a unified
/// LifeOS context snapshot before a command is processed.
class YansiContextBridge {
  final YansiBrain brain;
  final LifeOSContextEngine context;

  const YansiContextBridge({required this.brain, required this.context});

  Future<YansiResult> process(String input, {String? voicePath}) async {
    final snapshot = context.snapshot();
    final enriched = snapshot['recentCount'] == 0
        ? input
        : '$input\n[LifeOS context: ${context.conciseSummary()}]';
    return brain.process(enriched, voicePath: voicePath);
  }
}
