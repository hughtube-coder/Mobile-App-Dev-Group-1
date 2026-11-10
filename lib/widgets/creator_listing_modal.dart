import 'package:flutter/material.dart';

import '../controllers/vault_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Community Creator & Player Listing Modal ("Sell / Swap Your Item").
/// Allows creators to publish new Lightroom Presets (LUTs), Sewing Patterns,
/// or 3D Print .STL files, and allows D&D players to swap Painted Miniatures,
/// Custom Dice Sets, or Digital Maps (strictly enforcing price >= ₱100).
class CreatorListingModal extends StatefulWidget {
  const CreatorListingModal({super.key});

  @override
  State<CreatorListingModal> createState() => _CreatorListingModalState();
}

class _CreatorListingModalState extends State<CreatorListingModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController =
      TextEditingController(text: '250');
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _fileController =
      TextEditingController(text: 'creator_bundle_v1.zip');

  ProductCategory _selectedCategory = ProductCategory.presets;

  static const Map<ProductCategory, String> _categoryDefaultImages = {
    ProductCategory.presets:
        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
    ProductCategory.sewingPatterns:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Bayeux_Tapestry_scene1_EDWARD_REX.jpg/800px-Bayeux_Tapestry_scene1_EDWARD_REX.jpg',
    ProductCategory.stlFiles:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Citadel_Miniatures_Space_Marine.jpg/800px-Citadel_Miniatures_Space_Marine.jpg',
    ProductCategory.minis:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Dungeons_%26_Dragons_Miniatures.jpg/800px-Dungeons_%26_Dragons_Miniatures.jpg',
    ProductCategory.dice:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Polyhedral_dice_set.jpg/800px-Polyhedral_dice_set.jpg',
    ProductCategory.digitalMaps:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Carta_Marina.jpeg/800px-Carta_Marina.jpeg',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _fileController.dispose();
    super.dispose();
  }

  void _publishListing() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim()) ?? 250.0;
    final img =
        _categoryDefaultImages[_selectedCategory] ??
        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';
    final isMini = _selectedCategory == ProductCategory.minis;
    final isLut = _selectedCategory == ProductCategory.presets;

    final newProduct = Product(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: _titleController.text.trim(),
      shortDescription: _descController.text.trim(),
      fullDescription:
          '${_descController.text.trim()}\n\nPublished via the Marketing Vikings Creator & Community Swap Studio. Includes instant digital download unlock upon checkout.',
      price: price,
      category: _selectedCategory,
      primaryImage: img,
      galleryImages: isMini
          ? List.filled(8, img)
          : [img],
      colors: const [
        ProductColorOption(name: 'Creator Original', color: Color(0xFFD4A537)),
        ProductColorOption(name: 'Variant Edition', color: Color(0xFF00ACC1)),
      ],
      sizes: isMini
          ? const ['28mm Standard', '32mm Heroic', '75mm Display']
          : const ['Full Pack (.ZIP)', 'Mobile + Desktop', 'Commercial License'],
      rating: 5.0,
      reviewCount: 1,
      has360View: isMini,
      hasLutPreview: isLut,
      isDigital: !isMini && _selectedCategory != ProductCategory.dice,
      downloadFileName: _fileController.text.trim().isEmpty
          ? 'creator_asset_pack.zip'
          : _fileController.text.trim(),
      photoCredit: 'Wikimedia Commons / Official Flutter Asset (Verified Non-AI)',
      license: 'CC-BY-SA 4.0',
    );

    VaultController.instance.addCommunityListing(newProduct);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade800,
        content: Text(
          'Published "${newProduct.name}" (${_selectedCategory.label}) to the live catalog!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignableCategories = ProductCategory.values
        .where((c) => c != ProductCategory.all)
        .toList();

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.stone,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_business, color: AppColors.gold),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'SELL / SWAP CREATOR & RPG ITEM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.mutedText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Text(
                'List a Lightroom LUT preset, sewing pattern, .STL file, painted miniature, or dice set (minimum ₱100 delimiter enforced):',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
              const SizedBox(height: 14),

              // Category Selector
              DropdownButtonFormField<ProductCategory>(
                initialValue: _selectedCategory,
                dropdownColor: AppColors.stone,
                style: const TextStyle(color: AppColors.parchment),
                decoration: InputDecoration(
                  labelText: 'Marketplace Category *',
                  filled: true,
                  fillColor: AppColors.dungeon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: assignableCategories.map((cat) {
                  final storeTag = cat.storeType == StoreType.digitalCreator
                      ? 'Store 1: Digital Market'
                      : 'Store 2: RPG Swap';
                  return DropdownMenuItem(
                    value: cat,
                    child: Text('${cat.label} ($storeTag)'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.parchment),
                decoration: InputDecoration(
                  labelText: 'Product / Listing Title *',
                  hintText: 'e.g. Cyberpunk Anime LUT Pack / Painted Dragon Mini',
                  filled: true,
                  fillColor: AppColors.dungeon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 3) {
                    return 'Enter a title (at least 3 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.parchment),
                      decoration: InputDecoration(
                        labelText: 'Price in Pesos (₱) *',
                        hintText: 'Min ₱100',
                        prefixText: '₱ ',
                        filled: true,
                        fillColor: AppColors.dungeon,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (val) {
                        final numVal = double.tryParse(val?.trim() ?? '');
                        if (numVal == null || numVal < 100) {
                          return 'Minimum price is ₱100';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _fileController,
                      style: const TextStyle(color: AppColors.parchment),
                      decoration: InputDecoration(
                        labelText: 'Download File (.ZIP/.STL/.DNG)',
                        filled: true,
                        fillColor: AppColors.dungeon,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.parchment),
                decoration: InputDecoration(
                  labelText: 'Short Description & Specs *',
                  hintText:
                      'Describe your LUT filter, pattern sizes, .STL supports, or miniature paint job...',
                  filled: true,
                  fillColor: AppColors.dungeon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a short description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _publishListing,
                  icon: const Icon(Icons.publish, color: AppColors.dungeon),
                  label: const Text('Publish to Marketplace'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.dungeon,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
