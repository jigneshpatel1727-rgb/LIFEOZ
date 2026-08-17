import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Small, bounded conversational memory. Long-term/core data remains in the
/// canonical five-core store rather than being duplicated here.
class IamyansiAgentMemory {
  static const _key = 'iamyansi_short_term_memory';
  static const _maxItems = 20;
  final SharedPreferences prefs;
  const IamyansiAgentMemory({required this.prefs});

  List<Map<String, dynamic>> read() => (prefs.getStringList(_key) ?? <String>[])
      .map((v) {
        try { return Map<String, dynamic>.from(jsonDecode(v) as Map); }
        catch (_) { return <String, dynamic>{}; }
      })
      .where((v) => v.isNotEmpty)
      .toList();

  Future<void> remember(String role, String text) async {
    final items = read();
    items.add({'role': role, 'text': text, 'at': DateTime.now().toIso8601String()});
    if (items.length > _maxItems) items.removeRange(0, items.length - _maxItems);
    await prefs.setStringList(_key, items.map(jsonEncode).toList());
  }

  Future<void> clear() => prefs.remove(_key);
}
