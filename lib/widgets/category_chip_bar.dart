import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';

/// Horizontal scrollable category selector bar using ListView.
/// Adapts dynamically to the active Dual E-Commerce StoreType.
class CategoryChipBar extends StatelessWidget {
  final ProductCategory selectedCategory;
  final ValueChanged<ProductCategory> onSelect;
  final List<ProductCategory> categories;

  const CategoryChipBar({
    super.key,
    required this.selectedCategory,
    required this.onSelect,
    this.categories = ProductCategory.values,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      // Scroll widget: ListView horizontal
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;

          return Container(
            decoration: BoxDecoration(
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton.icon(
              onPressed: () => onSelect(cat),
              icon: Icon(
                cat.icon,
                size: 18,
                color: isSelected ? AppColors.dungeon : AppColors.gold,
              ),
              label: Text(
                cat.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                  color: isSelected ? AppColors.dungeon : AppColors.parchment,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? AppColors.gold
                    : AppColors.stone.withValues(alpha: 0.85),
                elevation: isSelected ? 4 : 0,
                side: BorderSide(
                  color: isSelected ? AppColors.gold : AppColors.goldFaded,
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
