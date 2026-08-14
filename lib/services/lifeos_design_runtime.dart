import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lifeos_design_preferences.dart';

/// Runtime bridge between persisted design choice and the live LifeOS shell.
/// UI code can depend on this single object instead of knowing how the choice
/// is stored or how the five design profiles are defined.
class LifeOSDesignRuntime {
  final SharedPreferences prefs;
  const LifeOSDesignRuntime(this.prefs);

  LifeOSDesignProfile get profile => LifeOSDesignPreferences.current(prefs);
  Color get accent => profile.accent;

  IconData iconForCore(String core) => switch (core) {
        'MONEY' => profile.moneyIcon,
        'PRODUCTIVITY' => profile.productivityIcon,
        'CALENDAR' => profile.calendarIcon,
        'HOUSEHOLD' => profile.householdIcon,
        _ => profile.goalsIcon,
      };

  Future<void> select(String designId) =>
      LifeOSDesignPreferences.save(prefs, designId);
}
