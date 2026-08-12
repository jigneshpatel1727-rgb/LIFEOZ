import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class UserProfileService {
  static const String _key = 'lifeos_user_profile';

  final SharedPreferences prefs;

  const UserProfileService(this.prefs);

  UserProfile? load() {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      return UserProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(UserProfile profile) async {
    await prefs.setString(_key, jsonEncode(profile.toJson()));

    // Keep the existing keys compatible with the current application.
    await prefs.setString('user_name', profile.fullName);
    await prefs.setString('country', profile.country);
    await prefs.setString('currency', profile.currencySymbol);
    await prefs.setInt('theme_index', profile.themeIndex);
  }

  Future<void> clear() async {
    await prefs.remove(_key);
  }
}
