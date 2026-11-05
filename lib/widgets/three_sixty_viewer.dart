import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Interactive 360-degree miniature paint job inspection scrubber.
/// Allows buyers to swipe horizontally across 8 authentic photographs
/// to inspect every angle of the hand-painted miniature.
class ThreeSixtyViewer extends StatefulWidget {
  final List<String> images;
  final double height;
  final String heroTag;

  const ThreeSixtyViewer({
    super.key,
    required this.images,
    this.height = 360,
    required this.heroTag,
  });

  @override
  State<ThreeSixtyViewer> createState() => _ThreeSixtyViewerState();
}

class _ThreeSixtyViewerState extends State<ThreeSixtyViewer>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  double _accumulatedDelta = 0.0;
  bool _isAutoRotating = false;
  late final AnimationController _autoRotateController;

  static const double _sensitivity = 28.0; // Pixels per frame shift

  @override
  void initState() {
    super.initState();
    _autoRotateController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 3200),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && _isAutoRotating) {
            _autoRotateController.repeat();
          }
        });

    _autoRotateController.addListener(() {
      if (_isAutoRotating && widget.images.isNotEmpty) {
        final newIndex =
            (_autoRotateController.value * widget.images.length).floor() %
            widget.images.length;
        if (newIndex != _currentIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _autoRotateController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isAutoRotating) {
      setState(() {
        _isAutoRotating = false;
        _autoRotateController.stop();
      });
    }

    _accumulatedDelta += details.delta.dx;
    if (_accumulatedDelta.abs() >= _sensitivity) {
      final step = (_accumulatedDelta / _sensitivity).toInt();
      final totalFrames = widget.images.length;
      setState(() {
        // Dragging right rotates clockwise, left counter-clockwise
        _currentIndex = (_currentIndex - step) % totalFrames;
        if (_currentIndex < 0) _currentIndex += totalFrames;
      });
      _accumulatedDelta = _accumulatedDelta % _sensitivity;
    }
  }

  void _toggleAutoRotate() {
    setState(() {
      _isAutoRotating = !_isAutoRotating;
      if (_isAutoRotating) {
        _autoRotateController.forward(from: 0.0);
      } else {
        _autoRotateController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No 360° photos available')),
      );
    }

    final total = widget.images.length;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.stone.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldFaded, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The interactive photo scrubber layer
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
              child: Image.network(
                widget.images[_currentIndex],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: AppColors.mutedText,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),

          // Top Left: Rotated 360° Inspection Badge (using Transform & Align)
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Transform.rotate(
                angle: -0.06, // Slight dynamic Viking battle badge tilt
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.dragonRed, Color(0xFF5C1010)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.threed_rotation,
                        color: AppColors.gold,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '360° INSPECT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: AppColors.parchment,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top Right: Auto-rotate button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: Icon(
                    _isAutoRotating
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_outline,
                    color: AppColors.gold,
                  ),
                  tooltip: _isAutoRotating
                      ? 'Pause Rotation'
                      : 'Auto 360° Spin',
                  onPressed: _toggleAutoRotate,
                ),
              ),
            ),
          ),

          // Bottom Bar: Frame Indicator, Angle info, and Horizontal drag hint
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.goldFaded),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swipe, color: AppColors.gold, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'Swipe to rotate',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.parchmentFaded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Frame indicator dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(total, (i) {
                      final isActive = i == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: isActive ? 14 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.gold
                              : AppColors.mutedText,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_currentIndex + 1}/$total',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
