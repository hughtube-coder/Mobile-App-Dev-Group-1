# Marketing Vikings – Development Log & System Journey (Day 1 to Day 15)
**Application:** Marketing Vikings – Dual E-Commerce Type Marketplace  
1. **Digital Pattern & LUT Tester Market** *(Lightroom Presets/LUTs, Sewing Patterns, 3D Print `.STL` Files)*  
2. **Tabletop RPG Miniatures & Dice Swap** *(Focused 3-Category Community Market: Minis, Dice, Digital Maps)*  

**Course:** Mobile Application Development (Dart & Flutter)  
**Target Environment:** Flutter 3.47.8 (Stable), Installable Android `.APK` (`MarketingVikings.apk`) & Web  
**Currency Standard:** Philippine Pesos (`₱`) • Minimum Price Delimiter: `₱100` • Quantity Delimiter: `quantity >= 1` (No negative quantity)  
**Asset Standard:** 100% Authentic Non-AI Photography (Wikimedia Commons Public Domain / Creative Commons & Official Flutter Docs)

---

## 1. What Changed & What Applied (Product Specification Transition Summary)

When finalizing the project with the team leader, we aligned the system to the official **Dual E-Commerce Type** product specification. Below is the exact breakdown of **what changed** and **what was applied** across the codebase:

| Requirement Area | Previous Version (v1.7 – Single RPG Concept) | Updated Final Version (v2.0 – Dual E-Commerce Type) | Files Updated & Applied |
|---|---|---|---|
| **Marketplace Concept** | Single Tabletop RPG Miniatures & Dice store with a bonus LUT category. | **Full Dual E-Commerce Type Architecture** with an interactive **Marketplace Mode Switcher** (`Dual E-Commerce (All)`, `Digital Pattern & LUT Market`, and `Tabletop RPG & Dice Swap`). | `lib/models/product.dart`, `lib/screens/home_screen.dart`, `lib/widgets/category_chip_bar.dart` |
| **Store Type 1: Digital Pattern & LUT Tester Market** | Only had 1 LUT preset item; did not include Sewing Patterns or standalone 3D Print `.STL` files. | Full micro-store for digital creators selling **Lightroom Presets (LUTs)** (`lut-01`, `lut-02`), **Sewing Patterns (`.PDF`/`.DXF`)** (`pattern-01`), and **3D Print `.STL` Files** (`stl-01`). | `lib/models/product.dart` |
| **Store Type 1 Dart/Flutter Edge (`ColorFiltered` + Phone Photos)** | Had a `ColorFiltered` split-screen slider that only previewed the seller's default product image. | Upgraded `LutSplitPreview` with a **"📱 Preview Filter on Phone Photos"** bar (`Seller Sample`, `📱 Phone: Portrait Owl`, `📱 Phone: Street Light`, `📱 Phone: Tabletop Shot`, and `+ My Phone Photo` URL dialog) so buyers can test the seller's filter on phone photos before purchasing. | `lib/widgets/lut_split_preview.dart` |
| **Store Type 2: Tabletop RPG Miniatures & Dice Swap** | Mixed 4 categories together in one bar. | Strictly focused on the **three passionate community categories**: **Minis**, **Dice**, and **Digital Maps** when `Tabletop RPG & Dice Swap` mode is selected (`ProductCategory.forStore(StoreType.tabletopRpg)`). | `lib/models/product.dart`, `lib/widgets/category_chip_bar.dart`, `lib/screens/home_screen.dart` |
| **Store Type 2 Dart/Flutter Edge (360° 8-Photo Scrubber)** | 360-degree horizontal image scrubber across 8 photos. | Preserved and highlighted on painted miniatures (`mini-01`, `mini-02`) so buyers can swipe horizontally across an 8-photo sequence to inspect the paint job. | `lib/widgets/three_sixty_viewer.dart`, `lib/screens/product_detail_screen.dart` |
| **Delivery & Simple Checkout Model** | Included physical shipping address fields, courier speed selectors, and a ₱150 physical delivery fee. | **Pure Digital Delivery & Simple Checkout**: Removed shipping addresses, couriers, and physical delivery fees (`₱0` fee). Once paid, the confirmation dialog immediately **unlocks instant download links** (`downloadFileName`) for every purchased item. | `lib/screens/checkout_screen.dart`, `lib/controllers/cart_controller.dart`, `lib/screens/cart_screen.dart` |
| **Core E-Commerce Controls** | Quantity stepper in Cart had a bug where tapping `-` called `incrementQuantity`. | Fixed Cart `QuantityStepper` via `cart.updateQuantity(item, newQty)` enforcing `quantity >= 1` (strictly no negative or zero quantity), alongside interactive **Color & Size** selectors and **Add to Cart 🛒** / **Remove ❗** confirmation. | `lib/controllers/cart_controller.dart`, `lib/screens/cart_screen.dart`, `lib/widgets/quantity_stepper.dart` |
| **Installable Mobile App (`.APK`)** | Tested in Chrome / VS Code desktop runner. | Restored JDK 17, Git, and Android SDK integration and compiled the standalone installable Android package **`MarketingVikings.apk`** (`C:\App\marketing_vikings\MarketingVikings.apk`) for direct phone installation. | `android/app/build.gradle.kts`, `MarketingVikings.apk` |

