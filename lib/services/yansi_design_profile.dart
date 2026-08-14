import 'package:shared_preferences/shared_preferences.dart';

enum YansiDesignId { neonPulse, auroraFlux, quantumGlass, cyberHalo, deepSpace }

class YansiDesignProfile {
  final YansiDesignId id;
  final String name;
  final String description;
  final List<String> coreIcons;
  final String orbStyle;
  final String motionStyle;
  final String visualMood;

  const YansiDesignProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.coreIcons,
    required this.orbStyle,
    required this.motionStyle,
    required this.visualMood,
  });
}

class YansiDesignCatalog {
  static const profiles = <YansiDesignProfile>[
    YansiDesignProfile(
      id: YansiDesignId.neonPulse,
      name: 'Neon Pulse',
      description: 'Electric neural energy with luminous precision.',
      coreIcons: ['wallet', 'bolt', 'calendar', 'basket', 'target'],
      orbStyle: 'neural_orb',
      motionStyle: 'pulse',
      visualMood: 'futuristic_energy',
    ),
    YansiDesignProfile(
      id: YansiDesignId.auroraFlux,
      name: 'Aurora Flux',
      description: 'Fluid aurora motion with a softer intelligent presence.',
      coreIcons: ['ring', 'spark', 'time', 'home', 'star'],
      orbStyle: 'aurora_orb',
      motionStyle: 'flow',
      visualMood: 'calm_intelligence',
    ),
    YansiDesignProfile(
      id: YansiDesignId.quantumGlass,
      name: 'Quantum Glass',
      description: 'Transparent depth, precision layers and quantum geometry.',
      coreIcons: ['cube', 'node', 'clock', 'grid', 'focus'],
      orbStyle: 'glass_core',
      motionStyle: 'orbit',
      visualMood: 'precision',
    ),
    YansiDesignProfile(
      id: YansiDesignId.cyberHalo,
      name: 'Cyber Halo',
      description: 'High-contrast cyber geometry with an active AI halo.',
      coreIcons: ['hex', 'flash', 'chrono', 'cart', 'crosshair'],
      orbStyle: 'halo_core',
      motionStyle: 'scan',
      visualMood: 'active_cyber',
    ),
    YansiDesignProfile(
      id: YansiDesignId.deepSpace,
      name: 'Deep Space',
      description: 'Minimal cosmic depth with a quiet ambient intelligence.',
      coreIcons: ['planet', 'energy', 'orbit', 'home', 'constellation'],
      orbStyle: 'cosmic_orb',
      motionStyle: 'drift',
      visualMood: 'ambient_cosmic',
    ),
  ];

  static YansiDesignProfile byId(String value) {
    return profiles.firstWhere(
      (profile) => profile.id.name == value,
      orElse: () => profiles.first,
    );
  }

  static Future<void> save(SharedPreferences prefs, YansiDesignId id) =>
      prefs.setString('yansi_design_id', id.name);

  static YansiDesignProfile current(SharedPreferences prefs) =>
      byId(prefs.getString('yansi_design_id') ?? YansiDesignId.neonPulse.name);
}
