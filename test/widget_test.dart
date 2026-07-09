import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// This imports your specific splash screen file
import 'package:flutter_application_1/feature/splash_screen/splash_screen.dart';

void main() {
  testWidgets('Splash screen loads successfully', (WidgetTester tester) async {
    // Build our app using the same structure as your main.dart file
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Verify that the SplashScreen widget is found on the screen
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}