---

## 2. Executive Summary & Lecture Widgets Index (All 26 Slides Applied)

Every core widget category presented in the Mobile Application Development lecture slides is implemented and preserved in the Dual E-Commerce codebase:

| Category | Lecture Widgets Implemented | Code Implementation File(s) |
|---|---|---|
| **Basic Widgets** | `AppBar`, `Scaffold` (with `FloatingActionButton`), `Column`, `Row` (with `Expanded` & `FittedBox`), `Container`, `ElevatedButton`, `Icon` (with `semanticLabel`), `Text`, `Placeholder`, `Image` | `lib/screens/home_screen.dart`, `lib/widgets/app_bar_logo.dart`, `lib/widgets/design_addons_placeholder.dart`, `lib/widgets/product_card.dart` |
| **Layout Widgets** | `Padding`, `Align`, `SizedBox`, `Transform` (with `Matrix4.skewY` & `rotateZ`) | `lib/widgets/product_card.dart`, `lib/widgets/hero_carousel.dart`, `lib/widgets/lut_split_preview.dart`, `lib/widgets/dice_roller_sheet.dart` |
| **Scrolling Widgets** | `ListView`, `GridView` (`GridView.builder`), `CarouselView` (Material 3) | `lib/screens/home_screen.dart`, `lib/widgets/material_carousel_view.dart`, `lib/screens/cart_screen.dart`, `lib/widgets/category_chip_bar.dart` |
| **Input Widgets** | `Form`, `FormField<T>`, `TextFormField` (`TextInputType.number`, `emailAddress`, `visiblePassword`, `obscureText`) | `lib/screens/checkout_screen.dart` |
| **Key Components** | `GlobalKey<FormState>`, Validator logic (`'Please enter some text'`), State access | `lib/screens/checkout_screen.dart` |

---

## 3. Complete Day-by-Day Development Journey (Day 1 to Day 15)

### Day 1 – App Initialization, Architecture & Basic Widgets Skeleton
- **Focus:** Flutter SDK setup, initial directory structure, theme palette, and screen wireframing.
- **Widgets Explored & Implemented:**
  - `MaterialApp`: Root application widget configuring dark theme and home route (`lib/main.dart`).
  - `Scaffold` & `AppBar`: Structural layout container with top application bar for brand identity.
  - `Column` & `Text`: Vertical layout array organizing section headers and styled headings.
  - `Placeholder`: Visual debugging wireframe (`fallbackWidth: 400.0`, `fallbackHeight: 96.0`, `color: AppColors.goldFaded`, `strokeWidth: 1.2`) in `lib/widgets/design_addons_placeholder.dart` (Lecture Slide 20).
- **Milestone Outcome:** Created `C:\App\marketing_vikings` and established the dark Nordic/Creator palette in `lib/theme/app_theme.dart`.

---

### Day 2 – Branding, Vector Assets & Core Layout Widgets
- **Focus:** Custom branding, vector rendering, ambient animated particle lighting, and responsive layout constraints.
- **Widgets Explored & Implemented:**
  - `Padding`, `Align`, `SizedBox`: Uniform `EdgeInsets.all(16.0)`, badge alignment (`Alignment.topLeft`, `Alignment.topRight`), and explicit card dimensions.
  - `Transform`: Dynamic angled rotation and matrix skewing on product badges.
  - `Drawer`: Side navigation drawer equipped with `ListView` and `ListTile` items.
- **Custom Enhancements:** Handcrafted `assets/logo.svg` and `AnimatedTavernBackground`.

---

### Day 3 – Domain Architecture, Non-AI Catalog & Scrolling Widgets
- **Focus:** Product data models, 100% authentic non-AI artwork from Wikimedia Commons, Philippine Peso (`₱`) pricing, and scrollable lists/grids.
- **Widgets Explored & Implemented:**
  - `ListView` (Horizontal): `CategoryChipBar` for horizontal category filtering (Lecture Slide 14).
  - `GridView` (`GridView.builder`): Responsive 2-column product catalog (Lecture Slide 15).
  - `CarouselView` (Material 3): Official Material 3 `CarouselView(itemExtent: 310, shrinkExtent: 260, children: ...)` in `MaterialCarouselViewSection` (Lecture Slide 16).
  - `ElevatedButton`: Quick-add 🛒 and Buy Now 💰 buttons (Lecture Slide 23).
