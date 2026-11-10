import 'package:flutter/material.dart';

/// Manages bookmarked / wishlisted products across both Dual E-Commerce stores.
class WishlistController extends ChangeNotifier {
  static final WishlistController instance = WishlistController._internal();

  WishlistController._internal();

  final Set<String> _favoriteIds = {'lut-01', 'mini-01'};

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  int get count => _favoriteIds.length;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
  }
}
