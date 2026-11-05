import 'package:flutter/material.dart';

import '../controllers/cart_controller.dart';
import '../models/cart_item.dart';
import '../theme/app_theme.dart';
import '../widgets/quantity_stepper.dart';
import 'checkout_screen.dart';

/// Full interactive Cart screen showcasing ListView, quantity delimiter,
/// Remove item ❗ with confirmation, delivery fee calculations, and checkout trigger.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _confirmRemove(BuildContext context, CartItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.stone,
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.dragonRed,
              size: 28,
            ),
            SizedBox(width: 8),
            Text('Remove Item ❗', style: TextStyle(color: AppColors.parchment)),
          ],
        ),
        content: Text(
          'Are you sure you want to discard ${item.product.name} (${item.selectedSize}) from your inventory cache?',
          style: const TextStyle(color: AppColors.parchmentFaded),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              CartController.instance.removeItem(item);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dragonRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove ❗'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guild Inventory Cache 🛒'),
        actions: [
          AnimatedBuilder(
            animation: CartController.instance,
            builder: (context, _) {
              if (CartController.instance.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(
                  Icons.delete_sweep,
                  color: AppColors.mutedText,
                ),
                tooltip: 'Clear Cart',
                onPressed: () {
                  CartController.instance.clear();
                },
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: CartController.instance,
        builder: (context, _) {
          final cart = CartController.instance;

          if (cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.stone.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.goldFaded),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your Guild Inventory Cache is Empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.parchment,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No painted miniatures, custom dice, or battle maps added yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.shield, color: AppColors.dungeon),
                      label: const Text('Explore Catalog'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.dungeon,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Cart with items: ListView and checkout bottom summary
          return Column(
            children: [
              Expanded(
                // Scroll widget: ListView of cart items
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.stone,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.goldFaded),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Image Thumbnail
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              item.product.primaryImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    color: AppColors.mutedText,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Item Details Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.parchment,
                                        ),
                                      ),
                                    ),
                                    // Remove Item Button (Icon: ❗)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppColors.dragonRed,
                                        size: 20,
                                      ),
                                      tooltip: 'Remove item ❗',
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () =>
                                          _confirmRemove(context, item),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Color & Size specifications
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: item.selectedColor.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${item.selectedColor.name} • ${item.selectedSize}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Quantity and Price Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    QuantityStepper(
                                      quantity: item.quantity,
                                      onChanged: (newQty) {
                                        cart.incrementQuantity(item);
                                      },
                                    ),
                                    Text(
                                      '£${item.totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Order Summary Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.stone,
                  border: const Border(
                    top: BorderSide(color: AppColors.goldFaded),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(color: AppColors.parchmentFaded),
                          ),
                          Text(
                            '£${cart.subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.parchment,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Raven Delivery Courier',
                                style: TextStyle(
                                  color: AppColors.parchmentFaded,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (!cart.hasPhysicalItems)
                                const Text(
                                  '(Free for Digital Maps)',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            cart.deliveryFee == 0
                                ? 'FREE'
                                : '£${cart.deliveryFee.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cart.deliveryFee == 0
                                  ? Colors.greenAccent
                                  : AppColors.parchment,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.parchment,
                            ),
                          ),
                          Text(
                            '£${cart.grandTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Proceed to Checkout Button (Icon: 💰)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CheckoutScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.monetization_on,
                            color: AppColors.dungeon,
                          ),
                          label: const Text('Proceed to Checkout 💰'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.dungeon,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