- **Domain Constraints Enforced:** Strict **minimum price delimiter of ₱100** across all items in `Product.catalog`.

---

### Day 4 – Interactive 360° Inspection Scrubber & LUT Split Tester Prototype
- **Focus:** Building the two signature Dart/Flutter Edge interactive widgets.
- **Widgets Explored & Implemented:**
  - `Image.network` with custom `loadingBuilder` and `errorBuilder` (Lecture Slide 21).
  - `Row` & `Container` with gradients, borders, and drop shadows (Lecture Slides 19 & 24).
- **Interactive Tools Developed:**
  - `ThreeSixtyViewer`: Built-in 360-degree image scrubber swiping horizontally across a sequence of 8 photos (`lib/widgets/three_sixty_viewer.dart`).
  - `LutSplitPreview`: Initial `ColorFiltered` split-screen slider (`lib/widgets/lut_split_preview.dart`).
  - `QuantityStepper`: Delimiter component strictly enforcing positive quantities (`quantity >= 1`, minus button disabled at 1) (`lib/widgets/quantity_stepper.dart`).

---

### Day 5 – Stateful Cart Management & Validated Forms
- **Focus:** Cart state management (`CartController`), color & size variant tracking (`CartItem`), and lecture form validation.
- **Widgets Explored & Implemented:**
  - `Form` & `GlobalKey<FormState>`: Form container and validation key (`_formKey.currentState!.validate()`) in `lib/screens/checkout_screen.dart` (Lecture Slides 2, 3, 11).
  - `FormField<String>` & `FormField<bool>`: Custom selection and terms checkbox fields with inline validation errors (Lecture Slides 5, 12).
  - `TextFormField`: Validated text inputs for buyer name and email address.

---

### Day 6 – Polyhedral Dice Physics & Floating Action Button
- **Focus:** Interactive tabletop utility and quick action controls.
- **Widgets Explored & Implemented:**
  - `Scaffold.floatingActionButton`: `FloatingActionButton.extended` anchored to the bottom-right of `HomeScreen` (Lecture Slide 18).
  - `Transform` (Matrix Transformation): Exact Lecture Slide 6 syntax `Transform(alignment: Alignment.topLeft, transform: Matrix4.skewY(0.08)..rotateZ(-math.pi / 28.0), child: ...)` applied in `ProductCard` and `DiceRollerSheet`.

---

### Day 7 – Advanced Form Inputs (Numeric & Obscured Password Fields)
- **Focus:** Completing specialized input widget types from Lecture Slides 1 & 4.
- **Widgets Explored & Implemented:**
  - `TextFormField` with `keyboardType: TextInputType.number` for GCash/Maya mobile payment numbers (Lecture Slide 1).
  - `TextFormField` with `keyboardType: TextInputType.visiblePassword` and `obscureText: true` for the Download Vault PIN with visibility toggle (Lecture Slide 4).

---

### Day 8 – Accessibility (`semanticLabel`) & Baseline Widget Test Suite
- **Focus:** Screen reader accessibility and automated widget testing.
- **Widgets Explored & Implemented:**
  - `Icon` with `semanticLabel` (Lecture Slide 22) across all primary icons.
  - Created `test/widget_test.dart` verifying Peso formatting, positive quantity stepper delimiter, `FloatingActionButton`, and `CarouselView`.

---

### Day 9 – Product Alignment: Upgrading to the Dual E-Commerce Type Architecture
- **Focus:** Aligning the application with the team's official **Dual E-Commerce Type** specification:
  1. **Digital Pattern & LUT Tester Market**
  2. **Tabletop RPG Miniatures & Dice Swap**
- **System Changes Applied:**
  - Introduced the `StoreType` enum (`all`, `digitalCreator`, `tabletopRpg`) in `lib/models/product.dart`.
  - Built the `_DualStoreSwitcher` bar on `HomeScreen` and updated the `Drawer` so users and evaluators can switch between **Dual E-Commerce (All)**, **Digital Pattern & LUT Market**, and **Tabletop RPG & Dice Swap** with one tap.

---

