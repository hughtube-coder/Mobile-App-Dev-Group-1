# Marketing Vikings – Development Log & Lecture Documentation
**Application:** Tabletop RPG Miniatures & Dice Swap (Philippine Guild Exchange)  
**Course:** Mobile Application Development (Flutter)  
**Target Environment:** Flutter 3.47.8 (Stable), Web & Mobile (Android/iOS)  
**Currency Standard:** Philippine Pesos (₱) • Minimum Delimiter: ₱100  
**Asset Standard:** 100% Authentic Non-AI Photography (Wikimedia Commons Public Domain & Creative Commons)

---

## Executive Summary & Lecture Widgets Index

This application was engineered step-by-step from **Day 1 to the final day (Day 8)** to implement every core widget category presented in the Mobile Application Development lecture slides:

| Category | Lecture Widgets Implemented | Code Implementation File(s) |
|---|---|---|
| **Basic Widgets** | `AppBar`, `Scaffold`, `Column`, `Row`, `Container`, `ElevatedButton`, `Icon`, `Text`, `Placeholder`, `Image` | `lib/screens/home_screen.dart`, `lib/widgets/app_bar_logo.dart`, `lib/widgets/design_addons_placeholder.dart`, `lib/widgets/product_card.dart` |
| **Layout Widgets** | `Padding`, `Align`, `SizedBox`, `Transform` (with `Matrix4.skewY` & `rotateZ`) | `lib/widgets/product_card.dart`, `lib/widgets/hero_carousel.dart`, `lib/widgets/lut_split_preview.dart` |
| **Scrolling Widgets** | `ListView`, `GridView` (`GridView.builder`), `CarouselView` (Material 3) | `lib/screens/home_screen.dart`, `lib/widgets/material_carousel_view.dart`, `lib/screens/cart_screen.dart`, `lib/widgets/category_chip_bar.dart` |
| **Input Widgets** | `Form`, `FormField<T>`, `TextFormField` (`TextInputType.number`, `emailAddress`, `visiblePassword`, `obscureText`) | `lib/screens/checkout_screen.dart` |
| **Key Components** | `GlobalKey<FormState>`, Validator logic, State access | `lib/screens/checkout_screen.dart` |

---

## Day-by-Day Development Progression (Day 1 to Final Day)

### Day 1 – App Initialization, Architecture & Basic Widgets Skeleton
- **Focus:** Flutter SDK setup, initial directory structure, theme palette, and screen wireframing.
- **Widgets Explored & Implemented:**
  - `MaterialApp`: Root application widget configuring dark theme and home route.
  - `Scaffold`: Structural layout container with initial app bar and body canvas.
  - `AppBar`: Top application bar for brand identity.
  - `Column`: Vertical layout array organizing section headers and wireframe boxes.
  - `Text`: Styled headings and body typography for table RPG lore.
  - `Placeholder`: Visual debugging tool (`fallbackWidth: 400.0`, `fallbackHeight: 96.0`, `color: AppColors.goldFaded`, `strokeWidth: 1.2`) marking upcoming features.
- **Milestone Outcome:** Successfully created `c:\App\marketing_vikings`, verified `flutter run -d chrome`, and established initial dark tavern palette in `lib/theme/app_theme.dart`.

---

### Day 2 – Branding, Vector Assets & Core Layout Widgets
- **Focus:** Custom branding, vector rendering, ambient animated particle lighting, and responsive layout constraints.
- **Widgets Explored & Implemented:**
  - `Padding`: Uniform `EdgeInsets.all(16.0)` and symmetric spacing across cards and headers.
  - `Align`: Positioning top-left category badges, top-right rating badges, and header elements (`Alignment.centerLeft`, `Alignment.topRight`).
  - `SizedBox`: Explicit dimension bounding for cards (`SizedBox(width: 200, height: 300)`) and vertical spacers.
  - `Transform`: Dynamic angled rotation (`Transform.rotate(angle: -0.06, child: ...)`) giving cards an authentic RPG treasure tag feel.
  - `Drawer`: Side navigation drawer equipped with `ListView` and `ListTile` items.
- **Custom Enhancements:**
  - Handcrafted `assets/logo.svg` featuring a Nordic Viking shield and D20 silhouette.
  - `AnimatedTavernBackground`: Custom animated canvas painting floating golden embers across the background.

---

