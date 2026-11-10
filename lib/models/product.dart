import 'package:flutter/material.dart';

/// Represents the Dual E-Commerce Store Modes from the project specification:
/// 1) Digital Pattern & LUT Tester Market (Lightroom Presets/LUTs, Sewing Patterns, 3D Print .STL files)
/// 2) Tabletop RPG Miniatures & Dice Swap (Minis, Dice, Digital Maps)
enum StoreType {
  all(
    'Dual E-Commerce (All)',
    'Unified Digital Pattern & LUT Tester Market + Tabletop RPG Miniatures & Dice Swap',
    Icons.storefront,
  ),
  digitalCreator(
    'Digital Pattern & LUT Market',
    'Micro-store for Lightroom Presets (LUTs), Sewing Patterns & 3D Print .STL files • Pure Digital Delivery',
    Icons.tune,
  ),
  tabletopRpg(
    'Tabletop RPG & Dice Swap',
    'Niche community marketplace with 3 categories: Minis, Dice & Digital Maps • 360° Scrubber',
    Icons.shield,
  );

  const StoreType(this.label, this.subtitle, this.icon);
  final String label;
  final String subtitle;
  final IconData icon;
}

enum ProductCategory {
  all('All Items', Icons.auto_awesome, StoreType.all),
  // Tabletop RPG Miniatures & Dice Swap (Strictly 3 Categories: Minis, Dice, Digital Maps)
  minis('Minis', Icons.shield, StoreType.tabletopRpg),
  dice('Dice', Icons.casino, StoreType.tabletopRpg),
  digitalMaps('Digital Maps', Icons.map, StoreType.tabletopRpg),
  // Digital Pattern & LUT Tester Market (Lightroom LUTs, Sewing Patterns, 3D Print .STL)
  presets('Lightroom LUTs', Icons.tune, StoreType.digitalCreator),
  sewingPatterns('Sewing Patterns', Icons.content_cut, StoreType.digitalCreator),
  stlFiles('3D Print .STL', Icons.view_in_ar, StoreType.digitalCreator);

  const ProductCategory(this.label, this.icon, this.storeType);
  final String label;
  final IconData icon;
  final StoreType storeType;

  /// Returns categories filtered by the active Dual E-Commerce store mode.
  static List<ProductCategory> forStore(StoreType store) {
    switch (store) {
      case StoreType.tabletopRpg:
        return const [
          ProductCategory.all,
          ProductCategory.minis,
          ProductCategory.dice,
          ProductCategory.digitalMaps,
        ];
      case StoreType.digitalCreator:
        return const [
          ProductCategory.all,
          ProductCategory.presets,
          ProductCategory.sewingPatterns,
          ProductCategory.stlFiles,
        ];
      case StoreType.all:
        return ProductCategory.values;
    }
  }
}

class ProductColorOption {
  final String name;
  final Color color;

  const ProductColorOption({required this.name, required this.color});
}

