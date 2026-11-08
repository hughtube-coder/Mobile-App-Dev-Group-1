import 'package:flutter/material.dart';

import '../controllers/cart_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_tavern_background.dart';
import '../widgets/app_bar_logo.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/design_addons_placeholder.dart';
import '../widgets/dice_roller_sheet.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/material_carousel_view.dart';
import '../widgets/product_card.dart';
import '../widgets/section_title.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'product_detail_screen.dart';

enum ProductSortOption {
  featured('Featured'),
  priceAsc('Price: Low to High'),
  priceDesc('Price: High to Low'),
  rating('Top Rated');

  const ProductSortOption(this.label);
  final String label;
}

/// Marketing Vikings: Tabletop RPG Miniatures & Dice Swap
/// Main Shop Screen featuring:
/// - AppBar with optimized SVG logo & cart badge
/// - Dynamic animated tavern background
/// - Live search and sorting filter
/// - Featured Hero Carousel
/// - Horizontal Category Chips (Minis, Dice, Digital Maps, LUTs)
/// - Responsive GridView of authentic non-AI product items (min ₱100)
/// - Interactive Valhalla D20 Dice Roller tool
/// - Placeholders for upcoming design add-ons
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProductCategory _selectedCategory = ProductCategory.all;
  String _searchQuery = '';
  ProductSortOption _sortOption = ProductSortOption.featured;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    List<Product> list = Product.catalog;

    // Filter by Category
    if (_selectedCategory != ProductCategory.all) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by Search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.shortDescription.toLowerCase().contains(q) ||
            p.category.label.toLowerCase().contains(q);
      }).toList();
    }

    // Sort
    switch (_sortOption) {
      case ProductSortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProductSortOption.featured:
        break;
    }

    return list;
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

  void _openDiceRoller() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const DiceRollerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

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
                setState(() {
                  _selectedCategory = ProductCategory.all;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
          ),
        ),
        title: const SizedBox.shrink(),
        actions: [
          // D20 Quick Dice Roller Action
          IconButton(
            icon: const Icon(Icons.casino, color: AppColors.gold),
            tooltip: 'Roll D20 🎲',
            onPressed: _openDiceRoller,
          ),

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

      // Navigation Drawer
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
            ListTile(
              leading: const Icon(Icons.tune, color: AppColors.gold),
              title: const Text(
                'LUTs & Presets (ColorFiltered)',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'Split-screen live filter tester',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                setState(() => _selectedCategory = ProductCategory.presets);
                Navigator.of(context).pop();
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.casino_outlined, color: AppColors.gold),
              title: const Text(
                'Valhalla D20 Dice Roller 🎲',
                style: TextStyle(color: AppColors.parchment),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _openDiceRoller();
              },
            ),
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
          ],
        ),
      ),

      // FloatingActionButton on Scaffold (Lecture Slide 18)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openDiceRoller,
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.dungeon,
        tooltip: 'Roll Valhalla D20 Polyhedral Dice 🎲',
        icon: const Icon(
          Icons.casino,
          color: AppColors.dungeon,
          semanticLabel: 'Roll Valhalla D20 Polyhedral Dice',
        ),
        label: const Text(
          'Roll D20',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: AppColors.dungeon,
          ),
        ),
      ),

      // Dynamic animated tavern background containing scrollable shop
      body: AnimatedTavernBackground(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
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
                    const SizedBox(height: 18),

                    // LIVE SEARCH & SORT BAR (100x improvement)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.stone.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.goldFaded),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.gold,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                color: AppColors.parchment,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Search painted minis, dice, maps, LUTs...',
                                hintStyle: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) {
                                setState(() => _searchQuery = val);
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.clear,
                                size: 18,
                                color: AppColors.mutedText,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                          PopupMenuButton<ProductSortOption>(
                            icon: const Icon(Icons.sort, color: AppColors.gold),
                            tooltip: 'Sort items',
                            color: AppColors.stone,
                            onSelected: (option) =>
                                setState(() => _sortOption = option),
                            itemBuilder: (context) =>
                                ProductSortOption.values.map((opt) {
                                  return PopupMenuItem(
                                    value: opt,
                                    child: Text(
                                      opt.label,
                                      style: TextStyle(
                                        color: opt == _sortOption
                                            ? AppColors.gold
                                            : AppColors.parchment,
                                        fontWeight: opt == _sortOption
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Featured Spotlight Carousel
                    const SectionTitle(
                      'Guild Spotlight & 360° Previews',
                      subtitle:
                          'Swipe horizontally to inspect featured treasures',
                    ),
                    HeroCarousel(onProductTap: _navigateToDetail),
                    const SizedBox(height: 24),

                    // Material 3 CarouselView (Lecture Slide 16)
                    const SectionTitle(
                      'Material 3 CarouselView • Featured Artifacts',
                      subtitle:
                          'Interactive card carousel built with Flutter Material 3 CarouselView',
                    ),
                    MaterialCarouselViewSection(onProductTap: _navigateToDetail),
                    const SizedBox(height: 24),

                    // Category Filter Chips
                    const SectionTitle(
                      'Categories',
                      subtitle: 'Filter miniatures, custom dice, digital maps, or presets',
                    ),
                    CategoryChipBar(
                      selectedCategory: _selectedCategory,
                      onSelect: (cat) =>
                          setState(() => _selectedCategory = cat),
                    ),
                    const SizedBox(height: 22),

                    // Product Catalog Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SectionTitle(
                          _selectedCategory.label,
                          subtitle:
                              '${filtered.length} Items • Minimum ₱100 • ${_sortOption.label}',
                        ),
                        if (_selectedCategory != ProductCategory.all ||
                            _searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedCategory = ProductCategory.all;
                              _searchQuery = '';
                              _searchController.clear();
                            }),
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: AppColors.gold),
                            ),
                          ),
                      ],
                    ),

                    // Responsive GridView of Product Cards
                    if (filtered.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: const Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: AppColors.mutedText,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No matching treasures found in this realm.',
                              style: TextStyle(color: AppColors.parchment),
                            ),
                          ],
                        ),
                      )
                    else
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
                      subtitle: 'Interactive roadmap features & simulators',
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
                  'PHILIPPINE TABLETOP GUILD',
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
                'Pesos (₱) • Non-AI',
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
            'A niche community exchange for D&D and board game adventurers in the Philippines. '
            'Buy and trade hand-painted 3D-printed miniatures with 360° inspection, '
            'custom polyhedral dice sets, digital campaign maps, and ColorFiltered LUT presets.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.parchmentFaded,
            ),
          ),
          const SizedBox(height: 12),

          // Layout Widgets: Row with Expanded & FittedBox (Lecture Slide 19 & 25)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.dungeon.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.goldFaded),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    '100% Non-AI Art',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.parchment,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Philippine Pesos (₱)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield,
                          color: AppColors.gold,
                          size: 14,
                          semanticLabel: 'Guild Guarantee',
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Guild Guarantee',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.parchment,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
            'All product photos are authentic physical miniatures and historic cartography from Wikimedia Commons. Denominated in Philippine Pesos (₱).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
