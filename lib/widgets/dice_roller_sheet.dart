import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/cart_controller.dart';
import '../theme/app_theme.dart';

/// Interactive Tabletop RPG Tavern Mini-Game & Polyhedral Dice Roller.
/// Built for the Tabletop RPG Miniatures & Dice Swap store mode.
/// Explains how RPG dice work and turns rolling into a fun mini-game:
/// 1) ⚔️ Monster Battle (D20 Encounter with Critical Hits & Unlockable Vouchers)
/// 2) 🎁 Mystery Loot Box (D100 Treasure Drop with Promo Codes)
/// 3) 🎲 Free Tabletop Polyhedral Roller (D4, D6, D8, D10, D12, D20, D100)
class DiceRollerSheet extends StatefulWidget {
  const DiceRollerSheet({super.key});

  @override
  State<DiceRollerSheet> createState() => _DiceRollerSheetState();
}

class _DiceRollerSheetState extends State<DiceRollerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rollController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;
  final math.Random _random = math.Random();

  int _selectedGameTab = 0; // 0 = Monster Battle, 1 = Mystery Loot, 2 = Free Roller
  int _selectedSides = 20;
  int _modifier = 0;
  int _currentRoll = 20;
  bool _isRolling = false;

  // Monster Battle state
  int _selectedMonsterIndex = 0;
  static const List<_MonsterTarget> _monsters = [
    _MonsterTarget(
      name: 'Frost Troll',
      ac: 14,
      icon: Icons.snowing,
      rewardCode: 'TROLL10',
      rewardDiscount: '10% OFF',
    ),
    _MonsterTarget(
      name: 'Ancient Red Dragon',
      ac: 18,
      icon: Icons.local_fire_department,
      rewardCode: 'DRAGON15',
      rewardDiscount: '15% OFF',
    ),
    _MonsterTarget(
      name: 'Goblin Ambush Squad',
      ac: 12,
      icon: Icons.warning_amber_rounded,
      rewardCode: 'GOBLIN5',
      rewardDiscount: '5% OFF',
    ),
  ];

  static const List<int> _diceTypes = [4, 6, 8, 10, 12, 20, 100];
  final List<String> _history = ['D20: 20 (Critical Hit!)', 'D20: 16 (Hit)', 'D100: 94 (Legendary Loot!)'];

  String? _unlockedPromoCode;
  String? _battleOutcomeMessage;

  @override
  void initState() {
    super.initState();
    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 4 * math.pi).animate(
      CurvedAnimation(parent: _rollController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _rollController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  void _rollDice() {
    if (_isRolling) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isRolling = true;
      _unlockedPromoCode = null;
      _battleOutcomeMessage = null;
    });

    _rollController.forward(from: 0.0);

    int ticks = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 55));
      if (!mounted) return false;
      setState(() {
        _currentRoll = 1 + _random.nextInt(_selectedSides);
      });
      ticks++;
      return ticks < 10;
    }).then((_) {
      if (!mounted) return;
      final finalRoll = 1 + _random.nextInt(_selectedSides);
      final total = finalRoll + _modifier;

      String logEntry;
      if (_selectedGameTab == 0) {
        // Monster Battle
        final monster = _monsters[_selectedMonsterIndex];
        if (finalRoll == 20) {
          _battleOutcomeMessage = '🔥 NATURAL 20! CRITICAL HIT! Defeated ${monster.name}!';
          _unlockedPromoCode = monster.rewardCode;
          logEntry = '⚔️ D20: 20 (NAT 20 CRIT vs ${monster.name}!)';
          CartController.instance.applyPromoCode(monster.rewardCode);
        } else if (finalRoll == 1) {
          _battleOutcomeMessage = '💀 NATURAL 1! Critical Fumble! The troll hit your shield!';
          logEntry = '💀 D20: 1 (FUMBLE vs ${monster.name})';
        } else if (total >= monster.ac) {
          _battleOutcomeMessage = '⚔️ HIT! Total $total beats AC ${monster.ac}! Monster takes 18 damage!';
          logEntry = '⚔️ D20+$_modifier: $total (HIT vs ${monster.name})';
        } else {
          _battleOutcomeMessage = '💨 MISS! Total $total is below AC ${monster.ac}. The monster parried!';
          logEntry = '💨 D20+$_modifier: $total (MISS vs ${monster.name})';
        }
      } else if (_selectedGameTab == 1) {
        // Mystery Loot Box (D100)
        if (finalRoll >= 90) {
          _battleOutcomeMessage = '🏆 MYTHIC TREASURE! Unlocked Promo Code: MYTHIC50 (-₱50)';
          _unlockedPromoCode = 'CREATOR50';
          logEntry = '🎁 D100: $finalRoll (Mythic Artifact Drop!)';
          CartController.instance.applyPromoCode('CREATOR50');
        } else if (finalRoll >= 60) {
          _battleOutcomeMessage = '💎 RARE LOOT! Hand-painted miniature resin chest discovered!';
          logEntry = '🎁 D100: $finalRoll (Rare Mini Chest)';
        } else if (finalRoll >= 30) {
          _battleOutcomeMessage = '📜 UNCOMMON LOOT! 8K VTT Dungeon Map PDF discovered!';
          logEntry = '🎁 D100: $finalRoll (Uncommon Map)';
        } else {
          _battleOutcomeMessage = '🐟 COMMON LOOT! Iron rations and a wooden tankard.';
          logEntry = '🎁 D100: $finalRoll (Common Loot)';
        }
      } else {
        // Free roller
        final modLabel = _modifier == 0 ? '' : (_modifier > 0 ? '+$_modifier' : '$_modifier');
        logEntry = 'D$_selectedSides$modLabel: $total';
      }

      setState(() {
        _currentRoll = finalRoll;
        _history.insert(0, logEntry);
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.gold, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag bar
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.goldFaded,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),

              // Title Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.casino, color: AppColors.gold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'TAVERN RPG ENCOUNTER & DICE GAME',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Educational explanation of what RPG dice are for
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.dungeon,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Text(
                  '💡 How it works: In D&D and Tabletop RPGs, multi-sided dice decide combat hits, skill tests & loot drops. Roll below to battle monsters or unlock cart promo vouchers!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.parchmentFaded, height: 1.3),
                ),
              ),
              const SizedBox(height: 8),

              // Mini-Game Mode Selector Tabs: Battle | Mystery Loot | Free Roller
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.dungeon,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.goldFaded),
                ),
                child: Row(
                  children: [
                    _buildGameTab(0, Icons.shield, 'Monster Battle'),
                    _buildGameTab(1, Icons.card_giftcard, 'Mystery Loot'),
                    _buildGameTab(2, Icons.casino_outlined, 'Free Roller'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tab 0 Content: Monster Target Selector
              if (_selectedGameTab == 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_monsters.length, (i) {
                    final m = _monsters[i];
                    final isSelected = i == _selectedMonsterIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        avatar: Icon(
                          m.icon,
                          size: 14,
                          color: isSelected ? AppColors.dungeon : AppColors.gold,
                        ),
                        label: Text('${m.name} (AC ${m.ac})'),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedMonsterIndex = i;
                            _selectedSides = 20;
                          });
                        },
                        selectedColor: AppColors.gold,
                        backgroundColor: AppColors.dungeon,
                        labelStyle: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? AppColors.dungeon : AppColors.parchment,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
              ] else if (_selectedGameTab == 2) ...[
                // Tab 2 Content: Standard Polyhedral Dice Type Selector
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _diceTypes.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 5),
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
                          color: selected ? AppColors.dungeon : AppColors.parchment,
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Animated Rolling Dice Core
              AnimatedBuilder(
                animation: _rollController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: _rollDice,
                  child: Container(
                    width: 108,
                    height: 108,
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
                          color: isCrit ? AppColors.gold.withValues(alpha: 0.6) : Colors.black54,
                          blurRadius: isCrit ? 22 : 10,
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
                            color: isCrit ? AppColors.dungeon : AppColors.gold,
                          ),
                        ),
                        Text(
                          '$totalResult',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            color: isCrit ? AppColors.dungeon : AppColors.parchment,
                          ),
                        ),
                        if (_modifier != 0)
                          Text(
                            '($_currentRoll ${_modifier > 0 ? '+ $_modifier' : '- ${_modifier.abs()}'})',
                            style: TextStyle(
                              fontSize: 9,
                              color: isCrit ? AppColors.dungeon : AppColors.parchmentFaded,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Game Outcome Badge / Narrative message
              if (_battleOutcomeMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCrit
                        ? AppColors.gold
                        : (isFumble
                            ? AppColors.dragonRed
                            : AppColors.dungeon),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCrit ? Colors.white : AppColors.goldFaded,
                    ),
                  ),
                  child: Text(
                    _battleOutcomeMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isCrit ? AppColors.dungeon : AppColors.parchment,
                    ),
                  ),
                ),

              // Unlocked Promo Code Banner (Tap to Copy)
              if (_unlockedPromoCode != null)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade900.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.celebration, color: Colors.greenAccent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Promo Unlocked: $_unlockedPromoCode!',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _unlockedPromoCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Copied code $_unlockedPromoCode to clipboard!')),
                          );
                        },
                        child: const Text(
                          'COPY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),

              // Ability Modifier Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Modifier: ',
                    style: TextStyle(fontSize: 11, color: AppColors.parchmentFaded),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.gold, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _modifier = (_modifier - 1).clamp(-5, 15)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.gold, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _modifier = (_modifier + 1).clamp(-5, 15)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Roll Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isRolling ? null : _rollDice,
                  icon: const Icon(Icons.casino, color: AppColors.dungeon, size: 18),
                  label: Text(
                    _isRolling
                        ? 'Rolling...'
                        : (_selectedGameTab == 0
                            ? 'ROLL ATTACK D20 ⚔️'
                            : (_selectedGameTab == 1
                                ? 'ROLL LOOT D100 🎁'
                                : 'ROLL D$_selectedSides 🎲')),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.dungeon,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Roll Log
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 4,
                children: [
                  const Text('Roll Log:', style: TextStyle(fontSize: 10, color: AppColors.mutedText)),
                  ..._history.map(
                    (entry) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.dungeon,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        entry,
                        style: const TextStyle(
                          fontSize: 9.5,
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

  Widget _buildGameTab(int index, IconData icon, String label) {
    final isSelected = _selectedGameTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGameTab = index;
            if (index == 0) _selectedSides = 20;
            if (index == 1) _selectedSides = 100;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppColors.dungeon : AppColors.gold,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.dungeon : AppColors.parchment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonsterTarget {
  final String name;
  final int ac;
  final IconData icon;
  final String rewardCode;
  final String rewardDiscount;

  const _MonsterTarget({
    required this.name,
    required this.ac,
    required this.icon,
    required this.rewardCode,
    required this.rewardDiscount,
  });
}
