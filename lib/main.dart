import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lifeoz_design_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(LifeOZApp(prefs: prefs));
}

class LifeOZApp extends StatelessWidget {
  final SharedPreferences prefs;
  const LifeOZApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LIFEOZ',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF01030A),
        ),
        home: LifeOZDesignHome(prefs: prefs),
      );
}