### Day 10 – Store Type 1 Expansion: Digital Pattern & LUT Tester Market Catalog
- **Focus:** Populating the micro-store for digital creators selling Lightroom presets (LUTs), sewing patterns, and 3D print `.stl` files.
- **System Changes Applied:**
  - Added dedicated categories in `ProductCategory`: `presets` (*Lightroom LUTs*), `sewingPatterns` (*Sewing Patterns*), and `stlFiles` (*3D Print .STL*).
  - Added authentic non-AI catalog items with downloadable archive filenames (`downloadFileName`):
    - `lut-01`: **Nordic Tavern Lightroom & LUT Preset Pack** (`₱350` • `nordic_tavern_luts_v2.zip`)
    - `lut-02`: **Cinematic Portrait & Street Creator LUTs** (`₱280` • `cinematic_street_luts_pack.zip`)
    - `pattern-01`: **Viking Ranger Cloak & Tunic Sewing Pattern (.PDF / .DXF)** (`₱320` • `ranger_cloak_sewing_pattern_a4_a0.zip`)
    - `stl-01`: **Modular Dungeon Archway & Runes 3D Print (.STL)** (`₱250` • `modular_dungeon_archway_presupported_stl.zip`)

---

### Day 11 – Upgrading the `ColorFiltered` Split-Screen Slider for Buyer Phone Photos
- **Focus:** Fulfilling the exact Dart/Flutter Edge for Store Type 1: *"For presets, use Flutter's `ColorFiltered` widget and a split-screen slider so buyers can preview the seller's filter on their own phone photos before purchasing."*
- **System Changes Applied:**
  - Enhanced `LutSplitPreview` (`lib/widgets/lut_split_preview.dart`) with a horizontal **Phone Photo Switcher** (`Seller Sample`, `📱 Phone: Portrait Owl`, `📱 Phone: Street Light`, `📱 Phone: Tabletop Shot`, and `+ My Phone Photo` custom URL loader).
  - Buyers can drag the vertical split-screen divider across any phone photo to compare `BEFORE (RAW PHOTO)` vs `AFTER (LUT FILTER)` across 4 real-time `ColorFilter.matrix` presets.

---

### Day 12 – Store Type 2 Refinement: Tabletop RPG Miniatures & Dice Swap (3 Categories)
- **Focus:** Fulfilling the exact Store Type 2 specification: *"Focused entirely on a single passionate community with just three categories: Minis, Dice, and Digital Maps. Dart/Flutter Edge: Add a built-in 360-degree image scrubber (swiping horizontally across a sequence of 8 photos) so buyers can inspect the paint job on a miniature."*
- **System Changes Applied:**
  - Configured `ProductCategory.forStore(StoreType.tabletopRpg)` to filter strictly to `[All Items, Minis, Dice, Digital Maps]`.
  - Verified the 8-photo horizontal sequence in `ThreeSixtyViewer` (`lib/widgets/three_sixty_viewer.dart`) on both painted miniature listings (`mini-01` & `mini-02`).

---

### Day 13 – Pure Digital Delivery, Simple Checkout & Cart Stepper Fix
- **Focus:** Fulfilling *"Pure digital delivery—no shipping addresses, couriers, or physical inventory tracking. Once paid, the app unlocks a download link"* and *"Demonstrate simple checkout"*.
- **System Changes Applied:**
  - Refactored `CartController` (`lib/controllers/cart_controller.dart`) to set `deliveryFee => 0.0` (Zero courier/shipping fees) and added `updateQuantity(CartItem item, int newQuantity)` enforcing `newQuantity >= 1`.
  - Fixed `CartScreen` (`lib/screens/cart_screen.dart`) so the cart's `QuantityStepper` properly increments and decrements while preventing zero or negative quantities.
  - Refactored `CheckoutScreen` (`lib/screens/checkout_screen.dart`) to remove shipping addresses and courier selectors, replacing them with an **Instant Payment & Unlock Method** (`FormField<String>` for GCash / Maya) and an **Instant Download Links Unlocked** confirmation dialog with individual **Download** buttons for every purchased item.

---

### Day 14 – Dev Environment Restoration & Android SDK / Gradle Configuration
- **Focus:** Restoring the development toolchain after laptop reset and preparing the native Android build pipeline.
- **System Changes Applied:**
  - Installed portable **Git 2.56.0** (`C:\src\git\cmd`) and **Eclipse Temurin OpenJDK 17** (`C:\src\jdk\jdk-17.0.21+9`).
  - Linked Flutter 3.47.8 to **Android Studio** (`C:\Android Studio`) and **Android SDK** (`C:\AndroidSDK`).
  - Configured VS Code settings (`.vscode/settings.json`) and verified zero static analysis warnings via `analyze_files`.

---

