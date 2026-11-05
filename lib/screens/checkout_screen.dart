import 'package:flutter/material.dart';

import '../controllers/cart_controller.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

/// Checkout screen demonstrating Form, FormField, TextFormField, and `GlobalKey<FormState>`.
/// Enforces comprehensive validation and simulates digital file delivery unlock upon purchase.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Key component: GlobalKey<FormState> for validating the checkout form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _paymentNoteController = TextEditingController();

  String _courierSpeed = 'standard';
  bool _agreedToGuildTerms = true;
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _paymentNoteController.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    // Validate all form fields using GlobalKey<FormState>
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.dragonRed,
          content: Text(
            'Please correct the highlighted fields before proceeding.',
          ),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(
      const Duration(milliseconds: 1400),
    ); // Simulate payment gate

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final cart = CartController.instance;
    final hadDigitalItems = cart.hasDigitalItems;
    final totalAmount = cart.grandTotal;

    // Show Order Confirmation Dialog with Digital Download Link unlock
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.stone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.dungeon,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.gold,
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'PAYMENT CONFIRMED 💰',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hail Adventurer ${_nameController.text.trim()}!',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.parchment,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your pledge of ${CurrencyFormatter.format(totalAmount)} has been recorded in the Guild Ledger. Confirmation dispatched to ${_emailController.text.trim()}.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.parchmentFaded,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // If Digital Maps were purchased, demonstrate the unlocked download link!
            if (hadDigitalItems) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dungeon,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lock_open,
                          color: Colors.greenAccent,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'DIGITAL DOWNLOAD UNLOCKED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'High-Res 8K VTT Grid and One-Shot Campaign PDFs are now ready for download.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.parchment,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              'Downloading: carta_marina_8k_vtt_bundle.zip (Simulated)',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download Assets (.ZIP)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: AppColors.dungeon,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            const Text(
              'Raven courier dispatch estimated: 2-3 tabletop moons.',
              style: TextStyle(fontSize: 11, color: AppColors.mutedText),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              cart.clear();
              Navigator.of(ctx).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.dungeon,
            ),
            child: const Text('Return to Realm Shop'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Guild Checkout & Pact 💰')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Input widget: Form container with GlobalKey
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.stone,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldFaded),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PLEDGE TOTAL',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mutedText,
                          ),
                        ),
                        Text(
                          '${cart.totalItemCount} Items across ${cart.uniqueItemCount} Sets',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.parchment,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.format(cart.grandTotal),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'ADVENTURER DETAILS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 12),

              // Input widget: TextFormField for Full Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.parchment),
                decoration: InputDecoration(
                  labelText: 'Adventurer Name *',
                  hintText: 'e.g. Ragnar Lodbrok / Lyra Moonwhisper',
                  prefixIcon: const Icon(Icons.person, color: AppColors.gold),
                  filled: true,
                  fillColor: AppColors.stone.withValues(alpha: 0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.goldFaded),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.gold,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your adventurer name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 runes long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Input widget: TextFormField for Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.parchment),
                decoration: InputDecoration(
                  labelText: 'Guild Communication Email *',
                  hintText: 'hero@realm.dnd',
                  prefixIcon: const Icon(Icons.email, color: AppColors.gold),
                  filled: true,
                  fillColor: AppColors.stone.withValues(alpha: 0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.goldFaded),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.gold,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide your email for digital keys and dispatch notices';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Input widget: TextFormField for Shipping Address (required if physical minis)
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.parchment),
                decoration: InputDecoration(
                  labelText: cart.hasPhysicalItems
                      ? 'Physical Realm Shipping Address *'
                      : 'Billing Sanctuary (Optional for digital)',
                  hintText: 'Kingdom, Stronghold, Hearth Number, Postal Rune',
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: AppColors.gold,
                  ),
                  filled: true,
                  fillColor: AppColors.stone.withValues(alpha: 0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.goldFaded),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.gold,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (cart.hasPhysicalItems &&
                      (value == null || value.trim().length < 6)) {
                    return 'Physical miniatures & dice require a valid delivery address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Input widget: FormField custom courier speed selector
              FormField<String>(
                initialValue: _courierSpeed,
                builder: (field) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.stone.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.goldFaded),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'COURIER DISPATCH SPEED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildCourierOption(
                          title: 'Standard Raven Courier (3-5 days)',
                          value: 'standard',
                          selected: _courierSpeed == 'standard',
                          onTap: () {
                            setState(() => _courierSpeed = 'standard');
                            field.didChange('standard');
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildCourierOption(
                          title: 'Wyvern Express (+₱100 tracked)',
                          value: 'express',
                          selected: _courierSpeed == 'express',
                          onTap: () {
                            setState(() => _courierSpeed = 'express');
                            field.didChange('express');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Input widget: FormField custom Terms & Conditions Checkbox
              FormField<bool>(
                initialValue: _agreedToGuildTerms,
                validator: (val) {
                  if (val != true) {
                    return 'You must accept the Viking Guild Marketplace covenant';
                  }
                  return null;
                },
                builder: (field) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: field.value,
                            activeColor: AppColors.gold,
                            checkColor: AppColors.dungeon,
                            onChanged: (newVal) {
                              setState(
                                () => _agreedToGuildTerms = newVal ?? false,
                              );
                              field.didChange(newVal);
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'I swear by the Guild Laws to honour my bid, acknowledge authentic non-AI artwork, and accept digital license terms.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.parchmentFaded,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (field.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            field.errorText!,
                            style: const TextStyle(
                              color: AppColors.dragonRed,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Final Submit ElevatedButton with Icon 💰
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _submitOrder,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.dungeon,
                          ),
                        )
                      : const Icon(
                          Icons.monetization_on,
                          color: AppColors.dungeon,
                        ),
                  label: Text(
                    _isProcessing
                        ? 'Sealing Pact...'
                        : 'Confirm & Pay ${CurrencyFormatter.format(cart.grandTotal)} 💰',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.dungeon,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourierOption({
    required String title,
    required String value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withValues(alpha: 0.15)
              : AppColors.dungeon,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.gold : Colors.white12,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? AppColors.gold : AppColors.mutedText,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? AppColors.gold : AppColors.parchment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
