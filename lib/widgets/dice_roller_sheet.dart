import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/cart_controller.dart';
import '../controllers/dice_quest_controller.dart';
import '../theme/app_theme.dart';

/// Interactive Tabletop RPG Tavern Mini-Game & Polyhedral Dice Roller.
/// Built for the Tabletop RPG Miniatures & Dice Swap store mode.
///
/// Features a non-infinite Roll Stamina economy where adventurers earn rolls
/// by completing interactive e-commerce quests:
/// 1) ⚔️ Boss Raid (D20 Encounter with animated HP bars & critical hits)
/// 2) 🍺 Barkeep Duel (Contested D20 tavern rolls)
/// 3) 🎁 Mystery Loot Box (D100 Percentile roll for discount vouchers)
/// 4) 🎲 Free Polyhedral Dice Tray (D4, D6, D8, D10, D12, D20, D100)
/// 5) 📜 Guild Quests & Bounties (Inspect items, browse catalog, test 360° scrubber to earn rolls)
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

  // 0 = Boss Raid, 1 = Barkeep Duel, 2 = Mystery Loot, 3 = Dice Tray, 4 = Quests & Rolls
  int _selectedGameTab = 0;
  int _selectedSides = 20;
  int _modifier = 0;
  int _currentRoll = 20;
  int _barkeepRoll = 12;
  bool _isRolling = false;

  // Monster Battle state with live HP bars
  int _selectedMonsterIndex = 0;
  final Map<int, int> _monsterHp = {0: 30, 1: 50, 2: 15};
  static const Map<int, int> _monsterMaxHp = {0: 30, 1: 50, 2: 15};

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
  final List<String> _history = [
    '⚔️ D20: 20 (Critical Hit!)',
    '🍺 Duel: You 18 vs Barkeep 14 (Won VIKING10)',
    '🎁 D100: 95 (Mythic Loot Unlocked!)',
  ];

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

    // Check if user has available rolls in the non-infinite dice economy
    if (!DiceQuestController.instance.hasRolls) {
      HapticFeedback.heavyImpact();
      setState(() {
        _selectedGameTab = 4; // Automatically switch to Tavern Quests tab!
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ You are out of Dice Rolls! Complete Tavern Quests below to earn more rolls!',
          ),
          backgroundColor: AppColors.dragonRed,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Consume 1 roll from the stamina balance
    DiceQuestController.instance.consumeRoll();

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
        // Mode 0: Monster Boss Raid
        final monster = _monsters[_selectedMonsterIndex];
        final maxHp = _monsterMaxHp[_selectedMonsterIndex] ?? 30;
        int currentHp = _monsterHp[_selectedMonsterIndex] ?? maxHp;

        if (finalRoll == 20) {
          const damage = 25;
          currentHp = (currentHp - damage).clamp(0, maxHp);
          _monsterHp[_selectedMonsterIndex] = currentHp;
          _battleOutcomeMessage =
              '🔥 NATURAL 20 CRITICAL HIT! Dealt $damage massive damage! ${currentHp == 0 ? "Boss Defeated!" : "Boss HP: $currentHp/$maxHp"}';
          _unlockedPromoCode = monster.rewardCode;
          logEntry = '⚔️ D20: 20 (NAT 20 CRIT! -${damage}HP vs ${monster.name})';
          CartController.instance.applyPromoCode(monster.rewardCode);
          if (currentHp == 0) {
            DiceQuestController.instance.recordBossDefeated();
          }
        } else if (finalRoll == 1) {
          _battleOutcomeMessage =
              '💀 NATURAL 1 FUMBLE! The ${monster.name} parried and counter-attacked your shield!';
          logEntry = '💀 D20: 1 (FUMBLE vs ${monster.name})';
        } else if (total >= monster.ac) {
          final damage = math.max(6, (total - monster.ac) * 3 + 4);
          currentHp = (currentHp - damage).clamp(0, maxHp);
          _monsterHp[_selectedMonsterIndex] = currentHp;
          if (currentHp == 0) {
            _battleOutcomeMessage =
                '🏆 BOSS SLAIN! Dealt $damage damage and defeated ${monster.name}! Unlocked code ${monster.rewardCode}!';
            _unlockedPromoCode = monster.rewardCode;
            CartController.instance.applyPromoCode(monster.rewardCode);
            DiceQuestController.instance.recordBossDefeated();
          } else {
            _battleOutcomeMessage =
                '⚔️ HIT! Total $total beats AC ${monster.ac}! Dealt $damage damage (Remaining HP: $currentHp/$maxHp)!';
          }
          logEntry = '⚔️ D20+$_modifier: $total (HIT -$damage HP vs ${monster.name})';
        } else {
          _battleOutcomeMessage =
              '💨 MISS! Total $total is below AC ${monster.ac}. The monster dodged!';
          logEntry = '💨 D20+$_modifier: $total (MISS vs ${monster.name})';
        }
      } else if (_selectedGameTab == 1) {
        // Mode 1: Tavern Barkeep Duel
        final bRoll = 1 + _random.nextInt(20);
        _barkeepRoll = bRoll;
        if (total > bRoll) {
          _battleOutcomeMessage =
              '🏆 YOU WIN! You rolled $total vs Barkeep\'s $bRoll! Barkeep slides you code VIKING10 (10% OFF)!';
          _unlockedPromoCode = 'VIKING10';
          logEntry = '🍺 Duel Won! You: $total vs Barkeep: $bRoll';
          CartController.instance.applyPromoCode('VIKING10');
          DiceQuestController.instance.recordBossDefeated();
        } else if (total == bRoll) {
          _battleOutcomeMessage =
              '⚔️ TIE ROLL ($total vs $bRoll)! A tense standoff at the bar! Roll again to break the tie!';
          logEntry = '🍺 Duel Tie: $total vs $bRoll';
        } else {
          _battleOutcomeMessage =
              '🍻 Barkeep Wins ($bRoll vs your $total)! "Drink your flagon and roll again, traveler!"';
          logEntry = '🍺 Barkeep: $bRoll beat You: $total';
        }
      } else if (_selectedGameTab == 2) {
        // Mode 2: Mystery Loot Box (D100)
        if (finalRoll >= 90) {
          _battleOutcomeMessage =
              '🏆 MYTHIC ARTIFACT! Unlocked secret promo voucher CREATOR50 (-₱50)!';
          _unlockedPromoCode = 'CREATOR50';
          logEntry = '🎁 D100: $finalRoll (Mythic Loot Drop!)';
          CartController.instance.applyPromoCode('CREATOR50');
        } else if (finalRoll >= 60) {
          _battleOutcomeMessage =
              '💎 RARE DROP! Artisan 3D Resin Dice Vault & Miniature Chest!';
          logEntry = '🎁 D100: $finalRoll (Rare Mini Chest)';
        } else if (finalRoll >= 30) {
          _battleOutcomeMessage =
              '📜 UNCOMMON DROP! 8K High-Res Tactical VTT Map PDF unlocked!';
          logEntry = '🎁 D100: $finalRoll (Uncommon Battle Map)';
        } else {
          _battleOutcomeMessage =
              '🪵 COMMON DROP! Runic stone dice pouch & traveler\'s journey rations.';
          logEntry = '🎁 D100: $finalRoll (Common Traveler Loot)';
        }
      } else {
        // Mode 3: Free Tabletop Roller
        final modLabel = _modifier == 0
            ? ''
            : (_modifier > 0 ? '+$_modifier' : '$_modifier');
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
                    'TAVERN RPG ENCOUNTER & QUESTS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // LIVE STAMINA & ROLLS BALANCE BAR
              AnimatedBuilder(
                animation: DiceQuestController.instance,
                builder: (context, _) {
                  final rolls = DiceQuestController.instance.availableRolls;
                  final claimable = DiceQuestController.instance.claimableCount;
                  final hasRolls = rolls > 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasRolls
                            ? [
                                AppColors.dungeon,
                                AppColors.dungeon.withValues(alpha: 0.8),
                              ]
                            : [
                                AppColors.dragonRed.withValues(alpha: 0.3),
                                AppColors.dungeon,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: hasRolls ? AppColors.goldFaded : AppColors.dragonRed,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bolt,
                              color: hasRolls ? Colors.amberAccent : AppColors.dragonRed,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hasRolls
                                  ? 'Dice Rolls: $rolls available'
                                  : '⚠️ 0 Rolls Left (Quests Required)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: hasRolls ? AppColors.parchment : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedGameTab = 4);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: claimable > 0
                                  ? Colors.greenAccent
                                  : AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: claimable > 0 ? Colors.greenAccent : AppColors.gold,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.assignment,
                                  size: 12,
                                  color: claimable > 0 ? Colors.black : AppColors.gold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  claimable > 0
                                      ? 'Claim ($claimable) 🎁'
                                      : 'Earn Rolls 📜',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: claimable > 0 ? Colors.black : AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Mini-Game Mode Selector Tabs: Boss Raid | Barkeep Duel | Mystery Loot | Dice Tray | Quests
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.dungeon,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.goldFaded),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildGameTab(0, Icons.shield, 'Boss Raid'),
                      const SizedBox(width: 4),
                      _buildGameTab(1, Icons.sports_kabaddi, 'Barkeep Duel'),
                      const SizedBox(width: 4),
                      _buildGameTab(2, Icons.card_giftcard, 'Mystery Loot'),
                      const SizedBox(width: 4),
                      _buildGameTab(3, Icons.casino_outlined, 'Dice Tray'),
                      const SizedBox(width: 4),
                      AnimatedBuilder(
                        animation: DiceQuestController.instance,
                        builder: (context, _) {
                          final claimable = DiceQuestController.instance.claimableCount;
                          return _buildGameTab(
                            4,
                            Icons.assignment_turned_in,
                            claimable > 0 ? 'Quests ($claimable)' : 'Quests',
                            highlightBadge: claimable > 0,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // TAB 4 CONTENT: GUILD TAVERN QUESTS & BOUNTY BOARD
              if (_selectedGameTab == 4) ...[
                _buildQuestsBoard(),
              ] else ...[
                // TAB 0-3 CONTENT: DICE BATTLES, ROLLS & ANIMATION

                // Tab 0 Content: Monster Target Selector & Boss HP Bar
                if (_selectedGameTab == 0) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
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
                  ),
                  const SizedBox(height: 8),

                  // Boss Health Bar
                  Builder(builder: (context) {
                    final maxHp = _monsterMaxHp[_selectedMonsterIndex] ?? 30;
                    final curHp = _monsterHp[_selectedMonsterIndex] ?? maxHp;
                    final ratio = curHp / maxHp;
                    final isDead = curHp == 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.dungeon,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDead ? Colors.greenAccent : Colors.white12,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isDead
                                    ? '💀 BOSS DEFEATED!'
                                    : 'BOSS HP: $curHp / $maxHp',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDead ? Colors.greenAccent : AppColors.gold,
                                ),
                              ),
                              if (isDead)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _monsterHp[_selectedMonsterIndex] = maxHp;
                                      _battleOutcomeMessage = null;
                                    });
                                  },
                                  child: const Text(
                                    'Respawn Boss ↺',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.greenAccent,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 7,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ratio > 0.5
                                    ? Colors.greenAccent
                                    : (ratio > 0.25 ? Colors.orangeAccent : AppColors.dragonRed),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Tab 1 Content: Barkeep Duel Banner
                if (_selectedGameTab == 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.dungeon,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('YOUR ROLL (D20)', style: TextStyle(fontSize: 10, color: AppColors.gold)),
                            const SizedBox(height: 2),
                            Text('$totalResult', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.gold)),
                          ],
                        ),
                        const Text('VS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white38)),
                        Column(
                          children: [
                            const Text('BARKEEP ROLL (D20)', style: TextStyle(fontSize: 10, color: Colors.orangeAccent)),
                            const SizedBox(height: 2),
                            Text('$_barkeepRoll', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.orangeAccent)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // Tab 2 Content: D100 Mystery Loot Drop Indicator
                if (_selectedGameTab == 2) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.dungeon,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Roll 90+ for Mythic Promo Voucher CREATOR50 (-₱50)!',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
                        ),
                      ],
                    ),
                  ),
                ],

                // Tab 3 Content: Free Polyhedral Dice Selector
                if (_selectedGameTab == 3) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: _diceTypes.map((sides) {
                      final isSelected = _selectedSides == sides;
                      return ChoiceChip(
                        label: Text('D$sides'),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedSides = sides),
                        selectedColor: AppColors.gold,
                        backgroundColor: AppColors.dungeon,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? AppColors.dungeon : AppColors.parchment,
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 12),

                // 3D Animated Polyhedral Die Visualization
                Center(
                  child: AnimatedBuilder(
                    animation: _rollController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: isCrit
                                    ? [const Color(0xFFFFE082), const Color(0xFFD4A537), const Color(0xFF8B6B1B)]
                                    : (isFumble
                                        ? [Colors.redAccent, AppColors.dragonRed, const Color(0xFF3E0A0A)]
                                        : [const Color(0xFF3A2D20), const Color(0xFF1E1710), Colors.black]),
                              ),
                              border: Border.all(
                                color: isCrit
                                    ? Colors.amberAccent
                                    : (isFumble ? Colors.redAccent : AppColors.gold),
                                width: isCrit ? 3.0 : 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isCrit
                                      ? Colors.amber.withValues(alpha: 0.6)
                                      : (isFumble
                                          ? Colors.red.withValues(alpha: 0.5)
                                          : AppColors.gold.withValues(alpha: 0.25)),
                                  blurRadius: isCrit ? 22 : 12,
                                  spreadRadius: isCrit ? 4 : 1,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$_currentRoll',
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        color: isCrit
                                            ? AppColors.dungeon
                                            : (isFumble ? Colors.white : AppColors.gold),
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'D$_selectedSides',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        color: isCrit
                                            ? AppColors.dungeon
                                            : AppColors.parchmentFaded,
                                      ),
                                    ),
                                  ],
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

                // Critical / Fumble Banner
                if (isCrit)
                  const Text(
                    '⭐ NATURAL 20! CRITICAL HIT! ⭐',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                      letterSpacing: 1.2,
                    ),
                  )
                else if (isFumble)
                  const Text(
                    '💀 NATURAL 1! CRITICAL FUMBLE! 💀',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.redAccent,
                      letterSpacing: 1.2,
                    ),
                  ),

                // Dynamic Battle Outcome Narrative Box
                if (_battleOutcomeMessage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCrit
                          ? AppColors.gold
                          : (isFumble ? AppColors.dragonRed : AppColors.dungeon),
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
                const SizedBox(height: 8),

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

                // Main Roll Action Button (Linked to finite dice roll stamina)
                AnimatedBuilder(
                  animation: DiceQuestController.instance,
                  builder: (context, _) {
                    final rolls = DiceQuestController.instance.availableRolls;
                    final hasRolls = rolls > 0;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isRolling
                            ? null
                            : (hasRolls
                                ? _rollDice
                                : () {
                                    setState(() => _selectedGameTab = 4);
                                  }),
                        icon: Icon(
                          hasRolls ? Icons.casino : Icons.assignment,
                          color: AppColors.dungeon,
                          size: 18,
                        ),
                        label: Text(
                          _isRolling
                              ? 'Rolling Die...'
                              : (hasRolls
                                  ? (_selectedGameTab == 0
                                      ? 'ROLL ATTACK D20 ⚔️ (1 Roll)'
                                      : (_selectedGameTab == 1
                                          ? 'ROLL DUEL D20 🍺 (1 Roll)'
                                          : (_selectedGameTab == 2
                                              ? 'ROLL LOOT D100 🎁 (1 Roll)'
                                              : 'ROLL D$_selectedSides 🎲 (1 Roll)')))
                                  : '⚠️ OUT OF ROLLS! View Quests (+2 Rolls) 📜'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasRolls ? AppColors.gold : Colors.amber.shade700,
                          foregroundColor: AppColors.dungeon,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Roll History Log
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    const Text('Log:', style: TextStyle(fontSize: 10, color: AppColors.mutedText)),
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
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the mode selection tabs (Boss Raid, Duel, Loot, Tray, Quests)
  Widget _buildGameTab(int index, IconData icon, String label, {bool highlightBadge = false}) {
    final isSelected = _selectedGameTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGameTab = index;
          if (index == 0) _selectedSides = 20;
          if (index == 1) _selectedSides = 20;
          if (index == 2) _selectedSides = 100;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold
              : (highlightBadge ? Colors.amber.withValues(alpha: 0.25) : Colors.transparent),
          borderRadius: BorderRadius.circular(7),
          border: highlightBadge && !isSelected
              ? Border.all(color: Colors.amberAccent)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? AppColors.dungeon : (highlightBadge ? Colors.amberAccent : AppColors.gold),
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
    );
  }

  /// Renders the complete Guild Tavern Quests & Bounty Board
  Widget _buildQuestsBoard() {
    return AnimatedBuilder(
      animation: DiceQuestController.instance,
      builder: (context, _) {
        final quests = DiceQuestController.instance.quests;
        final allClaimed = DiceQuestController.instance.allQuestsClaimed;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guild Bounty Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.dungeon,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.goldFaded),
              ),
              child: const Row(
                children: [
                  Icon(Icons.military_tech, color: AppColors.gold, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VALHALLA GUILD BOUNTY BOARD',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: AppColors.gold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dice rolls are finite! Explore the marketplace, inspect items, and test features to earn rolls.',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.parchmentFaded,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Quests List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final q = quests[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.dungeon,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: q.canClaim
                          ? Colors.greenAccent
                          : (q.isClaimed ? Colors.white12 : AppColors.goldFaded.withValues(alpha: 0.5)),
                      width: q.canClaim ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: q.isClaimed
                              ? Colors.white10
                              : (q.canClaim
                                  ? Colors.greenAccent.withValues(alpha: 0.2)
                                  : AppColors.stone),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          q.icon,
                          size: 18,
                          color: q.isClaimed
                              ? Colors.white38
                              : (q.canClaim ? Colors.greenAccent : AppColors.gold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    q.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: q.isClaimed ? Colors.white38 : AppColors.parchment,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    '+${q.rewardRolls} Rolls',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              q.description,
                              style: TextStyle(
                                fontSize: 10,
                                color: q.isClaimed ? Colors.white24 : AppColors.parchmentFaded,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: q.progressRatio,
                                      minHeight: 5,
                                      backgroundColor: Colors.white10,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        q.isCompleted ? Colors.greenAccent : AppColors.gold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${q.currentProgress}/${q.targetProgress}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: q.isCompleted ? Colors.greenAccent : AppColors.parchmentFaded,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Claim Button or Status Indicator
                      if (q.canClaim)
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            final rolls = DiceQuestController.instance.claimReward(q.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🎉 Claimed +$rolls Dice Rolls! Ready to roll!'),
                                backgroundColor: Colors.green.shade800,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            visualDensity: VisualDensity.compact,
                            textStyle: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          child: const Text('CLAIM 🎁'),
                        )
                      else if (q.isClaimed)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                            SizedBox(width: 3),
                            Text('Claimed', style: TextStyle(fontSize: 9.5, color: Colors.white38)),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'In Progress',
                            style: TextStyle(fontSize: 9, color: AppColors.parchmentFaded),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // If all quests are claimed, show repeat/refresh bounty board button!
            if (allClaimed)
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    DiceQuestController.instance.refreshBounties();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🔄 Guild Bounty Board refreshed! Complete quests again for more rolls!')),
                    );
                  },
                  icon: const Icon(Icons.refresh, color: AppColors.gold, size: 16),
                  label: const Text(
                    'Refresh Bounty Board (Repeat Quests)',
                    style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold),
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Back to Battle Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _selectedGameTab = 0);
                },
                icon: const Icon(Icons.shield, color: AppColors.dungeon, size: 16),
                label: const Text('BACK TO BATTLE & ROLL ⚔️'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.dungeon,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
