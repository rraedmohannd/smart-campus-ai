import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF9E1B22),
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: const Color(0xFF9E1B22)),
        scaffoldBackgroundColor: const Color(0xFFF7F7F8),

      ),
    home: const HomeScreen(
  studentName: "Test User",
  studentId: "12345",
  token: "test_token",
),

    );
  }
}
