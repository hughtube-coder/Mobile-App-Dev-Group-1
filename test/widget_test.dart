import 'package:flutter_test/flutter_test.dart';
import 'package:marketing_vikings/main.dart';

void main() {
  testWidgets('Home screen shows the shop name', (tester) async {
    await tester.pumpWidget(const MarketingVikingsApp());
    expect(find.text('Marketing Vikings'), findsOneWidget);
    expect(find.text('Tabletop RPG Miniatures & Dice Swap'), findsOneWidget);
  });
}
