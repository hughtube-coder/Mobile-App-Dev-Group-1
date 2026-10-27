import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A heading for each section of the home screen,
/// with an optional subtitle and a small gold underline.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.parchment,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
            ),
          const SizedBox(height: 6),
          // Gold underline
          Container(width: 40, height: 3, color: AppColors.gold),
        ],
      ),
    );
  }
}
