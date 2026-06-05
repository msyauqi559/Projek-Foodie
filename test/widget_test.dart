import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodie_1/main.dart';

void main() {
  testWidgets('Foodie splash screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodieApp());

    expect(find.byType(Image), findsOneWidget);

    // Selesaikan timer navigasi splash → auth agar tidak ada pending timer.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
