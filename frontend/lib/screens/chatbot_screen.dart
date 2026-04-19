import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  final String studentId;
  const ChatbotScreen({super.key, required this.studentId});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _msgController = TextEditingController();
  String reply = '';

  Future<void> _sendMessage() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/chat/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': _msgController.text,
        'student_id': widget.studentId,
        'session_id': widget.studentId,
      }),
    );
    if (response.statusCode == 200) {
      setState(() => reply = jsonDecode(response.body)['reply']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot')),
      body: Column(
        children: [
          TextField(controller: _msgController),
          ElevatedButton(onPressed: _sendMessage, child: const Text('Send')),
          Text(reply),
        ],
      ),
    );
  }
}
