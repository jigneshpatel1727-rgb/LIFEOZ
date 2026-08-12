import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/life_entry.dart';

class LifeDatabase {
  static late SharedPreferences _prefs;

  static const String _entriesKey =
      'lifeos_entries';

  static const String _nameKey =
      'lifeos_user_name';

  static Future<void> initialize() async {
    _prefs =
        await SharedPreferences.getInstance();
  }

  static Future<void> saveUserName(
    String name,
  ) async {
    await _prefs.setString(
      _nameKey,
      name,
    );
  }

  static String getUserName() {
    return _prefs.getString(
          _nameKey,
        ) ??
        '';
  }

  static Future<void> saveEntry(
    LifeEntry entry,
  ) async {
    final entries = getEntries();

    entries.removeWhere(
      (item) => item.id == entry.id,
    );

    entries.add(entry);

    final encoded = entries
        .map(
          (e) => jsonEncode(e.toJson()),
        )
        .toList();

    await _prefs.setStringList(
      _entriesKey,
      encoded,
    );
  }

  static List<LifeEntry> getEntries() {
    final data =
        _prefs.getStringList(
              _entriesKey,
            ) ??
            [];

    return data.map((item) {
      return LifeEntry.fromJson(
        jsonDecode(item),
      );
    }).toList();
  }

  static List<LifeEntry> getByType(
    String type,
  ) {
    return getEntries()
        .where(
          (entry) => entry.type == type,
        )
        .toList();
  }

  static Future<void> deleteEntry(
    String id,
  ) async {
    final entries = getEntries();

    entries.removeWhere(
      (entry) => entry.id == id,
    );

    final encoded = entries
        .map(
          (e) => jsonEncode(e.toJson()),
        )
        .toList();

    await _prefs.setStringList(
      _entriesKey,
      encoded,
    );
  }
}
