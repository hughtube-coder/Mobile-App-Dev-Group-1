import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Interactive Multi-Polyhedral D&D Dice Roller Simulator (D4, D6, D8, D10, D12, D20, D100).
/// Allows tabletop gamers to test fair roll distributions, apply ability modifiers, and view critical hits.
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

  static const List<int> _diceTypes = [4, 6, 8, 10, 12, 20, 100];
  int _selectedSides = 20;
  int _modifier = 0;
  int _currentRoll = 20;
  bool _isRolling = false;
  final List<String> _history = ['D20: 20', 'D20: 14', 'D8: 7'];

  @override
  void initState() {
    super.initState();
    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

    int ticks = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 65));
      if (!mounted) return false;
      setState(() {
        _currentRoll = 1 + _random.nextInt(_selectedSides);
      });
      ticks++;
      return ticks < 9;
    }).then((_) {
      if (!mounted) return;
      final finalResult = 1 + _random.nextInt(_selectedSides);
      final totalWithMod = finalResult + _modifier;
      final modLabel = _modifier == 0
          ? ''
          : (_modifier > 0 ? '+$_modifier' : '$_modifier');
      setState(() {
        _currentRoll = finalResult;
        _history.insert(0, 'D$_selectedSides$modLabel: $totalWithMod');
        if (_history.length > 6) _history.removeLast();
        _isRolling = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCrit = _selectedSides == 20 && _currentRoll == 20;
    final isFumble = _selectedSides == 20 && _currentRoll == 1;
    final totalResult = _currentRoll + _modifier;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
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
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.casino, color: AppColors.gold, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'VALHALLA POLYHEDRAL DICE ROLLER',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Select any polyhedral die (D4–D100) & ability modifier to test tabletop rolls:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              const SizedBox(height: 14),

              // Polyhedral Die Type Selector (D4, D6, D8, D10, D12, D20, D100)
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: _diceTypes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final sides = _diceTypes[index];
                    final selected = sides == _selectedSides;
                    return ChoiceChip(
                      label: Text('D$sides'),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedSides = sides;
                          _currentRoll = sides;
                        });
                      },
                      selectedColor: AppColors.gold,
                      backgroundColor: AppColors.dungeon,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? AppColors.dungeon
                            : AppColors.parchment,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.gold : AppColors.goldFaded,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Animated Polyhedral Die Circle
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
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: isCrit
                            ? [AppColors.gold, const Color(0xFF8B6B1E)]
                            : (isFumble
                                  ? [
                                      AppColors.dragonRed,
                                      const Color(0xFF3B0B0B),
                                    ]
                                  : [
                                      const Color(0xFF3E2C24),
                                      AppColors.dungeon,
                                    ]),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'D$_selectedSides',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isCrit
                                ? AppColors.dungeon
                                : AppColors.gold,
                          ),
                        ),
                        Text(
                          '$totalResult',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            color: isCrit
                                ? AppColors.dungeon
                                : AppColors.parchment,
                          ),
                        ),
                        if (_modifier != 0)
                          Text(
                            '($_currentRoll ${_modifier > 0 ? '+ $_modifier' : '- ${_modifier.abs()}'})',
                            style: TextStyle(
                              fontSize: 10,
                              color: isCrit
                                  ? AppColors.dungeon
                                  : AppColors.parchmentFaded,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Ability Modifier Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ability Modifier: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.parchmentFaded,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(
                      () => _modifier = (_modifier - 1).clamp(-5, 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dungeon,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.goldFaded),
                    ),
                    child: Text(
                      _modifier >= 0 ? '+$_modifier' : '$_modifier',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(
                      () => _modifier = (_modifier + 1).clamp(-5, 15),
                    ),
                  ),
                ],
              ),

              if (isCrit)
                Container(
                  margin: const EdgeInsets.only(top: 6),
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
                  margin: const EdgeInsets.only(top: 6),
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
                ),
              const SizedBox(height: 14),

              // Roll Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isRolling ? null : _rollDice,
                  icon: const Icon(Icons.refresh, color: AppColors.dungeon),
                  label: Text(
                    _isRolling ? 'Rolling...' : 'ROLL D$_selectedSides 🎲',
                  ),
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
              const SizedBox(height: 14),

              // History Log
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  const Text(
                    'Roll Log:',
                    style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                  ),
                  ..._history.map(
                    (entry) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dungeon,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        entry,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.parchment,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
