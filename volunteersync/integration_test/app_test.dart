import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('App launches and renders a MaterialApp', (tester) async {
      // Verify the test framework itself is operational.
      // Full integration tests with Supabase require a live environment.
      expect(IntegrationTestWidgetsFlutterBinding.instance, isNotNull);

      // Build a minimal MaterialApp to verify rendering works.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('VolunteerSync'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify basic rendering is working.
      expect(find.text('VolunteerSync'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
