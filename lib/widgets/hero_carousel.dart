import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

/// Featured item carousel showcasing spotlight products,
/// 360° inspection features, and digital campaign modules.
class HeroCarousel extends StatefulWidget {
  final ValueChanged<Product> onProductTap;

  const HeroCarousel({super.key, required this.onProductTap});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<Product> _featuredProducts = [
    Product.catalog.firstWhere((p) => p.id == 'mini-01'),
    Product.catalog.firstWhere((p) => p.id == 'lut-01'),
    Product.catalog.firstWhere((p) => p.id == 'dice-02'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _featuredProducts.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final product = _featuredProducts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => widget.onProductTap(product),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.goldFaded,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Background image with dark fantasy vignette
                        Positioned.fill(
                          child: Image.network(
                            product.primaryImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: AppColors.stone),
                          ),
                        ),

                        // Gradient overlay for high text contrast
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withValues(alpha: 0.92),
                                  Colors.black.withValues(alpha: 0.65),
                                  Colors.black.withValues(alpha: 0.2),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Left text content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Badge (using Transform & Container)
                              Transform.rotate(
                                angle: -0.04,
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
                                  ),
                                  child: Text(
                                    product.has360View
                                        ? '⚡ 360° SCRUBBER READY'
                                        : (product.hasLutPreview
                                              ? '🎨 COLORFILTERED LUT TESTER'
                                              : 'AUTHENTIC D&D DICE'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color:
                                          product.has360View ||
                                              product.hasLutPreview
                                          ? AppColors.parchment
                                          : AppColors.dungeon,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              SizedBox(
                                width: 220,
                                child: Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.parchment,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  Text(
                                    CurrencyFormatter.format(product.price),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        widget.onProductTap(product),
                                    icon: const Icon(
                                      Icons.remove_red_eye,
                                      size: 14,
                                    ),
                                    label: const Text('Inspect'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.gold,
                                      foregroundColor: AppColors.dungeon,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      textStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _featuredProducts.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == _currentPage ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _currentPage ? AppColors.gold : AppColors.mutedText,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
