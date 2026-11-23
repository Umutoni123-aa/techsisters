import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techsisters/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final sizes = {
    'small phone': const Size(320, 568),
    'large phone': const Size(430, 932),
    'landscape': const Size(932, 430),
  };

  sizes.forEach((name, size) {
    testWidgets('No overflow on $name', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const TechSistersApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull); // Home tab

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull); // Profile tab
    });
  });
}
