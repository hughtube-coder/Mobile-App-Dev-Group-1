import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'product_photo.dart';

/// Featured carousel implemented using Flutter Material 3's [CarouselView]
/// exactly as taught in the Mobile Application Development lecture slides.
class MaterialCarouselViewSection extends StatelessWidget {
  final ValueChanged<Product> onProductTap;

  const MaterialCarouselViewSection({super.key, required this.onProductTap});

  @override
  Widget build(BuildContext context) {
    final featured = Product.catalog.where((p) => p.isFeatured).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: CarouselView(
            itemExtent: 320,
            shrinkExtent: 260,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.goldFaded, width: 1.2),
            ),
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            children: featured.map((product) {
              return GestureDetector(
                onTap: () => onProductTap(product),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.stone,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Authentic photograph background
                      ProductPhoto(
                        imageSource: product.primaryImage,
                        fit: BoxFit.cover,
                      ),

                      // Vignette gradient for text contrast
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.92),
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Angled discount/feature badge using Transform
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Transform(
                          alignment: Alignment.topRight,
                          transform: Matrix4.skewY(0.12)..rotateZ(-0.06),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: product.has360View
                                  ? AppColors.dragonRed
                                  : (product.hasLutPreview
                                      ? const Color(0xFF00695C)
                                      : AppColors.gold),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.gold,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              product.has360View
                                  ? '360° ROTATION'
                                  : (product.hasLutPreview
                                      ? 'LUT PREVIEW'
                                      : 'DISCOUNTED!'),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: product.has360View || product.hasLutPreview
                                    ? AppColors.parchment
                                    : AppColors.dungeon,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Product info overlay at bottom
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.parchment,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      CurrencyFormatter.format(product.price),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: 12,
                                        color: AppColors.dungeon,
                                        semanticLabel: 'Inspect item details',
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Inspect',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.dungeon,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
