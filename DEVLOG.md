# Marketing Vikings – Development Log
App: **Tabletop RPG Miniatures & Dice Swap**
Subject: Mobile Application Development (Flutter)

---

## Day 1 – October 28, 2026
**Goal:** Install Flutter and build the app skeleton.

**Done:**
- Installed Flutter SDK 3.47.8 (stable) in `C:\src\flutter` and added it to PATH
- Installed the Flutter extension in VS Code
- Ran `flutter doctor` (Flutter ✅, Chrome ✅)
- Created the project `marketing_vikings` with `flutter create`
- Built the home screen skeleton using:
  - **Scaffold** – page layout
  - **AppBar** – top bar with the shop name
  - **Column** – stacks the sections vertically
  - **Text** – shop name, description, section titles
  - **Placeholder** – reserved spots for categories, products, and add-ons
- Replaced the default counter test with a home screen test (`flutter test` passes)

**Day 1 polish:**
- Organized the code into folders: `screens/`, `widgets/`, `theme/`
- Added a custom dark fantasy theme (dragon red, gold, parchment) in `app_theme.dart`
- Added a welcome banner with a gradient, a footer, and reusable `SectionTitle` and `ComingSoonBox` widgets
- Kept the content phone-width (max 600px) so it looks good in Chrome too
- Changed the Android app label to "Marketing Vikings"

**Problems / what I learned:**
- _(write yours here)_

**Next (Day 2):** SVG logo in the AppBar, navigation drawer, app colors.
