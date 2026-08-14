import 'yansi_memory_policy.dart';

/// Stable stored representation for approved Yansi memory.
///
/// Storage implementations can evolve independently from the intelligence
/// layer. Records carry provenance and expiry so memory remains explainable
/// and bounded.
class YansiMemoryRecord {
  final String id;
  final String source;
  final String content;
  final YansiMemoryClass memoryClass;
  final double confidence;
  final DateTime observedAt;
  final DateTime expiresAt;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const YansiMemoryRecord({
    required this.id,
    required this.source,
    required this.content,
    required this.memoryClass,
    required this.confidence,
    required this.observedAt,
    required this.expiresAt,
    required this.createdAt,
    this.metadata = const <String, dynamic>{},
  });

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);

  Map<String, dynamic> toMap() => {
        'id': id,
        'source': source,
        'content': content,
        'memoryClass': memoryClass.name,
        'confidence': confidence.clamp(0, 1),
        'observedAt': observedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'metadata': metadata,
      };
}
