# Story Sizing — Vạn Tuế native Android/iOS

**Readiness:** Needs Split — prototype, durable gameplay and store delivery are separate outcomes.  
**Recommended size:** No final Story Points; provisional effort intervals below.  
**Confidence:** Low — no Project DNA store, no native build or native storage validation.  
**Reference basis:** House ladder, ODAI-26 (5 points), governing behavior with meaningful verification. Full delivery has broader outcomes.  
**Dominant drivers:** Storage correctness and native regression.  
**DNA status:** Absent; no tiered footprint is claimed.

> Exploratory planning requested on 2026-10-31. Guideline v1.5 local snapshot. No Jira key or confirmed acceptance criteria. Expected AI assistance does not reduce Story Points. Effort intervals are engineering judgment, not a conversion from points. A confirmed point estimate would require refinement and PO/BU Head confirmation.

## 1. What the Story asks for

Outcome: install and play the current game as a Flutter Android/iOS app.

Proposed acceptance criteria, pending scope confirmation:

- AC-01: Launch a compiled Flutter application on Android and iOS simulators.
- AC-02: Create, advance, close and reopen a reign, retaining archive and scoreboard offline.
- AC-03: Preserve archive transaction rollback, duplicate-command protection, schema handling and report-read acknowledgements.
- AC-04: Support mobile safe areas, keyboard, Android Back, resume, text and map scrolling without blocking gameplay.
- AC-05: Install a signed internal Android release and an iOS device/TestFlight release; verify release-mode gameplay.

Optional next endpoint: prepare listings and submit both stores. No online accounts, cloud sync, ads, purchases, notifications, new gameplay, or automatic transfer of existing browser saves are assumed.

## 2. Where it lands in the Project DNA

| Item | Value |
|---|---|
| Placement | Unavailable: no DNA store |
| Platform fit | ADAPT, based on source inspection only |
| Footprint | Rules and tiered neighbors unknown; not equivalent to a DNA-backed count |
| Neighbor evidence | None available |

Source observations:

- No android/ or ios/ runner directory exists. Flutter code and bundled assets already exist.
- lib/game/data/store_factory_stub.dart:3 throws UnsupportedError outside Web.
- lib/game/data/game_store.dart:7 defines a small storage interface. IndexedGameStore accepts an IdbFactory and stores the serialized archive in a transaction.
- lib/game/presentation/outcome_read_factory_stub.dart:3 returns null; report acknowledgements use memory on native today.
- lib/main.dart still presents browser-specific storage failure guidance.
- There are 85 Dart source files and 64 top-level test files, including 30 containing widget tests. These are file counts, not passing test counts or Story Points.
- Three storage-related test files are browser-only. Native storage needs its own regression coverage.
- Assets occupy approximately 21 MB on disk. Native decoded-image memory and release package size remain unmeasured.

Already covered in DNA: none established. Source reuse candidates are the game engine, models, widgets, assets and existing tests; no native runtime behavior is proven by this inspection.

## 3. Factor assessment

| Factor | Rating | Evidence |
|---|---|---|
| Functional scope | Unknown | Missing features/findings; AC-01–05 are proposed |
| Data and UX/UI impact | Unknown | Missing surfaces/findings; source shows two persistence concerns |
| Technical complexity | Unknown | Missing services/findings; adapter compatibility unverified |
| Integrations and dependencies | Unknown | Missing edges/intakes; signing access unverified |
| Testing and regression | Unknown | No tiered DNA footprint or native integration results |
| Uncertainty | High | Native build, durable storage and release device behavior untested |

Dominant drivers: storage transactions protect the entire reign, and mobile lifecycle behavior can expose data loss despite a successful build. These need verification beyond visual parity.

## 4. Comparison with the house calibration ladder

ODAI-26 is the closest driver signature for the persistence slice: a small code surface governs behavior elsewhere and needs meaningful negative-path verification. Its 5 points are a reference, not a proposed size here. Its footprint is 3 covering-feature rules, 1 evidence file, and 0 STRONG/0 MEDIUM neighbors. The target metrics are unknown, so a numeric comparison would be unsupported.

