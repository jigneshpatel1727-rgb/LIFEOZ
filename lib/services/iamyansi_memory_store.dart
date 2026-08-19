import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Small, local, user-controlled memory layer for iAmYansi.
/// Stores preferences and useful task context without silently collecting
/// unrestricted personal data.
class IamyansiMemoryStore {
  static const _key = 'iamyansi_memory_v1';
  final SharedPreferences prefs;

  const IamyansiMemoryStore({required this.prefs});

  List<IamyansiMemory> get all {
    final raw = prefs.getStringList(_key) ?? const <String>[];
    return raw.map((value) {
      try {
        final map = jsonDecode(value) as Map<String, dynamic>;
        return IamyansiMemory(
          category: '${map['category'] ?? 'general'}',
          value: '${map['value'] ?? ''}',
          createdAt: DateTime.tryParse('${map['createdAt'] ?? ''}') ?? DateTime.now(),
        );
      } catch (_) {
        return null;
      }
    }).whereType<IamyansiMemory>().toList(growable: false);
  }

  Future<void> remember(String category, String value) async {
    final clean = value.trim();
    if (clean.isEmpty) return;
    final raw = [...(prefs.getStringList(_key) ?? const <String>[])];
    raw.add(jsonEncode({
      'category': category.trim().isEmpty ? 'general' : category.trim(),
      'value': clean,
      'createdAt': DateTime.now().toIso8601String(),
    }));
    if (raw.length > 100) raw.removeRange(0, raw.length - 100);
    await prefs.setStringList(_key, raw);
  }

  Future<void> clear() => prefs.remove(_key);
}

class IamyansiMemory {
  final String category;
  final String value;
  final DateTime createdAt;

  const IamyansiMemory({
    required this.category,
    required this.value,
    required this.createdAt,
  });
}
