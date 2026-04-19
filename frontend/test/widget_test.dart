import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/login_screen.dart';

void main() {
  testWidgets('Login screen shows fields and button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Login'), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}