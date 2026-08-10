import 'package:flutter/material.dart';

import 'screens/ai_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const LifeOSApp());
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      home: const AIScreen(),
    );
  }
}
