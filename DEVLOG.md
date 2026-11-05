# Marketing Vikings – Development Log
App: **Tabletop RPG Miniatures & Dice Swap**
Subject: Mobile Application Development (Flutter)

---

## Day 1 – App Skeleton & Initial Setup
**Goal:** Install Flutter, configure project structure, and build the initial skeleton.
**Done:**
- Installed Flutter SDK (stable) and VS Code Dart/Flutter extensions.
- Configured project `marketing_vikings`.
- Built home skeleton using **MaterialApp**, **Scaffold**, **AppBar**, **Column**, **Text**, and **Placeholder**.
- Set up initial dark tavern theme foundation in `app_theme.dart`.

---

## Day 2 – SVG Logo, Animated Background & Layout Widgets
**Goal:** Implement vector assets, interactive top navigation, dynamic animated backgrounds, and layout widgets.
**Done:**
- Created custom Norse D20 shield vector graphic in `assets/logo.svg` and integrated `flutter_svg`.
- Implemented `AppBarLogo` with touch feedback animation in the **AppBar**.
- Added `AnimatedTavernBackground` with ambient golden embers and dynamic Norse dungeon lighting on **Scaffold**.
- Applied core layout widgets:
  - **Padding**: Structured consistent spacing across all components.
  - **Align**: Positioned badges, indicators, and top controls.
  - **SizedBox**: Defined explicit constraints and vertical section spacing.
  - **Transform**: Applied angled dynamic badges (`Transform.rotate`) for authenticity and 360° markers.
- Added a full navigation **Drawer** with category filters and guild shortcuts.

---

## Day 3 – Categories, Product Catalog & Scroll Widgets
**Goal:** Integrate authentic non-AI product catalog and implement scrollable containers.
**Done:**
- Curated authentic, non-AI photographs from Wikimedia Commons with complete photographer licenses & credits.
- Built `Product` model with 3 core tabletop categories: **Painted Minis**, **Custom Dice**, and **Digital Maps**.
- Enforced strict business rule: **£100 minimum price** across all items in the catalog.
- Implemented scroll widgets:
  - **ListView** (Horizontal): `CategoryChipBar` allowing quick filtering with item badges.
  - **CarouselView / PageView**: `HeroCarousel` spotlighting 360° inspectable treasures.
  - **GridView**: Responsive 2-column `ProductCard` grid showcasing prices, ratings, and actions.
- Styled cards with **Container**, **ElevatedButton**, and **Icons** (🛒 add to cart, 💰 buy now).

---

## Day 4 – 360° Image Scrubber & Positive Quantity Delimiter
**Goal:** Build interactive inspection tools and detail controls for miniatures.
**Done:**
- Built `ThreeSixtyViewer`: Horizontal drag scrubber cycling across 8 authentic camera angles of the miniature so buyers can inspect the paint job.
- Added auto-rotation toggle (play/pause) and frame indicator.
- Created `QuantityStepper`: Strict delimiter enforcing `quantity >= 1` (zero negative quantities possible).
- Implemented interactive color variant selector (circular color chips) and scale/format selector (28mm Heroic, 32mm Tabletop, 75mm Bust, 8K VTT PDF).
- Built sticky bottom action bar with live total calculation (`£price * quantity`).

---

## Day 5 – Cart System & Validated Checkout Form
**Goal:** Complete stateful cart management, Form validation, and digital file delivery unlock.
**Done:**
- Built `CartController` (ChangeNotifier) managing items, live badge counts, and realm delivery calculation (free delivery for pure digital maps, £15 flat for physical minis).
- Built `CartScreen` with **ListView**, live quantity modification, and **remove item ❗** confirmation dialog.
- Built `CheckoutScreen` with core Input Widgets:
  - **Form** widget container.
  - **GlobalKey<FormState>** to validate all inputs before purchase.
  - **TextFormField** for Adventurer Name (min length validation).
  - **TextFormField** for Guild Email (email regex validation).
  - **TextFormField** for Realm Delivery Address (required for physical goods).
  - **FormField** for courier dispatch speed selection.
  - **FormField** for Guild Covenant & Terms acceptance checkbox.
- Simulated instant payment processing and showed confirmation dialog.
- Built **Digital Delivery Unlock**: Instant download link simulator for buyers purchasing digital battle maps and one-shot PDFs.
- Added `DesignAddonsPlaceholder` using **Placeholder** widgets for upcoming AR miniature placer and live 3D dice roller simulator.
- Verified test suite: 100% tests passing with 0 lint analysis issues!
