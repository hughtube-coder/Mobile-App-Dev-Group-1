import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketing_vikings/controllers/auth_controller.dart';
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
    'Marketing Vikings Dual E-Commerce Home Screen renders key components with Pesos (₱)',
    (tester) async {
      await tester.pumpWidget(const MarketingVikingsApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verify Dual E-Commerce Headline and Store Switcher chips
      expect(
        find.text('Dual E-Commerce: LUT & Pattern Market + RPG Swap'),
        findsOneWidget,
      );
      expect(find.text('Digital Pattern & LUT Market'), findsOneWidget);
      expect(find.text('Tabletop RPG & Dice Swap'), findsOneWidget);

      // Verify Categories chip section
      expect(find.text('Dual Market Categories'), findsOneWidget);
      expect(find.text('Lightroom LUTs'), findsWidgets);

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

      // Verify StoreType category filtering matches exact Dual E-Commerce specs
      expect(
        ProductCategory.forStore(StoreType.digitalCreator),
        equals([
          ProductCategory.all,
          ProductCategory.presets,
          ProductCategory.sewingPatterns,
          ProductCategory.stlFiles,
        ]),
      );
      expect(
        ProductCategory.forStore(StoreType.tabletopRpg),
        equals([
          ProductCategory.all,
          ProductCategory.minis,
          ProductCategory.dice,
          ProductCategory.digitalMaps,
        ]),
      );
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

  testWidgets(
    'Scaffold FloatingActionButton and Material 3 CarouselView render correctly',
    (tester) async {
      await tester.pumpWidget(const MarketingVikingsApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verify FloatingActionButton (Slide 18)
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Roll D20'), findsOneWidget);

      // Verify CarouselView (Slide 16)
      expect(find.byType(CarouselView), findsOneWidget);
    },
  );

  test(
    'AuthController enforces strict password rules, Sign Up, Sign Out, Sign In, and Email OTP Reset',
    () {
      final auth = AuthController.instance;

      // Weak password should fail strict validation
      expect(AuthController.validateStrictPassword('weak'), isNotNull);
      expect(AuthController.validateStrictPassword('Strong@2026'), isNull);

      // Sign up a new user
      final signUpRes = auth.signUp(
        fullName: 'Freya Tester',
        email: 'freya@vikings.ph',
        password: 'Freya@2026',
        role: 'Digital Creator & Seller',
      );
      expect(signUpRes.success, isTrue);
      expect(signUpRes.emailAlert, isNotNull);
      expect(auth.currentUser?.email, 'freya@vikings.ph');

      // Sign Out
      auth.signOut();
      expect(auth.isSignedIn, isFalse);

      // Email Password Reset OTP flow
      final resetReq = auth.sendPasswordResetEmail('freya@vikings.ph');
      expect(resetReq.success, isTrue);
      expect(resetReq.otpCode, isNotNull);
      expect(resetReq.otpCode!.length, 6);

      final resetConfirm = auth.resetPasswordWithOtp(
        email: 'freya@vikings.ph',
        otpCode: resetReq.otpCode!,
        newPassword: 'NewViking#99',
      );
      expect(resetConfirm.success, isTrue);
      expect(auth.isSignedIn, isTrue);
    },
  );
}