The complete request includes independent platform installation, usability and distribution outcomes. It should not receive one aggregate Story Point number. The suite adopted the IAM anchors as a house ladder on 2026-08-25; this is a suite convention rather than a claim that the underlying guideline publishes an organization-wide calibration.

Local refinement: none.

## 5. Recommendation

No final Story Points. Planning effort assumes the same offline feature set, shared Flutter UI/engine, available developer accounts, and no major toolchain migration.

| Work package | Person-days, including implementation and relevant checks |
|---|---:|
| Android/iOS runners, identifiers and build configuration | 0.5–1 |
| Durable archive and acknowledgement storage; transaction regression | 1.5–3 |
| Mobile interaction, Back, keyboard and lifecycle adjustments | 1–2 |
| Release performance and bundled-image checks | 0.5–1 |
| Cross-platform gameplay, persistence and upgrade regression; fixes | 2–3 |
| Internal release signing, packaging and installation verification | 0.5–1 |
| Store assets, declarations, listings and submission preparation | 2–4 |

Cumulative milestones:

- Simulator prototype: 2–4 person-days, a subset of the packages above.
- Internal beta on both platforms: 6–11 person-days.
- Both store submissions prepared: 8–15 person-days.
- Planning allowance with approximately 20–30% contingency: 10–19 person-days.

Intervals overlap by milestone and must not be added together. Person-days measure effort, not a committed calendar duration. Review queues, account enrollment and external approvals are excluded from elapsed-time predictions. No tests or native builds were executed during this estimate.

## 6. Split recommendation

| Slice | Testable outcome | AC | DNA anchor | Indicative size |
|---|---|---|---|---|
| Native prototype | Launch and start a new reign on both simulators | AC-01 | Unavailable | Unassigned |
| Durable offline gameplay | Reopen a saved reign and preserve read acknowledgements; rollback failed commands | AC-02–03 | Unavailable | Unassigned |
| Mobile playability | Complete a season with mobile navigation and resume | AC-04 | Unavailable | Unassigned |
| Internal distribution | Install and play signed release builds | AC-05 | Unavailable | Unassigned |
| Public distribution | Reviewable store submissions | Optional scope | Unavailable | Unassigned |

Order: prototype, persistence, usability, internal release, store submission. Each slice needs its own refined criteria before assigning points.

## 7. Assumptions

Flutter native compilation is the intended meaning of native; no Kotlin/Swift UI rewrite is assumed. Android/iOS share the current Flutter gameplay and widgets. The native app begins with its own local saves. A browser-to-app import/export path is additional work, provisionally 1–3 person-days for a user-mediated file transfer with validation; cross-device sync is a separate feature.

An idb_sqflite adapter could preserve the existing IdbFactory boundary. Its documentation supports Android/iOS, but dependency versions, paths, transaction abort behavior and the installed Flutter SDK must be validated. This is a candidate approach rather than a proven drop-in replacement.

## 8. Questions before confirmation

These do not block the requested exploratory estimate:

1. BA: Is the delivery endpoint simulators, internal device installation, or public stores? This changes functional and distribution scope.
2. BA: Must existing Web saves move to the mobile app? This adds a data-transfer outcome.
3. TL: Can the chosen adapter pass durable-save and rollback checks on both platforms with the current SDK? A short native prototype should resolve this before a committed schedule.

## 9. Self-check

- [ ] Confirmed outcome, AC and Definition of Done: proposed only.
- [ ] Complete impact map: DNA absent.
- [x] Testing, dependencies and uncertainty included.
- [x] House ladder reviewed; no unsupported aggregate points assigned.
- [x] Expected AI assistance did not reduce points.
- [x] Split recommended.

Sources: [Flutter compilation and platform FAQ](https://docs.flutter.dev/resources/faq), [idb_sqflite maintainer documentation](https://pub.dev/packages/idb_sqflite), [Android release guide](https://docs.flutter.dev/deployment/android), [iOS release guide](https://docs.flutter.dev/deployment/ios).
