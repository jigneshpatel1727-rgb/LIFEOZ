import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/life_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LifeDatabase.initialize();

  runApp(const LifeOS());
}

class LifeOS extends StatelessWidget {
  const LifeOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF02070D),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),

        fontFamily: 'sans',

        useMaterial3: true,
      ),

      home: const LoginScreen(),
    );
  }
}
