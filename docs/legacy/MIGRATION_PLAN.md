# Srpski_card to Flessel Migration Plan

## Purpose

This document is the single source of truth for the migration of the srpski_card Flutter app to the Flessel UI library and the full renaming of the project to "langwij". It exists so that any session — including after context compaction or a restart — can recover the full state of the migration by reading this file plus `MIGRATION_MATRIX.md`.

The plan is mostly static: it captures decisions, principles, and phase structure. Dynamic per-widget progress lives in `MIGRATION_MATRIX.md`. The `Current state` section below is the one part of this file that updates at phase boundaries.

## Context

### srpski_card
A Flutter prototype for learning Serbian and other languages. Lives at `front/` inside this repo. Uses `flutter_riverpod`, `go_router`, `sqflite`, `shared_preferences`, `phosphor_flutter`, `country_flags`, `google_fonts`. Current package name: `srpski_card`. Version 1.0.4+6 per pubspec.

### Flessel
UI library developed as part of the `vessel` sibling repo, checked out here at `.vessel/packages/flessel/`. Consumed by `front/pubspec.yaml` as a path dependency. Flessel is the canonical UI library for all future projects — strengthening it is a first-class goal, not a side effect of this migration.

### Vessel (old)
Before flessel existed, srpski_card grew its own set of `Vessel*` custom widgets under `front/lib/shared/ui/` along with `VesselThemeData`, `VesselFonts`, `VesselLayout` under `front/lib/app/theme/` and `front/lib/app/layout/`. This set is being fully retired. The name collision with the sibling `vessel` repo is historical — the old srpski widgets predate flessel and share nothing with the current vessel repo.

### State before migration
- 51 custom widget classes identified across `front/lib/shared/ui/` and `front/lib/features/vocab/widgets/`
- Zero `package:flessel` imports anywhere in `front/lib/`
- `VesselThemeData` has approximately 200 properties; `FlesselThemeData` has approximately 60
- `VesselFonts` has approximately 30 named styles
- `VesselLayout` has approximately 50 constants (mix of generic and product-specific)
- App identity: package name `srpski_card`, git folder `srpski_card`, native IDs match

### Rename in scope
Full identity rename from `srpski_card` to `langwij`: pubspec name, imports, Android namespace and applicationId, Kotlin package path, iOS bundle ID, macOS / Linux / Windows desktop project identifiers, IntelliJ module file, README references, and the git folder name (performed externally by the project owner outside the session).

## Goals

1. Every widget in `front/lib/` uses flessel as its sole source of visual primitives
2. Flessel is strengthened — not worked around — wherever srpski needs something flessel lacks
3. Post-migration, only two prefixes exist: `Flessel*` (library primitives) and `Langwij*` (product-specific composites that take domain models)
4. Full project identity rename completes as part of the same effort
5. Every decision is explicitly approved before execution — zero silent changes

## Non-goals

1. Visual identity overhaul. `theme_01` is the starting theme; visual tuning for langwij is future work, not part of this migration
2. Feature additions beyond what is needed for flessel compliance
3. Flutter framework upgrades, state management changes, routing changes, database schema changes
4. Retrofitting any other project to flessel

## Locked principles

Seven principles, agreed during Phase 0 alignment, fixed for the duration of the migration.

1. **Strict flessel purity for theme and fonts.** No `LangwijTheme`, no `LangwijFonts`. Every color and every text style comes from `FlesselThemeData` and `FlesselFonts` directly. If srpski needs something that does not exist there, it becomes a flessel grow proposal.

2. **Grow flessel only with per-item approval.** Every new control, theme property, font style, layout constant, or existing-control parameter addition is a separate approval item. No bundled "while we are at it" changes.

3. **Two prefixes only post-migration.** `Flessel*` for library primitives consumed from `package:flessel`. `Langwij*` for product-specific composites living in `front/lib/` that take domain models and compose flessel primitives internally. All `Vessel*` and `Project*` widgets are deleted.

4. **Starting theme.** srpski installs `FlesselThemeCatalog.byId('theme_01')` at the root of the widget tree. Picking or tuning a different theme for the langwij product is a separate, later decision.

