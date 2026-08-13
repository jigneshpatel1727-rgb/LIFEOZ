import 'lifeos_intelligence_bus.dart';

/// Cross-core memory index used by Yansi to connect events across LifeOS.
class YansiCrossCoreMemory {
  final LifeOSIntelligenceBus bus;
  const YansiCrossCoreMemory(this.bus);

  Map<String, List<LifeOSSignal>> grouped({int limitPerCore = 10}) {
    final result = <String, List<LifeOSSignal>>{};
    for (final signal in bus.signals.reversed) {
      final key = signal.type.name;
      final bucket = result.putIfAbsent(key, () => <LifeOSSignal>[]);
      if (bucket.length < limitPerCore) bucket.add(signal);
    }
    return result;
  }

  List<LifeOSSignal> relatedTo(String text) {
    final words = text.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((w) => w.length >= 4).toSet();
    if (words.isEmpty) return const [];
    return bus.signals.reversed.where((signal) {
      final haystack = '${signal.text} ${signal.type.name} ${signal.data.values.join(' ')}'.toLowerCase();
      return words.any(haystack.contains);
    }).take(20).toList(growable: false);
  }

  String explainConnection(String text) {
    final related = relatedTo(text);
    if (related.isEmpty) return 'No strong cross-core connection found yet.';
    final types = related.map((s) => s.type.name).toSet().toList();
    return 'Yansi found related activity across: ${types.join(', ')}.';
  }
}
