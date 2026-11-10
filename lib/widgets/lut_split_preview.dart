import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'product_photo.dart';

/// Dart/Flutter Edge Feature (Digital Pattern & LUT Tester Market):
/// Interactive split-screen slider using Flutter's [ColorFiltered] widget.
/// Allows creators and buyers to preview the seller's LUT/Lightroom filter effects
/// on sample phone camera photos or their own custom photo before purchasing,
/// complete with real-time Intensity & Exposure sliders and an Auto-Sweep demo mode!
class LutSplitPreview extends StatefulWidget {
  final String imageUrl;

  const LutSplitPreview({super.key, required this.imageUrl});

  @override
  State<LutSplitPreview> createState() => _LutSplitPreviewState();
}

class _LutSplitPreviewState extends State<LutSplitPreview>
    with SingleTickerProviderStateMixin {
  // Divider split position: 0.0 (all raw) to 1.0 (all filtered)
  double _splitFraction = 0.5;

  int _selectedPresetIndex = 0;
  int _selectedPhonePhotoIndex = 0;
  String? _customPhonePhotoUrl;

  // Fine-tuning controls: LUT Strength (0.2..1.0) & Exposure Offset (-25..+25)
  double _filterIntensity = 1.0;
  double _exposureOffset = 0.0;
  bool _isAutoSweeping = false;
  late final AnimationController _sweepController;

  static const List<double> _identityMatrix = <double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const List<_SamplePhonePhoto> _phonePhotos = [
    _SamplePhonePhoto(
      label: 'Seller Sample',
      icon: Icons.photo_camera_back,
      url: '', // Uses widget.imageUrl
    ),
    _SamplePhonePhoto(
      label: '📱 Phone: Studio Portrait',
      icon: Icons.smartphone,
      url: 'assets/images/lut_01.jpg',
    ),
    _SamplePhonePhoto(
      label: '📱 Phone: Tavern Mini',
      icon: Icons.smartphone,
      url: 'assets/images/mini_01.jpg',
    ),
    _SamplePhonePhoto(
      label: '📱 Phone: Amber Warmth',
      icon: Icons.smartphone,
      url: 'assets/images/lut_02.jpg',
    ),
    _SamplePhonePhoto(
      label: '📱 Phone: Dice Macro',
      icon: Icons.smartphone,
      url: 'assets/images/dice_01.jpg',
    ),
    _SamplePhonePhoto(
      label: '📱 Phone: Linen Texture',
      icon: Icons.smartphone,
      url: 'assets/images/pattern_01.jpg',
    ),
    _SamplePhonePhoto(
      label: '📱 Phone: Ancient Map',
      icon: Icons.smartphone,
      url: 'assets/images/map_01.jpg',
    ),
  ];

  static const List<_LutPreset> _presets = [
    _LutPreset(
      name: 'Warm Hearth Amber',
      description: 'Golden hour candle glow & warm cinematic skin/portrait tones',
      matrix: <double>[
        1.25, 0.0, 0.0, 0.0, 20.0,
        0.0, 1.10, 0.0, 0.0, 10.0,
        0.0, 0.0, 0.85, 0.0, -15.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    _LutPreset(
      name: 'Nordic Frost Cyan',
      description: 'Cool glacial shadows with crisp teal & orange highlights',
      matrix: <double>[
        0.90, 0.0, 0.0, 0.0, -10.0,
        0.0, 1.15, 0.0, 0.0, 15.0,
        0.0, 0.0, 1.35, 0.0, 30.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    _LutPreset(
      name: 'Grimdark Monochrome',
      description: 'High dynamic range desaturated silver-gelatin film grain look',
      matrix: <double>[
        0.35, 0.35, 0.35, 0.0, 5.0,
        0.35, 0.35, 0.35, 0.0, 5.0,
        0.35, 0.35, 0.35, 0.0, 5.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    _LutPreset(
      name: 'Dragon Fire Ruby',
      description: 'Intense crimson saturation for vibrant sunset & neon shots',
      matrix: <double>[
        1.45, 0.0, 0.0, 0.0, 25.0,
        0.0, 0.90, 0.0, 0.0, -10.0,
        0.0, 0.0, 0.85, 0.0, -15.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    _LutPreset(
      name: 'Cyberpunk Gold',
      description: 'Vibrant magenta-gold contrast boost for night city photography',
      matrix: <double>[
        1.30, 0.05, 0.0, 0.0, 18.0,
        0.0, 1.05, 0.0, 0.0, 5.0,
        0.05, 0.0, 1.25, 0.0, 20.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    _LutPreset(
      name: 'Kodak 400 Vintage',
      description: 'Soft analog film fade with lifted matte shadows & warm greens',
      matrix: <double>[
        1.12, 0.04, 0.0, 0.0, 14.0,
        0.02, 1.12, 0.02, 0.0, 12.0,
        0.0, 0.04, 0.95, 0.0, 8.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..addListener(() {
        if (_isAutoSweeping) {
          setState(() {
            _splitFraction = 0.12 + (_sweepController.value * 0.76);
          });
        }
      });
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  void _toggleAutoSweep() {
    setState(() {
      _isAutoSweeping = !_isAutoSweeping;
      if (_isAutoSweeping) {
        _sweepController.repeat(reverse: true);
      } else {
        _sweepController.stop();
      }
    });
  }

  ColorFilter _buildBlendedFilter(List<double> targetMatrix) {
    final blended = List<double>.generate(20, (i) {
      final base = _identityMatrix[i];
      final target = targetMatrix[i];
      double val = base + (target - base) * _filterIntensity;
      // Apply exposure boost to RGB translation columns (indices 4, 9, 14)
      if (i == 4 || i == 9 || i == 14) {
        val += _exposureOffset;
      }
      return val;
    });
    return ColorFilter.matrix(blended);
  }

  String get _activePhotoUrl {
    if (_customPhonePhotoUrl != null && _customPhonePhotoUrl!.isNotEmpty) {
      return _customPhonePhotoUrl!;
    }
    final chosen = _phonePhotos[_selectedPhonePhotoIndex];
    return chosen.url.isEmpty ? widget.imageUrl : chosen.url;
  }

  void _promptCustomPhonePhoto() {
    final controller = TextEditingController(text: _customPhonePhotoUrl ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.stone,
        title: const Row(
          children: [
            Icon(Icons.add_photo_alternate, color: AppColors.gold),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Test LUT on Your Phone Photo',
                style: TextStyle(color: AppColors.parchment, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste any photo URL or select a camera roll preset to preview this seller\'s ColorFiltered LUT before buying:',
              style: TextStyle(color: AppColors.parchmentFaded, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.parchment, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'https://...',
                hintStyle: const TextStyle(color: AppColors.mutedText),
                filled: true,
                fillColor: AppColors.dungeon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _customPhonePhotoUrl = null);
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Reset to Default',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _customPhonePhotoUrl = controller.text.trim();
              });
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.dungeon,
            ),
            child: const Text('Apply Photo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePreset = _presets[_selectedPresetIndex];
    final currentImageUrl = _activePhotoUrl;
    final activeFilter = _buildBlendedFilter(activePreset.matrix);

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
                  'INTERACTIVE LUT PRESET TESTER STUDIO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    color: AppColors.gold,
                  ),
                ),
              ),
              // Auto-Sweep Toggle Button
              InkWell(
                onTap: _toggleAutoSweep,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _isAutoSweeping
                        ? AppColors.gold
                        : AppColors.dungeon,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.gold),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isAutoSweeping ? Icons.pause : Icons.play_arrow,
                        size: 13,
                        color: _isAutoSweeping
                            ? AppColors.dungeon
                            : AppColors.gold,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _isAutoSweeping ? 'Sweeping' : 'Auto Sweep',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _isAutoSweeping
                              ? AppColors.dungeon
                              : AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            'Drag the vertical split-screen slider to preview the seller\'s LUT filter on phone photos before purchasing:',
            style: TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 10),

          // Phone Photo Switcher Row ("Preview on Buyer's Phone Photos")
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _phonePhotos.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == _phonePhotos.length) {
                  final hasCustom =
                      _customPhonePhotoUrl != null &&
                      _customPhonePhotoUrl!.isNotEmpty;
                  return ActionChip(
                    avatar: Icon(
                      Icons.add_a_photo,
                      size: 14,
                      color: hasCustom ? AppColors.dungeon : AppColors.gold,
                    ),
                    label: Text(
                      hasCustom ? 'Custom Phone Photo ✓' : '+ My Phone Photo',
                    ),
                    backgroundColor: hasCustom
                        ? AppColors.gold
                        : AppColors.dungeon,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: hasCustom
                          ? AppColors.dungeon
                          : AppColors.parchment,
                    ),
                    side: const BorderSide(color: AppColors.goldFaded),
                    onPressed: _promptCustomPhonePhoto,
                  );
                }

                final photo = _phonePhotos[index];
                final isSelected =
                    _customPhonePhotoUrl == null &&
                    index == _selectedPhonePhotoIndex;

                return ChoiceChip(
                  label: Text(photo.label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _customPhonePhotoUrl = null;
                      _selectedPhonePhotoIndex = index;
                    });
                  },
                  selectedColor: AppColors.gold.withValues(alpha: 0.25),
                  backgroundColor: AppColors.dungeon,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? AppColors.gold : AppColors.parchment,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.gold : Colors.white12,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

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
                      if (_isAutoSweeping) {
                        _sweepController.stop();
                        _isAutoSweeping = false;
                      }
                      setState(() {
                        _splitFraction = (details.localPosition.dx / width)
                            .clamp(0.02, 0.98);
                      });
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Left / Background Layer: RAW Unfiltered Image
                        ProductPhoto(
                          imageSource: currentImageUrl,
                          fit: BoxFit.cover,
                        ),

                        // Right Layer: ColorFiltered with custom LUT Matrix + live intensity/exposure
                        ClipRect(
                          clipper: _RightSideClipper(splitX: splitX),
                          child: ColorFiltered(
                            colorFilter: activeFilter,
                            child: ProductPhoto(
                              imageSource: currentImageUrl,
                              fit: BoxFit.cover,
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
                              'BEFORE (RAW PHOTO)',
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
                            child: Text(
                              'AFTER (${(_filterIntensity * 100).round()}% LUT)',
                              style: const TextStyle(
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
          const SizedBox(height: 10),

          // Live LUT Intensity & Exposure Tuning Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.dungeon.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.opacity, size: 14, color: AppColors.gold),
                    const SizedBox(width: 6),
                    const SizedBox(
                      width: 78,
                      child: Text(
                        'LUT Strength',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.parchment,
                        ),
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
                          value: _filterIntensity,
                          min: 0.2,
                          max: 1.0,
                          activeColor: AppColors.gold,
                          inactiveColor: Colors.white12,
                          onChanged: (v) =>
                              setState(() => _filterIntensity = v),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${(_filterIntensity * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.wb_sunny_outlined,
                      size: 14,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 6),
                    const SizedBox(
                      width: 78,
                      child: Text(
                        'Exposure EV',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.parchment,
                        ),
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
                          value: _exposureOffset,
                          min: -25.0,
                          max: 25.0,
                          activeColor: AppColors.gold,
                          inactiveColor: Colors.white12,
                          onChanged: (v) =>
                              setState(() => _exposureOffset = v),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${_exposureOffset >= 0 ? '+' : ''}${_exposureOffset.round()}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SamplePhonePhoto {
  final String label;
  final IconData icon;
  final String url;

  const _SamplePhonePhoto({
    required this.label,
    required this.icon,
    required this.url,
  });
}

class _LutPreset {
  final String name;
  final String description;
  final List<double> matrix;

  const _LutPreset({
    required this.name,
    required this.description,
    required this.matrix,
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