5. **Flessel change discipline.** Every flessel grow lands as a single coherent change that updates:
   - Library implementation under `.vessel/packages/flessel/lib/src/`
   - `theme_01..05` files for any new theme field (values supplied for every theme)
   - Barrel export in `.vessel/packages/flessel/lib/flessel.dart`
   - Controls inventory in `.vessel/packages/flessel/consumer.claude.md`
   - Documentation page in `.vessel/packages/flessel/example/`
   - Analyzer stays clean on both the flessel package and its example app

6. **Per-item approval before every execution.** No batch approvals, no "obvious" changes executed silently. The plan and matrix are proposals; execution happens one approved unit at a time with the literal `unleash` trigger per unit.

7. **Four decision categories plus DELETE.** Every widget in the matrix gets exactly one of:
   - `SWITCH` — flessel equivalent is sufficient; rewrite call sites and delete the Vessel version
   - `EXTEND_FLESSEL` — flessel equivalent exists but lacks features; grow it upstream, then switch
   - `ADD_TO_FLESSEL` — no flessel equivalent; port a generic version up into flessel, then switch
   - `LANGWIJ_COMPOSITE` — widget takes a domain model or is too product-specific for flessel; becomes a new `Langwij*` widget that composes flessel primitives at the app layer
   - `DELETE` — widget is no longer needed; removed with no replacement

## Layout policy (resolution of Q9)

Theme and fonts are strict: no local layer, flessel only. Layout is different — a local `LangwijLayout` layer MAY exist, but only if an approved constant requires it.

### Why layout differs from theme and fonts

Theme colors and font styles are inherently tied to visual identity, and flessel's theme system is designed to own that identity entirely. A product-specific theme layer would fragment that ownership.

Layout is subtler. Flessel provides generic spatial primitives — gap tiers, control min-heights per `FlesselSize`, navbar and app-bar heights, icon sizes, border widths. These are reusable across any project. But a product like langwij has dimensions that are **specific to particular composite widgets** and **not reusable** across projects, for example the height of a vocab deck tile, the aspect ratio of a round quiz option tile, the width of a language flag chip. Three things must be true about those dimensions:

1. They cannot be hardcoded in widget code (flessel consumer rule)
2. They should not pollute flessel (flessel must stay generic; a name like `vocabTileHeight` means nothing to another project)
3. If multiple widgets in the product share one, they need a single source of truth

### Per-constant disposition options

Every product-specific constant currently in `VesselLayout` gets exactly one of:

- **GROW_FLESSEL** — the dimension is generic enough to live in flessel under a generic name (for example `tileHeightL` instead of `vocabTileHeight`). Requires per-property flessel grow approval.
- **LANGWIJ_LAYOUT** — the dimension is product-specific but needs to be centralized. Goes into a new `LangwijLayout` class. The layer only materializes if at least one approved constant lands there. Per-constant, three possible shapes are picked:
  - *Shape A — raw constants*: `static const double vocabTileHeight = 180;`
  - *Shape B — flessel-derived expressions*: `static double get vocabTileHeight => FlesselLayout.gapXl * 7 + FlesselLayout.gapXs;`
  - *Shape C — size-scaled*: `LangwijLayout.vocabTileHeight(FlesselSize.m)` for size-responsive product dimensions
- **COMPOSE_INLINE** — the dimension is derivable from flessel primitives without a named constant, via layout widgets (`Flexible`, `Wrap`, `AspectRatio`, `FlesselSize` passthrough). No constant anywhere; the widget shape computes itself.
- **DROP** — the dimension is incidental; the widget works without pinning it.
- **REDESIGN** — the widget is too tied to a specific magic number; it gets reshaped under flessel's constraints.

## Decision categories reference

Each decision carries a specific execution protocol.

### SWITCH
Trigger condition: Vessel widget has a flessel equivalent whose feature surface covers every current use.

Protocol:
1. Identify every call site in `front/lib/`
2. Rewrite each call site to use the flessel widget
3. Run `flutter analyze` on `front/`
4. When zero call sites reference the Vessel widget, delete its source file
5. Run analyzer again

### EXTEND_FLESSEL
Trigger condition: flessel equivalent exists but lacks one or more features the Vessel version provides.

