import 'package:flutter_test/flutter_test.dart';
import 'package:techsisters/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Bottom navigation switches between tabs', (tester) async {
    await tester.pumpWidget(const TechSistersApp());
    SharedPreferences.setMockInitialValues({});
    // Home tab is open first
    expect(find.text('Home'), findsWidgets);

    // Tap the Learn tab
    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();

    // The Learn page is now shown
    expect(find.text('Learn'), findsWidgets);
  });
}