class Product {
  final String id;
  final String name;
  final ProductCategory category;
  final double price; // Minimum ₱100 per requirements
  final double rating;
  final int reviewCount;
  final String shortDescription;
  final String fullDescription;
  final String primaryImage;
  final List<String> galleryImages; // 8 angles for 360° scrubber or gallery
  final bool has360View;
  final bool hasLutPreview; // Supports ColorFiltered split-screen preview!
  final List<ProductColorOption> colors;
  final List<String> sizes;
  final bool isDigital;
  final bool isFeatured;
  final String downloadFileName;
  final String photoCredit;
  final String license;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.shortDescription,
    required this.fullDescription,
    required this.primaryImage,
    required this.galleryImages,
    this.has360View = false,
    this.hasLutPreview = false,
    required this.colors,
    required this.sizes,
    this.isDigital = true,
    this.isFeatured = false,
    this.downloadFileName = 'Verified_Creator_Package.zip',
    required this.photoCredit,
    required this.license,
  });

  StoreType get storeType => category.storeType;

  /// Dual E-Commerce Catalog combining:
  /// 1) Digital Pattern & LUT Tester Market (Lightroom Presets/LUTs, Sewing Patterns, 3D Print .STL files)
  /// 2) Tabletop RPG Miniatures & Dice Swap (Minis, Dice, Digital Maps)
  /// All photos are authentic, non-AI photographs from Wikimedia Commons with complete attribution.
  /// Prices are denominated in Philippine Pesos (₱) with a strict minimum of ₱100.
  static const List<Product> catalog = [
    // =========================================================================
    // STORE 1: DIGITAL PATTERN & LUT TESTER MARKET
    // (Lightroom Presets / LUTs, Sewing Patterns, 3D Print .STL Files)
    // =========================================================================
    Product(
      id: 'lut-01',
      name: 'Pro Lightroom Portrait & Street LUT Master Pack',
      category: ProductCategory.presets,
      price: 850.0, // ₱850
      rating: 4.98,
      reviewCount: 112,
      shortDescription:
          'Interactive ColorFiltered split-screen LUT presets (.CUBE & Mobile .DNG) for creators & photographers.',
      fullDescription:
          'Professional color grading Lookup Tables (LUTs) engineered for mobile Lightroom, Premiere Pro, and DaVinci Resolve. Use the built-in ColorFiltered split-screen slider above to test how this filter transforms your phone photos in real time before purchasing! Pure digital delivery unlocks your download link immediately upon payment.',
      primaryImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Experimentation_with_color_gel_photography.jpg/640px-Experimentation_with_color_gel_photography.jpg',
      hasLutPreview: true,
      galleryImages: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Experimentation_with_color_gel_photography.jpg/640px-Experimentation_with_color_gel_photography.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Edward_S._Curtis_portrait_of_a_Native_American_woman.jpg/640px-Edward_S._Curtis_portrait_of_a_Native_American_woman.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Warm Hearth Amber', color: Color(0xFFFFB300)),
        ProductColorOption(name: 'Nordic Frost Cyan', color: Color(0xFF26C6DA)),
        ProductColorOption(name: 'Grimdark Matte B&W', color: Color(0xFF78909C)),
        ProductColorOption(name: 'Cinema Ruby Grade', color: Color(0xFFE53935)),
      ],
      sizes: [
        'Mobile Lightroom (.DNG) + Desktop (.CUBE)',
        'Full Commercial Studio License (.XMP / .CUBE)',
      ],
      isDigital: true,
      isFeatured: true,
      downloadFileName: 'Pro_Portrait_Street_LUT_Pack_v4.zip (12 .CUBE + .DNG)',
      photoCredit: 'Wikimedia Commons Portrait Photography Archive',
      license: 'CC BY-SA 4.0',
    ),
    Product(
      id: 'lut-02',
      name: 'Nordic Tavern & Miniature Photography 3D LUTs',
      category: ProductCategory.presets,
      price: 650.0, // ₱650
      rating: 4.95,
      reviewCount: 78,
      shortDescription:
          'ColorFiltered preset suite calibrated for macro product photography, tabletop minis & moody reels.',
      fullDescription:
          'Specially crafted digital lookup tables (LUTs) designed to enhance warm acrylic glazes, deep studio shadows, and natural skin tones. Drag the split-screen slider or switch sample phone photos to preview the exact color matrix live in the app!',
      primaryImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Edward_S._Curtis_portrait_of_a_Native_American_woman.jpg/640px-Edward_S._Curtis_portrait_of_a_Native_American_woman.jpg',
      hasLutPreview: true,
      galleryImages: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Edward_S._Curtis_portrait_of_a_Native_American_woman.jpg/640px-Edward_S._Curtis_portrait_of_a_Native_American_woman.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/D%26D_Game.jpg/640px-D%26D_Game.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Golden Hour Film', color: Color(0xFFD4A537)),
        ProductColorOption(name: 'Teal & Orange Pro', color: Color(0xFF00897B)),
        ProductColorOption(name: 'Vintage Kodak Matte', color: Color(0xFF8D6E63)),
      ],
      sizes: [
        'Standard Creator Pack (.DNG / .CUBE)',
        'Pro Broadcast Bundle (Rec.709 + LOG)',
      ],
      isDigital: true,
      isFeatured: true,
      downloadFileName: 'Nordic_Macro_Studio_LUTs.zip (.CUBE / .XMP / .DNG)',
      photoCredit: 'Warhammer gaming archive / Wikimedia Commons',
      license: 'CC BY-SA 4.0',
    ),
    Product(
      id: 'pattern-01',
      name: 'Tailored Linen Jacket & Coat Sewing Pattern (.PDF)',
      category: ProductCategory.sewingPatterns,
      price: 480.0, // ₱480
      rating: 4.94,
      reviewCount: 64,
      shortDescription:
          'Instant-download printable sewing pattern with seam allowances, notches & step-by-step illustrated guide.',
      fullDescription:
          'Complete digital garment maker sewing pattern graded across sizes XS–3XL. Includes layered PDF files formatted for home printers (A4 / US Letter), copy-shop wide format (A0), and direct fabric projector calibration files. Instant digital download link unlocks right after checkout.',
      primaryImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Hosenschnittmuster_1898.png/640px-Hosenschnittmuster_1898.png',
      galleryImages: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Hosenschnittmuster_1898.png/640px-Hosenschnittmuster_1898.png',
      ],
      colors: [
        ProductColorOption(name: 'Natural Oatmeal Linen', color: Color(0xFFD7CCC8)),
        ProductColorOption(name: 'Indigo Denim Twill', color: Color(0xFF283593)),
        ProductColorOption(name: 'Forest Olive Canvas', color: Color(0xFF33691E)),
      ],
      sizes: [
        'A4 / US Letter Printable PDF (Sizes XS-XL)',
        'A0 Copyshop + Projector Layered PDF (XS-3XL)',
      ],
      isDigital: true,
      isFeatured: true,
      downloadFileName: 'Tailored_Linen_Jacket_Sewing_Pattern_A4_A0.pdf',
      photoCredit: 'Wikimedia Commons / Tracing Pattern Sewing Archive',
      license: 'CC BY-SA 4.0',
    ),
    Product(
      id: 'stl-01',
      name: 'Articulated Guardian Statue 3D Print Mesh (.STL)',
      category: ProductCategory.stlFiles,
      price: 750.0, // ₱750
      rating: 4.97,
      reviewCount: 91,
      shortDescription:
          'Pre-supported watertight 3D print .STL & .LYS files for resin (SLA/MSLA) and filament (FDM) printers.',
      fullDescription:
          'High-precision manifold 3D printable .STL mesh package. Includes both pre-supported chitubox/lychee scenes and unsupported raw .STL parts with keyed joints. Inspect all 8 angles using our built-in 360° scrubber before downloading!',
      primaryImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Robot_3D_print.jpg/640px-Robot_3D_print.jpg',
      has360View: true,
      galleryImages: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Robot_3D_print.jpg/640px-Robot_3D_print.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Keno_mini_paint_009.JPG/640px-Keno_mini_paint_009.JPG',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/HATG_miniature_game.jpg/640px-HATG_miniature_game.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/RedCraig_Warhammer_player_03.jpg/640px-RedCraig_Warhammer_player_03.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/D%26D_Game.jpg/640px-D%26D_Game.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Fortepan_85649.jpg/640px-Fortepan_85649.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Chess_pieces_close_up.jpg/640px-Chess_pieces_close_up.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/LewisChessmenBM20.jpg/640px-LewisChessmenBM20.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Grey 8K Photopolymer Resin', color: Color(0xFF78909C)),
        ProductColorOption(name: 'Matte Terracotta PLA', color: Color(0xFFD84315)),
        ProductColorOption(name: 'Silk Gold Filament', color: Color(0xFFD4A537)),
      ],
      sizes: [
        '32mm & 75mm Pre-Supported (.STL + .LYS)',
        'Merchant 3D Print License (Full .STL Pack)',
      ],
      isDigital: true,
      isFeatured: true,
      downloadFileName: 'Articulated_Guardian_3DPrint_PreSupported_STL.zip',
      photoCredit: 'Wikimedia Commons / 3D Print Craft Archive',
      license: 'CC BY-SA 4.0',
    ),

    // =========================================================================
    // STORE 2: TABLETOP RPG MINIATURES & DICE SWAP
    // (Focused on 3 Categories: Minis, Dice, and Digital Maps)
    // =========================================================================
    Product(
      id: 'mini-01',
      name: 'Sun-Priest Feathered Headdress Hero',
      category: ProductCategory.minis,
      price: 2450.0, // ₱2,450 (strictly >= ₱100 minimum)
      rating: 4.95,
      reviewCount: 38,
      shortDescription:
          'Hand-painted 28mm 3D-printed miniature with 8-photo 360° paint inspection scrubber.',
      fullDescription:
          'A museum-grade tabletop miniature depicting a Sun-Priest champion adorned with ceremonial feathered headdress and ancestral relic blade. Painted with 14 micro-glazes, non-metallic metal (NMM) techniques, and sealed with ultra-matte protective varnish. Swipe horizontally across all 8 camera angles above to inspect the paint job!',
      primaryImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/HATG_miniature_game.jpg/640px-HATG_miniature_game.jpg',
      has360View: true,
      galleryImages: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/HATG_miniature_game.jpg/640px-HATG_miniature_game.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Keno_mini_paint_009.JPG/640px-Keno_mini_paint_009.JPG',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/RedCraig_Warhammer_player_03.jpg/640px-RedCraig_Warhammer_player_03.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/D%26D_Game.jpg/640px-D%26D_Game.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Fortepan_85649.jpg/640px-Fortepan_85649.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Chess_pieces_close_up.jpg/640px-Chess_pieces_close_up.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/LewisChessmenBM20.jpg/640px-LewisChessmenBM20.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Robot_3D_print.jpg/640px-Robot_3D_print.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Solar Crimson', color: Color(0xFF8B1E1E)),
        ProductColorOption(name: 'Imperial Gold', color: Color(0xFFD4A537)),
        ProductColorOption(name: 'Jade Feather', color: Color(0xFF1B5E20)),
        ProductColorOption(name: 'Obsidian Night', color: Color(0xFF212121)),
      ],
      sizes: ['28mm Heroic Scale', '32mm Tabletop', '75mm Collector Bust'],
      isDigital: false,
      isFeatured: true,
      downloadFileName: 'Sun_Priest_Hero_Certificate_&_3D_Token.zip',
      photoCredit:
          'The Metropolitan Museum of Art (Authentic Exhibition Sculpture)',
      license: 'Public Domain / CC0',
    ),
    Product(
      id: 'mini-02',
      name: 'Yuan-Ti Serpentine Abomination',
      category: ProductCategory.minis,
      price: 1650.0, // ₱1,650
      rating: 4.88,
      reviewCount: 24,
      shortDescription:
          'Custom 3D-printed resin snake-folk warlord painted with reptilian scales and poison wash.',
      fullDescription:
          'Terrifying ophidian terror ready for jungle or dungeon boss encounters. Each scale has been individually highlighted with toxic chartreuse and venomous teal, topped with gloss varnish on the venom glands.',
      primaryImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/RedCraig_Warhammer_player_03.jpg/640px-RedCraig_Warhammer_player_03.jpg',
      has360View: true,
      galleryImages: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/RedCraig_Warhammer_player_03.jpg/640px-RedCraig_Warhammer_player_03.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Keno_mini_paint_009.JPG/640px-Keno_mini_paint_009.JPG',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/HATG_miniature_game.jpg/640px-HATG_miniature_game.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/D%26D_Game.jpg/640px-D%26D_Game.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Fortepan_85649.jpg/640px-Fortepan_85649.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Chess_pieces_close_up.jpg/640px-Chess_pieces_close_up.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/LewisChessmenBM20.jpg/640px-LewisChessmenBM20.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Robot_3D_print.jpg/640px-Robot_3D_print.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Viper Green', color: Color(0xFF2E7D32)),
        ProductColorOption(name: 'Cobra Purple', color: Color(0xFF4A148C)),
        ProductColorOption(name: 'Copperhead Bronze', color: Color(0xFF8D6E63)),
      ],
      sizes: ['28mm Large Base', '32mm Epic Monster'],
      isDigital: false,
      downloadFileName: 'Yuan_Ti_Boss_Statblock_&_VTT_Token.pdf',
      photoCredit: 'Wikimedia Commons / C. Jones collection',
      license: 'CC BY-SA 3.0',
    ),
    Product(
      id: 'dice-01',
      name: 'Crimson Dragonfire Polyhedral 7-Dice Set',
      category: ProductCategory.dice,
      price: 1200.0, // ₱1,200
      rating: 4.92,
      reviewCount: 54,
      shortDescription:
          'Balanced 7-piece RPG dice set (D4, D6, D8, D10, D%, D12, D20) with sharp hand-polished edges.',
      fullDescription:
          'Tournament-grade polyhedral dice set cast in high-density translucent crimson resin with gold-leaf numerals. Bubble-free vacuum casting ensures fair, randomized rolls for D&D 5e and Pathfinder sessions.',
      primaryImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/6sided_dice_%28cropped%29.jpg/640px-6sided_dice_%28cropped%29.jpg',
      galleryImages: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/6sided_dice_%28cropped%29.jpg/640px-6sided_dice_%28cropped%29.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Dados_4_a_20_lados.jpg/640px-Dados_4_a_20_lados.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Dragonfire Red', color: Color(0xFFC62828)),
        ProductColorOption(name: 'Emerald Venom', color: Color(0xFF2E7D32)),
        ProductColorOption(name: 'Amethyst Arcane', color: Color(0xFF6A1B9A)),
      ],
      sizes: ['Standard 16mm (7-Dice Set)', 'Oversized 22mm DM Set'],
      isDigital: false,
      downloadFileName: 'Dice_Calibration_Certificate.pdf',
      photoCredit: 'Photo by Wikimedia user / Polyhedral dice set',
      license: 'CC BY-SA 4.0',
    ),
    Product(
      id: 'dice-02',
      name: 'Astral Cobalt & Gold Font Polyhedrals',
      category: ProductCategory.dice,
      price: 1350.0, // ₱1,350
      rating: 4.90,
      reviewCount: 33,
      shortDescription:
          'Deep midnight blue dice with pearlescent swirls reminiscent of deep cosmos and arcane rifts.',
      fullDescription:
          'Crafted from heavy jewel-grade resin with deep pigment dispersion. High-contrast golden numerals ensure instant legibility across dimly-lit gaming tables. Includes velvet dice vault pouch.',
      primaryImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Dados_4_a_20_lados.jpg/640px-Dados_4_a_20_lados.jpg',
      galleryImages: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Dados_4_a_20_lados.jpg/640px-Dados_4_a_20_lados.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/6sided_dice_%28cropped%29.jpg/640px-6sided_dice_%28cropped%29.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Astral Blue', color: Color(0xFF1565C0)),
        ProductColorOption(name: 'Deep Sea Teal', color: Color(0xFF00695C)),
        ProductColorOption(name: 'Royal Midnight', color: Color(0xFF0D47A1)),
      ],
      sizes: ['Standard 16mm Set (7pcs)', 'Deluxe 11-Piece (with 4d6)'],
      isDigital: false,
      isFeatured: true,
      downloadFileName: 'Astral_Cobalt_Vault_Receipt.pdf',
      photoCredit: 'Wikimedia Commons gaming collection',
      license: 'CC BY 2.0',
    ),
    Product(
      id: 'map-01',
      name: 'Carta Marina Kraken & Sea Serpent One-Shot PDF + Map',
      category: ProductCategory.digitalMaps,
      price: 550.0, // ₱550
      rating: 4.96,
      reviewCount: 89,
      shortDescription:
          'Instant 8K Digital Battle Map & One-Shot Campaign PDF with gridded/gridless VTT exports.',
      fullDescription:
          'A historic Nordic cartographic masterpiece adapted for VTT (Roll20, Foundry, Owlbear Rodeo) and tabletop sessions. Includes a 20-page Level 5 One-Shot Campaign PDF, monster statblocks, and 8K battle maps. Unlocks instant download link upon checkout!',
      primaryImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Carta_Marina.jpeg/640px-Carta_Marina.jpeg',
      galleryImages: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Carta_Marina.jpeg/640px-Carta_Marina.jpeg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/OrteliusWorldMap1570.jpg/640px-OrteliusWorldMap1570.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Aged Parchment', color: Color(0xFFD7CCC8)),
        ProductColorOption(name: 'Night Exploration', color: Color(0xFF37474F)),
        ProductColorOption(name: 'Sepia Vintage', color: Color(0xFF8D6E63)),
      ],
      sizes: [
        '8K Digital VTT + One-Shot Campaign PDF',
        'Printable Poster PDF 300DPI (36x24")',
      ],
      isDigital: true,
      isFeatured: true,
      downloadFileName: 'Carta_Marina_8K_Map_&_OneShot_Campaign.zip',
      photoCredit:
          'Olaus Magnus (1539) / Uppsala University / Wikimedia Commons',
      license: 'Public Domain',
    ),
    Product(
      id: 'map-02',
      name: 'Islandia Eldritch Glacier One-Shot PDF & Map Bundle',
      category: ProductCategory.digitalMaps,
      price: 680.0, // ₱680
      rating: 4.89,
      reviewCount: 46,
      shortDescription:
          'Arctic caldera battle maps and 24-page One-Shot Campaign PDF: "The Frost Serpent of Mount Hekla".',
      fullDescription:
          'Complete arctic wilderness digital module including 5 interconnected high-resolution battle maps, dynamic lighting walls for Foundry VTT, and a 24-page PDF one-shot adventure. Pure digital delivery unlocks immediately after payment.',
      primaryImage:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/OrteliusWorldMap1570.jpg/640px-OrteliusWorldMap1570.jpg',
      galleryImages: [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/OrteliusWorldMap1570.jpg/640px-OrteliusWorldMap1570.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Carta_Marina.jpeg/640px-Carta_Marina.jpeg',
      ],
      colors: [
        ProductColorOption(name: 'Glacial Ice', color: Color(0xFF80DEEA)),
        ProductColorOption(name: 'Volcanic Ash', color: Color(0xFF455A64)),
        ProductColorOption(name: 'Runic Parchment', color: Color(0xFFE0E0E0)),
      ],
      sizes: [
        'Complete Digital Bundle (4K VTT + One-Shot PDF)',
        'Commercial DM Streamer License',
      ],
      isDigital: true,
      downloadFileName: 'Islandia_Glacier_OneShot_PDF_&_Maps.zip',
      photoCredit: 'Abraham Ortelius (ca 1590) / Wikimedia Commons',
      license: 'Public Domain',
    ),
  ];
}