Protocol:
1. Enumerate every grow point needed (new parameter, new variant, new theme field, new layout constant, new font style)
2. Propose each grow point individually for approval
3. After all grow points approved, make a single coherent flessel change implementing all of them
4. Update theme files, barrel, consumer.claude.md, example app page — per the flessel change discipline
5. Run analyzer on the flessel package
6. Proceed as SWITCH from step 2

### ADD_TO_FLESSEL
Trigger condition: no flessel equivalent exists and the widget is generic enough to belong in flessel (takes only primitive params, no domain models, reusable across projects).

Protocol:
1. Design the flessel version: name (`Flessel` prefix plus UI concept), props (all primitive), size variants (`FlesselSize`), visual variants, callbacks
2. Enumerate grow points needed in `FlesselThemeData`, `FlesselLayout`, `FlesselFonts`
3. Propose each grow point individually for approval
4. After all approved, implement the new control under `.vessel/packages/flessel/lib/src/controls/`
5. Create a new example app page documenting the control
6. Update barrel, consumer.claude.md
7. Run analyzer on the flessel package
8. Proceed as SWITCH — rewrite call sites in `front/lib/`, delete the Vessel version

### LANGWIJ_COMPOSITE
Trigger condition: widget takes a domain model (for example `Tag`, `CardModel`, `VocabDeckTileData`) or is too tied to product features to live in flessel.

Protocol:
1. Design the Langwij widget: name (`Langwij` prefix plus concept), props including the domain model type
2. Choose a location — `front/lib/shared/ui/langwij_*.dart` for cross-feature composites, `front/lib/features/<feature>/widgets/langwij_*.dart` for feature-local
3. Implementation uses only `FlesselThemes.of(context)`, `FlesselFonts.*`, `FlesselLayout.*`, and flessel primitives (`FlesselCard`, `FlesselTile`, `FlesselTextInput`, etc.)
4. No hardcoded colors, sizes, or strings
5. Any layout dimension needed resolves through the layout policy above
6. Rewrite call sites in `front/lib/`
7. When zero call sites reference the Vessel version, delete it

### DELETE
Trigger condition: the widget is no longer needed — its use was vestigial, or its purpose is fulfilled by a flessel primitive used directly without any wrapper.

Protocol:
1. Confirm every call site can be rewritten to not use the widget
2. Rewrite call sites
3. Delete the Vessel source file

## Phase plan

### Phase 0 — Alignment
**Status**: complete.

Inputs: initial task statement, reconnaissance of both codebases.
Outputs: seven locked principles, layout policy, decision categories, phase plan, this document.
Gate: all clarifying questions answered; this document exists.

### Phase 1 — Widgets decision matrix
**Status**: not started.

Inputs: this document, full reconnaissance of `front/lib/` widgets, full reconnaissance of `.vessel/packages/flessel/lib/`.
Outputs: `MIGRATION_MATRIX.md` containing one row per identified Vessel / Project widget (approximately 51 rows). Columns: `#`, `Vessel widget`, `Location`, `Flessel equivalent`, `Gap`, `Proposed decision`, `Rationale`, `Grow points likely needed`, `Example app page needed`, `Approval status`.
Gate: matrix produced, ready for row-by-row approval.
Notes: read-only analysis phase; the matrix is a proposal, no code changes yet. Producing the matrix does not require `unleash`; writing `MIGRATION_MATRIX.md` itself does. Also during this phase: inspect `.vessel/packages/flessel/example/` structure to understand the documentation pattern so each grow point carries a concrete example-app task.

### Phase 2 — Full project rename
**Status**: not started. Blocked on Phase 1 completion.

**Phase 2a — code-side renames** (performed inside the session):
1. `front/pubspec.yaml`: `name: srpski_card` to `name: langwij`, description update
2. Every `import 'package:srpski_card/...'` to `import 'package:langwij/...'` across `front/lib/`, `front/test/`, `front/tool/`, `front/scripts/`
3. `front/l10n.yaml`: update `output-class` / output file naming if referenced
4. `front/README.md` project name
5. Android `android/app/build.gradle`: `namespace`, `applicationId`
6. Android `AndroidManifest.xml`: package references
7. Android Kotlin source: move files to new package path, update `package` declarations
8. iOS `ios/Runner.xcodeproj/project.pbxproj`: `PRODUCT_BUNDLE_IDENTIFIER`
9. iOS `Info.plist`: `CFBundleName`, `CFBundleDisplayName`
10. macOS / Linux / Windows desktop project files: equivalent bundle IDs and product names
11. `flutter_launcher_icons` / `flutter_native_splash` references
12. IntelliJ module file `front/srpski_card.iml` renamed
13. Analyzer pass inside `front/`

