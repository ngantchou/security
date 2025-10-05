// This is a basic Flutter widget test for Safety Alert App.

import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SafetyAlertApp());

    // Verify that the splash screen appears
    expect(find.text('Safety Alert'), findsOneWidget);
    expect(find.text('Community Safety Network'), findsOneWidget);
  });
}
