import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Interactive Placeholder widget demonstrating potential future design add-ons
/// (e.g. 3D Augmented Reality Miniature Placer & Tabletop D20 Dice Roller).
class DesignAddonsPlaceholder extends StatelessWidget {
  const DesignAddonsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.stone.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldFaded, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.extension_outlined, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'POTENTIAL DESIGN ADD-ONS (ROADMAP)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Add-on 1: 3D AR Tabletop Mini Placer
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Placeholder(
              fallbackHeight: 88,
              color: AppColors.goldFaded,
              strokeWidth: 1.2,
              child: Container(
                color: AppColors.dungeon.withValues(alpha: 0.85),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.view_in_ar, color: AppColors.gold, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'AR Miniature Tabletop Placer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.parchment,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Preview the 28mm/32mm miniature in augmented reality directly on your physical battle mat.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Add-on 2: Live Polyhedral Dice Roller Simulator
          Placeholder(
            fallbackHeight: 88,
            color: AppColors.goldFaded,
            strokeWidth: 1.2,
            child: Container(
              color: AppColors.dungeon.withValues(alpha: 0.85),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                children: [
                  Icon(Icons.casino, color: AppColors.gold, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Simulated 3D Physics Dice Roller',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.parchment,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Test the roll balance and audio acoustic thud before purchasing handmade resin dice sets.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