**Phase 2b — folder rename** (performed by project owner, outside the session):
1. Session closed
2. `srpski_card/` folder renamed to `langwij/` at its parent directory
3. Session reopened from the new path

**Phase 2c — post-restart verification**:
1. `flutter clean` and `flutter pub get` in `front/`
2. `flutter analyze` clean
3. `flutter build` for at least one platform
4. Git status shows a consistent rename commit boundary

Gate for Phase 3: Phase 2c passes cleanly. If build fails on any platform, fix before proceeding.

### Phase 3 — Iterative widget migration
**Status**: not started.

**Phase 3a — install FlesselThemes at app root** (one-time setup):
Install `FlesselThemes(theme: FlesselThemeCatalog.byId('theme_01')!.data)` in the app widget tree, sitting alongside the existing `VesselThemes` wrapper. Both coexist during migration. New flessel-consuming widgets read from `FlesselThemes.of(context)`; surviving Vessel widgets keep using `VesselThemes.of(context)`. No widget migration happens in this sub-phase.

**Phase 3b..3z — per-widget migration**:
For each approved row in the matrix, in dependency order (primitives before composites; flessel grows before the SWITCH that depends on them):

- **SWITCH**: per protocol above
- **EXTEND_FLESSEL** / **ADD_TO_FLESSEL**: each grow point approved individually before flessel is touched. After approval, flessel change lands per the change discipline. Then SWITCH
- **LANGWIJ_COMPOSITE**: per protocol. Any layout dimension needed triggers the layout policy disposition, with per-constant approval at that moment
- **DELETE**: per protocol

Every unit of execution requires `unleash` at the moment of execution. Multiple units can be batched per `unleash` if explicitly stated.

Gate for Phase 4: `grep -r Vessel front/lib/` returns only Vessel source files that are explicitly scheduled for deletion in Phase 4 (theme, fonts, layout).

### Phase 4 — Theme, fonts, layout retirement
**Status**: not started. Blocked on Phase 3 completion.

Preconditions:
- Zero Vessel widget usages outside Vessel source files
- All widgets using `VesselThemes.of(context)`, `VesselFonts.*`, `VesselLayout.*` have been migrated to the flessel equivalents

Steps:
1. Remove the `VesselThemes` wrapper from the app root; `FlesselThemes` becomes the sole theme installer
2. Delete `front/lib/app/theme/vessel_themes.dart`
3. Delete `front/lib/app/theme/vessel_fonts.dart`
4. Delete all `front/lib/app/theme/themes/theme0N_theme.dart` files
5. Delete `front/lib/app/layout/vessel_layout.dart`
6. Delete `front/lib/shared/theme/app_theme.dart` if present (legacy file noted in reconnaissance)
7. Run analyzer; expect zero errors
8. Run the app; visual check

### Phase 5 — Localization cleanup
**Status**: not started.

During Phases 2–4, any hardcoded user-facing string encountered is flagged and added to l10n. Phase 5 is a final sweep.

Steps:
1. Grep for string literals in user-facing contexts in `front/lib/`: `Text(...)`, `label:`, `hint:`, `placeholder:`, `title:`, `tooltip:`
2. For each hit, add the appropriate entry to `front/lib/l10n/app_en.arb` plus other locale files
3. Replace the literal with the localized reference

### Phase 6 — Final verification
**Status**: not started.

