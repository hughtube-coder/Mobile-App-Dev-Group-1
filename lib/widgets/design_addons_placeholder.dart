import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'dice_roller_sheet.dart';

/// Interactive Placeholder widget demonstrating potential future design add-ons
/// with live interactive simulation (e.g. Valhalla D20 Dice Roller).
class DesignAddonsPlaceholder extends StatelessWidget {
  const DesignAddonsPlaceholder({super.key});

  void _openDiceRoller(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const DiceRollerSheet(),
    );
  }

  void _showArInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.stone,
        title: const Row(
          children: [
            Icon(Icons.view_in_ar, color: AppColors.gold, size: 28),
            SizedBox(width: 8),
            Text(
              'AR Miniature Placer',
              style: TextStyle(color: AppColors.parchment),
            ),
          ],
        ),
        content: const Text(
          'In this upcoming feature, buyers can project 3D .STL miniature scans into their physical room or battle grid using phone camera ARKit / ARCore tracking before buying!',
          style: TextStyle(color: AppColors.parchmentFaded),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.dungeon,
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

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
              Expanded(
                child: Text(
                  'POTENTIAL DESIGN ADD-ONS (TAP TO TEST)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Add-on 1: 3D AR Tabletop Mini Placer
          GestureDetector(
            onTap: () => _showArInfo(context),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Placeholder(
                fallbackHeight: 96,
                color: AppColors.goldFaded,
                strokeWidth: 1.2,
                child: Container(
                  color: AppColors.dungeon.withValues(alpha: 0.85),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.view_in_ar, color: AppColors.gold, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'AR Miniature Tabletop Placer (Tap)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.parchment,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Preview 28mm/32mm miniatures directly on physical gaming mats.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Add-on 2: Live Polyhedral Dice Roller Simulator (Interactive!)
          GestureDetector(
            onTap: () => _openDiceRoller(context),
            child: Placeholder(
              fallbackHeight: 96,
              color: AppColors.gold,
              strokeWidth: 1.4,
              child: Container(
                color: AppColors.dungeon.withValues(alpha: 0.85),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.casino, color: AppColors.gold, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Valhalla D20 Dice Roller Simulator (Tap)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tap here to test live dice rolls, critical hits, and acoustics!',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.parchmentFaded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.play_circle_fill,
                      color: AppColors.gold,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
