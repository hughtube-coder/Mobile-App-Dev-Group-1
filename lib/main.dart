import 'package:flutter/material.dart';

// Day 1 – App skeleton
// Widgets used: MaterialApp, Scaffold, AppBar, Column, Text, Placeholder

void main() {
  runApp(const MarketingVikingsApp());
}

/// Root widget: sets up the app name, theme and first screen.
class MarketingVikingsApp extends StatelessWidget {
  const MarketingVikingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketing Vikings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B1E1E), // dragon red
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// The main shop screen. For now it is mostly placeholders
/// that we will replace with real widgets in the next days.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SCAFFOLD: the basic page layout (app bar + body).
    return Scaffold(
      // APPBAR: top bar. Day 2 → replace text with an SVG logo + menu.
      appBar: AppBar(
        title: const Text(
          'Marketing Vikings',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),

      // BODY: scrollable so content never overflows on small phones.
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        // COLUMN: stacks the sections of the shop vertically.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TEXT: what the shop is and what it sells.
            Text(
              'Tabletop RPG Miniatures & Dice Swap',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'A marketplace for D&D and board game players. '
              'Buy and sell painted 3D-printed miniatures, custom dice sets, '
              'and digital maps & one-shot campaign PDFs.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            SizedBox(height: 24),

            // Section 1: Categories (Day 3: Minis / Dice / Digital Maps)
            SectionTitle('Categories'),
            Placeholder(
              fallbackHeight: 80,
              child: Center(child: Text('Day 3: Minis • Dice • Digital Maps')),
            ),
            SizedBox(height: 24),

            // Section 2: Featured products (Day 4: real product photos)
            SectionTitle('Featured Items'),
            Placeholder(
              fallbackHeight: 220,
              child: Center(child: Text('Day 4: Product grid with images')),
            ),
            SizedBox(height: 24),

            // Section 3: Potential design add-ons
            SectionTitle('Coming Soon'),
            Placeholder(
              fallbackHeight: 100,
              child: Center(child: Text('360° mini viewer • Cart • Checkout')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small reusable heading for each section.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
