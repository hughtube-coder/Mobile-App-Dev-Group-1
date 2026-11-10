import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar_logo.dart';

/// Strict & Secure Authentication Screen featuring:
/// 1) Sign In / Log In (with brute-force protection & 1-tap Demo Login)
/// 2) Create New Account / Sign Up (with live 5-rule Password Strength Meter)
/// 3) Email Password Reset (dispatches a 6-digit OTP verification email to the user's email address)
/// 4) Sign Out / Log Out & Security Email Inbox Viewer
class AuthScreen extends StatefulWidget {
  final int initialTab;

  const AuthScreen({super.key, this.initialTab = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late int _selectedTab; // 0 = Sign In, 1 = Create Account, 2 = Email Reset

  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  // Sign In controllers
  final _signInEmailCtrl = TextEditingController(
    text: 'andre.vikings@guild.ph',
  );
  final _signInPassCtrl = TextEditingController(text: 'Viking@2026');
  bool _obscureSignIn = true;

  // Sign Up controllers
  final _signUpNameCtrl = TextEditingController();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpPassCtrl = TextEditingController();
  final _signUpConfirmCtrl = TextEditingController();
  String _selectedRole = 'Digital Creator & Seller';
  bool _obscureSignUp = true;

  // Email Password Reset controllers
  final _resetEmailCtrl = TextEditingController();
  final _resetOtpCtrl = TextEditingController();
  final _resetNewPassCtrl = TextEditingController();
  bool _obscureResetPass = true;
  DispatchedEmail? _latestResetEmail;

  String? _statusMessage;
  bool _isStatusSuccess = true;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    final current = AuthController.instance.currentUser;
    if (current != null) {
      _resetEmailCtrl.text = current.email;
    } else {
      _resetEmailCtrl.text = 'andre.vikings@guild.ph';
    }
  }

  @override
  void dispose() {
    _signInEmailCtrl.dispose();
    _signInPassCtrl.dispose();
    _signUpNameCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPassCtrl.dispose();
    _signUpConfirmCtrl.dispose();
    _resetEmailCtrl.dispose();
    _resetOtpCtrl.dispose();
    _resetNewPassCtrl.dispose();
    super.dispose();
  }

  void _showEmailPopup(DispatchedEmail email) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.stone,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.mark_email_read,
                  color: Colors.greenAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'EMAIL SENT TO: ${email.toEmail}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              email.subject,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.parchment,
              ),
            ),
            if (email.otpCode != null) ...[
              const SizedBox(height: 4),
              Text(
                'Verification Code: ${email.otpCode} (Tap Autofill below)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ],
        ),
        action: email.otpCode != null
            ? SnackBarAction(
                label: 'AUTOFILL',
                textColor: AppColors.gold,
                onPressed: () {
                  setState(() {
                    _resetOtpCtrl.text = email.otpCode!;
                  });
                },
              )
            : null,
      ),
    );
  }

  void _handleSignIn() {
    if (!_signInFormKey.currentState!.validate()) return;
    final res = AuthController.instance.signIn(
      email: _signInEmailCtrl.text,
      password: _signInPassCtrl.text,
    );
    setState(() {
      _statusMessage = res.message;
      _isStatusSuccess = res.success;
    });
    if (res.emailAlert != null) {
      _showEmailPopup(res.emailAlert!);
    }
    if (res.success && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      });
    }
  }

  void _handleSignUp() {
    if (!_signUpFormKey.currentState!.validate()) return;
    final res = AuthController.instance.signUp(
      fullName: _signUpNameCtrl.text,
      email: _signUpEmailCtrl.text,
      password: _signUpPassCtrl.text,
      role: _selectedRole,
    );
    setState(() {
      _statusMessage = res.message;
      _isStatusSuccess = res.success;
    });
    if (res.emailAlert != null) {
      _showEmailPopup(res.emailAlert!);
    }
    if (res.success && mounted) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      });
    }
  }

  void _handleSendResetEmail() {
    final emailErr = AuthController.validateEmail(_resetEmailCtrl.text);
    if (emailErr != null) {
      setState(() {
        _statusMessage = emailErr;
        _isStatusSuccess = false;
      });
      return;
    }

    final res = AuthController.instance.sendPasswordResetEmail(
      _resetEmailCtrl.text,
    );
    setState(() {
      _statusMessage = res.message;
      _isStatusSuccess = res.success;
      _latestResetEmail = res.emailAlert;
      if (res.otpCode != null) {
        _resetOtpCtrl.text = res.otpCode!;
      }
    });
    if (res.emailAlert != null) {
      _showEmailPopup(res.emailAlert!);
    }
  }

  void _handleResetPasswordSubmit() {
    if (!_resetFormKey.currentState!.validate()) return;
    final res = AuthController.instance.resetPasswordWithOtp(
      email: _resetEmailCtrl.text,
      otpCode: _resetOtpCtrl.text,
      newPassword: _resetNewPassCtrl.text,
    );
    setState(() {
      _statusMessage = res.message;
      _isStatusSuccess = res.success;
    });
    if (res.emailAlert != null) {
      _showEmailPopup(res.emailAlert!);
    }
    if (res.success && mounted) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 165,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: AppBarLogo(),
        ),
        title: const Text('Account & Security Vault 🔐'),
        actions: [
          if (Navigator.of(context).canPop())
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.gold),
              tooltip: 'Back to Store',
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: AuthController.instance,
        builder: (context, _) {
          final auth = AuthController.instance;
          final user = auth.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active Session Banner (Sign Out / Log Out or Guest Warning)
                    _buildCurrentSessionCard(user),
                    const SizedBox(height: 16),

                    // Mode Switcher Tabs: Sign In | Create Account | Email Reset
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.stone,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.goldFaded),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(
                            index: 0,
                            icon: Icons.login,
                            label: 'Sign In / Log In',
                          ),
                          _buildTabButton(
                            index: 1,
                            icon: Icons.person_add_alt_1,
                            label: 'Create Account',
                          ),
                          _buildTabButton(
                            index: 2,
                            icon: Icons.mark_email_unread_outlined,
                            label: 'Email Reset',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Status Alert Banner
                    if (_statusMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isStatusSuccess
                              ? Colors.green.shade900.withValues(alpha: 0.45)
                              : AppColors.dragonRed.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isStatusSuccess
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isStatusSuccess
                                  ? Icons.verified_user
                                  : Icons.error_outline,
                              color: _isStatusSuccess
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _statusMessage!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.parchment,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Active Tab Form Content
                    if (_selectedTab == 0)
                      _buildSignInForm()
                    else if (_selectedTab == 1)
                      _buildSignUpForm()
                    else
                      _buildEmailPasswordResetForm(),

                    const SizedBox(height: 20),

                    // Dispatched Security Emails Inbox Viewer
                    _buildEmailOutboxSection(auth),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentSessionCard(UserAccount? user) {
    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.dragonRed.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.gold, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIGNED OUT • GUEST SESSION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.gold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Sign in to your existing account, create a new verified account, or reset your password via email OTP.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.parchmentFaded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2D24), AppColors.stone],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.greenAccent),
            ),
            child: const Icon(
              Icons.verified_user,
              color: Colors.greenAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.parchment,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SIGNED IN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.email} • ${user.role}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              AuthController.instance.signOut();
              setState(() {
                _statusMessage =
                    'You have safely signed out (logged out) of your account.';
                _isStatusSuccess = true;
              });
            },
            icon: const Icon(Icons.logout, size: 15, color: Colors.white),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dragonRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTab = index;
          _statusMessage = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.dungeon : AppColors.parchment,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AppColors.dungeon : AppColors.parchment,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldFaded),
      ),
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.gold),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'STRICT SIGN IN / LOG IN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(
                    Icons.bolt,
                    size: 14,
                    color: AppColors.dungeon,
                  ),
                  label: const Text('Demo Credentials'),
                  backgroundColor: AppColors.gold,
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dungeon,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    setState(() {
                      _signInEmailCtrl.text = 'andre.vikings@guild.ph';
                      _signInPassCtrl.text = 'Viking@2026';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your registered email and strict password to unlock creator tools and your digital vault:',
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _signInEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.parchment),
              decoration: _inputDecoration(
                label: 'Email Address',
                hint: 'andre.vikings@guild.ph',
                icon: Icons.email_outlined,
              ),
              validator: AuthController.validateEmail,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signInPassCtrl,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _obscureSignIn,
              style: const TextStyle(color: AppColors.parchment),
              decoration: _inputDecoration(
                label: 'Password',
                hint: 'Enter your strict password',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscureSignIn ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscureSignIn = !_obscureSignIn),
                ),
              ),
              validator: (val) =>
                  (val == null || val.isEmpty) ? 'Password is required' : null,
            ),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _resetEmailCtrl.text = _signInEmailCtrl.text.trim();
                    _selectedTab = 2;
                    _statusMessage = null;
                  });
                },
                icon: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 15,
                  color: AppColors.gold,
                ),
                label: const Text(
                  'Forgot Password? Email me a 6-Digit Reset Code',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleSignIn,
                icon: const Icon(Icons.login, color: AppColors.dungeon),
                label: const Text('Sign In to Account 🔐'),
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
    );
  }

  Widget _buildSignUpForm() {
    final pass = _signUpPassCtrl.text;
    final strength = AuthController.calculatePasswordStrength(pass);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldFaded),
      ),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_add_alt_1, color: AppColors.gold),
                SizedBox(width: 8),
                Text(
                  'CREATE NEW VERIFIED ACCOUNT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Strict security policy enforced: requires a valid email and a strong password (8+ chars, uppercase, lowercase, number, and symbol).',
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _signUpNameCtrl,
              style: const TextStyle(color: AppColors.parchment),
              decoration: _inputDecoration(
                label: 'Full Name / Creator Handle',
                hint: 'e.g. Freya Lindqvist',
                icon: Icons.badge_outlined,
              ),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Please enter your full name'
                  : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.parchment),
              decoration: _inputDecoration(
                label: 'Email Address (For Verification & Reset)',
                hint: 'yourname@gmail.com',
                icon: Icons.email_outlined,
              ),
              validator: AuthController.validateEmail,
            ),
            const SizedBox(height: 12),

            // Role Selector using FormField<String> (Lecture Slide 20)
            FormField<String>(
              initialValue: _selectedRole,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Account Role:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        'Digital Creator & Seller',
                        'Tabletop Adventurer & Buyer',
                      ].map((role) {
                        final selected = _selectedRole == role;
                        return ChoiceChip(
                          label: Text(role),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => _selectedRole = role);
                            state.didChange(role);
                          },
                          selectedColor: AppColors.gold,
                          backgroundColor: AppColors.dungeon,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? AppColors.dungeon
                                : AppColors.parchment,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpPassCtrl,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _obscureSignUp,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.parchment),
              decoration: _inputDecoration(
                label: 'Strict Password',
                hint: 'Min 8 chars, A-Z, a-z, 0-9 & symbol (@#!)',
                icon: Icons.security,
                suffix: IconButton(
                  icon: Icon(
                    _obscureSignUp ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscureSignUp = !_obscureSignUp),
                ),
              ),
              validator: AuthController.validateStrictPassword,
            ),
            const SizedBox(height: 8),

            // Live Password Strength Meter & 5-Rule Checklist
            _buildPasswordStrengthChecklist(pass, strength),
            const SizedBox(height: 12),

            TextFormField(
              controller: _signUpConfirmCtrl,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _obscureSignUp,
              style: const TextStyle(color: AppColors.parchment),
              decoration: _inputDecoration(
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                icon: Icons.lock_reset,
              ),
              validator: (val) {
                if (val != _signUpPassCtrl.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleSignUp,
                icon: const Icon(
                  Icons.verified_user,
                  color: AppColors.dungeon,
                ),
                label: const Text('Create Verified Account & Sign In ✅'),
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
    );
  }

  Widget _buildEmailPasswordResetForm() {
    final newPass = _resetNewPassCtrl.text;
    final strength = AuthController.calculatePasswordStrength(newPass);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldFaded),
      ),
      child: Form(
        key: _resetFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.mark_email_read, color: AppColors.gold),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'EMAIL PASSWORD RESET & OTP VERIFICATION',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your email address below. Our system will email a 6-digit OTP verification code to your email so you can securely reset your password:',
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _resetEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.parchment),
                    decoration: _inputDecoration(
                      label: 'Account Email Address',
                      hint: 'Enter your email address',
                      icon: Icons.email_outlined,
                    ),
                    validator: AuthController.validateEmail,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _handleSendResetEmail,
                    icon: const Icon(
                      Icons.send,
                      size: 15,
                      color: AppColors.dungeon,
                    ),
                    label: const Text('Email Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.dungeon,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Simulated Email Notification Preview Card
            if (_latestResetEmail != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dungeon,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.mark_email_unread,
                          color: Colors.greenAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'EMAIL DELIVERED TO: ${_latestResetEmail!.toEmail}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            if (_latestResetEmail!.otpCode != null) {
                              Clipboard.setData(
                                ClipboardData(
                                  text: _latestResetEmail!.otpCode!,
                                ),
                              );
                              setState(() {
                                _resetOtpCtrl.text =
                                    _latestResetEmail!.otpCode!;
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.copy,
                            size: 13,
                            color: AppColors.gold,
                          ),
                          label: const Text(
                            'Copy & Fill Code',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 12),
                    Text(
                      _latestResetEmail!.subject,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _latestResetEmail!.body,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.parchmentFaded,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 6-Digit OTP Input (TextInputType.number - Slide 20)
            TextFormField(
              controller: _resetOtpCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
              decoration: _inputDecoration(
                label: '6-Digit Email Verification Code (OTP)',
                hint: 'e.g. 482910',
                icon: Icons.pin_outlined,
              ),
              validator: (val) {
                if (val == null || val.trim().length != 6) {
                  return 'Enter the 6-digit verification code sent to your email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // New Strict Password Input
            TextFormField(
              controller: _resetNewPassCtrl,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _obscureResetPass,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.parchment),
              decoration: _inputDecoration(
                label: 'New Strict Password',
                hint: 'Min 8 chars, uppercase, lowercase, number & symbol',
                icon: Icons.lock_reset,
                suffix: IconButton(
                  icon: Icon(
                    _obscureResetPass ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscureResetPass = !_obscureResetPass),
                ),
              ),
              validator: AuthController.validateStrictPassword,
            ),
            const SizedBox(height: 8),
            _buildPasswordStrengthChecklist(newPass, strength),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleResetPasswordSubmit,
                icon: const Icon(Icons.key, color: AppColors.dungeon),
                label: const Text('Verify Email Code & Reset Password 🔑'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.dungeon,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthChecklist(String password, double strength) {
    final hasLen = password.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasNum = RegExp(r'[0-9]').hasMatch(password);
    final hasSym = RegExp(
      r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\]',
    ).hasMatch(password);

    Color barColor = Colors.redAccent;
    String label = 'Weak';
    if (strength >= 1.0) {
      barColor = Colors.greenAccent;
      label = 'Strict & Secure (100%)';
    } else if (strength >= 0.6) {
      barColor = AppColors.gold;
      label = 'Medium (${(strength * 100).round()}%)';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.dungeon.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Password Security Meter:',
                style: TextStyle(fontSize: 11, color: AppColors.mutedText),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              _ruleBadge('8+ Chars', hasLen),
              _ruleBadge('A-Z Upper', hasUpper),
              _ruleBadge('a-z Lower', hasLower),
              _ruleBadge('0-9 Number', hasNum),
              _ruleBadge('@#! Symbol', hasSym),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ruleBadge(String text, bool met) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 12,
          color: met ? Colors.greenAccent : AppColors.mutedText,
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: met ? Colors.greenAccent : AppColors.mutedText,
            fontWeight: met ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailOutboxSection(AuthController auth) {
    final emails = auth.emailLog;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.stone.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.forward_to_inbox, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'SECURITY EMAIL NOTIFICATION LOG (${emails.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (emails.isEmpty)
            const Text(
              'No security emails dispatched in this session yet. Sign in, register an account, or request a password reset to view live email dispatches.',
              style: TextStyle(fontSize: 11, color: AppColors.mutedText),
            )
          else
            ...emails.take(4).map((e) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.dungeon,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.goldFaded),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'To: ${e.toEmail}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (e.otpCode != null)
                          Text(
                            'OTP: ${e.otpCode}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.subject,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.parchment,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.body,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.parchmentFaded, fontSize: 12),
      hintStyle: const TextStyle(color: AppColors.mutedText, fontSize: 12),
      prefixIcon: Icon(icon, color: AppColors.gold, size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.dungeon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.goldFaded),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.goldFaded),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
    );
  }
}
