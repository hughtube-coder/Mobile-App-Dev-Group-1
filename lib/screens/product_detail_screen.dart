import 'package:flutter/material.dart';

import '../controllers/cart_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../widgets/lut_split_preview.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/three_sixty_viewer.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

/// Comprehensive product detail screen featuring 360° image scrubber for miniatures,
/// interactive ColorFiltered LUT split-screen preview for digital presets,
/// interactive color and size selectors, strictly positive quantity delimiter,
/// and Add to Cart 🛒 / Buy Now 💰 actions with Philippine Pesos (₱).
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

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.product.colors.first;
    _selectedSize = widget.product.sizes.first;
  }

  void _addToCart() {
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
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CartScreen()));
          },
        ),
      ),
    );
  }

  void _buyNow() {
    CartController.instance.addItem(
      product: widget.product,
      color: _selectedColor,
      size: _selectedSize,
      quantity: _quantity,
    );

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
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
              // 1) 360° Scrubber (for miniatures)
              // 2) ColorFiltered Split-Screen Preview (for presets/LUTs)
              // 3) Zoomable image (for dice & maps)
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
                      Image.network(
                        p.primaryImage,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.gold,
                                ),
                              ),
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: AppColors.mutedText,
                                size: 48,
                              ),
                            ),
                      ),
                      if (p.isDigital)
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
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.file_download,
                                  size: 14,
                                  color: AppColors.dungeon,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'DIGITAL DELIVERY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.dungeon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Product Title, Category & Price Row (Philippine Pesos ₱)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.category.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.4,
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

              // Rating and Reviews Row
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
                    Icons.verified,
                    color: Colors.greenAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Authentic (No AI)',
                    style: TextStyle(fontSize: 11, color: Colors.greenAccent),
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
                        'QUANTITY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.gold,
                        ),
                      ),
                      Text(
                        'Minimum 1 item (delimiter enforced)',
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
}
