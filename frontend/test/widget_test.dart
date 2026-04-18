import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp()); // ✅ استخدم MyApp بدل SmartCampusApp
    expect(find.text('Smart Campus AI'), findsOneWidget);
  });
}
