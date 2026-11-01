# Verification — 2026-11-01

- `flutter analyze`: no issues found.
- `flutter test --dart-define=COUNTRY_PREVIEWS=true test/country_ui_test.dart test/citadel_hub_test.dart test/frontier_ui_test.dart test/warfare_ui_test.dart test/warfare_test.dart test/frontier_test.dart --reporter expanded`: all 101 tests passed.
- `flutter build web --release`: built `build/web` successfully.
- Local server at `http://127.0.0.1:4173/` returns 200 for the rebuilt app and the new northern country background asset.
- Actual Flutter-rendered PNGs inspected for all three country panoramas, narrow layouts, embassy peace/war states and border details. Images use live fixture values; production uses saved game state.
- Covered desktop/tablet/phone/landscape viewports: 1440×900, 1024×768, 390×844, 320×568, 844×390.
- Navigation checks compare both in-memory and persisted state before/after opening all three destinations. Envoy cancel/confirm checks cover treasury, actions, relation, other countries remaining unchanged and persistence. Additional checks cover treaty debt, country report filtering, correct frontier destination, old saves and busy-state controls.

No new game rules, schema changes or migrations were introduced. Preview art source and production background prompts are in `background-prompts.txt`; the built-in ImageGen PNG originals remain under the generated_images directory.
