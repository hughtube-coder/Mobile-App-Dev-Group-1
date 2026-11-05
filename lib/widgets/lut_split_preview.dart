import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dart/Flutter Edge Feature:
/// Interactive split-screen slider using Flutter's [ColorFiltered] widget.
/// Allows creators and buyers to preview LUT and Lightroom filter effects
/// by dragging a vertical divider across the image before purchasing.
class LutSplitPreview extends StatefulWidget {
  final String imageUrl;

  const LutSplitPreview({super.key, required this.imageUrl});

  @override
  State<LutSplitPreview> createState() => _LutSplitPreviewState();
}

class _LutSplitPreviewState extends State<LutSplitPreview> {
  // Divider split position: 0.0 (all raw) to 1.0 (all filtered)
  double _splitFraction = 0.5;

  int _selectedPresetIndex = 0;

  static const List<_LutPreset> _presets = [
    _LutPreset(
      name: 'Warm Hearth Amber',
      description: 'Golden hour candle glow & warm tabletop miniatures look',
      filter: ColorFilter.matrix(<double>[
        1.25,
        0.0,
        0.0,
        0.0,
        20.0,
        0.0,
        1.10,
        0.0,
        0.0,
        10.0,
        0.0,
        0.0,
        0.85,
        0.0,
        -15.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
      ]),
    ),
    _LutPreset(
      name: 'Nordic Frost Cyan',
      description:
          'Cool glacial shadows with high-contrast icy magical weapons',
      filter: ColorFilter.matrix(<double>[
        0.90,
        0.0,
        0.0,
        0.0,
        -10.0,
        0.0,
        1.15,
        0.0,
        0.0,
        15.0,
        0.0,
        0.0,
        1.35,
        0.0,
        30.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
      ]),
    ),
    _LutPreset(
      name: 'Grimdark Monochrome',
      description: 'High dynamic range desaturated dramatic battle grimdark',
      filter: ColorFilter.matrix(<double>[
        0.35,
        0.35,
        0.35,
        0.0,
        5.0,
        0.35,
        0.35,
        0.35,
        0.0,
        5.0,
        0.35,
        0.35,
        0.35,
        0.0,
        5.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
      ]),
    ),
    _LutPreset(
      name: 'Dragon Fire Ruby',
      description: 'Intense crimson saturation for lava bases & fire spells',
      filter: ColorFilter.matrix(<double>[
        1.45,
        0.0,
        0.0,
        0.0,
        25.0,
        0.0,
        0.90,
        0.0,
        0.0,
        -10.0,
        0.0,
        0.0,
        0.85,
        0.0,
        -15.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
      ]),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activePreset = _presets[_selectedPresetIndex];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldFaded, width: 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'INTERACTIVE LUT PRESET TESTER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: AppColors.gold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.dragonRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ColorFiltered',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Drag the vertical divider horizontally to compare RAW photo vs applied LUT filter:',
            style: TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 12),

          // Split Screen Container
          SizedBox(
            height: 280,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final splitX = width * _splitFraction;

                  return GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _splitFraction = (details.localPosition.dx / width)
                            .clamp(0.02, 0.98);
                      });
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Left / Background Layer: RAW Unfiltered Image
                        Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: AppColors.dungeon),
                        ),

                        // Right Layer: ColorFiltered with custom LUT Matrix
                        ClipRect(
                          clipper: _RightSideClipper(splitX: splitX),
                          child: ColorFiltered(
                            colorFilter: activePreset.filter,
                            child: Image.network(
                              widget.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: AppColors.dungeon),
                            ),
                          ),
                        ),

                        // Left Badge: RAW
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Text(
                              'BEFORE (RAW)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Right Badge: LUT FILTERED
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AFTER (LUT FILTER)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dungeon,
                              ),
                            ),
                          ),
                        ),

                        // Draggable Split Divider Line & Handle
                        Positioned(
                          left: splitX - 1.5,
                          top: 0,
                          bottom: 0,
                          child: Container(width: 3, color: AppColors.gold),
                        ),

                        // Divider Handle Thumb
                        Positioned(
                          left: splitX - 16,
                          top: 124,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.compare_arrows,
                              size: 18,
                              color: AppColors.dungeon,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Preset Selection Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presets.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final preset = _presets[index];
                final isSelected = index == _selectedPresetIndex;

                return ChoiceChip(
                  label: Text(preset.name),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedPresetIndex = index),
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.dungeon,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? AppColors.dungeon : AppColors.parchment,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.gold : AppColors.goldFaded,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            activePreset.description,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.mutedText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _LutPreset {
  final String name;
  final String description;
  final ColorFilter filter;

  const _LutPreset({
    required this.name,
    required this.description,
    required this.filter,
  });
}

class _RightSideClipper extends CustomClipper<Rect> {
  final double splitX;

  _RightSideClipper({required this.splitX});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(splitX, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant _RightSideClipper oldClipper) {
    return oldClipper.splitX != splitX;
  }
}
