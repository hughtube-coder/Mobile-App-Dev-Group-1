import 'package:flutter/material.dart';

import '../controllers/cart_controller.dart';
import '../controllers/dice_quest_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/auth_guard.dart';
import '../widgets/lut_split_preview.dart';
import '../widgets/product_photo.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/three_sixty_viewer.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

/// Comprehensive product detail screen featuring:
/// - 360° 8-photo image scrubber + 3x Loupe Zoom for miniatures
/// - Interactive ColorFiltered LUT split-screen preview on phone photos for presets
/// - Interactive VTT Grid Overlay for Digital Maps
/// - Interactive Tailor Yardage Calculator for Sewing Patterns & Slicer Estimator for .STL files
/// - Color and size selectors, strictly positive quantity delimiter (quantity >= 1),
///   and Add to Cart 🛒 / Buy Now 💰 actions with Philippine Pesos (₱).
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductColorOption _selectedColor;
  late String _selectedSize;
  int _quantity = 1;

  // Interactive category tools state
  bool _showVttGridOverlay = true;
  String _printerMode = 'SLA Resin (0.03mm)';
  String _fabricBoltWidth = '60" Wide Bolt';

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.product.colors.first;
    _selectedSize = widget.product.sizes.first;
    DiceQuestController.instance.recordProductView(widget.product.id);
  }

  void _addToCart() {
    AuthGuard.protect(
      context,
      actionName: 'add this item to your cart',
      onAuthenticated: () {
        CartController.instance.addItem(
          product: widget.product,
          color: _selectedColor,
          size: _selectedSize,
          quantity: _quantity,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.stone,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.shopping_cart, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Added $_quantity x ${widget.product.name} to Cart 🛒',
                    style: const TextStyle(color: AppColors.parchment),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: AppColors.gold,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _buyNow() {
    AuthGuard.protect(
      context,
      actionName: 'proceed to buy this item',
      onAuthenticated: () {
        CartController.instance.addItem(
          product: widget.product,
          color: _selectedColor,
          size: _selectedSize,
          quantity: _quantity,
        );

        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final totalPrice = p.price * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          p.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Wishlist Heart Toggle
          AnimatedBuilder(
            animation: WishlistController.instance,
            builder: (context, _) {
              final isFav = WishlistController.instance.isFavorite(p.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : AppColors.gold,
                  semanticLabel: 'Toggle favorite item',
                ),
                tooltip: 'Bookmark Item',
                onPressed: () =>
                    WishlistController.instance.toggleFavorite(p.id),
              );
            },
          ),
          // Animated Cart Action with Badge
          AnimatedBuilder(
            animation: CartController.instance,
            builder: (context, _) {
              final count = CartController.instance.totalItemCount;
              return Stack(
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
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.dragonRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
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
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual Component:
              // 1) 360° 8-Photo Scrubber (for miniatures)
              // 2) ColorFiltered Split-Screen Preview on Phone Photos (for presets/LUTs)
              // 3) Interactive Viewer with optional VTT Grid Overlay (for maps, patterns, .stl, dice)
              if (p.has360View)
                ThreeSixtyViewer(images: p.galleryImages, heroTag: p.id)
              else if (p.hasLutPreview)
                LutSplitPreview(imageUrl: p.primaryImage)
              else
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppColors.stone,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.goldFaded, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 3.0,
                        child: ProductPhoto(
                          imageSource: p.primaryImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (p.category == ProductCategory.digitalMaps &&
                          _showVttGridOverlay)
                        IgnorePointer(
                          child: CustomPaint(
                            painter: _VttTacticalGridPainter(),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.file_download,
                                size: 14,
                                color: AppColors.dungeon,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'INSTANT UNLOCK: ${p.downloadFileName}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dungeon,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (p.category == ProductCategory.digitalMaps)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: ElevatedButton.icon(
                            onPressed: () => setState(
                              () => _showVttGridOverlay = !_showVttGridOverlay,
                            ),
                            icon: Icon(
                              _showVttGridOverlay
                                  ? Icons.grid_on
                                  : Icons.grid_off,
                              size: 15,
                            ),
                            label: Text(
                              _showVttGridOverlay
                                  ? '5ft VTT Grid: ON'
                                  : 'Gridless View',
                              style: const TextStyle(fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: AppColors.gold,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Category-Specific Interactive Studio Estimator (Sewing Patterns & 3D .STL Files)
              if (p.category == ProductCategory.sewingPatterns)
                _buildSewingPatternCalculator()
              else if (p.category == ProductCategory.stlFiles)
                _buildStlSlicerEstimator(),

              // Product Title, Category & Price Row (Philippine Pesos ₱)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p.category.storeType.label.toUpperCase()} • ${p.category.label.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.parchment,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Price Tag in Philippine Pesos (₱)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dragonRed.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(
                      CurrencyFormatter.format(p.price),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Rating, Reviews & Instant Download File Badge
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.gold, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    p.rating.toStringAsFixed(2),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.parchment,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${p.reviewCount} Guild Reviews)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.lock_open,
                    color: Colors.greenAccent,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      p.downloadFileName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 32),

              // COLOR SELECTION
              const Text(
                'COLOR VARIANT / PALETTE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: p.colors.map((c) {
                  final isSelected = c.name == _selectedColor.name;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.stone : AppColors.dungeon,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.gold : Colors.white24,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: c.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.parchment,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // SIZE / SCALE SELECTION
              const Text(
                'SIZE & SCALE / FORMAT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: p.sizes.map((size) {
                  final isSelected = size == _selectedSize;
                  return ChoiceChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedSize = size),
                    selectedColor: AppColors.gold,
                    backgroundColor: AppColors.stone,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.dungeon
                          : AppColors.parchment,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.gold : AppColors.goldFaded,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // QUANTITY DELIMITER (STRICTLY NO NEGATIVE QUANTITY)
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUANTITY DELIMITER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.gold,
                        ),
                      ),
                      Text(
                        'Minimum 1 item (no negative quantity)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  QuantityStepper(
                    quantity: _quantity,
                    onChanged: (newQty) => setState(() => _quantity = newQty),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 32),

              // PRODUCT DESCRIPTION & LORE
              const Text(
                'PRODUCT ARCHIVE & CRAFTSMANSHIP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                p.fullDescription,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.parchmentFaded,
                ),
              ),
              const SizedBox(height: 14),

              // Photo Attribution Banner (Authentic, Non-AI verification)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.stone.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.gold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Source: ${p.photoCredit} (${p.license})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Spacing for sticky bottom bar
            ],
          ),
        ),
      ),

      // STICKY BOTTOM ACTION BAR: Add to Cart 🛒 & Buy Now 💰 (Philippine Pesos ₱)
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.stone,
          border: const Border(top: BorderSide(color: AppColors.goldFaded)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Total calculation in Philippine Pesos (₱)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL AMOUNT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.mutedText,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(totalPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Add to Cart Button (Icon: 🛒)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_cart, size: 18),
                  label: const Text('Add 🛒'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold, width: 1.5),
                    foregroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Buy Now Button (Icon: 💰)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _buyNow,
                  icon: const Icon(
                    Icons.monetization_on,
                    size: 18,
                    color: AppColors.dungeon,
                  ),
                  label: const Text('Buy Now 💰'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.dungeon,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSewingPatternCalculator() {
    final isWide = _fabricBoltWidth == '60" Wide Bolt';
    final yards = isWide ? '2.8 Yards' : '3.6 Yards';
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldFaded),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.content_cut, color: AppColors.gold, size: 18),
              SizedBox(width: 8),
              Text(
                'INTERACTIVE TAILOR YARDAGE & PATTERN ESTIMATOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['45" Standard Bolt', '60" Wide Bolt'].map((bolt) {
              final selected = _fabricBoltWidth == bolt;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(bolt),
                  selected: selected,
                  onSelected: (_) => setState(() => _fabricBoltWidth = bolt),
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.dungeon,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: selected ? AppColors.dungeon : AppColors.parchment,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Estimated Fabric Required: $yards • Includes 5/8" seam allowances, A4/US Letter home printer tiles (22 pages) + A0 copyshop sheet.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.parchmentFaded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStlSlicerEstimator() {
    final isResin = _printerMode.startsWith('SLA');
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldFaded),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.view_in_ar, color: AppColors.gold, size: 18),
              SizedBox(width: 8),
              Text(
                '3D PRINT .STL SLICER & SUPPORT ESTIMATOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['SLA Resin (0.03mm)', 'FDM PLA+ (0.12mm)'].map((mode) {
              final selected = _printerMode == mode;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(mode),
                  selected: selected,
                  onSelected: (_) => setState(() => _printerMode = mode),
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.dungeon,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: selected ? AppColors.dungeon : AppColors.parchment,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            isResin
                ? 'Estimated UV Resin: 38 mL • Print Time: ~3h 20m • 100% Pre-Supported (.STL + Chitubox .CTB included).'
                : 'Estimated PLA+ Filament: 54g • Print Time: ~4h 45m • Supportless flat-bed orientation included.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.parchmentFaded,
            ),
          ),
        ],
      ),
    );
  }
}

class _VttTacticalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4A537).withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    const double step = 36.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
