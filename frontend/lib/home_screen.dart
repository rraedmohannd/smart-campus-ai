import 'package:flutter/material.dart';
import 'screens/chatbot_screen.dart';
import 'screens/library_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/bus_screen.dart';

class HomeScreen extends StatelessWidget {
  final String studentId;
  final String name;
  final String token;

  const HomeScreen({
    super.key,
    required this.studentId,
    required this.name,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome $name')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Chatbot'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatbotScreen(studentId: studentId),
              ),
            ),
          ),
          ListTile(
            title: const Text('Library'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LibraryScreen()), // ✅ fixed
            ),
          ),
          ListTile(
            title: const Text('Rules'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RulesScreen(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Bus System'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BusScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