### Day 3 – Domain Architecture, Non-AI Catalog & Scrolling Widgets
- **Focus:** Real tabletop RPG data models, 100% authentic non-AI artwork, Philippine Peso pricing, and scrollable lists/grids.
- **Widgets Explored & Implemented:**
  - `ListView` (Horizontal): `CategoryChipBar` allowing quick filtering across Minis, Dice, Maps, and LUTs with badges.
  - `GridView` (`GridView.builder`): High-performance 2-column product catalog (`crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.58`).
  - `CarouselView` (Material 3): Integrated official Material 3 `CarouselView(itemExtent: 310, shrinkExtent: 220, children: ...)` in `MaterialCarouselViewSection` matching lecture Slide 16.
  - `ElevatedButton`: Quick-add 🛒 and Buy Now 💰 buttons styled with `ElevatedButton.styleFrom(backgroundColor: AppColors.gold)`.
- **Domain Constraints Enforced:**
  - Strict **minimum price delimiter of ₱100** across all items in `Product.catalog`.
  - Curated high-resolution photographs from Wikimedia Commons with public domain / CC attribution.

---

### Day 4 – Interactive 360° Inspection Scrubber & LUT Split Tester
- **Focus:** Custom interactive e-commerce preview tools for tabletop hobbyists.
- **Widgets Explored & Implemented:**
  - `Image` / `Image.network`: Responsive image loading with `loadingBuilder` and `errorBuilder`.
  - `Row`: Horizontal alignment of quantity steppers, action buttons, and ratings.
  - `Container`: Decorated boxes with gradients, border radii, and drop shadows (`BoxShadow(color: Colors.black45, blurRadius: 10)`).
- **Interactive Tools Developed:**
  - `ThreeSixtyViewer`: Horizontal drag scrubber cycling smoothly through 8 authentic high-res camera angles of physical miniatures.
  - `LutSplitPreview`: `ColorFiltered` split-screen preview slider allowing digital painters to test color grading lookup tables (Warm Hearth Amber, Nordic Frost Cyan, Grimdark Monochrome, Dragon Fire Ruby) in real time.
  - `QuantityStepper`: Delimiter component strictly enforcing positive quantities (`quantity >= 1`, minus button disabled at 1).

---

### Day 5 – Stateful Cart Management & Validated Forms
- **Focus:** Cart state management, order calculation, and lecture form validation.
- **Widgets Explored & Implemented:**
  - `Form`: Top-level form container grouping adventurer checkout inputs.
  - `GlobalKey<FormState>`: Form key used to trigger `_formKey.currentState!.validate()`.
  - `FormField<T>`: Custom form field implementations:
    - `FormField<String>` for courier dispatch speed selection.
    - `FormField<bool>` for Guild Covenant & Terms acceptance checkbox with custom error display.
  - `TextFormField`:
    - Full Name input with minimum rune length validation.
    - Email address input with `@` and `.` structure checks.
    - Physical Realm shipping address (conditionally required only for physical miniatures and dice).
- **Cart Logic:** `CartController` (ChangeNotifier) automatically applies free delivery for digital battle maps and flat ₱150 shipping for physical miniatures.

---

### Day 6 – Polyhedral Dice Physics & Floating Action Button
- **Focus:** Interactive tabletop utility and quick action controls.
- **Widgets Explored & Implemented:**
  - `Scaffold.floatingActionButton`: Floating action button (`FloatingActionButton.extended`) anchored to the bottom-right of the screen for rolling the D20 dice at any moment (Lecture Slide 18).
  - `Transform` (Matrix Transformation): Exact lecture Slide 6 syntax:
    ```dart
    Transform(
      alignment: Alignment.topLeft,
      transform: Matrix4.skewY(0.08)..rotateZ(-math.pi / 28.0),
      child: Container(...),
    )
    ```
    applied to promotional "360° VIEW", "LUT SLIDER", and "DISCOUNTED!" badges.
- **Utility Developed:** `DiceRollerSheet` simulating a weighted 20-sided die with rolling animations, custom sound vibrations, critical hit (Natural 20) celebratory banners, and critical fumble (Natural 1) alerts.

---

