import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/core_report_screen.dart';

class LifeOZCoreHub extends StatelessWidget {
  final SharedPreferences prefs;
  final int coreIndex;
  const LifeOZCoreHub({super.key, required this.prefs, required this.coreIndex});

  @override
  Widget build(BuildContext context) {
    return CoreReportScreen(
      core: coreIndex,
      currency: widgetCurrency(prefs),
    );
  }
}

String widgetCurrency(SharedPreferences prefs) {
  final value = prefs.getString('currency');
  if (value == null || value.trim().isEmpty) return '₹';
  return value.trim();
}
