import 'package:flutter/material.dart';

import 'features/student/student_dashboard.dart';

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
    return StudentDashboard(
      user: {
        'student_id': studentId,
        'name': name,
        'token': token,
        'role': 'student',
      },
    );
  }
}
