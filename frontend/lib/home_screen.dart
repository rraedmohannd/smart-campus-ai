import 'package:flutter/material.dart';
import 'screens/chatbot_screen.dart';
import 'screens/bus_screen.dart';
import 'screens/library_screen.dart';
import 'screens/rules_screen.dart';

const Color primaryRed = Color(0xFF9E1B22);

class HomeScreen extends StatelessWidget {
  final String? studentName;
  final String? studentId;
  final String? token;

  const HomeScreen({super.key, this.studentName, this.studentId, this.token});

  Widget _buildCard(BuildContext context, IconData icon, String title, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: primaryRed),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String effectiveStudentId = studentId ?? "12345";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Campus AI"),
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(context, Icons.chat_bubble_outline, "Chatbot", const ChatbotScreen()),
            _buildCard(context, Icons.directions_bus_outlined, "Bus System", const BusScreen()),
            _buildCard(context, Icons.local_library_outlined, "Library", LibraryScreen(studentId: effectiveStudentId)),
            _buildCard(context, Icons.rule_outlined, "Rules", const RulesScreen()),
          ],
        ),
      ),
    );
  }
}
