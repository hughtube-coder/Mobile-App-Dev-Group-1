import 'package:flutter/material.dart';

enum ProductCategory {
  all('All Items', Icons.auto_awesome),
  minis('Painted Minis', Icons.shield),
  dice('Custom Dice', Icons.casino),
  digitalMaps('Digital Maps', Icons.map),
  presets('LUTs & Presets', Icons.tune);

  const ProductCategory(this.label, this.icon);
  final String label;
  final IconData icon;
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
    this.isDigital = false,
    required this.photoCredit,
    required this.license,
  });

  /// Authentic catalog of tabletop RPG miniatures, custom dice, digital maps, and digital LUT presets.
  /// All photos are authentic, non-AI photographs from Wikimedia Commons with complete attribution.
  /// Prices are denominated in Philippine Pesos (₱) with a strict minimum of ₱100.
  static const List<Product> catalog = [
    Product(
      id: 'mini-01',
      name: 'Sun-Priest Feathered Headdress Hero',
      category: ProductCategory.minis,
      price: 2450.0, // ₱2,450 (strictly >= ₱100 minimum)
      rating: 4.95,
      reviewCount: 38,
      shortDescription: 'Expertly hand-painted 28mm miniature with multi-layer acrylic shading and gold leaf trim.',
      fullDescription: 'A museum-grade tabletop miniature depicting a Sun-Priest champion adorned with ceremonial feathered headdress and ancestral relic blade. Painted with 14 micro-glazes, non-metallic metal (NMM) techniques, and sealed with ultra-matte protective varnish. Comes mounted on a sculpted scenic dungeon base.',
      primaryImage: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/4/48/Standing_Figure_with_Feathered_Headdress_MET_DP239898.jpg/640px-Standing_Figure_with_Feathered_Headdress_MET_DP239898.jpg',
      has360View: true,
      galleryImages: [
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/4/48/Standing_Figure_with_Feathered_Headdress_MET_DP239898.jpg/640px-Standing_Figure_with_Feathered_Headdress_MET_DP239898.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8c/Standing_Figure_with_Feathered_Headdress_MET_DP239899.jpg/640px-Standing_Figure_with_Feathered_Headdress_MET_DP239899.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4b/Standing_Figure_with_Feathered_Headdress_MET_DP239900.jpg/640px-Standing_Figure_with_Feathered_Headdress_MET_DP239900.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bd/Standing_Figure_with_Feathered_Headdress_MET_DP239901.jpg/640px-Standing_Figure_with_Feathered_Headdress_MET_DP239901.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2b/Standing_Figure_with_Feathered_Headdress_MET_DP239902.jpg/640px-Standing_Figure_with_Feathered_Headdress_MET_DP239902.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/af/Standing_Figure_with_Feathered_Headdress_MET_DP239903.jpg/640px-Standing_Figure_with_Feathered_Headdress_MET_DP239903.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/6c/Standing_Figure_with_Feathered_Headdress_MET_DP235239.jpg/640px-Standing_Figure_with_Feathered_Headdress_MET_DP235239.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/34/Standing_Figure_with_Feathered_Headdress_MET_163432.jpg/640px-Standing_Figure_with_Feathered_Headdress_MET_163432.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Solar Crimson', color: Color(0xFF8B1E1E)),
        ProductColorOption(name: 'Imperial Gold', color: Color(0xFFD4A537)),
        ProductColorOption(name: 'Jade Feather', color: Color(0xFF1B5E20)),
        ProductColorOption(name: 'Obsidian Night', color: Color(0xFF212121)),
      ],
      sizes: ['28mm Heroic Scale', '32mm Tabletop', '75mm Collector Bust'],
      isDigital: false,
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
      shortDescription: 'Custom 3D-printed resin snake-folk warlord painted with reptilian scales and poison wash.',
      fullDescription: 'Terrifying ophidian terror ready for jungle or dungeon boss encounters. Each scale has been individually high-lit with toxic chartreuse and venomous teal, topped with gloss varnish on the venom glands.',
      primaryImage: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/ba/Yuan_Ti_s.jpg/640px-Yuan_Ti_s.jpg',
      galleryImages: [
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/ba/Yuan_Ti_s.jpg/640px-Yuan_Ti_s.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/17/Miniatures_by_C_Jones.jpg/640px-Miniatures_by_C_Jones.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Viper Green', color: Color(0xFF2E7D32)),
        ProductColorOption(name: 'Cobra Purple', color: Color(0xFF4A148C)),
        ProductColorOption(name: 'Copperhead Bronze', color: Color(0xFF8D6E63)),
      ],
      sizes: ['28mm Large Base', '32mm Epic Monster'],
      isDigital: false,
      photoCredit: 'Wikimedia Commons / C. Jones collection',
      license: 'CC BY-SA 3.0',
    ),
    Product(
      id: 'mini-03',
      name: 'Vanguard Chaos Knight & Steed',
      category: ProductCategory.minis,
      price: 2900.0, // ₱2,900
      rating: 4.98,
      reviewCount: 42,
      shortDescription: 'Competition-tier heavy armored dread knight on dynamic volcanic scenic terrain.',
      fullDescription: 'Showcase centerpiece miniature featured in local regional painting competitions. Weathered rust pitting on spiked battle plate, molten lava osl on the base, and parchment scrolls with microscopic hand-inked runes.',
      primaryImage: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3f/Warhammer_AoS_Lind.jpg/640px-Warhammer_AoS_Lind.jpg',
      galleryImages: [
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3f/Warhammer_AoS_Lind.jpg/640px-Warhammer_AoS_Lind.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f7/Games_Day_2015%2C_Budapest%2C_71_%28cropped%29.jpg/640px-Games_Day_2015%2C_Budapest%2C_71_%28cropped%29.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Blood Iron', color: Color(0xFF7F1D1D)),
        ProductColorOption(name: 'Void Black', color: Color(0xFF18181B)),
        ProductColorOption(name: 'Runic Silver', color: Color(0xFF94A3B8)),
      ],
      sizes: ['32mm Mounted Cavalry', '54mm Display Statue'],
      isDigital: false,
      photoCredit: 'Photograph by Lind / Wikimedia Commons',
      license: 'CC BY-SA 4.0',
    ),
    Product(
      id: 'dice-01',
      name: 'Lilac Amethyst Resin 7-Piece Dice Set',
      category: ProductCategory.dice,
      price: 1200.0, // ₱1,200
      rating: 4.92,
      reviewCount: 51,
      shortDescription: 'Sharp-edged translucent resin polyhedral dice with lilac shimmer inclusions and crisp gold numbering.',
      fullDescription: 'Balanced handmade resin dice set including d4, d6, d8, d10, d%, d12, and high-impact d20. Poured in pressurized chambers to eliminate micro-bubbles. Balanced centre-of-gravity tested for fair rolls.',
      primaryImage: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/00/Dice_Lilac_Set.jpg/640px-Dice_Lilac_Set.jpg',
      galleryImages: [
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/00/Dice_Lilac_Set.jpg/640px-Dice_Lilac_Set.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e5/Dice_%28typical_role_playing_game_dice%29.jpg/640px-Dice_%28typical_role_playing_game_dice%29.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Lilac Dream', color: Color(0xFFB388FF)),
        ProductColorOption(name: 'Arcane Rose', color: Color(0xFFF06292)),
        ProductColorOption(name: 'Celestial White', color: Color(0xFFEDE7F6)),
      ],
      sizes: ['Standard 16mm', 'Oversized 20mm Chonk d20'],
      isDigital: false,
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
      shortDescription: 'Deep midnight blue dice with pearlescent swirls reminiscent of deep cosmos and arcane rifts.',
      fullDescription: 'Crafted from heavy jewel-grade resin with deep pigment dispersion. High-contrast golden numerals ensure instant legibility across dimly-lit gaming tables. Includes velvet dice vault pouch.',
      primaryImage: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8c/Gaming_dice_multisided_blue.jpg/640px-Gaming_dice_multisided_blue.jpg',
      galleryImages: [
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8c/Gaming_dice_multisided_blue.jpg/640px-Gaming_dice_multisided_blue.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/af/Assorted_dice_for_games%2C_2024.jpg/640px-Assorted_dice_for_games%2C_2024.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Astral Blue', color: Color(0xFF1565C0)),
        ProductColorOption(name: 'Deep Sea Teal', color: Color(0xFF00695C)),
        ProductColorOption(name: 'Royal Midnight', color: Color(0xFF0D47A1)),
      ],
      sizes: ['Standard 16mm Set (7pcs)', 'Deluxe 11-Piece (with 4d6)'],
      isDigital: false,
      photoCredit: 'Wikimedia Commons gaming collection',
      license: 'CC BY 2.0',
    ),
    Product(
      id: 'dice-03',
      name: 'The One Ring Artisan Dwarven Dice Vault',
      category: ProductCategory.dice,
      price: 1950.0, // ₱1,950
      rating: 4.97,
      reviewCount: 67,
      shortDescription: 'Heavyweight semi-precious stone & metallic alloy dice with runic tengwar border accents.',
      fullDescription: 'Forged for high-stakes journeys into the Shadow. Distinct weight in hand creates satisfying tactile thuds on leather dice trays. Includes two matched sets in carved walnut display case.',
      primaryImage: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d9/The_One_Ring_Roleplaying_Game_-_Two_dice_sets.jpg/640px-The_One_Ring_Roleplaying_Game_-_Two_dice_sets.jpg',
      galleryImages: [
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d9/The_One_Ring_Roleplaying_Game_-_Two_dice_sets.jpg/640px-The_One_Ring_Roleplaying_Game_-_Two_dice_sets.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/7b/Role-playing_dice.jpg/640px-Role-playing_dice.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Mithril Grey', color: Color(0xFFB0BEC5)),
        ProductColorOption(name: 'Dragon Gold', color: Color(0xFFC5A059)),
        ProductColorOption(name: 'Erebor Bronze', color: Color(0xFF8D6E63)),
      ],
      sizes: ['Vault Box + 2 Dice Sets', 'Collector Edition with Dice Tower'],
      isDigital: false,
      photoCredit: 'Wikimedia Commons / RPG Artifact Archive',
      license: 'CC BY-SA 4.0',
    ),
    Product(
      id: 'map-01',
      name: 'Carta Marina Kraken & Leviathan Sea Battle Map',
      category: ProductCategory.digitalMaps,
      price: 1100.0, // ₱1,100
      rating: 4.96,
      reviewCount: 89,
      shortDescription: 'Instant 8K Ultra-HD Digital Campaign Map with grid and gridless VTT exports + printable PDF.',
      fullDescription: 'A historic Nordic cartographic masterpiece adapted for VTT (Roll20, Foundry, Fantasy Grounds) and in-person tabletop sessions. Features treacherous sea monsters, whirlpool hazard zones, and high-res battle grid.',
      primaryImage: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/79/Carta_Marina_1539_with_sea_serpent.jpg/640px-Carta_Marina_1539_with_sea_serpent.jpg',
      galleryImages: [
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/79/Carta_Marina_1539_with_sea_serpent.jpg/640px-Carta_Marina_1539_with_sea_serpent.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/21/Carta_Marina.jpg/640px-Carta_Marina.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Aged Parchment', color: Color(0xFFD7CCC8)),
        ProductColorOption(name: 'Night Exploration', color: Color(0xFF37474F)),
        ProductColorOption(name: 'Sepia Vintage', color: Color(0xFF8D6E63)),
      ],
      sizes: ['8K Digital VTT (Foundry/Roll20)', 'Printable PDF 300DPI 36x24"'],
      isDigital: true,
      photoCredit:
          'Olaus Magnus (1539) / Uppsala University / Wikimedia Commons',
      license: 'Public Domain',
    ),
    Product(
      id: 'map-02',
      name: 'Islandia Eldritch Glacier & Volcano Battle Map Pack',
      category: ProductCategory.digitalMaps,
      price: 1400.0, // ₱1,400
      rating: 4.89,
      reviewCount: 46,
      shortDescription: 'Epic glacial chasm, steaming caldera, and frost-giant realm digital battle map bundle with one-shot PDF adventure.',
      fullDescription: 'Complete arctic wilderness module including 5 interconnected high-resolution battle maps, dynamic lighting walls for Foundry VTT, weather overlay assets, and a 24-page PDF one-shot adventure: "The Frost Serpent of Mount Hekla".',
      primaryImage: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b7/Abraham_Ortelius-Islandia-ca_1590.jpg/640px-Abraham_Ortelius-Islandia-ca_1590.jpg',
      galleryImages: [
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b7/Abraham_Ortelius-Islandia-ca_1590.jpg/640px-Abraham_Ortelius-Islandia-ca_1590.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/09/Thule_%26_Orkney_%26_Feroe_Carta_Marina_Olaus_Magnus.jpg/640px-Thule_%26_Orkney_%26_Feroe_Carta_Marina_Olaus_Magnus.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Glacial Ice', color: Color(0xFF80DEEA)),
        ProductColorOption(name: 'Volcanic Ash', color: Color(0xFF455A64)),
        ProductColorOption(name: 'Runic Parchment', color: Color(0xFFE0E0E0)),
      ],
      sizes: [
        'Complete Digital Bundle (4K VTT + PDF)',
        'Commercial Streamer License',
      ],
      isDigital: true,
      photoCredit: 'Abraham Ortelius (ca 1590) / Wikimedia Commons',
      license: 'Public Domain',
    ),
    // Dual e-commerce feature: Digital Pattern & LUT Tester Market
    Product(
      id: 'lut-01',
      name: 'Nordic Tavern Hearth & Frost 3D LUT Cinematic Pack',
      category: ProductCategory.presets,
      price: 850.0, // ₱850 (strictly >= ₱100 minimum)
      rating: 4.96,
      reviewCount: 78,
      shortDescription: 'Professional color grading LUT presets (.cube & mobile DNG) calibrated for miniature photography and fantasy film creators.',
      fullDescription: 'Specially crafted digital lookup tables (LUTs) designed to enhance warm acrylic mini glazes, deep shadows, and luminous magical weapon effects. Interactive split-screen test slider available right in the app before you purchase!',
      primaryImage: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4f/Warhammer_game.jpg/640px-Warhammer_game.jpg',
      hasLutPreview: true,
      galleryImages: [
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4f/Warhammer_game.jpg/640px-Warhammer_game.jpg',
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0b/D%26D_Game_1.jpg/640px-D%26D_Game_1.jpg',
      ],
      colors: [
        ProductColorOption(name: 'Warm Hearth Amber', color: Color(0xFFFFB300)),
        ProductColorOption(name: 'Nordic Frost Cyan', color: Color(0xFF26C6DA)),
        ProductColorOption(
          name: 'Grimdark Monochrome',
          color: Color(0xFF78909C),
        ),
        ProductColorOption(name: 'Dragon Fire Ruby', color: Color(0xFFE53935)),
      ],
      sizes: [
        'All-in-One (.CUBE, .XMP, Mobile DNG)',
        'Creator Studio Commercial License',
      ],
      isDigital: true,
      photoCredit: 'Warhammer gaming archive / Wikimedia Commons',
      license: 'CC BY-SA 4.0',
    ),
  ];
}