Checklist:
1. `flutter analyze` clean on `.vessel/packages/flessel/`
2. `flutter analyze` clean on `.vessel/packages/flessel/example/`
3. `flutter analyze` clean on `front/`
4. `flutter build` succeeds for at least one platform
5. `grep -r "Vessel" front/lib/` returns zero hits
6. `grep -r "Project" front/lib/` returns zero hits for widget prefixes
7. `grep -r "srpski_card" front/` returns zero hits
8. Regex scan for `Color\(0x`, `.withOpacity(`, raw hex literals: zero hits in `front/lib/` widget code
9. Regex scan for `SizedBox\(` with width/height: zero hits outside approved `Langwij*` composites
10. No raw string literals in user-facing `Text(...)` positions
11. App runs; every screen manually verified
12. `MIGRATION_MATRIX.md` shows every row as approved and completed

## Current state

**Phase**: Phases 1, 2a, 3a–3n, 4, 5, and 6 (in-session items) complete. Only the manual screen-verification gate (Phase 6 #11) and external Phase 2b folder rename / Phase 2c post-restart verification remain.

**Principle 1 deviation reverted (2026-04-10)**: a previous session created `front/lib/shared/theme/langwij_theme.dart` (`LangwijThemeData` with retention/testBadge color fields) as a workaround for the deferred retention color grow. This violated locked principle 1 ("No `LangwijTheme`, no `LangwijFonts`") and the matrix row 48 deferral. The file has been deleted, both `_ProgressBadge` widgets in `group_list_screen.dart` and `agreement_group_list_screen.dart` rewritten to render plain neutral `FlesselTag`s per matrix row 48, and the `retentionColor()` helper dropped. Retention coloring remains DEFERRED and will land as a per-property flessel grow proposal in a future row.

**Phase 5 verified complete (2026-04-10)**: localization sweep over `front/lib/` found zero hardcoded user-facing copy literals. The sweep covered `Text(...)` first-arg positions, plus `label:` / `title:` / `hint:` / `tooltip:` / similar copy slots. Twenty literal hits were classified into three tiers: 11 acceptable as-is (the MaterialApp app identity `'Langwij'`, a heart-emoji glyph, pure percentage / integer interpolations like `'$pct%'`, the `' → '` visual separator between result_screen columns, the framework error fallback in app_router); 9 pre-localized compositions where every text token comes from `l10n.*` joined with `" "` or `" → "` glue at the widget layer (round_screen.dart and result_screen.dart quiz-feedback strings, langwij_bug_report_sheet.dart card preview); 0 hardcoded user-facing English copy. The 9 compositions are deferred to a future i18n cleanup pass that would convert them to ICU placeholder keys; that work is gated on a second locale being added, since `front/lib/l10n/` currently holds only `app_en.arb`. No file changes in `front/lib/` for Phase 5.

**Phase 6 in-session items complete (2026-04-10)**: ten of twelve checklist items resolved in-session.

- **Block A — regression greps (#5–10)**: clean. Zero hits for `Vessel`, `Project[A-Z]`, `srpski_card`, `Color(0x`, `.withOpacity(`, raw hex literals. Initial sweep surfaced two regression classes that survived Phase 3/4 quality gates and were fixed in cleanup CL-Phase6-A:
  - **10 raw `CircularProgressIndicator` sites** across 8 files (`agreement_group_list_screen.dart`, `group_list_screen.dart`, `language_screen.dart`, `lang_picker_screen.dart`, `vocab_deck_list_screen.dart`, `result_screen.dart`, `round_screen.dart` ×3, `settings_screen.dart`) — replaced with `FlesselSpinner()` (default `FlesselSize.s`) for full-screen loaders and `FlesselSpinner(size: FlesselSize.xs, color: t.textSecondary)` for the inline settings validator. The settings spinner change also eliminated a `SizedBox(width: 24, height: 24, ..., strokeWidth: 2)` triple-magic-number wrapper.
  - **1 `SizedBox`-as-spacer site** in `round_screen.dart:776` — `const SizedBox(width: FlesselLayout.gapS)` between two `Expanded` columns replaced with `const FlesselGap.s()` per consumer rule "All spacing between widgets uses `FlesselGap` (not raw `SizedBox`)".
- **Block B — flutter analyze (#1–3)**: zero errors on all three packages. Pre-existing non-blocking findings recorded:
  - `.vessel/packages/flessel/lib/src/theme/flessel_fonts.dart:12,14` — `_m08` and `_m08b` unused private declarations (warning level). Flessel-internal hygiene; deferred to flessel maintenance.
  - `front/lib/pages/lang_picker_screen.dart:37,42` — two `unnecessary_underscores` info-level lints in `(_, __)` error callbacks. The same pattern in `language_screen.dart:44` is suppressed with an `// ignore: unnecessary_underscores` directive; lang_picker_screen lacks the directive. Trivial fix deferred.
- **Block C — flutter build apk (#4)**: success. `flutter build apk` (release) completed in ~75s and produced `front/build/app/outputs/flutter-apk/app-release.apk` (70.6 MB). Build log surfaced one pre-existing pubspec issue: `cupertino_icons` font is referenced via an `IconData` somewhere but not declared in pubspec assets — non-blocking, build still succeeds via tree-shaking.
- **Block D — matrix sign-off (#12)**: `MIGRATION_MATRIX.md` updated. All 60 row statuses (48 widget rows + 12 enum/data-class rows) flipped from `APPROVED` to `DONE`, both in the summary table and per-row blocks. A new `## Sign-off (2026-04-10)` section at the top of the matrix records the completion date and the residual gates not covered by per-row sign-off.
- **Phase 5 localization sweep (#10)**: already verified above; counts as Phase 6 #10.

**Phase 6 residual gates (not done in-session, by design):**

1. **Phase 6 #11 — manual screen verification on a running build.** Meatbag's task. Build artifact at `front/build/app/outputs/flutter-apk/app-release.apk`; install on a device or emulator and walk every screen.
2. **Phase 2b — folder rename `srpski_card/` → `langwij/`** at the parent directory. External, by project owner. Closes the session, performs the rename, reopens.
3. **Phase 2c — post-restart `flutter clean` / `pub get` / `analyze` / `build`** after Phase 2b. External.

After items 1–3 are resolved, the migration is fully shipped.

**Last updated**: 2026-04-10.

This section updates at each phase boundary. Updates are small targeted edits; no other section of this document changes during the migration.

## Appendix A — Question and answer trail

This appendix captures the clarifying questions asked during Phase 0 alignment and the answers given, in order. It is paraphrased from session turns, not verbatim. Purpose: preserve the reasoning behind each locked decision so future sessions can understand why principles are what they are.

**Q1 — Flessel source of truth**
Is the flessel package at `.vessel/packages/flessel/` the canonical, source-of-truth version? Changes made there are real edits to the vessel repo.
**A1**: Yes, confirmed. Latest state and source of truth.

**Q2 — Theme migration scope**
Should srpski end up on (a) a catalog theme as-is, (b) a new srpski-specific theme added to the catalog, or (c) a supplementary app-level theme layered on top?
**A2**: Option (a), use `theme_01` directly. No local modifications. If flessel themes need improvement for srpski later, that is a separate discussion. For now, strict flessel theme usage.

**Q3 — Fonts strategy**
Same question shape as themes.
**A3**: Same as themes. Only fonts from flessel. Pick closest sizes. Strict flessel usage. No local modifications.

**Q4 — "Merge" decisions**
Should flessel grow to absorb features from srpski controls automatically, or is each grow a discussion?
**A4**: Grow flessel, but ask for every grow point. All of them are validated individually.

**Q5 — Scope of the first plan turn**
Full decision matrix or phased?
**A5**: Full per-control decision matrix.

**Q6 — Fourth decision category**
Widgets that take domain models cannot live in flessel (no domain models rule); they become app-level composites. Confirm.
**A6**: Agreed. Every control and component is still individually validated before work begins.

**Q7 — Theme strategy for product-specific properties**
Product-specific theme properties exist in `VesselThemeData` (Badge, DeckIcon, Retention, Tag palette, TestBadge). Hold them in an app-level theme layer, or push everything into flessel?
**A7**: Neither. If the theme needs to grow, it grows in flessel, property by property, each discussed. Strict flessel theme usage is the expectation. No app-level theme layer.

**Q8 — Fonts strategy for product-specific aliases**
**A8**: No fonts outside of flessel. Same discipline as themes.

**Q9 — Layout strategy for product-specific constants**
Two-turn resolution. First turn was misread as a firm rejection of any local layer (same as theme and fonts). Clarification turn: the original question was a request to explain the proposition better, not a rejection. A `LangwijLayout` layer may exist; the decision is per-constant, based on proposals from the session, approved item by item.
**A9**: See the Layout policy section above for the resolved form. Per-constant dispositions: GROW_FLESSEL / LANGWIJ_LAYOUT / COMPOSE_INLINE / DROP / REDESIGN. Three possible LangwijLayout shapes (raw / flessel-derived / size-scaled) picked per constant.

**Q10 — Prefix for product composites**
**A10**: "App" is a bad prefix. The project is being renamed to "langwij", so composites use the `Langwij*` prefix. Apply the project rename as part of this work.

**Q11 — Flessel work location and discipline**
**A11**: Agreed that flessel work happens at `.vessel/packages/flessel/`. Every flessel change must also update the example app, which has a dedicated documentation page per control.

**Q12 — Rename scope**
Widget prefix only, widget prefix plus pubspec, or full rename including folder and native projects?
**A12**: Full rename. Everywhere.

**Q13 — Matrix delivery format**
All four matrices upfront, or widgets upfront with theme/fonts/layout decisions surfacing per-widget during execution?
**A13**: Widgets-only upfront. Theme, fonts, and layout decisions surface per-widget during migration and are approved at that moment.

**Q14 — Flessel example app verification**
**A14**: Deferred to Phase 1.

**Q15 — Intent verification**
Check that no other answer was misread before producing the matrix.
**A15**: All seven locked principles and the corrected layout policy match intent. Confirmed.

## Appendix B — Reconnaissance snapshot

Frozen snapshot of initial codebase reconnaissance performed during Phase 0. Not updated as the migration progresses.

### App location
- Git root: this directory
- Flutter app: `front/`
- Flessel library: `.vessel/packages/flessel/` (path dep in `front/pubspec.yaml`)
- Flessel example app: `.vessel/packages/flessel/example/`

### App structure
```
front/lib/
  app/
    layout/      — VesselLayout constants (~50)
    providers/
    router/
    theme/       — VesselThemes, VesselThemeData, VesselFonts, theme01..05 files
  entities/      — domain models (Card, Tag, Deck, etc.)
  features/
    vocab/
      widgets/   — 4 feature-specific composites using domain models
  l10n/          — app_en.arb and generated l10n
  pages/
  shared/
    lib/
    repositories/
    theme/       — legacy app_theme.dart (to be deleted)
    ui/          — 33 files holding 47 shared widget classes
    validators/
  main.dart
```

### Widget count by base class
- `StatelessWidget`: 39
- `StatefulWidget`: 5
- `ConsumerWidget` (riverpod): 8 (all button variants plus lang button and button group)
- Factory functions: `showVesselBottomSheet`, `showBugReportSheet`, `showModeBottomSheet`, `VesselSnackBar` static

### Custom widgets grouped by category under `front/lib/shared/ui/`
- answer_tile: `VesselAnswerTile`
- bottom_navbar: `VesselNavBar`, `VesselNavBarIcon`
- bottom_sheet: `showVesselBottomSheet`, `showBugReportSheet`, `_BugReportSheetContent`, `showModeBottomSheet`, `_ModeTile`, `_CountTile`
- buttons: `VesselButton`, `VesselAccentButton`, `VesselDangerButton`, `VesselTextButton`, `VesselAccentTextButton`, `VesselDangerTextButton`, `ProjectButtonGroup`, `VesselButtonStyleResolver`
- card: `VesselCard`, `VesselAttentionCard`
- divider: `VesselDivider`
- gap: `VesselGap`
- inputs: `VesselTextInput`, `VesselDropdown`, `VesselInputRow` / `ProjectInputRow`, `VesselRadioTile`, `ProjectRadioGrid`, `VesselSliderInput`, `VesselTimeSlider`, `VesselDatePicker`, `VesselHourPicker`, `VesselCheckbox`, `VesselSwitch`, `VesselCheckboxLabeled`, `VesselSwitchLabeled`
- lang_button: `VesselLangButton`
- note: `VesselNote`
- progress_bar: `VesselProgressBar`
- screen_layout: `VesselScaffold`
- snackbar: `VesselSnackBar`
- tag: `VesselTagChip`, `VesselTagColorPreview`, `VesselTagLabel`
- text: `VesselHeader`
- tile: `VesselTile`

### Custom widgets in `front/lib/features/vocab/widgets/`
- `VocabDailyActivityCard` (takes `AsyncValue<DailyActivityStats>`)
- `VocabDeckTile` (takes `VocabDeckTileData`)
- `VocabLevelCard` (takes `VocabLevelData`)
- `VocabLevelStatsRow` (takes `VocabLevelData`)

### Widgets known to take domain models (LANGWIJ_COMPOSITE candidates)
- `VesselTagChip` — takes `Tag`
- `VesselTagColorPreview` — takes `TagColor` enum
- `VesselTagLabel` — takes `Tag`
- `showBugReportSheet` — takes `CardModel`
- `VocabDailyActivityCard` — takes async stats
- `VocabDeckTile` — takes deck tile data
- `VocabLevelCard` — takes level data
- `VocabLevelStatsRow` — takes level data

### Theme system (current)
- `VesselThemeData` — approximately 200 properties spanning generic primitives and product-specific sections (Badge, DeckIcon, RoundAnswerTile, TestBadge, Retention, 5-color Tag palette, Toggle)
- `AppTheme` enum with five variants: `theme01..theme05`
- `VesselThemes.getThemeData(AppTheme)` factory
- Five theme files at `front/lib/app/theme/themes/theme0N_theme.dart`
- Legacy constants at `front/lib/shared/theme/app_theme.dart`

### Fonts (current)
- `VesselFonts` — approximately 30 named styles
- Header font: `IosevkaCustom3` (bundled)
- Body font: `Montserrat` (via google_fonts)
- Private base styles composed into public product styles
- Includes product-specific names: `textAppBarTitle`, `textTileHeader`, `textLevelHeader`

### Layout (current)
- `VesselLayout` — approximately 50 constants
- Generic tier: `gapXxs..gapXxl`, screen padding, list item gap
- Product-specific: `vocabTileHeight`, `vocabTileMinWidth`, `vocabTileGap`, `roundScoreToCardGap`, `roundOptionTileAspectRatio`, `langFlagWidth`, `langFlagHeight`, navbar and app-bar heights

### Flessel capabilities (for reference)
- Theme system: `FlesselThemeData` (approximately 60 properties), `FlesselFonts`, `FlesselLayout`, `FlesselSize` enum (xxs..l), five themes in `FlesselThemeCatalog`
- Controls inventory: buttons (6 variants), `FlesselButtonGroup`, `FlesselCard` / `FlesselAttentionCard`, `FlesselDivider`, `FlesselGap`, `FlesselList` / `FlesselListItem` (with reorder), text input, dropdown, date picker, hour picker, slider input, time slider, button grid, toggles (checkbox and switch, labeled variants), radio tile, tag, note, tile, progress bar, spinner, bottom sheet, snackbar, scaffold, top bar, navbar (plain and notched)
- Icons: Phosphor icons via `phosphor_flutter`, re-exported
- Utilities: `PlatformUtils`

### Notable flessel capabilities srpski does not have
- `FlesselList` plus `FlesselListItem` with reorder support
- Unified `FlesselSize` tier system across all controls (xxs..l)
- `FlesselNavBar` takes a generic item list (srpski's `VesselNavBar` hardcodes four tabs)
- `FlesselScaffold` takes a generic `bottomNavBar: Widget?` (srpski's `VesselScaffold` hardcodes integration)
- `FlesselTag` supports `tagStyles: List<FlesselTagStyle>` natively

### Notable places srpski has features flessel lacks
- `VesselCard` supports `onTap`, `padding`, `transparent`
- `showVesselBottomSheet` supports padding, dismissibility, blur, border, draggable configuration
- `VesselHeader` — no equivalent flessel text/header primitive
- `VesselTagLabel` — four sizes (icon, tiny, regular, cluster)
- `VesselTagColorPreview` — colored swatch picker (distinct concept)
- `ProjectButtonGroup` supports `maxPerRow` wrapping
- `VesselSliderInput` has zones, counter mode, button controls
- `ProjectRadioGrid` — grid-based radio selector

---

End of document.
