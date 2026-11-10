import 'package:flutter/material.dart';

/// Represents an interactive Tavern Quest / Guild Bounty that earns dice rolls.
class TavernQuest {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int targetProgress;
  final int rewardRolls;
  int currentProgress;
  bool isClaimed;

  TavernQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetProgress,
    required this.rewardRolls,
    this.currentProgress = 0,
    this.isClaimed = false,
  });

  bool get isCompleted => currentProgress >= targetProgress;
  bool get canClaim => isCompleted && !isClaimed;
  double get progressRatio =>
      targetProgress == 0 ? 1.0 : (currentProgress / targetProgress).clamp(0.0, 1.0);
}

/// Central controller managing the Tavern Dice economy and Guild Quests.
/// Dice rolls are non-infinite; players must explore the marketplace, inspect
/// products, and test features to earn additional rolls.
class DiceQuestController extends ChangeNotifier {
  DiceQuestController._();
  static final DiceQuestController instance = DiceQuestController._();

  /// Starting balance for new adventurers (3 initial rolls to test mechanics)
  int _availableRolls = 3;
  int get availableRolls => _availableRolls;
  bool get hasRolls => _availableRolls > 0;

  /// Set of unique product IDs viewed to ensure unique inspection progress
  final Set<String> _viewedProductIds = {};

  /// Cumulative catalog browsing seconds
  int _browseSeconds = 0;
  int get browseSeconds => _browseSeconds;

  /// Total rolls earned through quest completions
  int _lifetimeRollsEarned = 0;
  int get lifetimeRollsEarned => _lifetimeRollsEarned;

  /// List of active guild bounties
  late final List<TavernQuest> _quests = [
    TavernQuest(
      id: 'quest_view_items',
      title: 'Catalog Inspector',
      description: 'View 5 distinct items (Minis, LUTs, Patterns, or Maps)',
      icon: Icons.visibility_outlined,
      targetProgress: 5,
      rewardRolls: 2,
    ),
    TavernQuest(
      id: 'quest_browse_time',
      title: 'Market Wanderer',
      description: 'Browse the e-commerce catalog for 10 seconds',
      icon: Icons.timer_outlined,
      targetProgress: 10,
      rewardRolls: 2,
    ),
    TavernQuest(
      id: 'quest_test_360',
      title: 'Turntable Master',
      description: 'Inspect miniature paint glazes with the 8-angle 360° scrubber',
      icon: Icons.threed_rotation,
      targetProgress: 1,
      rewardRolls: 2,
    ),
    TavernQuest(
      id: 'quest_test_lut',
      title: 'LUT Colorist',
      description: 'Test a Lightroom LUT preset using the split-screen slider',
      icon: Icons.tune,
      targetProgress: 1,
      rewardRolls: 2,
    ),
    TavernQuest(
      id: 'quest_add_cart',
      title: 'Viking Merchant',
      description: 'Add any digital pattern, LUT, mini, or dice set to your cart',
      icon: Icons.add_shopping_cart,
      targetProgress: 1,
      rewardRolls: 3,
    ),
    TavernQuest(
      id: 'quest_boss_slain',
      title: 'Valhalla Champion',
      description: 'Defeat a Tavern Boss (Frost Troll, Dragon) or win a Barkeep Duel',
      icon: Icons.shield_outlined,
      targetProgress: 1,
      rewardRolls: 3,
    ),
    TavernQuest(
      id: 'quest_daily_login',
      title: 'Guild Member Loyalty',
      description: 'Log in or sign up with your verified account',
      icon: Icons.verified_user_outlined,
      targetProgress: 1,
      rewardRolls: 5,
    ),
  ];

  List<TavernQuest> get quests => List.unmodifiable(_quests);

  /// Number of quests completed and ready to be claimed
  int get claimableCount => _quests.where((q) => q.canClaim).length;

  /// Whether all quests have been completed and claimed
  bool get allQuestsClaimed => _quests.every((q) => q.isClaimed);

  // ---------------------------------------------------------------------------
  // ROLL CONSUMPTION & GRANTING
  // ---------------------------------------------------------------------------

  /// Attempts to consume 1 dice roll. Returns true if granted, false if out of rolls.
  bool consumeRoll() {
    if (_availableRolls <= 0) {
      notifyListeners();
      return false;
    }
    _availableRolls--;
    notifyListeners();
    return true;
  }

  /// Grants rolls directly (e.g. from quest claims, boss rewards)
  void grantRolls(int count, {String? reason}) {
    if (count <= 0) return;
    _availableRolls += count;
    _lifetimeRollsEarned += count;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // QUEST PROGRESS TRACKING HOOKS
  // ---------------------------------------------------------------------------

  /// Called when a user opens a product detail screen
  void recordProductView(String productId) {
    if (_viewedProductIds.contains(productId)) return;
    _viewedProductIds.add(productId);

    final quest = _findQuest('quest_view_items');
    if (quest != null && !quest.isCompleted) {
      quest.currentProgress = _viewedProductIds.length.clamp(0, quest.targetProgress);
      notifyListeners();
    }
  }

  /// Called each second while the user is actively on HomeScreen
  void recordBrowseTick() {
    _browseSeconds++;
    final quest = _findQuest('quest_browse_time');
    if (quest != null && !quest.isCompleted) {
      quest.currentProgress = _browseSeconds.clamp(0, quest.targetProgress);
      notifyListeners();
    }
  }

  /// Called when the 360° scrubber or turntable is scrubbed
  void recordScrubberUsed() {
    final quest = _findQuest('quest_test_360');
    if (quest != null && !quest.isCompleted) {
      quest.currentProgress = 1;
      notifyListeners();
    }
  }

  /// Called when a user interacts with the LUT split-screen preview
  void recordLutTested() {
    final quest = _findQuest('quest_test_lut');
    if (quest != null && !quest.isCompleted) {
      quest.currentProgress = 1;
      notifyListeners();
    }
  }

  /// Called when an item is added to the Cart
  void recordCartAdded() {
    final quest = _findQuest('quest_add_cart');
    if (quest != null && !quest.isCompleted) {
      quest.currentProgress = 1;
      notifyListeners();
    }
  }

  /// Called when a boss is defeated or duel won in the Tavern game
  void recordBossDefeated() {
    final quest = _findQuest('quest_boss_slain');
    if (quest != null && !quest.isCompleted) {
      quest.currentProgress = 1;
      notifyListeners();
    }
  }

  /// Called when user signs in or creates an account
  void recordUserLogin() {
    final quest = _findQuest('quest_daily_login');
    if (quest != null && !quest.isCompleted) {
      quest.currentProgress = 1;
      notifyListeners();
    }
  }

  /// Claims reward for a completed quest
  int claimReward(String questId) {
    final quest = _findQuest(questId);
    if (quest == null || !quest.canClaim) return 0;

    quest.isClaimed = true;
    grantRolls(quest.rewardRolls, reason: 'Completed "${quest.title}"');
    notifyListeners();
    return quest.rewardRolls;
  }

  /// Refreshes all bounties when all are completed so the user can earn more rolls
  void refreshBounties() {
    for (final q in _quests) {
      q.currentProgress = 0;
      q.isClaimed = false;
    }
    _viewedProductIds.clear();
    _browseSeconds = 0;
    notifyListeners();
  }

  TavernQuest? _findQuest(String id) {
    try {
      return _quests.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }
}
