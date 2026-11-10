import 'dart:math';
import 'package:flutter/foundation.dart';

class UserAccount {
  final String id;
  final String fullName;
  final String email;
  String password;
  final String role;
  final DateTime createdAt;
  final bool emailVerified;

  UserAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
    this.emailVerified = true,
  });
}

class DispatchedEmail {
  final String toEmail;
  final String subject;
  final String body;
  final String? otpCode;
  final DateTime timestamp;

  const DispatchedEmail({
    required this.toEmail,
    required this.subject,
    required this.body,
    this.otpCode,
    required this.timestamp,
  });
}

/// Strict, secure authentication controller supporting:
/// - Sign In (Log In) with failed-attempt tracking
/// - Sign Out (Log Out)
/// - Create New Account (Sign Up) with strict 5-point password policy
/// - Email Password Reset with 6-digit OTP verification & simulated email dispatch
class AuthController extends ChangeNotifier {
  AuthController._() {
    final defaultUser = UserAccount(
      id: 'usr-leader-01',
      fullName: 'Andre • Guild Leader',
      email: 'andre.vikings@guild.ph',
      password: 'Viking@2026',
      role: 'Digital Creator & RPG Master',
      createdAt: DateTime(2026, 10, 27),
    );
    _accounts.add(defaultUser);
    _currentUser = defaultUser;
  }

  static final AuthController instance = AuthController._();

  final List<UserAccount> _accounts = [];
  final List<DispatchedEmail> _emailLog = [];
  final Map<String, String> _activeResetOtps = {};
  final Map<String, int> _failedAttempts = {};

  UserAccount? _currentUser;

  UserAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  List<UserAccount> get registeredAccounts => List.unmodifiable(_accounts);
  List<DispatchedEmail> get emailLog => List.unmodifiable(_emailLog);

