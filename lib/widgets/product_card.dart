import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'auth_guard.dart';
import 'product_photo.dart';

/// Reusable product card displayed inside GridView and ListView listings.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onQuickBuy;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onQuickBuy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.stone.withValues(alpha: 0.9),
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Container with Badges
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductPhoto(
                    imageSource: product.primaryImage,
                    fit: BoxFit.cover,
                  ),

                  // Subtle gradient shadow on bottom of image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.stone,
                            AppColors.stone.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top Left: 360° / LUT Badge using Transform & Align (Lecture Slide 6)
                  if (product.has360View)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Transform(
                          alignment: Alignment.topLeft,
                          transform: Matrix4.skewY(0.08)..rotateZ(-math.pi / 28.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.dragonRed,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.gold,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.threed_rotation,
                                  size: 12,
                                  color: AppColors.gold,
                                  semanticLabel: '360 degree rotational inspection',
                                ),
                                SizedBox(width: 3),
                                Text(
                                  '360° VIEW',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.parchment,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (product.hasLutPreview)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Transform(
                          alignment: Alignment.topLeft,
                          transform: Matrix4.skewY(0.08)..rotateZ(-math.pi / 28.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00695C),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.gold,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.tune,
                                  size: 12,
                                  color: AppColors.gold,
                                  semanticLabel: 'ColorFiltered LUT split preview',
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'LUT SLIDER',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.parchment,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Top Right: Rating Chip + Wishlist Heart Button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.goldFaded),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: AppColors.gold,
                                  semanticLabel: 'Product review rating star',
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.parchment,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedBuilder(
                            animation: WishlistController.instance,
                            builder: (context, _) {
                              final isFav = WishlistController.instance
                                  .isFavorite(product.id);
                              return GestureDetector(
                                onTap: () {
                                  WishlistController.instance.toggleFavorite(
                                    product.id,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isFav
                                          ? Colors.redAccent
                                          : Colors.white24,
                                    ),
                                  ),
                                  child: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 14,
                                    color: isFav
                                        ? Colors.redAccent
                                        : AppColors.parchment,
                                    semanticLabel: 'Bookmark favorite item',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Product Details Container
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.parchment,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),

                    // Price & Actions Row (Philippine Pesos ₱)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CurrencyFormatter.format(product.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Action Buttons Row (Add to cart 🛒 & Buy now 💰)
                        Row(
                          children: [
                            // Quick Add to Cart Button (Icon: 🛒)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  AuthGuard.protect(
                                    context,
                                    actionName: 'add items to your cart',
                                    onAuthenticated: () {
                                      CartController.instance.addItem(
                                        product: product,
                                        color: product.colors.first,
                                        size: product.sizes.first,
                                        quantity: 1,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.stone,
                                          behavior: SnackBarBehavior.floating,
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.shopping_cart,
                                                color: AppColors.gold,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Added ${product.name} to cart!',
                                                  style: const TextStyle(
                                                    color: AppColors.parchment,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.goldFaded,
                                  ),
                                  foregroundColor: AppColors.gold,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Buy Now Button (Icon: 💰)
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  AuthGuard.protect(
                                    context,
                                    actionName: 'buy this item',
                                    onAuthenticated: onQuickBuy,
                                  );
                                },
                                icon: const Icon(
                                  Icons.monetization_on,
                                  size: 14,
                                  color: AppColors.dungeon,
                                ),
                                label: const Text('Buy Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: AppColors.dungeon,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  textStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
