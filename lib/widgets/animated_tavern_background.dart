import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dynamic animated tavern background with floating ambient golden embers
/// and glowing Norse dungeon gradient lighting.
class AnimatedTavernBackground extends StatefulWidget {
  final Widget child;

  const AnimatedTavernBackground({super.key, required this.child});

  @override
  State<AnimatedTavernBackground> createState() =>
      _AnimatedTavernBackgroundState();
}

class _AnimatedTavernBackgroundState extends State<AnimatedTavernBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_EmberParticle> _particles = [];
  final math.Random _random = math.Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate ambient embers
    for (int i = 0; i < 28; i++) {
      _particles.add(
        _EmberParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: 1.2 + _random.nextDouble() * 2.2,
          speed: 0.15 + _random.nextDouble() * 0.35,
          opacity: 0.2 + _random.nextDouble() * 0.6,
          sway: 0.05 + _random.nextDouble() * 0.1,
          color: i % 3 == 0 ? AppColors.gold : AppColors.dragonRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark dungeon background with subtle ambient radial glow
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.6),
                radius: 1.2,
                colors: [
                  Color(0xFF261412), // Warm hearth glow
                  AppColors.dungeon, // Deep tavern black
                  Color(0xFF0C0908),
                ],
                stops: [0.0, 0.65, 1.0],
              ),
            ),
          ),
        ),

        // Animated glowing embers floating upward
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _EmbersPainter(
                  progress: _controller.value,
                  particles: _particles,
                ),
              );
            },
          ),
        ),

        // Foreground content
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _EmberParticle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;
  final double sway;
  final Color color;

  const _EmberParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.sway,
    required this.color,
  });
}

class _EmbersPainter extends CustomPainter {
  final double progress;
  final List<_EmberParticle> particles;

  _EmbersPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = ((p.y - (progress * p.speed)) % 1.0) * size.height;
      final currentX =
          ((p.x + math.sin((progress * 2 * math.pi) + (p.y * 10)) * p.sway) %
              1.0) *
          size.width;

      final wave = (0.4 + 0.6 * math.sin(progress * 2 * math.pi + p.x));
      final alpha = (p.opacity * wave).clamp(0.0, 1.0);

      final paint = Paint()..color = p.color.withValues(alpha: alpha);

      canvas.drawCircle(Offset(currentX, currentY), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmbersPainter oldDelegate) => true;
}
