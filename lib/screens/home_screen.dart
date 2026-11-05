import 'package:flutter/material.dart';

import '../controllers/cart_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_tavern_background.dart';
import '../widgets/app_bar_logo.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/design_addons_placeholder.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/product_card.dart';
import '../widgets/section_title.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'product_detail_screen.dart';

/// Marketing Vikings: Tabletop RPG Miniatures & Dice Swap
/// Main Shop Screen featuring:
/// - AppBar with optimized SVG logo & cart badge
/// - Dynamic animated tavern background
/// - Featured Hero Carousel
/// - Horizontal Category Chips (Minis, Dice, Digital Maps)
/// - Responsive GridView of authentic non-AI product items (min £100)
/// - Placeholders for upcoming design add-ons (AR placer, dice roller)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProductCategory _selectedCategory = ProductCategory.all;

  List<Product> get _filteredProducts {
    if (_selectedCategory == ProductCategory.all) {
      return Product.catalog;
    }
    return Product.catalog
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  void _navigateToDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  void _quickBuy(Product product) {
    CartController.instance.addItem(
      product: product,
      color: product.colors.first,
      size: product.sizes.first,
      quantity: 1,
    );
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    // Scaffold with dynamic animated background
    return Scaffold(
      appBar: AppBar(
        // Optimized SVG Logo in AppBar
        leadingWidth: 180,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppBarLogo(
              onTap: () {
                setState(() => _selectedCategory = ProductCategory.all);
              },
            ),
          ),
        ),
        title: const SizedBox.shrink(),
        actions: [
          // Cart Action with Live Badge (Icon: 🛒)
          AnimatedBuilder(
            animation: CartController.instance,
            builder: (context, _) {
              final count = CartController.instance.totalItemCount;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.gold,
                      ),
                      tooltip: 'View Cart 🛒',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.dragonRed,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // Navigation Drawer with realm shortcuts and information
      drawer: Drawer(
        backgroundColor: AppColors.stone,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.dragonRed, AppColors.stone],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppBarLogo(
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() => _selectedCategory = ProductCategory.all);
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tabletop RPG Miniatures & Dice Swap',
                    style: TextStyle(
                      color: AppColors.parchment,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: AppColors.gold),
              title: const Text(
                'All Items',
                style: TextStyle(color: AppColors.parchment),
              ),
              onTap: () {
                setState(() => _selectedCategory = ProductCategory.all);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield, color: AppColors.gold),
              title: const Text(
                'Painted Miniatures',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'With 360° inspection scrubber',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                setState(() => _selectedCategory = ProductCategory.minis);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.casino, color: AppColors.gold),
              title: const Text(
                'Custom Dice Sets',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'Artisan resin & metal polyhedrals',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                setState(() => _selectedCategory = ProductCategory.dice);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: AppColors.gold),
              title: const Text(
                'Digital Maps & One-Shots',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'Instant download delivery',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                setState(() => _selectedCategory = ProductCategory.digitalMaps);
                Navigator.of(context).pop();
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: AppColors.gold),
              title: const Text(
                'Inventory Cache / Cart 🛒',
                style: TextStyle(color: AppColors.parchment),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
            const Divider(color: Colors.white12),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Mobile Application Development\nMarketing Vikings • Days 1-5 Milestone',
                style: TextStyle(color: AppColors.mutedText, fontSize: 11),
              ),
            ),
          ],
        ),
      ),

      // Dynamic animated tavern background containing scrollable shop
      body: AnimatedTavernBackground(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Banner
                    const _WelcomeBanner(),
                    const SizedBox(height: 20),

                    // Featured Spotlight Carousel (CarouselView / PageView)
                    const SectionTitle(
                      'Guild Spotlight & 360° Previews',
                      subtitle:
                          'Swipe horizontally to inspect featured treasures',
                    ),
                    HeroCarousel(onProductTap: _navigateToDetail),
                    const SizedBox(height: 24),

                    // Category Filter Chips (ListView horizontal)
                    const SectionTitle(
                      'Categories',
                      subtitle:
                          'Filter miniatures, custom dice, or digital maps',
                    ),
                    CategoryChipBar(
                      selectedCategory: _selectedCategory,
                      onSelect: (cat) =>
                          setState(() => _selectedCategory = cat),
                    ),
                    const SizedBox(height: 22),

                    // Product Catalog Section with Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SectionTitle(
                          _selectedCategory.label,
                          subtitle:
                              '${filtered.length} Authentic Items • Minimum £100',
                        ),
                        if (_selectedCategory != ProductCategory.all)
                          TextButton(
                            onPressed: () => setState(
                              () => _selectedCategory = ProductCategory.all,
                            ),
                            child: const Text(
                              'View All',
                              style: TextStyle(color: AppColors.gold),
                            ),
                          ),
                      ],
                    ),

                    // Scroll widget: Responsive GridView of Product Cards
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.58,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return ProductCard(
                          product: product,
                          onTap: () => _navigateToDetail(product),
                          onQuickBuy: () => _quickBuy(product),
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    // Potential Design Add-ons (Placeholder widget)
                    const SectionTitle(
                      'Future Design Add-ons',
                      subtitle: 'Roadmap features using Placeholder widgets',
                    ),
                    const DesignAddonsPlaceholder(),
                    const SizedBox(height: 36),

                    // Footer
                    const _Footer(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Top banner introducing the marketplace and D&D community focus
class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.dragonRed, AppColors.stone],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldFaded, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'AUTHENTIC TABLETOP MARKET',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: AppColors.dungeon,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.verified, color: Colors.greenAccent, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Non-AI Certified',
                style: TextStyle(color: Colors.greenAccent, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Tabletop RPG Miniatures & Dice Swap',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.parchment,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'A niche community exchange for D&D and board game adventurers. '
            'Buy and trade hand-painted 3D-printed miniatures with 360° inspection, '
            'custom polyhedral dice sets, and digital campaign map PDFs with instant unlock.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.parchmentFaded,
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer with copyright and student attribution
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_moon, color: AppColors.gold, size: 16),
              SizedBox(width: 6),
              Text(
                'Marketing Vikings • Mobile Application Development',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.parchment,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'All product photos are authentic physical miniatures and historic cartography from Wikimedia Commons.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
