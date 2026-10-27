import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketing_vikings/main.dart';

void main() {
  testWidgets('Home screen shows the shop name and sections', (tester) async {
    await tester.pumpWidget(const MarketingVikingsApp());

    // App bar title and banner text
    expect(find.text('Marketing Vikings'), findsOneWidget);
    expect(find.text('Tabletop RPG Miniatures & Dice Swap'), findsOneWidget);

    // Section titles
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Featured Items'), findsOneWidget);

    // 4 placeholders for future features
    expect(find.byType(Placeholder), findsNWidgets(4));
  });
}
