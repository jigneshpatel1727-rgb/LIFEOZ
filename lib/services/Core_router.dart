import 'package:flutter/material.dart';

import '../screens/core_report_screen.dart';

class CoreRouter {
  static void open(
    BuildContext context,
    int core,
    String currency,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoreReportScreen(
          core: core,
          currency: currency,
        ),
      ),
    );
  }
}
