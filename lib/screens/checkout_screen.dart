import 'package:flutter/material.dart';

import '../controllers/cart_controller.dart';
import '../models/cart_item.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

/// Simple Checkout Screen demonstrating Form, FormField, TextFormField, and `GlobalKey<FormState>`.
/// Implements Pure Digital Delivery (no shipping addresses, couriers, or physical inventory tracking).
/// Once paid, the app immediately unlocks downloadable links for every purchased item.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Key component: GlobalKey<FormState> for validating the checkout form (Lecture Slide 2)
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passkeyController = TextEditingController();

  String _paymentChannel = 'gcash';
  bool _agreedToGuildTerms = true;
  bool _obscurePasskey = true;
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passkeyController.dispose();
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
      const Duration(milliseconds: 900),
    ); // Simulate payment verification

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final cart = CartController.instance;
    final purchasedItems = List<CartItem>.from(cart.items);
    final totalAmount = cart.grandTotal;

    // Show Order Confirmation Dialog with Unlocked Download Links for every item!
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
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.dungeon,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                color: Colors.greenAccent,
                size: 42,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'PAYMENT CONFIRMED 💰\nDOWNLOAD LINKS UNLOCKED',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thank you, ${_nameController.text.trim()}!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.parchment,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your payment of ${CurrencyFormatter.format(totalAmount)} is complete. '
                'Pure digital delivery—no shipping addresses or couriers required. '
                'A backup link was also sent to ${_emailController.text.trim()}.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.parchmentFaded,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),

              // Unlocked Download Links Container
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
                          Icons.cloud_download,
                          color: Colors.greenAccent,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'INSTANT DOWNLOAD LINKS UNLOCKED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...purchasedItems.map((item) {
                      final fileName = item.product.downloadFileName;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.stone,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.folder_zip,
                                color: AppColors.gold,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.parchment,
                                      ),
                                    ),
                                    Text(
                                      fileName,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green.shade800,
                                      content: Text(
                                        'Downloading $fileName (${item.selectedSize})...',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.download, size: 14),
                                label: const Text(
                                  'Download',
                                  style: TextStyle(fontSize: 11),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  foregroundColor: AppColors.dungeon,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
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
            child: const Text('Return to Marketplace'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Simple Checkout & Instant Unlock 💰')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // Input widget: Form container with GlobalKey
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pure Digital / Instant Unlock Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.stone,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldFaded),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SIMPLE CHECKOUT TOTAL',
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
                    const Divider(color: Colors.white12, height: 18),
                    const Row(
                      children: [
                        Icon(
                          Icons.bolt,
                          color: Colors.greenAccent,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Pure Digital / Direct Unlock: No shipping addresses, couriers, or physical inventory tracking. Instant download link unlocked once paid!',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              const Text(
                'BUYER & DOWNLOAD ACCOUNT DETAILS',
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
                  labelText: 'Creator / Adventurer Name *',
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
                    return 'Name must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Input widget: TextFormField for Email (Slide 1 & 2)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.parchment),
                decoration: InputDecoration(
                  labelText: 'Instant Download Email *',
                  hintText: 'creator@realm.ph',
                  prefixIcon: const Icon(
                    Icons.email,
                    color: AppColors.gold,
                    semanticLabel: 'Email input icon',
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some text'; // Exact slide 2 validator text
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Input widget: TextFormField with TextInputType.number (Slide 1)
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.parchment),
                decoration: InputDecoration(
                  labelText: 'GCash / Maya Mobile Number (₱ Payment) *',
                  hintText: 'e.g. 09171234567',
                  prefixIcon: const Icon(
                    Icons.phone_android,
                    color: AppColors.gold,
                    semanticLabel: 'Mobile phone numeric input',
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some text'; // Exact slide 2 validator text
                  }
                  if (value.trim().length < 7) {
                    return 'Enter a valid contact number (at least 7 digits)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Input widget: TextFormField with TextInputType.visiblePassword & obscureText (Slide 4)
              TextFormField(
                controller: _passkeyController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _obscurePasskey,
                style: const TextStyle(color: AppColors.parchment),
                decoration: InputDecoration(
                  labelText: 'Download Vault Passcode / PIN *',
                  hintText: 'Enter secret PIN to authorize payment',
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: AppColors.gold,
                    semanticLabel: 'Vault secret security passcode',
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePasskey ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.gold,
                      semanticLabel: 'Toggle secret passcode visibility',
                    ),
                    onPressed: () =>
                        setState(() => _obscurePasskey = !_obscurePasskey),
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some text'; // Exact slide 2 validator text
                  }
                  if (value.trim().length < 4) {
                    return 'Passcode must be at least 4 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Input widget: FormField custom instant payment channel selector (Slide 3)
              FormField<String>(
                initialValue: _paymentChannel,
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
                          'INSTANT PAYMENT & UNLOCK METHOD (₱)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildPaymentOption(
                          title: 'GCash Instant Unlock (₱0 Fee • Immediate Link)',
                          value: 'gcash',
                          selected: _paymentChannel == 'gcash',
                          onTap: () {
                            setState(() => _paymentChannel = 'gcash');
                            field.didChange('gcash');
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          title: 'Maya Creator Wallet (₱0 Fee • Immediate Link)',
                          value: 'maya',
                          selected: _paymentChannel == 'maya',
                          onTap: () {
                            setState(() => _paymentChannel = 'maya');
                            field.didChange('maya');
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
                              'I confirm my order and accept the pure digital license & creator community swap terms.',
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
                        ? 'Unlocking Download Links...'
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

  Widget _buildPaymentOption({
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
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? AppColors.gold : AppColors.parchment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
