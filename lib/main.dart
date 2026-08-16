import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lifeoz_3d_theme_home.dart';
import 'services/yansi_phase2_intelligence.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Phase 2 runs safe, local intelligence maintenance at startup.
  // Yansi remains ambient; this does not open a chatbot or add a new core.
  await YansiPhase2Intelligence(prefs: prefs).runDailyMaintenance();

  runApp(AllInMyDayApp(prefs: prefs));
}

class AllInMyDayApp extends StatelessWidget {
  final SharedPreferences prefs;
  const AllInMyDayApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ALL IN MY DAY',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF020A18),
        ),
        home: LifeOZ3DThemeHome(prefs: prefs),
      );
}