  /// Strict email format validator
  static String? validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(v)) {
      return 'Enter a valid email (e.g., name@gmail.com)';
    }
    return null;
  }

  /// Strict 5-rule password policy validator
  static String? validateStrictPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Must be at least 8 characters long';
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Must include at least 1 uppercase letter (A-Z)';
    }
    if (!RegExp(r'[a-z]').hasMatch(v)) {
      return 'Must include at least 1 lowercase letter (a-z)';
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'Must include at least 1 number (0-9)';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\]').hasMatch(v)) {
      return 'Must include at least 1 special symbol (e.g. @, #, !)';
    }
    return null;
  }

  /// Evaluates password strength from 0.0 to 1.0 across 5 security rules
  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\]').hasMatch(password)) score++;
    return score / 5.0;
  }

  /// Attempts to sign in with strict verification
  ({bool success, String message, DispatchedEmail? emailAlert}) signIn({
    required String email,
    required String password,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final account = _accounts
        .cast<UserAccount?>()
        .firstWhere((a) => a!.email.toLowerCase() == cleanEmail, orElse: () => null);

    if (account == null) {
      return (
        success: false,
        message:
            'No account found for "$cleanEmail". Please create a new account or check your email.',
        emailAlert: null,
      );
    }

    final attempts = _failedAttempts[cleanEmail] ?? 0;
    if (account.password != password) {
      final newAttempts = attempts + 1;
      _failedAttempts[cleanEmail] = newAttempts;
      if (newAttempts >= 3) {
        final securityEmail = DispatchedEmail(
          toEmail: account.email,
          subject: '⚠️ Security Alert: Multiple Failed Sign-In Attempts',
          body:
              'Hi ${account.fullName},\n\nWe detected $newAttempts failed login attempts on your Marketing Vikings account (${account.email}). If this was you, please use the "Forgot Password / Email Reset" tab to receive a 6-digit reset code.',
          timestamp: DateTime.now(),
        );
        _emailLog.insert(0, securityEmail);
        notifyListeners();
        return (
          success: false,
          message:
              'Incorrect password ($newAttempts failed attempts). A security alert email was sent to ${account.email}. Use "Forgot Password" to reset.',
          emailAlert: securityEmail,
        );
      }
      return (
        success: false,
        message:
            'Invalid password for ${account.email} (Attempt $newAttempts/3). Passwords are case-sensitive.',
        emailAlert: null,
      );
    }

    _failedAttempts[cleanEmail] = 0;
    _currentUser = account;

    final loginEmail = DispatchedEmail(
      toEmail: account.email,
      subject: '🔐 New Sign-In to Marketing Vikings Dual Market',
      body:
          'Hi ${account.fullName},\n\nYour account (${account.email}) just signed in to the Marketing Vikings Dual E-Commerce App as ${account.role}.',
      timestamp: DateTime.now(),
    );
    _emailLog.insert(0, loginEmail);
    notifyListeners();

    return (
      success: true,
      message: 'Welcome back, ${account.fullName}!',
      emailAlert: loginEmail,
    );
  }

  /// Creates a new verified account and sends a welcome confirmation email
  ({bool success, String message, DispatchedEmail? emailAlert}) signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final emailErr = validateEmail(cleanEmail);
    if (emailErr != null) {
      return (success: false, message: emailErr, emailAlert: null);
    }

    final passErr = validateStrictPassword(password);
    if (passErr != null) {
      return (success: false, message: passErr, emailAlert: null);
    }

    final exists = _accounts.any((a) => a.email.toLowerCase() == cleanEmail);
    if (exists) {
      return (
        success: false,
        message: 'An account with "$cleanEmail" is already registered. Please sign in or reset your password.',
        emailAlert: null,
      );
    }

    final newAccount = UserAccount(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: cleanEmail,
      password: password,
      role: role,
      createdAt: DateTime.now(),
    );

    _accounts.add(newAccount);
    _currentUser = newAccount;

    final welcomeEmail = DispatchedEmail(
      toEmail: cleanEmail,
      subject: '✅ Welcome to Marketing Vikings! Account Verified',
      body:
          'Hello ${newAccount.fullName},\n\nYour Marketing Vikings Dual E-Commerce account ($cleanEmail) has been created and verified with strict security protection.\nRole: ${newAccount.role}\n\nYou now have full access to the Digital Pattern & LUT Tester Market and Tabletop RPG Miniatures & Dice Swap!',
      timestamp: DateTime.now(),
    );
    _emailLog.insert(0, welcomeEmail);
    notifyListeners();

    return (
      success: true,
      message: 'Account created for $cleanEmail! Confirmation email sent.',
      emailAlert: welcomeEmail,
    );
  }

  /// Generates a 6-digit OTP reset code and sends a Password Reset Email to the user's email
  ({bool success, String message, DispatchedEmail? emailAlert, String? otpCode})
      sendPasswordResetEmail(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final emailErr = validateEmail(cleanEmail);
    if (emailErr != null) {
      return (
        success: false,
        message: emailErr,
        emailAlert: null,
        otpCode: null,
      );
    }

    // Check if account exists; if not, auto-provision a guest-recoverable account so any email can be tested live in class!
    UserAccount? account = _accounts
        .cast<UserAccount?>()
        .firstWhere((a) => a!.email.toLowerCase() == cleanEmail, orElse: () => null);

    if (account == null) {
      final namePart = cleanEmail.split('@').first;
      account = UserAccount(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        fullName: namePart[0].toUpperCase() + namePart.substring(1),
        email: cleanEmail,
        password: 'Viking@2026',
        role: 'Verified Guild Member',
        createdAt: DateTime.now(),
      );
      _accounts.add(account);
    }

    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    _activeResetOtps[cleanEmail] = otp;

    final resetEmail = DispatchedEmail(
      toEmail: cleanEmail,
      subject: '🔑 Password Reset Verification Code: $otp',
      body:
          'Hello ${account.fullName},\n\nWe received a request to reset the password for your Marketing Vikings account ($cleanEmail).\n\nYour 6-Digit Security Reset Code is:\n👉  $otp  👈\n\nEnter this 6-digit code in the app along with your new strict password to complete your password reset.',
      otpCode: otp,
      timestamp: DateTime.now(),
    );
    _emailLog.insert(0, resetEmail);
    notifyListeners();

    return (
      success: true,
      message: 'Password reset code sent to $cleanEmail! Check the email notification below.',
      emailAlert: resetEmail,
      otpCode: otp,
    );
  }

  /// Verifies the 6-digit OTP sent to the user's email and updates their password
  ({bool success, String message, DispatchedEmail? emailAlert})
      resetPasswordWithOtp({
    required String email,
    required String otpCode,
    required String newPassword,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final expectedOtp = _activeResetOtps[cleanEmail];
    if (expectedOtp == null) {
      return (
        success: false,
        message: 'Please tap "Send Reset Code to Email" first to generate a verification code.',
        emailAlert: null,
      );
    }

    if (expectedOtp != otpCode.trim()) {
      return (
        success: false,
        message: 'Invalid 6-digit verification code. Please check the email sent to $cleanEmail.',
        emailAlert: null,
      );
    }

    final passErr = validateStrictPassword(newPassword);
    if (passErr != null) {
      return (success: false, message: passErr, emailAlert: null);
    }

    final account = _accounts
        .cast<UserAccount?>()
        .firstWhere((a) => a!.email.toLowerCase() == cleanEmail, orElse: () => null);

    if (account == null) {
      return (
        success: false,
        message: 'Account not found for $cleanEmail.',
        emailAlert: null,
      );
    }

    account.password = newPassword;
    _activeResetOtps.remove(cleanEmail);
    _failedAttempts[cleanEmail] = 0;
    _currentUser = account;

    final confirmEmail = DispatchedEmail(
      toEmail: cleanEmail,
      subject: '✅ Your Password Has Been Reset Successfully',
      body:
          'Hello ${account.fullName},\n\nThe password for your Marketing Vikings account ($cleanEmail) was successfully updated using your 6-digit email verification code. You are now securely signed in.',
      timestamp: DateTime.now(),
    );
    _emailLog.insert(0, confirmEmail);
    notifyListeners();

    return (
      success: true,
      message: 'Password reset complete! You are now signed in as ${account.email}.',
      emailAlert: confirmEmail,
    );
  }

  /// Signs out (logs out) the current user session
  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
