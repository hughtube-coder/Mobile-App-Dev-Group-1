import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Quantity Stepper widget enforcing strictly positive numbers (no negative quantity).
/// Perfect delimiter control for purchasing miniatures, dice, or campaign licenses.
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int max;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldFaded, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus button: Disabled when quantity is 1 (ensures no negative/zero quantity!)
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            color: quantity > 1 ? AppColors.parchment : AppColors.mutedText,
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            tooltip: 'Decrease quantity',
          ),

          // Display container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.dungeon,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
          ),

          // Plus button
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            color: quantity < max ? AppColors.gold : AppColors.mutedText,
            onPressed: quantity < max ? () => onChanged(quantity + 1) : null,
            tooltip: 'Increase quantity',
          ),
        ],
      ),
    );
  }
}
