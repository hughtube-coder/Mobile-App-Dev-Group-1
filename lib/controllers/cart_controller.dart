import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Central cart state controller managing added items, quantities, and totals.
/// Notifies listeners whenever the cart contents change.
class CartController extends ChangeNotifier {
  static final CartController instance = CartController._internal();

  CartController._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get uniqueItemCount => _items.length;

  int get totalItemCount =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  bool get hasPhysicalItems => _items.any((item) => !item.product.isDigital);

  bool get hasDigitalItems => _items.any((item) => item.product.isDigital);

  double get subtotal =>
      _items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);

  /// Standard flat delivery fee for hand-painted physical minis/dice in the Philippines (₱150).
  /// Free delivery if the order contains only pure digital campaign maps or LUT presets!
  double get deliveryFee => (hasPhysicalItems && !isEmpty) ? 150.0 : 0.0;

  double get grandTotal => subtotal + deliveryFee;

  void addItem({
    required Product product,
    required ProductColorOption color,
    required String size,
    int quantity = 1,
  }) {
    if (quantity <= 0) return;

    final key = '${product.id}_${color.name}_$size';
    final existingIndex = _items.indexWhere((item) => item.uniqueKey == key);

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          selectedColor: color,
          selectedSize: size,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void incrementQuantity(CartItem item) {
    item.quantity += 1;
    notifyListeners();
  }

  void decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity -= 1;
      notifyListeners();
    }
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