### Day 7 – Advanced Form Inputs & Instant Digital Delivery
- **Focus:** Completing specialized input widget types from lecture slides and simulated instant asset delivery.
- **Widgets Explored & Implemented:**
  - `TextFormField` with `keyboardType: TextInputType.number` (Lecture Slide 1):
    - Added dedicated mobile number / GCash / Maya dispatch input.
    - Uses exact lecture validator pattern: `if (value == null || value.trim().isEmpty) return 'Please enter some text';`.
  - `TextFormField` with `keyboardType: TextInputType.visiblePassword` and `obscureText: true` (Lecture Slide 4):
    - Added Adventurer Guild Vault Secret Passcode input with interactive eye icon to toggle rune visibility.
- **Digital Delivery Simulation:**
  - Added order confirmation modal featuring instant digital key unlocks for 8K VTT battle maps and PDF campaigns with simulated download tokens and receipt ledger summaries.

---

### Day 8 – Testing, Accessibility (A11y), Code Cleanliness & Submission Readiness
- **Focus:** Automated widget test suite, accessibility announcements, and final clean-room verification.
- **Widgets Explored & Implemented:**
  - `Icon` with `semanticLabel` (Lecture Slide 22):
    ```dart
    Icon(
      Icons.casino,
      color: AppColors.gold,
      size: 24.0,
      semanticLabel: 'Roll Valhalla D20 Polyhedral Dice',
    )
    ```
    added across all icons to support screen readers and TalkBack/VoiceOver accessibility.
- **Verification Metrics:**
  - Automated analysis: `analyze_files` report: **No errors (0 warnings, 0 issues)**.
  - Widget tests: 100% passed (`test/widget_test.dart` verifying home screen rendering, Philippine Peso currency formatting, positive quantity stepper boundary, FloatingActionButton presence, and Material 3 CarouselView rendering).

---

## Project Updates & Version Changelog ("Things like update for documents")

### [Update v1.7.0] – Final Classroom Release & Accessibility Overhaul
- **Added:** `semanticLabel` to every major `Icon` widget across the application according to Lecture Slide 22.
- **Added:** `MaterialCarouselViewSection` utilizing Flutter Material 3's `CarouselView` component according to Lecture Slide 16.
- **Added:** `FloatingActionButton.extended` on `HomeScreen` `Scaffold` according to Lecture Slide 18.
- **Updated:** `Transform` matrix skew in `ProductCard` to use `Matrix4.skewY(0.08)..rotateZ(-math.pi / 28.0)` according to Lecture Slide 6.
- **Verified:** 0 analyzer errors and 100% test pass rate.

### [Update v1.6.0] – Advanced Input Widgets & GCash/Passcode Fields
- **Added:** `TextFormField` with `keyboardType: TextInputType.number` for GCash/Maya phone numbers (Slide 1).
- **Added:** `TextFormField` with `keyboardType: TextInputType.visiblePassword` and `obscureText` toggle for vault security (Slide 4).
- **Updated:** Form validation error strings to match Slide 2's recommended `Please enter some text` fallback.

### [Update v1.5.0] – Currency Standardization to Philippine Pesos (₱)
- **Updated:** All product prices converted to Philippine Pesos (`₱`) with thousands commas (`CurrencyFormatter.format`).
- **Enforced:** Strict business rule: Every single item in the catalog has a minimum price of ₱100.
- **Updated:** Delivery fee set to ₱150 for physical miniatures and free for digital maps.

### [Update v1.4.0] – ColorFiltered LUT Split-Screen Preview Tester
- **Added:** Dual e-commerce feature for digital creators: `LutSplitPreview` widget with split comparison slider and 4 authentic color grading lookups.

### [Update v1.3.0] – Interactive Valhalla D20 Dice Roller
- **Added:** Built-in modal bottom sheet simulator for polyhedral dice rolling with natural 20 critical triumph banners.

### [Update v1.2.0] – 360° Miniature Rotation Scrubber
- **Added:** Multi-angle inspection tool cycling across 8 high-resolution authentic photographs with auto-rotation playback.

### [Update v1.1.0] – Search, Sort & Category Filtering
- **Added:** Real-time text search bar with instant clear button and multi-criteria sorting (Price Low-to-High, High-to-Low, Top Rated, Featured).

### [Update v1.0.0] – Initial Project Baseline & Architecture
- **Added:** Base Flutter scaffolding, custom tavern color theme, and SVG logo.

---

## How to Run & Verify the Application

To run the complete application in Google Chrome:
```powershell
cd C:\App\marketing_vikings
flutter run -d chrome
```

To run the automated test suite:
```powershell
cd C:\App\marketing_vikings
flutter test
```

To run static analysis:
```powershell
cd C:\App\marketing_vikings
dart analyze
```
