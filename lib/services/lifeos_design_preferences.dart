import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOSDesignProfile {
  final String id;
  final String name;
  final IconData moneyIcon;
  final IconData productivityIcon;
  final IconData calendarIcon;
  final IconData householdIcon;
  final IconData goalsIcon;
  final Color accent;

  const LifeOSDesignProfile({required this.id, required this.name, required this.moneyIcon, required this.productivityIcon, required this.calendarIcon, required this.householdIcon, required this.goalsIcon, required this.accent});
}

class LifeOSDesignPreferences {
  static const String key = 'lifeos_design_id';

  static const List<LifeOSDesignProfile> profiles = <LifeOSDesignProfile>[
    LifeOSDesignProfile(id: 'neural_flow', name: 'Neural Flow', moneyIcon: Icons.account_balance_wallet_rounded, productivityIcon: Icons.bolt_rounded, calendarIcon: Icons.calendar_month_rounded, householdIcon: Icons.shopping_basket_rounded, goalsIcon: Icons.track_changes_rounded, accent: Color(0xFF00E5FF)),
    LifeOSDesignProfile(id: 'quantum_pulse', name: 'Quantum Pulse', moneyIcon: Icons.currency_exchange_rounded, productivityIcon: Icons.speed_rounded, calendarIcon: Icons.schedule_rounded, householdIcon: Icons.local_mall_rounded, goalsIcon: Icons.bolt_rounded, accent: Color(0xFF63FFB1)),
    LifeOSDesignProfile(id: 'holo_prism', name: 'Holo Prism', moneyIcon: Icons.diamond_outlined, productivityIcon: Icons.auto_awesome_rounded, calendarIcon: Icons.view_timeline_rounded, householdIcon: Icons.grid_view_rounded, goalsIcon: Icons.explore_rounded, accent: Color(0xFF8A9CFF)),
    LifeOSDesignProfile(id: 'aurora_core', name: 'Aurora Core', moneyIcon: Icons.savings_rounded, productivityIcon: Icons.psychology_rounded, calendarIcon: Icons.event_available_rounded, householdIcon: Icons.home_work_rounded, goalsIcon: Icons.flag_rounded, accent: Color(0xFF00FFC6)),
    LifeOSDesignProfile(id: 'cyber_matrix', name: 'Cyber Matrix', moneyIcon: Icons.dataset_rounded, productivityIcon: Icons.memory_rounded, calendarIcon: Icons.data_exploration_rounded, householdIcon: Icons.storage_rounded, goalsIcon: Icons.schema_rounded, accent: Color(0xFFB8FF4D)),
  ];

  static LifeOSDesignProfile resolve(String? id) => profiles.firstWhere((p) => p.id == id, orElse: () => profiles.first);
  static LifeOSDesignProfile current(SharedPreferences prefs) => resolve(prefs.getString(key));
  static Future<void> save(SharedPreferences prefs, String id) async {
    if (profiles.any((p) => p.id == id)) await prefs.setString(key, id);
  }
}