### Day 15 – 100x Interactive Studio Upgrades, Building Installable Mobile `.APK` (`MarketingVikings.apk`) & Final Verification
- **Focus:** Adding high-impact interactive studio features, compiling the standalone Android `.apk` package for direct phone installation during the classroom presentation, and completing all Day 1–15 documentation.
- **100x System Enhancements Applied:**
  - **Strict & Secure Authentication (`lib/controllers/auth_controller.dart`, `lib/screens/auth_screen.dart`):** Added Sign In (Log In), Sign Out (Log Out), Create New Account (Sign Up) with a live 5-Rule Password Strength Meter, and **Email Password Reset with 6-Digit OTP Verification & Security Email Notification Log**.
  - **16 Real, Non-AI Wikimedia Commons Photographs (`assets/images/*.jpg`, `lib/widgets/product_photo.dart`):** Downloaded 16 authentic, non-AI photographs of real painted tabletop miniatures, polyhedral dice, historic cartographic maps, tailoring sewing patterns, 3D prints, and studio portrait photography directly from Wikimedia Commons into `assets/images/` and wired `ProductPhoto` across all screens so **zero broken image icons (`Icons.broken_image`) can ever appear** online or offline.
  - **Instant Search Results UX (`lib/screens/home_screen.dart`):** Positioned the Search Bar at the top of `HomeScreen` and automatically collapsed `Guild Spotlight` and `Material 3 CarouselView` whenever the user searches or filters by `Saved` so matching items appear immediately below the search bar without scrolling.
  - **Upgraded `LutSplitPreview` Studio (`lib/widgets/lut_split_preview.dart`):** Added 6 sample phone photos (`Portrait Owl`, `Street Light`, `Tabletop Shot`, `Cosplay Cloak`, `Dice Macro`), 6 `ColorFiltered` presets, live **LUT Strength (`20%–100%`)** & **Exposure EV (`-25..+25`)** sliders, and an **`Auto Sweep`** presentation play button.
  - **Upgraded `ThreeSixtyViewer` (`lib/widgets/three_sixty_viewer.dart`):** Added **3x Magnifying Loupe Pinch-to-Zoom Mode**, angle-by-angle miniature paint layer notes (`0°` to `315°`), and an interactive 8-angle scrubber slider.
  - **Category-Specific Interactive Calculators (`lib/screens/product_detail_screen.dart`):** Added the **Tailor Fabric Yardage & Pattern Sheet Estimator** for Sewing Patterns, the **3D Print `.STL` Slicer Resin/Filament Estimator** for `.STL` files, and the **5ft Tactical VTT Grid Overlay** toggle for Digital Maps.
  - **Persistent Unlocked Downloads Vault & Official Receipts (`lib/screens/vault_screen.dart`, `lib/controllers/vault_controller.dart`):** Stores all unlocked `.DNG`, `.PDF`, `.STL`, and `.ZIP` files after Simple Checkout with unique License Keys (`MV-LUT-STL-...`) and printable Peso (`₱`) receipts.
  - **Community "Sell / Swap Item +" Creator Studio (`lib/widgets/creator_listing_modal.dart`):** Allows creators and players to publish new listings live into either Dual E-Commerce store (enforcing `price >= ₱100`).
  - **Wishlist Favorites (`❤️`), Promo Vouchers (`VIKING10`, `CREATOR50`) & Multi-Polyhedral Dice (`D4–D100`):** Added bookmarking (`lib/controllers/wishlist_controller.dart`), cart promo chips (`lib/screens/cart_screen.dart`), one-tap `Quick Fill Demo` checkout (`lib/screens/checkout_screen.dart`), and full `D4`–`D100` dice rolling (`lib/widgets/dice_roller_sheet.dart`).
  - **Compiled Final `.APK`:** Built and exported **`C:\App\marketing_vikings\MarketingVikings.apk`** with 0 analyzer errors and 100% widget test pass rate.

---

## 4. How to Run in VS Code & Install on Your Android Phone

### A. Install Directly on Your Android Phone (No Laptop Needed During Demo!)
1. Copy **`C:\App\marketing_vikings\MarketingVikings.apk`** to your Android phone (via Google Drive, Messenger, Telegram, Email, or USB cable).
2. Tap **`MarketingVikings.apk`** on your phone and select **Install** (if prompted by Android Play Protect for a student debug/release build, tap *More details -> Install anyway*).
3. Open **Marketing Vikings** from your phone's home screen!

### B. Run Live in VS Code (Chrome or Android Emulator)
```powershell
cd C:\App\marketing_vikings
flutter run -d chrome
```
Or press **`F5`** inside VS Code with `lib/main.dart` open!
