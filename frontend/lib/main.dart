import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus AI Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(), // ✅ start at LoginScreen
    );
  }
}
