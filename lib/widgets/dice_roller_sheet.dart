import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Interactive D20 Polyhedral Dice Roller Simulator.
/// Allows tabletop gamers to roll, test audio/visual balance, and view critical hits.
class DiceRollerSheet extends StatefulWidget {
  const DiceRollerSheet({super.key});

  @override
  State<DiceRollerSheet> createState() => _DiceRollerSheetState();
}

class _DiceRollerSheetState extends State<DiceRollerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rollController;
  late final Animation<double> _rotationAnimation;
  final math.Random _random = math.Random();

  int _currentRoll = 20;
  bool _isRolling = false;
  final List<int> _history = [18, 14, 20];

  @override
  void initState() {
    super.initState();
    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 4 * math.pi).animate(
      CurvedAnimation(parent: _rollController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  void _rollDice() {
    if (_isRolling) return;

    setState(() => _isRolling = true);
    _rollController.forward(from: 0.0);

    // Fast number cycling during roll
    int ticks = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 70));
      if (!mounted) return false;
      setState(() {
        _currentRoll = 1 + _random.nextInt(20);
      });
      ticks++;
      return ticks < 10;
    }).then((_) {
      if (!mounted) return;
      final finalResult = 1 + _random.nextInt(20);
      setState(() {
        _currentRoll = finalResult;
        _history.insert(0, finalResult);
        if (_history.length > 8) _history.removeLast();
        _isRolling = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCrit = _currentRoll == 20;
    final isFumble = _currentRoll == 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.goldFaded,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.casino, color: AppColors.gold, size: 24),
                SizedBox(width: 8),
                Text(
                  'VALHALLA D20 DICE ROLLER',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Test fair roll distribution of our resin & metal tabletop dice sets:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),

            // Animated D20 Polygon
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: _rollDice,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: isCrit
                          ? [AppColors.gold, const Color(0xFF8B6B1E)]
                          : (isFumble
                                ? [AppColors.dragonRed, const Color(0xFF3B0B0B)]
                                : [const Color(0xFF3E2C24), AppColors.dungeon]),
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCrit ? Colors.white : AppColors.gold,
                      width: isCrit ? 3.0 : 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCrit
                            ? AppColors.gold.withValues(alpha: 0.6)
                            : Colors.black54,
                        blurRadius: isCrit ? 24 : 12,
                        spreadRadius: isCrit ? 4 : 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$_currentRoll',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: isCrit ? AppColors.dungeon : AppColors.parchment,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Critical hit or fumble text
            if (isCrit)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⚔️ NATURAL 20! CRITICAL HIT!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dungeon,
                  ),
                ),
              )
            else if (isFumble)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.dragonRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💀 NATURAL 1... CRITICAL FUMBLE!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              )
            else
              const SizedBox(height: 24),
            const SizedBox(height: 16),

            // Roll Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRolling ? null : _rollDice,
                icon: const Icon(Icons.refresh, color: AppColors.dungeon),
                label: Text(_isRolling ? 'Rolling...' : 'ROLL THE D20 🎲'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.dungeon,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // History Log
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Recent rolls: ',
                  style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                ),
                ..._history.map(
                  (val) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dungeon,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: val == 20 ? AppColors.gold : Colors.white10,
                      ),
                    ),
                    child: Text(
                      '$val',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: val == 20 ? AppColors.gold : AppColors.parchment,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
