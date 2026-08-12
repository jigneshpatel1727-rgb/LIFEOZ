import 'package:flutter/material.dart';

import '../models/lifeos_core.dart';
import '../screens/calendar_core_screen.dart';
import '../screens/core_report_screen.dart';

/// Single routing boundary for the five permanent LifeOS cores.
/// The home screen can continue passing stable integer IDs while the
/// destination logic stays centralized here.
class CoreRouter {
  static void open(
    BuildContext context,
    int core,
    String currency,
  ) {
    final definition = coreByIndex(core);

    if (definition.core == LifeOSCore.calendar) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CalendarCoreScreen(currency: currency),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoreReportScreen(
          core: definition.index,
          currency: currency,
        ),
      ),
    );
  }
}
