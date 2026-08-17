import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lifeoz_3d_theme_home.dart';
import 'services/iamyansi_phase2_intelligence.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // iamyansi remains the ambient AI intelligence inside AllInMyDay.
  await IamyansiPhase2Intelligence(prefs: prefs).runDailyMaintenance();

  runApp(AllInMyDayApp(prefs: prefs));
}

class AllInMyDayApp extends StatelessWidget {
  final SharedPreferences prefs;
  const AllInMyDayApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AllInMyDay',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF020A18),
        ),
        home: LifeOZ3DThemeHome(prefs: prefs),
      );
}
