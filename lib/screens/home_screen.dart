import 'dart:async';
import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/dice_quest_controller.dart';
import '../controllers/vault_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_tavern_background.dart';
import '../widgets/app_bar_logo.dart';
import '../widgets/auth_guard.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/creator_listing_modal.dart';
import '../widgets/design_addons_placeholder.dart';
import '../widgets/dice_roller_sheet.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/material_carousel_view.dart';
import '../widgets/product_card.dart';
import '../widgets/section_title.dart';
import 'auth_screen.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import 'product_detail_screen.dart';
import 'vault_screen.dart';

enum ProductSortOption {
  featured('Featured'),
  priceAsc('Price: Low to High'),
  priceDesc('Price: High to Low'),
  rating('Top Rated');

  const ProductSortOption(this.label);
  final String label;
}

/// Marketing Vikings: Dual E-Commerce Type Marketplace
/// 1) Digital Pattern & LUT Tester Market (Lightroom LUTs, Sewing Patterns, 3D Print .STL files)
///    - Pure digital delivery — unlocks instant download links upon payment.
///    - Dart/Flutter Edge: ColorFiltered widget + split-screen slider to preview filters on phone photos.
/// 2) Tabletop RPG Miniatures & Dice Swap (3 Categories: Minis, Dice, Digital Maps)
///    - Dart/Flutter Edge: Built-in 360-degree image scrubber (8-photo horizontal sequence).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StoreType _selectedStore = StoreType.all;
  ProductCategory _selectedCategory = ProductCategory.all;
  String _searchQuery = '';
  ProductSortOption _sortOption = ProductSortOption.featured;
  bool _showFavoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;
  bool _isScrolled = false;
  Timer? _browseTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final scrolled = _scrollController.hasClients && _scrollController.offset > 15;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });

    // 10-second catalog browse timer for Guild Tavern Quests
    _browseTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        DiceQuestController.instance.recordBrowseTick();
      }
    });
  }

  @override
  void dispose() {
    _browseTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectStore(StoreType store) {
    setState(() {
      _selectedStore = store;
      final validCategories = ProductCategory.forStore(store);
      if (!validCategories.contains(_selectedCategory)) {
        _selectedCategory = ProductCategory.all;
      }
    });
  }

  List<Product> get _filteredProducts {
    List<Product> list = VaultController.instance.fullCatalog;

    // Filter by Dual E-Commerce Store Type
    if (_selectedStore != StoreType.all) {
      list = list.where((p) => p.category.storeType == _selectedStore).toList();
    }

    // Filter by Category
    if (_selectedCategory != ProductCategory.all) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by Favorites
    if (_showFavoritesOnly) {
      list = list
          .where((p) => WishlistController.instance.isFavorite(p.id))
          .toList();
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
        list = List<Product>.from(list)
          ..sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        list = List<Product>.from(list)
          ..sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.rating:
        list = List<Product>.from(list)
          ..sort((a, b) => b.rating.compareTo(a.rating));
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
    AuthGuard.protect(
      context,
      actionName: 'buy this item',
      onAuthenticated: () {
        CartController.instance.addItem(
          product: product,
          color: product.colors.first,
          size: product.sizes.first,
          quantity: 1,
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
        );
      },
    );
  }

  void _openDiceRoller() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const DiceRollerSheet(),
    );
  }

  void _openCreatorListingModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const CreatorListingModal(),
    );
  }

  void _openQuickLutStudio() {
    final lutProduct = Product.catalog.firstWhere(
      (p) => p.hasLutPreview,
      orElse: () => Product.catalog.first,
    );
    _navigateToDetail(lutProduct);
  }

  void _openQuick360Inspector() {
    final miniProduct = Product.catalog.firstWhere(
      (p) => p.has360View,
      orElse: () => Product.catalog.first,
    );
    _navigateToDetail(miniProduct);
  }

  void _openAuthScreen({int initialTab = 0}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AuthScreen(initialTab: initialTab)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeCategories = ProductCategory.forStore(_selectedStore);

    return Scaffold(
      appBar: AppBar(
        elevation: _isScrolled ? 5.0 : 0.0,
        shadowColor: AppColors.gold.withValues(alpha: 0.35),
        bottom: _isScrolled
            ? PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  height: 1.0,
                ),
              )
            : null,
        // Optimized SVG Logo in AppBar
        leadingWidth: 155,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppBarLogo(
              onTap: () {
                setState(() {
                  _selectedStore = StoreType.all;
                  _selectedCategory = ProductCategory.all;
                  _showFavoritesOnly = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
          ),
        ),
        title: const SizedBox.shrink(),
        actions: [
          // Sell / Swap Creator Listing Studio Button
          IconButton(
            icon: const Icon(
              Icons.add_business_outlined,
              color: AppColors.gold,
              semanticLabel: 'Sell or swap item in marketplace',
            ),
            tooltip: 'Sell / Swap Item +',
            onPressed: _openCreatorListingModal,
          ),

          // Unlocked Downloads Vault Action with Badge
          AnimatedBuilder(
            animation: VaultController.instance,
            builder: (context, _) {
              final unlocked = VaultController.instance.unlockedCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.cloud_download_outlined,
                      color: AppColors.gold,
                      semanticLabel: 'Open unlocked downloads vault',
                    ),
                    tooltip: 'Unlocked Downloads Vault 🔓',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VaultScreen()),
                      );
                    },
                  ),
                  if (unlocked > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unlocked',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // D20 Quick Dice Roller Action with Live Roll Stamina & Quest Badge
          AnimatedBuilder(
            animation: DiceQuestController.instance,
            builder: (context, _) {
              final rolls = DiceQuestController.instance.availableRolls;
              final claimable = DiceQuestController.instance.claimableCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.casino, color: AppColors.gold),
                    tooltip: 'Tavern Dice & Quests 🎲 ($rolls rolls available)',
                    onPressed: _openDiceRoller,
                  ),
                  if (claimable > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$claimable',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (rolls == 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          color: AppColors.dragonRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: const Text(
                          '0',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
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

          // Account / Profile Action Button (Head icon placed after Cart 🛒)
          AnimatedBuilder(
            animation: AuthController.instance,
            builder: (context, _) {
              final user = AuthController.instance.currentUser;
              final isSignedIn = user != null;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: IconButton(
                  icon: isSignedIn
                      ? Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.greenAccent, width: 1.5),
                            color: AppColors.stone,
                          ),
                          child: Center(
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.account_circle_outlined,
                          color: AppColors.gold,
                          size: 26,
                        ),
                  tooltip: isSignedIn
                      ? 'Account (${user.fullName}) • Tap to Manage'
                      : 'Log In / Sign Up',
                  onPressed: () => _openAuthScreen(initialTab: 0),
                ),
              );
            },
          ),
        ],
      ),

      // Navigation Drawer showcasing Dual E-Commerce Type stores & categories
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
                      setState(() {
                        _selectedStore = StoreType.all;
                        _selectedCategory = ProductCategory.all;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Dual E-Commerce Marketplace',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Text(
                    '1) Digital Pattern & LUT Market\n2) Tabletop RPG Minis & Dice Swap',
                    style: TextStyle(
                      color: AppColors.parchment,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.storefront, color: AppColors.gold),
              title: const Text(
                'Dual Catalog (All Stores)',
                style: TextStyle(
                  color: AppColors.parchment,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedStore = StoreType.all;
                  _selectedCategory = ProductCategory.all;
                });
                Navigator.of(context).pop();
              },
            ),
            const Divider(color: Colors.white12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'STORE 1: DIGITAL PATTERN & LUT MARKET',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.gold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.tune, color: AppColors.gold),
              title: const Text(
                'Lightroom LUTs (ColorFiltered)',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'Split-screen slider on phone photos',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                setState(() {
                  _selectedStore = StoreType.digitalCreator;
                  _selectedCategory = ProductCategory.presets;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_cut, color: AppColors.gold),
              title: const Text(
                'Sewing Patterns (.PDF / .DXF)',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'Pure digital delivery • Instant unlock',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                setState(() {
                  _selectedStore = StoreType.digitalCreator;
                  _selectedCategory = ProductCategory.sewingPatterns;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_in_ar, color: AppColors.gold),
              title: const Text(
                '3D Print .STL Files',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'Pre-supported .STL meshes',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                setState(() {
                  _selectedStore = StoreType.digitalCreator;
                  _selectedCategory = ProductCategory.stlFiles;
                });
                Navigator.of(context).pop();
              },
            ),
            const Divider(color: Colors.white12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'STORE 2: TABLETOP RPG & DICE SWAP (3 CATEGORIES)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.gold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shield, color: AppColors.gold),
              title: const Text(
                'Minis (Painted 3D-Printed)',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'Built-in 360° 8-photo image scrubber',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                setState(() {
                  _selectedStore = StoreType.tabletopRpg;
                  _selectedCategory = ProductCategory.minis;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.casino, color: AppColors.gold),
              title: const Text(
                'Dice (Custom Polyhedral Sets)',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'Artisan resin & metal D&D sets',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                setState(() {
                  _selectedStore = StoreType.tabletopRpg;
                  _selectedCategory = ProductCategory.dice;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: AppColors.gold),
              title: const Text(
                'Digital Maps & One-Shot PDFs',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'Instant VTT & campaign PDF unlock',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                setState(() {
                  _selectedStore = StoreType.tabletopRpg;
                  _selectedCategory = ProductCategory.digitalMaps;
                });
                Navigator.of(context).pop();
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(
                Icons.cloud_download,
                color: Colors.greenAccent,
              ),
              title: const Text(
                'Unlocked Downloads Vault 🔓',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Access purchased .DNG, .PDF, .STL & .ZIP links',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const VaultScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_business, color: AppColors.gold),
              title: const Text(
                'Sell / Swap Creator Item +',
                style: TextStyle(color: AppColors.parchment),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _openCreatorListingModal();
              },
            ),
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
            const Divider(color: Colors.white12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'ACCOUNT & SECURITY VAULT 🔐',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.gold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.login, color: AppColors.gold),
              title: const Text(
                'Sign In / Log In',
                style: TextStyle(color: AppColors.parchment),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _openAuthScreen(initialTab: 0);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person_add_alt_1,
                color: Colors.greenAccent,
              ),
              title: const Text(
                'Create New Account (Sign Up)',
                style: TextStyle(color: AppColors.parchment),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _openAuthScreen(initialTab: 1);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.gold,
              ),
              title: const Text(
                'Email Password Reset (OTP)',
                style: TextStyle(color: AppColors.parchment),
              ),
              subtitle: const Text(
                'Send 6-digit reset code to email',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _openAuthScreen(initialTab: 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Log Out / Sign Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                AuthController.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Signed out of account. Tap Sign In anytime to log back in.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // FloatingActionButton on Scaffold (Lecture Slide 18)
      floatingActionButton: AnimatedBuilder(
        animation: DiceQuestController.instance,
        builder: (context, _) {
          final rolls = DiceQuestController.instance.availableRolls;
          final claimable = DiceQuestController.instance.claimableCount;
          final hasRolls = rolls > 0;
          return FloatingActionButton.extended(
            onPressed: _openDiceRoller,
            backgroundColor: hasRolls ? AppColors.gold : Colors.amber.shade700,
            foregroundColor: AppColors.dungeon,
            tooltip: hasRolls
                ? 'Roll Valhalla D20 Polyhedral Dice 🎲 ($rolls rolls remaining)'
                : 'Out of Rolls! Complete Quests to Earn 📜',
            icon: Icon(
              hasRolls ? Icons.casino : Icons.assignment_turned_in,
              color: AppColors.dungeon,
              semanticLabel: 'Roll Valhalla D20 Polyhedral Dice',
            ),
            label: Text(
              hasRolls
                  ? 'Roll D20 ($rolls)'
                  : (claimable > 0 ? 'Claim Rolls (!$claimable)' : 'Get Rolls 📜'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.dungeon,
              ),
            ),
          );
        },
      ),

      // Dynamic animated tavern background containing scrollable shop
      body: AnimatedTavernBackground(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            VaultController.instance,
            WishlistController.instance,
            AuthController.instance,
          ]),
          builder: (context, _) {
            final filtered = _filteredProducts;
            final isSearchingOrFiltering =
                _searchQuery.trim().isNotEmpty || _showFavoritesOnly;
            final isFiltering = _selectedStore != StoreType.all ||
                _selectedCategory != ProductCategory.all ||
                isSearchingOrFiltering;

            return SingleChildScrollView(
              controller: _scrollController,
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
                        // LIVE SEARCH & SORT BAR (Placed directly at top with floating AppBar above)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.stone.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSearchingOrFiltering
                                  ? AppColors.gold
                                  : AppColors.goldFaded,
                              width: isSearchingOrFiltering ? 1.8 : 1.0,
                            ),
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
                                        'Search LUTs, patterns, .stl, minis, dice, maps...',
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
                                    color: AppColors.gold,
                                  ),
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                ),
                              PopupMenuButton<ProductSortOption>(
                                icon: const Icon(
                                  Icons.sort,
                                  color: AppColors.gold,
                                ),
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
                        const SizedBox(height: 12),

                        // DUAL E-COMMERCE MODE SWITCHER
                        _DualStoreSwitcher(
                          selectedStore: _selectedStore,
                          onSelectStore: _selectStore,
                        ),
                        const SizedBox(height: 10),

                        // QUICK INTERACTIVE STUDIO LAB LAUNCHER BAR
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ActionChip(
                                avatar: const Icon(
                                  Icons.tune,
                                  size: 15,
                                  color: AppColors.gold,
                                ),
                                label: const Text(
                                  'Test LUT Split-Slider',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.parchment,
                                  ),
                                ),
                                backgroundColor: AppColors.stone,
                                side: const BorderSide(
                                  color: AppColors.goldFaded,
                                ),
                                onPressed: _openQuickLutStudio,
                              ),
                              const SizedBox(width: 8),
                              ActionChip(
                                avatar: const Icon(
                                  Icons.threed_rotation,
                                  size: 15,
                                  color: AppColors.gold,
                                ),
                                label: const Text(
                                  'Test 360° Mini Scrubber',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.parchment,
                                  ),
                                ),
                                backgroundColor: AppColors.stone,
                                side: const BorderSide(
                                  color: AppColors.goldFaded,
                                ),
                                onPressed: _openQuick360Inspector,
                              ),
                              const SizedBox(width: 8),
                              ActionChip(
                                avatar: const Icon(
                                  Icons.add_business,
                                  size: 15,
                                  color: AppColors.gold,
                                ),
                                label: const Text(
                                  '+ Sell / Swap Item',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.parchment,
                                  ),
                                ),
                                backgroundColor: AppColors.stone,
                                side: const BorderSide(
                                  color: AppColors.goldFaded,
                                ),
                                onPressed: _openCreatorListingModal,
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                avatar: Icon(
                                  Icons.favorite,
                                  size: 14,
                                  color: _showFavoritesOnly
                                      ? AppColors.dungeon
                                      : Colors.redAccent,
                                ),
                                label: Text(
                                  'Saved (${WishlistController.instance.count})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _showFavoritesOnly
                                        ? AppColors.dungeon
                                        : AppColors.parchment,
                                  ),
                                ),
                                selected: _showFavoritesOnly,
                                selectedColor: AppColors.gold,
                                backgroundColor: AppColors.stone,
                                side: const BorderSide(
                                  color: AppColors.goldFaded,
                                ),
                                onSelected: (val) =>
                                    setState(() => _showFavoritesOnly = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Instant Focus Mode: When searching, filtering by Saved, or selecting a specific Store Mode or Category,
                        // Guild Spotlight & Material 3 CarouselView are collapsed so matching products appear right away!
                        if (!isFiltering) ...[
                          // Featured Spotlight Carousel
                          const SectionTitle(
                            'Guild Spotlight: 360° Scrubber & LUT Tester',
                            subtitle:
                                'Tap any item to test the 360° 8-photo scrubber or ColorFiltered LUT split-screen slider',
                          ),
                          HeroCarousel(onProductTap: _navigateToDetail),
                          const SizedBox(height: 22),

                          // Material 3 CarouselView (Lecture Slide 16)
                          const SectionTitle(
                            'Material 3 CarouselView • Featured Artifacts',
                            subtitle:
                                'Interactive card carousel built with Flutter Material 3 CarouselView',
                          ),
                          MaterialCarouselViewSection(
                            onProductTap: _navigateToDetail,
                          ),
                          const SizedBox(height: 22),
                        ] else ...[
                          // Active Filter / Search Banner (Confirms carousels are collapsed for direct product view)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gold),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.manage_search,
                                  color: AppColors.gold,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _searchQuery.trim().isNotEmpty
                                        ? 'Search: Found ${filtered.length} matching item(s) for "${_searchQuery.trim()}"'
                                        : _showFavoritesOnly
                                        ? 'Showing ${filtered.length} Saved Favorite item(s)'
                                        : '${_selectedStore.label} • ${filtered.length} items',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.parchment,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _selectedStore = StoreType.all;
                                      _selectedCategory = ProductCategory.all;
                                      _searchQuery = '';
                                      _showFavoritesOnly = false;
                                    });
                                  },
                                  child: const Text(
                                    'Show All',
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Category Filter Chips (adapts to selected StoreType!)
                        SectionTitle(
                          _selectedStore == StoreType.tabletopRpg
                              ? 'Tabletop RPG Categories (Minis, Dice, Digital Maps)'
                              : _selectedStore == StoreType.digitalCreator
                              ? 'Digital Creator Categories (LUTs, Patterns, .STL)'
                              : 'Dual Market Categories',
                          subtitle: _selectedStore.subtitle,
                        ),
                        CategoryChipBar(
                          categories: storeCategories,
                          selectedCategory: _selectedCategory,
                          onSelect: (cat) =>
                              setState(() => _selectedCategory = cat),
                        ),
                        const SizedBox(height: 22),

                        // Product Catalog Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SectionTitle(
                                _selectedCategory.label,
                                subtitle:
                                    '${filtered.length} Items • Minimum ₱100 • ${_sortOption.label}',
                              ),
                            ),
                            if (_selectedStore != StoreType.all ||
                                _selectedCategory != ProductCategory.all ||
                                _showFavoritesOnly ||
                                _searchQuery.isNotEmpty)
                              TextButton(
                                onPressed: () => setState(() {
                                  _selectedStore = StoreType.all;
                                  _selectedCategory = ProductCategory.all;
                                  _showFavoritesOnly = false;
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

                        // Welcome Banner with Dual E-Commerce Type Header (Moved to bottom per user request)
                        _WelcomeBanner(selectedStore: _selectedStore),
                        const SizedBox(height: 28),

                        // Footer
                        const _Footer(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


/// Interactive Switcher Bar for the Dual E-Commerce Type architecture
class _DualStoreSwitcher extends StatelessWidget {
  final StoreType selectedStore;
  final ValueChanged<StoreType> onSelectStore;

  const _DualStoreSwitcher({
    required this.selectedStore,
    required this.onSelectStore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.stone.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldFaded, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.layers, color: AppColors.gold, size: 16),
              SizedBox(width: 6),
              Text(
                'SELECT E-COMMERCE MARKETPLACE MODE:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: StoreType.values.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final store = StoreType.values[index];
                final isSelected = store == selectedStore;
                return ChoiceChip(
                  avatar: Icon(
                    store.icon,
                    size: 16,
                    color: isSelected ? AppColors.dungeon : AppColors.gold,
                  ),
                  label: Text(store.label),
                  selected: isSelected,
                  onSelected: (_) => onSelectStore(store),
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.dungeon,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    color: isSelected ? AppColors.dungeon : AppColors.parchment,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.gold : AppColors.goldFaded,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Top banner introducing the Dual E-Commerce Type marketplace
class _WelcomeBanner extends StatelessWidget {
  final StoreType selectedStore;

  const _WelcomeBanner({required this.selectedStore});

  @override
  Widget build(BuildContext context) {
    final String headline;
    final String description;

    switch (selectedStore) {
      case StoreType.digitalCreator:
        headline = 'Digital Pattern & LUT Tester Market';
        description =
            'A micro-store for digital creators selling Lightroom presets (LUTs), '
            'sewing patterns, and 3D print .stl files. Pure digital delivery—once paid, '
            'the app unlocks instant download links. Includes a ColorFiltered split-screen '
            'slider to preview filters on phone photos.';
        break;
      case StoreType.tabletopRpg:
        headline = 'Tabletop RPG Miniatures & Dice Swap';
        description =
            'A niche marketplace for D&D and board game players to buy/sell painted '
            '3D-printed miniatures, custom dice sets, and one-shot campaign PDFs across '
            'three dedicated categories: Minis, Dice, and Digital Maps—complete with a '
            'built-in 360° 8-photo image scrubber.';
        break;
      case StoreType.all:
        headline = 'Dual E-Commerce: LUT & Pattern Market + RPG Swap';
        description =
            'Combining (1) Digital Pattern & LUT Tester Market (Lightroom LUTs with '
            'ColorFiltered split-screen preview, Sewing Patterns, 3D Print .STL files, '
            'and instant download unlocks) with (2) Tabletop RPG Miniatures & Dice Swap '
            '(Minis with 8-photo 360° scrubber, Custom Dice, and Digital Maps).';
        break;
    }

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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'DUAL E-COMMERCE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.dungeon,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.greenAccent, size: 12),
                    SizedBox(width: 4),
                    Text(
                      '₱ Pesos • Instant',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            headline,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppColors.parchment,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
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
                'Marketing Vikings • Dual E-Commerce Mobile App',
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
            'Digital Pattern & LUT Tester Market + Tabletop RPG Miniatures & Dice Swap. Denominated in Philippine Pesos (₱).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
