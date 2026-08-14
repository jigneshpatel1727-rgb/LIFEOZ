import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lifeoz_master_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(LifeOZApp(prefs: prefs));
}

class LifeOZApp extends StatelessWidget {
  final SharedPreferences prefs;
  const LifeOZApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LIFEOZ',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF010207),
      ),
      home: LifeOZMasterShell(prefs: prefs),
    );
  }
}
