import 'yansi_capability_context.dart';
import 'yansi_memory_record.dart';
import 'yansi_memory_retrieval.dart';
import 'yansi_multimodal_context.dart';

/// Final, bounded context envelope assembled immediately before Yansi reasoning.
/// It bridges the existing LifeOS context snapshot with the permanent Yansi
/// intelligence contracts without replacing the existing storage layer.
class YansiUnifiedReasoningContext {
  final Map<String, dynamic> lifeContext;
  final YansiMultimodalContext observations;
  final List<YansiMemoryRecord> relevantMemories;
  final YansiCapabilityContext capabilities;

  const YansiUnifiedReasoningContext({
    this.lifeContext = const <String, dynamic>{},
    this.observations = const YansiMultimodalContext(),
    this.relevantMemories = const <YansiMemoryRecord>[],
    this.capabilities = const YansiCapabilityContext(),
  });
}

class YansiUnifiedReasoningContextBuilder {
  final YansiMemoryRetrieval memoryRetrieval;

  const YansiUnifiedReasoningContextBuilder({
    this.memoryRetrieval = const YansiMemoryRetrieval(),
  });

  YansiUnifiedReasoningContext build({
    Map<String, dynamic> lifeContext = const <String, dynamic>{},
    YansiMultimodalContext observations = const YansiMultimodalContext(),
    Iterable<YansiMemoryRecord> memories = const <YansiMemoryRecord>[],
    Set<String> memoryTopics = const <String>{},
    YansiCapabilityContext capabilities = const YansiCapabilityContext(),
    int memoryLimit = 12,
  }) {
    final relevant = memoryRetrieval.relevant(
      memories: memories,
      topics: memoryTopics,
      limit: memoryLimit,
    );

    return YansiUnifiedReasoningContext(
      lifeContext: Map<String, dynamic>.unmodifiable(lifeContext),
      observations: observations,
      relevantMemories: relevant,
      capabilities: capabilities,
    );
  }
}
