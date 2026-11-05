import 'product.dart';

class CartItem {
  final Product product;
  final ProductColorOption selectedColor;
  final String selectedSize;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    this.quantity = 1,
  }) : assert(quantity > 0, 'Cart item quantity must be positive');

  double get totalPrice => product.price * quantity;

  String get uniqueKey => '${product.id}_${selectedColor.name}_$selectedSize';
}
