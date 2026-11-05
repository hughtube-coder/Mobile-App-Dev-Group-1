import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketing_vikings/main.dart';
import 'package:marketing_vikings/models/product.dart';
import 'package:marketing_vikings/utils/currency_formatter.dart';
import 'package:marketing_vikings/widgets/quantity_stepper.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets(
    'Marketing Vikings Home Screen renders key components with Pesos (₱)',
    (tester) async {
      await tester.pumpWidget(const MarketingVikingsApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verify Title and Subtitle
      expect(find.text('Tabletop RPG Miniatures & Dice Swap'), findsOneWidget);

      // Verify Categories chip section
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Painted Minis'), findsOneWidget);
      expect(find.text('Custom Dice'), findsOneWidget);
      expect(find.text('Digital Maps'), findsOneWidget);

      // Verify Placeholder design add-ons section
      expect(find.byType(Placeholder), findsWidgets);

      // Verify all prices in the catalog comply with the ₱100 minimum requirement
      for (final product in Product.catalog) {
        expect(
          product.price >= 100.0,
          isTrue,
          reason: 'Product ${product.name} must have a minimum price of ₱100',
        );
      }
    },
  );

  test(
    'CurrencyFormatter accurately outputs Philippine Peso sign (₱) with commas',
    () {
      expect(CurrencyFormatter.format(100), '₱100');
      expect(CurrencyFormatter.format(1250), '₱1,250');
      expect(CurrencyFormatter.format(24500), '₱24,500');
      expect(CurrencyFormatter.format(150.50, showDecimals: true), '₱150.50');
    },
  );

  testWidgets(
    'QuantityStepper strictly prevents negative and zero quantities',
    (tester) async {
      int currentQuantity = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return QuantityStepper(
                  quantity: currentQuantity,
                  onChanged: (newQty) {
                    setState(() => currentQuantity = newQty);
                  },
                );
              },
            ),
          ),
        ),
      );

      // At quantity 1, minus button should be disabled
      final minusFinder = find.byIcon(Icons.remove);
      expect(minusFinder, findsOneWidget);

      // Tap minus: quantity must remain 1 (no negative / zero quantity)
      await tester.tap(minusFinder);
      await tester.pump();
      expect(currentQuantity, 1);
      expect(find.text('1'), findsOneWidget);

      // Tap plus: quantity increments to 2
      final plusFinder = find.byIcon(Icons.add);
      await tester.tap(plusFinder);
      await tester.pump();
      expect(currentQuantity, 2);
      expect(find.text('2'), findsOneWidget);
    },
  );
}
