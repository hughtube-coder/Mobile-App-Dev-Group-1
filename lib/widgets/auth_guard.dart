import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../screens/auth_screen.dart';
import '../theme/app_theme.dart';

/// Guard utility that ensures a user is logged in before performing actions like:
/// - Adding an item to the shopping cart
/// - Quick Buy / Instant Checkout
/// - Accessing checkout with cart items
///
/// Guests can freely browse all products, inspect 360° views, test LUT presets,
/// calculate pattern yardage, and view 3D slicer estimators.
class AuthGuard {
  AuthGuard._();

  /// Checks if the user is signed in.
  /// If signed in, executes [onAuthenticated] immediately.
  /// If NOT signed in, presents a sleek dialog prompting the user to Log In or Sign Up.
  static void protect(
    BuildContext context, {
    required String actionName,
    required VoidCallback onAuthenticated,
  }) {
    if (AuthController.instance.isSignedIn) {
      onAuthenticated();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.stone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.gold, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Log In Required 🔐',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are currently browsing as a Guest. To $actionName, please log in to your account or create a new account.',
              style: const TextStyle(
                color: AppColors.parchment,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.dungeon,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.greenAccent, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Browsing, 360° inspection & LUT testing remain 100% free for guests!',
                      style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Keep Browsing',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AuthScreen(initialTab: 1),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.greenAccent,
              side: const BorderSide(color: Colors.greenAccent),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Sign Up'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AuthScreen(initialTab: 0),
                ),
              );
            },
            icon: const Icon(Icons.login, size: 16),
            label: const Text('Log In 🔐'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.dungeon,
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
