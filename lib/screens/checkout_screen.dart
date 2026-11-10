import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/vault_controller.dart';
import '../models/cart_item.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'vault_screen.dart';

/// Simple Checkout Screen demonstrating Form, FormField, TextFormField, and `GlobalKey<FormState>`.
/// Implements Pure Digital Delivery (no shipping addresses, couriers, or physical inventory tracking).
/// Supports E-Money (GCash with strict 11-digit phone & 4-digit MPIN, Maya) and Credit / Debit Cards.
/// Once paid, the app immediately unlocks downloadable links and dispatches an official receipt email.
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
  final TextEditingController _pinController = TextEditingController();

  // Credit / Debit Card controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();

  String _paymentChannel = 'gcash'; // 'gcash', 'maya', 'card'
  bool _agreedToGuildTerms = true;
  bool _obscurePin = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final user = AuthController.instance.currentUser;
    if (user != null) {
      _nameController.text = user.fullName;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  void _quickFillDemoBuyer() {
    final user = AuthController.instance.currentUser;
    setState(() {
      _nameController.text = user?.fullName ?? 'Alex Rivera';
      _emailController.text = user?.email ?? 'alex.creator@gmail.com';
      _phoneController.text = '09178842026';
      _pinController.text = '2026';
      _cardNumberController.text = '4532 8923 1120 2026';
      _cardExpiryController.text = '12/28';
      _cardCvvController.text = '888';
    });
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
      const Duration(milliseconds: 800),
    ); // Simulate payment verification

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final cart = CartController.instance;
    final purchasedItems = List<CartItem>.from(cart.items);
    final totalAmount = cart.grandTotal;
    final buyerName = _nameController.text.trim();
    final buyerEmail = _emailController.text.trim();

    // Permanently unlock all purchased files into the Downloads Vault
    VaultController.instance.unlockOrder(
      items: purchasedItems,
      buyerName: buyerName,
      buyerEmail: buyerEmail,
      paymentChannel: _paymentChannel,
    );

    // Send official confirmation email with download license links
    final orderId = 'MV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final summaries = purchasedItems
        .map((it) =>
            '${it.product.name} (${it.selectedSize}) • ₱${it.totalPrice.toStringAsFixed(0)} • Link: ${it.product.downloadFileName}')
        .toList();

    AuthController.instance.sendOrderConfirmationEmail(
      toEmail: buyerEmail,
      buyerName: buyerName,
      orderId: orderId,
      totalAmount: totalAmount,
      paymentChannel: _paymentChannel == 'card'
          ? 'Credit/Debit Card'
          : _paymentChannel.toUpperCase(),
      itemSummaries: summaries,
    );

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
                'Thank you, $buyerName!',
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
                'Your files are unlocked below and saved to your Downloads Vault ($buyerEmail).',
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
          OutlinedButton.icon(
            onPressed: () {
              cart.clear();
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const VaultScreen()),
              );
            },
            icon: const Icon(Icons.lock_open, size: 16),
            label: const Text('Open Vault 🔓'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.greenAccent,
              side: const BorderSide(color: Colors.greenAccent),
            ),
          ),
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
            child: const Text('Return to Shop'),
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
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BUYER & DOWNLOAD ACCOUNT DETAILS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                      color: AppColors.gold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _quickFillDemoBuyer,
                    icon: const Icon(
                      Icons.flash_on,
                      size: 14,
                      color: AppColors.gold,
                    ),
                    label: const Text(
                      'Quick Fill Demo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

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
                          'SELECT PAYMENT METHOD (E-MONEY OR CARD):',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildPaymentOption(
                          title: 'GCash (E-Money • 11-digit mobile & 4-digit PIN)',
                          value: 'gcash',
                          selected: _paymentChannel == 'gcash',
                          onTap: () {
                            setState(() => _paymentChannel = 'gcash');
                            field.didChange('gcash');
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          title: 'Maya Wallet (E-Money • 11-digit mobile & 4-digit PIN)',
                          value: 'maya',
                          selected: _paymentChannel == 'maya',
                          onTap: () {
                            setState(() => _paymentChannel = 'maya');
                            field.didChange('maya');
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          title: 'Credit / Debit Card (Visa / Mastercard • 16-digit card)',
                          value: 'card',
                          selected: _paymentChannel == 'card',
                          onTap: () {
                            setState(() => _paymentChannel = 'card');
                            field.didChange('card');
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // DYNAMIC PAYMENT INPUT FIELDS (Accurate E-Money vs Card)
              if (_paymentChannel == 'card') ...[
                // Card Number (16 Digits)
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                    LengthLimitingTextInputFormatter(19),
                  ],
                  style: const TextStyle(
                    color: AppColors.parchment,
                    letterSpacing: 2.0,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Card Number (16 Digits) *',
                    hintText: '4532 8923 1120 2026',
                    prefixIcon: const Icon(
                      Icons.credit_card,
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
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your card number';
                    }
                    final digits = value.replaceAll(' ', '');
                    if (digits.length != 16) {
                      return 'Card number must be 16 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    // Expiry Date (MM/YY)
                    Expanded(
                      child: TextFormField(
                        controller: _cardExpiryController,
                        keyboardType: TextInputType.datetime,
                        maxLength: 5,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        style: const TextStyle(color: AppColors.parchment),
                        decoration: InputDecoration(
                          labelText: 'Expiry (MM/YY) *',
                          hintText: '12/28',
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: AppColors.gold,
                            size: 18,
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
                            return 'Required';
                          }
                          if (!value.contains('/') || value.trim().length != 5) {
                            return 'Format MM/YY';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // CVV (3 Digits)
                    Expanded(
                      child: TextFormField(
                        controller: _cardCvvController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        style: const TextStyle(color: AppColors.parchment),
                        decoration: InputDecoration(
                          labelText: 'CVV (3 Digits) *',
                          hintText: '888',
                          prefixIcon: const Icon(
                            Icons.security,
                            color: AppColors.gold,
                            size: 18,
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
                            return 'Required';
                          }
                          if (value.trim().length != 3) {
                            return '3 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // E-Money: Strictly 11-digit mobile number
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  style: const TextStyle(color: AppColors.parchment),
                  decoration: InputDecoration(
                    labelText:
                        '${_paymentChannel == 'gcash' ? 'GCash' : 'Maya'} Mobile Number (Strictly 11 Digits) *',
                    hintText: '09171234567',
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
                      return 'Please enter your 11-digit mobile number';
                    }
                    final clean = value.trim();
                    if (clean.length != 11) {
                      return 'Number must be exactly 11 digits (e.g. 09171234567)';
                    }
                    if (!clean.startsWith('09')) {
                      return 'Mobile number must start with 09';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // E-Money: Strictly 4-digit PIN
                TextFormField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: _obscurePin,
                  maxLength: 4,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: const TextStyle(
                    color: AppColors.gold,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        '${_paymentChannel == 'gcash' ? 'GCash' : 'Maya'} 4-Digit Security MPIN *',
                    hintText: '4-digit PIN (e.g. 2026)',
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: AppColors.gold,
                      semanticLabel: 'Vault secret security passcode',
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePin ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.gold,
                        semanticLabel: 'Toggle secret passcode visibility',
                      ),
                      onPressed: () =>
                          setState(() => _obscurePin = !_obscurePin),
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
                      return 'Please enter your 4-digit PIN';
                    }
                    if (value.trim().length != 4) {
                      return 'PIN must be exactly 4 digits';
                    }
                    return null;
                  },
                ),
              ],
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
