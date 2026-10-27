import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/coming_soon_box.dart';
import '../widgets/section_title.dart';

/// The main shop screen.
/// Day 1: layout skeleton – real features replace the placeholders later.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SCAFFOLD: the basic page layout (app bar + body).
    return Scaffold(
      // APPBAR: top bar with a temporary logo icon.
      // Day 2 → replace the icon with our SVG logo + navigation menu.
      appBar: AppBar(
        leading: const Icon(Icons.shield_outlined, color: AppColors.gold),
        title: const Text(
          'Marketing Vikings',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
      ),

      // BODY: scrollable so nothing overflows on small phones.
      body: SingleChildScrollView(
        child: Center(
          // Keeps the content phone-width even on a big browser window.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Padding(
              padding: EdgeInsets.all(16),
              // COLUMN: stacks every section from top to bottom.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeBanner(),
                  SizedBox(height: 28),

                  SectionTitle(
                    'Categories',
                    subtitle: 'Minis • Dice • Digital Maps',
                  ),
                  ComingSoonBox(day: 3, label: 'Category buttons', height: 90),
                  SizedBox(height: 28),

                  SectionTitle(
                    'Featured Items',
                    subtitle: 'Hand-painted & hand-picked',
                  ),
                  ComingSoonBox(
                    day: 4,
                    label: 'Product cards with real photos',
                    height: 220,
                  ),
                  SizedBox(height: 28),

                  // PLACEHOLDER: potential design add-ons.
                  SectionTitle(
                    'Coming Soon',
                    subtitle: 'Features in development',
                  ),
                  ComingSoonBox(day: 5, label: '360° miniature viewer'),
                  SizedBox(height: 12),
                  ComingSoonBox(day: 6, label: 'Cart & checkout'),
                  SizedBox(height: 36),

                  _Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Top banner: tells the user what the shop is and what it sells.
class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.dragonRed, AppColors.stone],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldFaded),
      ),
      // TEXT: shop name, tagline and description.
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WELCOME, ADVENTURER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.gold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tabletop RPG Miniatures & Dice Swap',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.parchment,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'A marketplace for D&D and board game players. Buy and sell '
            'painted 3D-printed miniatures, custom dice sets, and digital '
            'maps & one-shot campaign PDFs.',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.parchmentFaded,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small footer at the bottom of the page.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '© 2026 Marketing Vikings • Made with Flutter',
        style: TextStyle(fontSize: 12, color: AppColors.mutedText),
      ),
    );
  }
}
