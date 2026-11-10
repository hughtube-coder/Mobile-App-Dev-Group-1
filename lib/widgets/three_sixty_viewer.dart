import 'package:flutter/material.dart';

import '../controllers/dice_quest_controller.dart';
import '../theme/app_theme.dart';
import 'product_photo.dart';

/// Dart/Flutter Edge Feature (Tabletop RPG Miniatures & Dice Swap):
/// Built-in 360-degree miniature paint job inspection scrubber.
/// Allows buyers to swipe horizontally across a sequence of 8 authentic photographs,
/// view angle-by-angle paint layer notes, or toggle 3x Magnifying Loupe Zoom!
class ThreeSixtyViewer extends StatefulWidget {
  final List<String> images;
  final double height;
  final String heroTag;

  const ThreeSixtyViewer({
    super.key,
    required this.images,
    this.height = 415,
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
  bool _isLoupeZoomMode = false;
  late final AnimationController _autoRotateController;

  static const double _sensitivity = 26.0; // Pixels per frame shift

  static const List<String> _angleLabels = [
    '0° Front Stance • NMM Gold & Face Glaze',
    '45° Right Quarter • Weapon Edge Highlight',
    '90° Right Profile • Shield Weathering',
    '135° Rear-Right • Cloak Wet-Blending',
    '180° Back View • Nuln Oil Recess Wash',
    '225° Rear-Left • Leather & Fur Drybrush',
    '270° Left Profile • OSL Rune Glow',
    '315° Heroic Angle • Scenic Slate Base',
  ];

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
    if (_isLoupeZoomMode) return;
    if (_isAutoRotating) {
      setState(() {
        _isAutoRotating = false;
        _autoRotateController.stop();
      });
    }

    _accumulatedDelta += details.delta.dx;
    DiceQuestController.instance.recordScrubberUsed();
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
      _isLoupeZoomMode = false;
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
    final angleNote = _angleLabels[_currentIndex % _angleLabels.length];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.stone.withValues(alpha: 0.9),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tabletop Collector Guidance Banner (Explains what the 360 scrubber does)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            color: AppColors.dungeon,
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.gold),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '360° Studio Turntable: Drag left/right to rotate this painted miniature across all 8 angles to inspect glaze & shading.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.parchmentFaded,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main 360° Interactive Canvas
          SizedBox(
            height: 310,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing Studio Turntable Pedestal
                Positioned(
                  bottom: 12,
                  child: Container(
                    width: 220,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(110),
                      gradient: RadialGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: 0.35),
                          AppColors.dragonRed.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                // Interactive Photo Scrubber or Pinch-to-Zoom Loupe Layer
                if (_isLoupeZoomMode)
                  InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.5,
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      height: double.infinity,
                      child: ProductPhoto(
                        imageSource: widget.images[_currentIndex],
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      height: double.infinity,
                      child: ProductPhoto(
                        imageSource: widget.images[_currentIndex],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                // Top Left: Rotated 360° Inspection Badge (using Transform & Align)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Transform.rotate(
                      angle: -0.06,
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
                              '360° 8-PHOTO SCRUBBER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: AppColors.parchment,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Top Right: Loupe Zoom Toggle + Auto-Rotate Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: _isLoupeZoomMode
                              ? AppColors.gold
                              : Colors.black54,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(
                              Icons.zoom_in,
                              color: _isLoupeZoomMode
                                  ? AppColors.dungeon
                                  : AppColors.gold,
                              size: 20,
                            ),
                            tooltip: 'Toggle 3x Paint Loupe Zoom',
                            onPressed: () {
                              setState(() {
                                _isLoupeZoomMode = !_isLoupeZoomMode;
                                if (_isLoupeZoomMode && _isAutoRotating) {
                                  _isAutoRotating = false;
                                  _autoRotateController.stop();
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(
                              _isAutoRotating
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_outline,
                              color: AppColors.gold,
                              size: 22,
                            ),
                            tooltip: _isAutoRotating
                                ? 'Pause Rotation'
                                : 'Auto 360° Spin',
                            onPressed: _toggleAutoRotate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Overlay: Frame Indicator & Angle Dots
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldFaded),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLoupeZoomMode ? Icons.pinch : Icons.swipe,
                          color: AppColors.gold,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isLoupeZoomMode
                              ? 'Pinch to zoom paint job'
                              : 'Swipe horizontally',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.parchmentFaded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(total, (i) {
                            final isActive = i == _currentIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2.5,
                              ),
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
          ),

          // Paint Recipe & Angle Scrubber Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.dungeon.withValues(alpha: 0.85),
              border: const Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.brush, size: 14, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'PAINT INSPECTOR: $angleNote',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Angle 1',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedText,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                        ),
                        child: Slider(
                          value: _currentIndex.toDouble(),
                          min: 0,
                          max: (total - 1).toDouble(),
                          divisions: total > 1 ? total - 1 : 1,
                          activeColor: AppColors.gold,
                          inactiveColor: Colors.white12,
                          onChanged: (val) {
                            if (_isAutoRotating) {
                              _autoRotateController.stop();
                              _isAutoRotating = false;
                            }
                            setState(() => _currentIndex = val.round());
                          },
                        ),
                      ),
                    ),
                    Text(
                      'Angle $total',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // 8 Quick Angle Preset Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(total, (i) {
                      final isSelected = i == _currentIndex;
                      final degrees = i * 45;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text('$degrees°'),
                          selected: isSelected,
                          selectedColor: AppColors.gold,
                          backgroundColor: AppColors.stone,
                          visualDensity: VisualDensity.compact,
                          labelStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.dungeon
                                : AppColors.parchment,
                          ),
                          onSelected: (_) {
                            if (_isAutoRotating) {
                              _autoRotateController.stop();
                              _isAutoRotating = false;
                            }
                            setState(() => _currentIndex = i);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
