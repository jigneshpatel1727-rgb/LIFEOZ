import 'lifeos_intelligence_bus.dart';
import 'lifeos_signal_store.dart';
import 'yansi_voice_intent_parser.dart';

class YansiResponseRouterFixed {
  final LifeOSSignalStore store;
  final YansiVoiceIntentParser parser;
  const YansiResponseRouterFixed(this.store, {this.parser = const YansiVoiceIntentParser()});
  bool route(String text) {
    final value = text.trim();
    if (value.isEmpty) return false;
    final intent = parser.parse(value);
    switch (intent.intent) {
      case 'expense': store.expense(intent.amount!, value, category: intent.category ?? 'Other'); return true;
      case 'task': store.task(value); return true;
      case 'calendar': store.calendar(value); return true;
      case 'household': store.household(value); return true;
      case 'diary': store.diary(value); return true;
      default: store.record(LifeOSSignalType.voice, value); return true;
    }
  }
}
