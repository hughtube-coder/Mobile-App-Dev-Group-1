import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class UnlockedVaultItem {
  final Product product;
  final ProductColorOption selectedColor;
  final String selectedSize;
  final int quantity;
  final String licenseKey;
  final String buyerName;
  final String buyerEmail;
  final String paymentChannel;
  final DateTime unlockedAt;
  bool isDownloaded;

  UnlockedVaultItem({
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    required this.quantity,
    required this.licenseKey,
    required this.buyerName,
    required this.buyerEmail,
    required this.paymentChannel,
    required this.unlockedAt,
    this.isDownloaded = false,
  });

  double get totalPaid => product.price * quantity;
}

/// Manages unlocked digital download links, receipts, license keys,
/// and user-submitted community marketplace listings.
class VaultController extends ChangeNotifier {
  static final VaultController instance = VaultController._internal();

  VaultController._internal();

  final List<UnlockedVaultItem> _unlockedItems = [];
  final List<Product> _communityListings = [];
  final math.Random _rng = math.Random();

  List<UnlockedVaultItem> get unlockedItems =>
      List.unmodifiable(_unlockedItems);

  List<Product> get communityListings => List.unmodifiable(_communityListings);

  /// Combined catalog of built-in authentic items + user-listed items
  List<Product> get fullCatalog => [
        ..._communityListings,
        ...Product.catalog,
      ];

  int get unlockedCount => _unlockedItems.length;

  void unlockOrder({
    required List<CartItem> items,
    required String buyerName,
    required String buyerEmail,
    required String paymentChannel,
  }) {
    final now = DateTime.now();
    for (final item in items) {
      final code = 1000 + _rng.nextInt(8999);
      final prefix = item.product.category.storeType == StoreType.digitalCreator
          ? 'LUT-STL'
          : 'RPG-SWAP';
      _unlockedItems.insert(
        0,
        UnlockedVaultItem(
          product: item.product,
          selectedColor: item.selectedColor,
          selectedSize: item.selectedSize,
          quantity: item.quantity,
          licenseKey: 'MV-$prefix-$code',
          buyerName: buyerName,
          buyerEmail: buyerEmail,
          paymentChannel: paymentChannel.toUpperCase(),
          unlockedAt: now,
        ),
      );
    }
    notifyListeners();
  }

  void markDownloaded(UnlockedVaultItem item) {
    item.isDownloaded = true;
    notifyListeners();
  }

  void addCommunityListing(Product newProduct) {
    _communityListings.insert(0, newProduct);
    notifyListeners();
  }
}
