import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

class DIASApp extends StatelessWidget {
  const DIASApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIAS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

void main() {
    runApp(const DIASApp());
}
