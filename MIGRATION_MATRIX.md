# Migration Matrix

Per-widget decision matrix for the srpski_card to flessel migration. Companion to `MIGRATION_PLAN.md`.

## Sign-off (2026-04-10)

**All 60 rows `DONE`** — 48 widget rows + 12 enum/data-class rows. Implementation work for every row is complete: call sites rewritten, vessel sources deleted, analyzer reports zero errors on `front/`, `.vessel/packages/flessel/`, and `.vessel/packages/flessel/example/`.

**Residual gates not covered by per-row sign-off** (tracked in `MIGRATION_PLAN.md` Current state, not in individual rows):

- **Phase 6 #11** — manual screen verification on a running build. Meatbag's task, not automatable.
- **Phase 6 #4** — `flutter build apk` for the front app. Outcome recorded in `MIGRATION_PLAN.md` Current state.
- **Phase 2b** — folder rename `srpski_card/` → `langwij/` at the parent directory. External, performed by the project owner.
- **Phase 2c** — post-restart `flutter clean` / `pub get` / `analyze` / `build` after Phase 2b. External.
- **Row 48 deferral** — retention coloring (5 vessel theme fields) remains DEFERRED until per-property flessel grow proposals are made. Both `_ProgressBadge` widgets currently render plain neutral `FlesselTag`s.
- **Pre-existing analyzer warnings/info** (non-blocking):
  - `.vessel/packages/flessel/lib/src/theme/flessel_fonts.dart:12,14` — `_m08` and `_m08b` unused private declarations (flessel-internal hygiene, not introduced by this migration).
  - `front/lib/pages/lang_picker_screen.dart:37,42` — two `unnecessary_underscores` info-level lints in `(_, __)` error callbacks. Same pattern in `language_screen.dart:44` is suppressed with an `// ignore:` directive; lang_picker_screen lacks the directive.

## How to use

Each row is a widget, widget group, or support class. Each row has a proposed decision. Approval is row-by-row. Nothing is executed until a row's status is `APPROVED` and an `unleash` is given for that specific execution. Approvals can be batched verbally (for example "approve rows 1–6") but execution still needs `unleash`.

Update this file as rows progress through their status lifecycle.

## Status legend

- `PROPOSED` — decision proposed, awaiting review
- `APPROVED` — decision approved, ready for execution
- `REJECTED` — decision rejected, needs re-proposal
- `IN_PROGRESS` — currently executing
- `DONE` — fully completed (call sites rewritten, old widget deleted, analyzer clean)

## Decision legend

- `SWITCH` — flessel equivalent is sufficient; rewrite call sites, delete Vessel version
- `EXTEND_FLESSEL` — flessel has an equivalent that needs growing (new params, variants, size tiers); grow upstream, then switch
- `ADD_TO_FLESSEL` — no flessel equivalent; port a generic version into flessel, then switch
- `LANGWIJ_COMPOSITE` — takes a domain model or is too product-specific for flessel; becomes a `Langwij*` composite using flessel primitives
- `DELETE` — no longer needed; removed with no replacement (composable inline from flessel primitives, or absorbed into another migration)

## Example app documentation pattern (Phase 1 finding)

The flessel example app at `.vessel/packages/flessel/example/` uses a **single `ControlsListScreen`** with scrollable sections, not one file per control. Key locations:

- `example/lib/main.dart` — `FlesselShowcaseApp` with 4-tab navigation: Controls, Themes, Fonts, Layout
- `example/lib/pages/controls_list_screen.dart` — all controls demo'd inline in one scrollable screen
- Section navigation via `_sectionGroups` constant (groups: Buttons, Selectors, Inputs, Layout, System)
- Each section has a `GlobalKey` in `_sectionKeys` for scroll-to navigation
- State for each demo is declared as fields on `_ControlsListScreenState`

**When adding or extending a flessel control**: update or add a section inside `controls_list_screen.dart`, register it in `_sectionGroups`, add any demo state to `_ControlsListScreenState`. No new files.

## Legacy-screen note (srpski_card side)

`front/lib/pages/controls_list_screen.dart` is the **srpski_card** legacy demo screen from the pre-flessel era. It is **slated for deletion after a successful flessel migration**. Per-row retargeting tables in this matrix that reference this file are listed only for keeping the file compilable during the intermediate migration period — the retargetings "don't matter" in the sense that the file will be removed afterwards.

Do **NOT** confuse this with the flessel library's own example app at `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart`, which is the canonical place to document flessel controls and is permanent.

Audit implications: when auditing call sites for a widget, usages inside the srpski_card legacy `controls_list_screen.dart` do **not** count as production usage for grow-point decisions. A prop used only in this file is effectively unused.

## Summary table

| # | Vessel item | Category | Decision | Status |
|---|---|---|---|---|
| 1 | VesselButton | Buttons | SWITCH | DONE |
| 2 | VesselAccentButton | Buttons | SWITCH | DONE |
| 3 | VesselDangerButton | Buttons | SWITCH | DONE |
| 4 | VesselTextButton | Buttons | SWITCH | DONE |
| 5 | VesselAccentTextButton | Buttons | SWITCH | DONE |
| 6 | VesselDangerTextButton | Buttons | SWITCH | DONE |
| 7 | ProjectButtonGroup | Buttons | SWITCH | DONE |
| 8 | VesselButtonStyleResolver | Buttons support | DELETE | DONE |
| 9 | VesselCard | Cards | EXTEND_FLESSEL | DONE |
| 10 | VesselAttentionCard | Cards | SWITCH + inherits row 9 API | DONE |
| 11 | VesselDivider | Divider | SWITCH | DONE |
| 12 | VesselGap | Gap | SWITCH | DONE |
| 13 | VesselTextInput | Inputs | EXTEND_FLESSEL | DONE |
| 14 | VesselDropdown | Inputs | EXTEND_FLESSEL (flessel bug fix) | DONE |
| 15 | VesselInputRow / ProjectInputRow | Inputs | DELETE | DONE |
| 16 | VesselRadioTile | Inputs | SWITCH | DONE |
| 17 | ProjectRadioGrid | Inputs | SWITCH (to FlesselButtonGrid) | DONE |
| 18 | VesselSliderInput | Inputs | SWITCH | DONE |
| 19 | VesselTimeSlider | Inputs | SWITCH | DONE |
| 20 | VesselDatePicker | Inputs | SWITCH | DONE |
| 21 | VesselHourPicker | Inputs | SWITCH | DONE |
| 22 | VesselCheckbox | Inputs | SWITCH | DONE |
| 23 | VesselSwitch | Inputs | SWITCH | DONE |
| 24 | VesselCheckboxLabeled | Inputs | SWITCH | DONE |
| 25 | VesselSwitchLabeled | Inputs | SWITCH | DONE |
| 26 | VesselInputStyles | Inputs support | DELETE | DONE |
| 27 | VesselLangButton | Lang button | DELETE | DONE |
| 28 | VesselNote | Note | SWITCH | DONE |
| 29 | VesselProgressBar | Progress | SWITCH | DONE |
| 30 | VesselScaffold | Scaffold | EXTEND_FLESSEL | DONE |
| 31 | VesselSnackBar | Snackbar | SWITCH | DONE |
| 32 | VesselTagChip | Tag | DELETE | DONE |
| 33 | VesselTagColorPreview | Tag | DELETE | DONE |
| 34 | VesselTagLabel | Tag | DELETE | DONE |
| 35 | VesselHeader | Text | DELETE | DONE |
| 36 | VesselTile | Tile | SWITCH | DONE |
| 37 | VesselAnswerTile | Answer tile | LANGWIJ_COMPOSITE | DONE |
| 38 | VesselNavBar | Bottom navbar | EXTEND_FLESSEL + LANGWIJ_COMPOSITE | DONE |
| 39 | VesselNavBarIcon | Bottom navbar | DELETE | DONE |
| 40 | showVesselBottomSheet | Bottom sheet | EXTEND_FLESSEL | DONE |
| 41 | showBugReportSheet | Bottom sheet | LANGWIJ_COMPOSITE | DONE |
| 42 | _BugReportSheetContent | Bottom sheet (private) | DELETE (absorbed into #41) | DONE |
| 43 | showModeBottomSheet + showCountBottomSheet | Bottom sheet | LANGWIJ_COMPOSITE | DONE |
| 44 | _ModeTileData / _ModeTileRow / _ModeTile / _CountTileGrid / _CountTile | Bottom sheet (private) | DELETE (absorbed into #43) | DONE |
| 45 | VocabDailyActivityCard | Features/vocab | LANGWIJ_COMPOSITE | DONE |
| 46 | VocabDeckTile | Features/vocab | LANGWIJ_COMPOSITE | DONE |
| 47 | VocabLevelCard | Features/vocab | LANGWIJ_COMPOSITE | DONE |
| 48 | VocabLevelStatsRow | Features/vocab | LANGWIJ_COMPOSITE | DONE |

### Enum and support data classes (retired with their owners)

| # | Item | Decision | Status |
|---|---|---|---|
| E1 | AppTheme enum | DELETE (replaced by FlesselThemeCatalog.byId('theme_01')) | DONE |
| E2 | VesselButtonSize enum | DELETE (replaced by FlesselSize) | DONE |
| E3 | ButtonVariant enum | DELETE (implicit in flessel variant classes) | DONE |
| E4 | VesselProgressBarMode enum | DELETE (replaced by FlesselProgressBarMode) | DONE |
| E5 | VesselTagLabelSize enum | DELETE (legacy-only, absorbed into #34 deletion) | DONE |
| E6 | VesselLabelPosition enum | DELETE (replaced by flessel LabelPosition) | DONE |
| E7 | VesselSliderInputMode enum | DELETE (replaced by flessel SliderInputMode) | DONE |
| E8 | VesselButtonColors data class | DELETE | DONE |
| E9 | VesselButtonGroupItem data class | DELETE (replaced by FlesselButtonGroupItem) | DONE |
| E10 | VesselInputRowField data class | DELETE (with #15) | DONE |
| E11 | VesselDropdownItem<T> data class | DELETE (replaced by FlesselDropdownItem<T>) | DONE |
| E12 | VesselRadioGridOption<T> data class | DELETE (replaced by FlesselButtonGridOption<T>) | DONE |

Domain enums and data classes (`TagColor`, `BugReportType`, `LevelTier`, `ModeSelection`, `VocabDeckTileData`, `VocabLevelData`, `DailyActivityStats`) stay — they are domain, not UI.

---

## Detailed rows

### 1. VesselButton

- **Location**: `front/lib/shared/ui/buttons/`
- **Base**: `ConsumerWidget`
- **Current props**: `onPressed`, `label`, `icon`, `size: VesselButtonSize {small, medium, large}`, `condensed`, `margin`
- **Flessel equivalent**: `FlesselButton`
- **Flessel props**: `onPressed`, `label`, `icon`, `size: FlesselSize {xxs, xs, s, m, l}`, `condensed`, `margin`
- **Dimensional parity (verified)**: `minHeight`, `hPadding`, `iconOnlyPadding` match exactly across small/s (32/10/4), medium/m (44/16/8), large/l (56/24/10)
- **Divergences (both accepted as-is, no flessel changes)**:
  1. **Icon size assignment** — vessel has `iconOnly > iconWithText` (20/28/32 vs 18/24/28); flessel has the opposite (18/24/28 vs 20/28/32). Same numeric sets, inverted assignment. Verdict: accept flessel — icon-only buttons will render slightly smaller in srpski post-migration.
  2. **Condensed half-height** — vessel halves `minHeight` on `condensed: true`; flessel does not (SizedBox enforces fixed tier height). Verdict: accept flessel — `condensed: true` is used only in `front/lib/pages/controls_list_screen.dart` (demo screen, scheduled for wholesale deletion); zero production impact.
- **Decision**: `SWITCH`
- **Call-site mapping**: `small → FlesselSize.s`, `medium → FlesselSize.m`, `large → FlesselSize.l`
- **Call-site retargeting (Phase 3 reference)**:
  - `front/lib/pages/language_screen.dart` (small)
  - `front/lib/pages/settings_screen.dart` (small)
  - `front/lib/pages/result_screen.dart` (small)
  - `front/lib/features/vocab/widgets/vocab_level_stats_row.dart` (small)
  - `front/lib/shared/ui/inputs/vessel_slider_input.dart` (small — internal, handled with row 18)
  - `front/lib/shared/ui/lang_button/vessel_lang_button.dart` (medium — internal, handled with row 27)
  - `front/lib/pages/controls_list_screen.dart` (demo, replaced wholesale)
  - Import swap: `package:srpski_card/shared/ui/buttons/vessel_buttons.dart` → `package:flessel/flessel.dart`
- **Grow points needed**: none
- **Example app page**: Already documented in `controls_list_screen.dart` Buttons section
- **Status**: `DONE`

### 2. VesselAccentButton

- **Location**: `front/lib/shared/ui/buttons/`
- **Base**: `ConsumerWidget`
- **Current props**: same as VesselButton
- **Flessel equivalent**: `FlesselAccentButton`
- **Divergences**: same as row 1 — both accepted as-is
- **Decision**: `SWITCH`
- **Grow points needed**: none
- **Status**: `DONE`

### 3. VesselDangerButton

- **Location**: `front/lib/shared/ui/buttons/`
- **Flessel equivalent**: `FlesselDangerButton`
- **Divergences**: same as row 1 — both accepted as-is
- **Decision**: `SWITCH`
- **Status**: `DONE`

### 4. VesselTextButton

- **Location**: `front/lib/shared/ui/buttons/`
- **Flessel equivalent**: `FlesselTextButton`
- **Divergences**: same as row 1 — both accepted as-is
- **Decision**: `SWITCH`
- **Status**: `DONE`

### 5. VesselAccentTextButton

- **Location**: `front/lib/shared/ui/buttons/`
- **Flessel equivalent**: `FlesselAccentTextButton`
- **Divergences**: same as row 1 — both accepted as-is
- **Decision**: `SWITCH`
- **Status**: `DONE`

### 6. VesselDangerTextButton

- **Location**: `front/lib/shared/ui/buttons/`
- **Flessel equivalent**: `FlesselDangerTextButton`
- **Divergences**: same as row 1 — both accepted as-is
- **Decision**: `SWITCH`
- **Status**: `DONE`

### 7. ProjectButtonGroup

- **Location**: `front/lib/shared/ui/buttons/vessel_button_group.dart`
- **Class name note**: the srpski class is `ProjectButtonGroup`, not `VesselButtonGroup` (mixed prefix). Item class is `VesselButtonGroupItem`.
- **Base**: `ConsumerWidget`
- **Current props**: `items: List<VesselButtonGroupItem>` (≥1), `size: VesselButtonSize`, `expanded: bool`, `maxPerRow: int?`
- **Item props**: `icon`, `label`, `onPressed`, `isSelected`
- **Flessel equivalent**: `FlesselButtonGroup`
- **Flessel props**: `items: List<FlesselButtonGroupItem>` (≥2), `selectedIndices: Set<int>`, `onChanged: ValueChanged<Set<int>>?`, `size: FlesselSize`, `expanded: bool`, `multiSelect: bool`, `multiline: bool`
- **Flessel item props**: `icon`, `label`, `onPressed`, `enabled`
- **Investigation outcome**:
  - Flessel supports **both** semantic modes out of the box:
    - `onChanged: null` → pure action group. Each item's `onPressed` fires on tap. `selectedIndices` still drives visual accent styling.
    - `onChanged` provided → controlled segmented selector (single or multi-select based on `multiSelect`).
  - `maxPerRow`: **zero usages** in entire `front/lib` (demos + production). Dead code in vessel, not worth porting.
  - Single-item groups (`items.length == 1`): zero usages. Flessel's `>= 2` assertion is safe.
  - All production sites map cleanly:
    - `settings_screen.dart` (language picker) → selector-with-custom-actions. Use `selectedIndices: { uiCodes.indexOf(currentLang) }` + per-item `onPressed`. Currently-selected item keeps `onPressed: null` so flessel auto-disables re-tap (via `isEnabled = item.enabled && (item.onPressed != null || onChanged != null)`).
    - `vessel_slider_input.dart` (minus/plus pair) → pure action group, direct field-for-field rename.
- **Gap**: none after investigation
- **Decision**: `SWITCH`
- **Call-site mapping**:
  - `VesselButtonGroupItem(isSelected: bool)` → `FlesselButtonGroupItem` + group-level `selectedIndices: Set<int>`
  - `maxPerRow` → DROP (dead code, zero usages)
  - Size enum maps same as row 1: `small → s`, `medium → m`, `large → l`
- **Call-site retargeting (Phase 3 reference)**:
  - `front/lib/pages/settings_screen.dart` (language picker, 1 call)
  - `front/lib/shared/ui/inputs/vessel_slider_input.dart` (internal — handled with row 18)
  - `front/lib/pages/controls_list_screen.dart` (6 demo calls — replaced wholesale)
  - Import swap: `package:srpski_card/shared/ui/buttons/vessel_button_group.dart` → `package:flessel/flessel.dart`
- **Grow points needed**: none
- **Grow points considered and rejected**:
  - G-BG-1 (port `maxPerRow` as count-based wrap to flessel): REJECT — zero usages
  - G-BG-2 (add `LangwijActionGroup` composite wrapper): REJECT — flessel already supports pure-action mode
- **Example app page**: Already has Button Groups section in `controls_list_screen.dart`
- **Status**: `DONE`

### 8. VesselButtonStyleResolver

- **Location**: `front/lib/shared/ui/buttons/vessel_button_styles.dart`
- **Type**: utility class (not a widget). Co-located with `VesselButtonSize` (E2), `ButtonVariant` (E3), `VesselButtonColors` (E8) — all four die with the file.
- **Purpose**: button styling logic helper
- **Usage audit**:
  - `vessel_buttons.dart` (rows 1-6 internals) — retired with those rows
  - `vessel_button_group.dart` (row 7 internals) — retired with that row
  - ~~`vessel_lang_button.dart` (row 27)~~ — **no longer a blocker**: row 27 flipped to DELETE (zero call sites). Row 27 execution removes the file entirely, including its `resolveColors` / `style` calls.
- **Decision**: `DELETE` (bundled with E2 + E3 + E8 — same file)
- **Ordering dependency**: blocked until rows 1-7 are all DONE. Row 27 is no longer a blocker.
- **Execution**: when rows 1-7 are DONE, delete `front/lib/shared/ui/buttons/vessel_button_styles.dart` as a single step. Can be bundled with row 27's deletion commit if convenient (both are dead code at that point).
- **Status**: `DONE`

### 9. VesselCard

- **Location**: `front/lib/shared/ui/card/vessel_card.dart`
- **Base**: `StatelessWidget`
- **Current props**: `child: Widget`, `onTap: VoidCallback?`, `padding: EdgeInsetsGeometry?`, `transparent: bool`
- **Flessel equivalent**: `FlesselCard`
- **Flessel props (before)**: `child: Widget`, `transparent: bool`, `header: String?`, `stretch: bool`
- **Flessel props (after this row executes)**: `child`, `transparent`, `header`, `stretch`, **`onTap: VoidCallback?`**, **`padding: FlesselSize = FlesselSize.m`**, **`margin: FlesselSize = FlesselSize.m`**
- **Decision**: `EXTEND_FLESSEL` (4 grow points, all approved)

#### Grow point G-CARD-1 — `onTap: VoidCallback?`
- Add `onTap` prop to `FlesselCard` (and to `FlesselAttentionCard` as part of row 10).
- When non-null, wrap the inner child in `Material(type: transparency) + InkWell` with `borderRadius: circular(t.cardBorderRadius)` so the ripple clips to the card shape.
- When null, no Material wrapper (preserves current behavior).

#### Grow point G-CARD-2 — `padding: FlesselSize` tier
- New constants in `FlesselLayout` (values per meatbag approval):
  - `cardPaddingXxs = 0.0`
  - `cardPaddingXs = 8.0`
  - `cardPaddingS = 12.0`
  - `cardPaddingM = 16.0` (default — identical to current `cardPadding`)
  - `cardPaddingL = 24.0`
- New lookup function: `static double cardPadding(FlesselSize size)`.
- Delete the existing constant `FlesselLayout.cardPadding = 16.0` — replaced by the function.
- `FlesselCard({padding = FlesselSize.m})` preserves current 16px default behavior.

#### Grow point G-CARD-3 — `margin: FlesselSize` tier
- New constants in `FlesselLayout` (same tier values as padding, per meatbag decision):
  - `cardMarginXxs = 0.0`
  - `cardMarginXs = 8.0`
  - `cardMarginS = 12.0`
  - `cardMarginM = 16.0` (default — closest tier to current 18)
  - `cardMarginL = 24.0`
- New lookup function: `static double cardMargin(FlesselSize size)`.
- Delete the existing constant `FlesselLayout.cardMarginBottom = 18.0` — replaced by the function.
- **Behavioral change**: default bottom margin tightens from 18 → 16. Call sites that need to suppress built-in margin (e.g., to preserve their own external `Padding` wrapper) use `margin: FlesselSize.xxs` (= 0).

#### Grow point G-CARD-4 — Transparent mode geometry fix
- Current bug: `_buildTransparent()` uses nested `Padding(bottom: 18) → Padding(bottom: 16) → child`. Produces 34px below the child and **nothing** on top/left/right. Asymmetric and inconsistent with non-transparent cards (which have 16 all sides inside + 18 bottom margin).
- Fix: transparent mode uses the same `Container` geometry as non-transparent mode, minus the visible background/border. Child gets tiered padding on all sides + tiered bottom margin. Same `padding` and `margin` FlesselSize props apply.
- Only current consumers are in `controls_list_screen.dart` (example demos) — verify visually after change.

#### Call-site retargeting

All production call sites use **default values** (`padding: FlesselSize.m`, `margin: FlesselSize.m`). Meatbag will tune specific sites during a later design pass.

| Site | Current | After | Notes |
|---|---|---|---|
| `language_screen.dart:515` | plain | default | — |
| `language_screen.dart:620` | onTap | default + onTap | — |
| `language_screen.dart:667` | plain | default | — |
| `round_screen.dart:167` | plain | default | — |
| `result_screen.dart:45` | plain | default | — |
| `result_screen.dart:205` | `padding: (v:12,h:16)` asymmetric | default (uniform 16) | vertical grows 12→16, horizontal stays 16. Retire `VesselLayout.resultEntryPaddingV/H` via MIGRATION_PLAN.md layout policy. Meatbag tunes later. |
| `settings_screen.dart:233` | plain | default | — |
| `settings_screen.dart:271` | onTap | default + onTap | — |
| `settings_screen.dart:287` | onTap | default + onTap | — |
| `tools_screen.dart:45` | onTap | default + onTap | — |
| `vocab_daily_activity_card.dart:23` | plain | default | — |
| `vocab_level_card.dart:37` | `padding: EdgeInsets.all(vocabLevelCardPadding=16)` | drop override, default | identical to default. Retire `VesselLayout.vocabLevelCardPadding` via MIGRATION_PLAN.md layout policy. |
| `agreement_group_list_screen.dart:220` | onTap + `padding: EdgeInsets.zero` | default + onTap | **VISUAL REGRESSION ACCEPTED**: Stack-overlay children will shift 16px inward. Per meatbag: fixed during later design pass. |
| `group_list_screen.dart:107` | onTap + `padding: EdgeInsets.zero` | default + onTap | **VISUAL REGRESSION ACCEPTED**: same pattern. Per meatbag: fixed during later design pass. |
| `controls_list_screen.dart:110,115,123,129,1270` | various | updated demos | example app — showcase padding/margin tiers + onTap. |

#### External `Padding` wrappers — mandatory deletion

All external `Padding` wrappers around `FlesselCard` are **deleted at execution time** — per consumer rule #4 (no caller-side sizing wrappers around flessel controls). `FlesselCard`'s built-in `margin: FlesselSize.m` (= 16px bottom) replaces the external spacing.

| Site | Current wrapper | Disposition |
|---|---|---|
| `tools_screen.dart:43-45` | `Padding(bottom: VesselLayout.listItemGap=12)` | Delete wrapper. Retire `VesselLayout.listItemGap` if no other consumers (verify at execution time). |
| `result_screen.dart:203-205` | `Padding(bottom: VesselLayout.listItemGapSmall=8)` | Delete wrapper. Retire `VesselLayout.listItemGapSmall` if no other consumers (verify at execution time). |
| `vocab_deck_list_screen.dart:133-138` | `Padding(bottom: VesselLayout.vocabDailyCardBottomGap=12)` | Handled by row 45. |
| `vocab_deck_list_screen.dart:148-167` | `Padding(bottom: VesselLayout.vocabLevelCardBottomGap=12)` | Handled by row 47. |

#### Example app
- Existing Cards section updated with:
  - Tap demo (card with `onTap` showing ripple)
  - Padding size variants row (xxs/xs/s/m/l)
  - Margin size variants row (xxs/xs/s/m/l)
  - Transparent card alongside regular card (post-fix geometry)

#### consumer.claude.md
- Update `FlesselCard` line in controls inventory to mention new `padding`, `margin`, and `onTap` props.

#### Ordering dependency
- Row 10 (`VesselAttentionCard`) inherits G-CARD-1 (`onTap`). Execute together in the same commit.
- Layout constants `vocabLevelCardPadding`, `resultEntryPaddingV/H` retire via the MIGRATION_PLAN.md per-constant layout policy.

- **Status**: `DONE`

### 10. VesselAttentionCard

- **Location**: `front/lib/shared/ui/card/vessel_card.dart`
- **Base**: `StatelessWidget`
- **Current vessel props**: `child: Widget`
- **Flessel equivalent**: `FlesselAttentionCard`
- **Flessel props (before)**: `child: Widget`
- **Flessel props (after this row executes)**: `child`, **`onTap: VoidCallback?`** (G-CARD-1), **`padding: FlesselSize = FlesselSize.m`** (G-CARD-2), **`margin: FlesselSize = FlesselSize.m`** (G-CARD-3)
- **Decision**: `SWITCH` + inherits row 9 grow points
- **API inheritance rationale**: row 9's grow points apply to the card family as a whole, not just plain `FlesselCard`. Diverging `FlesselAttentionCard`'s sizing API would force callers of tappable/non-default-padding attention cards to fall back to raw Material widgets, violating the consumer rule. Transparent mode (G-CARD-4) does **not** propagate — a transparent attention card defeats the purpose.
- **Call-site audit**: one production call site — `controls_list_screen.dart:138`, plain `VesselAttentionCard(child: Text(...))`. No surprises. Clean default migration.
- **Call-site retargeting**:

| Site | Current | After |
|---|---|---|
| `controls_list_screen.dart:138` | plain | default (m padding + m margin) |

- **Example app**: attention card section extended alongside row 9's Cards updates (tap demo, padding/margin size variants).
- **consumer.claude.md**: update `FlesselAttentionCard` inventory line alongside `FlesselCard` in the same commit.
- **Ordering dependency**: must execute in the same commit as row 9 — API inheritance requires both widgets gain the new props together.
- **Status**: `DONE`

### 11. VesselDivider

- **Location**: `front/lib/shared/ui/divider/vessel_divider.dart`
- **Base**: `StatelessWidget`
- **Current props**: none
- **Flessel equivalent**: `FlesselDivider`
- **Prop parity**: identical (zero-arg constructors on both sides)
- **Theme parity**: both read `dividerWidth` and `dividerColor` the same way; flessel reads `height` from `FlesselLayout.dividerHeight = 1.0` instead of a literal, no behavioral difference
- **Gaps**: none
- **Grow points**: none
- **Decision**: `SWITCH`
- **Call-site retargeting**: single mechanical rename — `VesselDivider()` → `FlesselDivider()` at `controls_list_screen.dart:988`
- **Status**: `DONE`

### 12. VesselGap

- **Location**: `front/lib/shared/ui/gap/vessel_gap.dart`
- **Base**: `StatelessWidget`
- **Current constructors**: `.xxs()`, `.xs()`, `.s()`, `.m()`, `.l()`, `.xl()`, `.xxl()`, `.hxxs()`, `.hxs()`, `.hs()`, `.hm()`, `.hl()`, `.hxl()` (13 total)
- **Flessel equivalent**: `FlesselGap`
- **Flessel constructors**: `.xxs()`, `.xs()`, `.s()`, `.m()`, `.l()`, `.xl()`, `.xxl()` (7 total)
- **Tier value parity**: identical both sides — `{gapXxs=2, gapXs=4, gapS=8, gapM=12, gapL=16, gapXl=24, gapXxl=48}`
- **Implementation difference**: vessel clamps the cross-axis to 0 (`.hs()` = 8×0 inside a Row); flessel sets both axes to the same value (`.s()` = 8×8). In practice identical — the Row/Column's cross-axis is driven by sibling content, not by the gap widget's declared footprint.
- **Edge-case note**: any theoretical misuse of `VesselGap.hs()` inside a `Column` (nonsensical — would produce invisible 8×0) gets "fixed" by flessel taking actual vertical space. Unlikely to exist.
- **Gap**: none
- **Grow points**: none
- **Decision**: `SWITCH`
- **Call-site retargeting** (120 sites across 12 files):
  - **86 vertical variants** (`.xxs..xxl`) — mechanical class rename only, same suffix: `VesselGap.s()` → `FlesselGap.s()`
  - **34 horizontal variants** (`.hxxs..hxl`) — rename + strip `h` prefix: `VesselGap.hs()` → `FlesselGap.s()`, `VesselGap.hm()` → `FlesselGap.m()`, etc.
- **Status**: `DONE`

### 13. VesselTextInput

- **Location**: `front/lib/shared/ui/inputs/vessel_text_input.dart`
- **Base**: `StatelessWidget`
- **Current vessel props**: `controller`, `focusNode`, `label`, `hint`, `onSubmitted`, `autofocus`, `textInputAction` (default `done`), `keyboardType`, `inputFormatters`, `autocorrect` (default `true`), `enableSuggestions` (default `true`), `obscureText`, `maxLines` (default `1`), `minLines`
- **Flessel equivalent**: `FlesselTextInput`
- **Flessel props (before)**: `controller`, `label`, `hint`, `onChanged`, `onSubmitted`, `keyboardType` (default `text`), `enabled`, `autofocus`, `maxLines`, `minLines`, `textCapitalization`, `focusNode`, `obscureText`, `size: FlesselSize`, `suggestions` (autocomplete list), `onSuggestionSelected`, `suggestionMinLength`
- **Flessel props (after this row executes)**: adds **`autocorrect: bool = true`**, **`enableSuggestions: bool = true`**, **`textInputAction: TextInputAction?`**
- **Decision**: `EXTEND_FLESSEL` (3 grow points, 1 original proposal dropped after audit)

#### Call-site audit (7 production sites)

| Site | Non-default props used |
|---|---|
| `settings_screen.dart:76` — dev password sheet | `autocorrect: false`, `enableSuggestions: false`, `obscureText`, `autofocus` |
| `round_screen.dart:316` — aspect imperfective write field | `textInputAction: next`, `autocorrect: false`, `enableSuggestions: false`, `autofocus`, `focusNode` |
| `round_screen.dart:332` — aspect perfective write field | `textInputAction: done`, `autocorrect: false`, `enableSuggestions: false` |
| `round_screen.dart:355` — single write field | `textInputAction: done`, `autocorrect: false`, `enableSuggestions: false`, `autofocus`, `focusNode` |
| `controls_list_screen.dart:710` — demo single-line | none beyond `controller`, `label`, `hint` |
| `controls_list_screen.dart:718` — demo multiline | `textInputAction: newline`, `keyboardType: multiline`, `maxLines: 4`, `minLines: 3` |
| `bug_report_sheet.dart:83` — bug report message | `textInputAction: newline`, `keyboardType: multiline`, `maxLines: 4`, `minLines: 3` |

#### Audit findings
- **`inputFormatters`**: **ZERO production usage**. Originally proposed as a grow point; **dropped** from this row. Over-engineered in vessel. If a future use case arises, add it then.
- **`autocorrect: false`**: 4 production sites (password + 3 write quiz fields). MUST be added.
- **`enableSuggestions: false`**: same 4 sites. MUST be added.
- **`textInputAction`**: 5 production sites (`next`, `done`, `newline`). MUST be added.

#### Grow point G-INPUT-1 — `autocorrect: bool = true`
- Pass-through to underlying `TextField`. Default preserves flessel's current implicit behavior.
- Applies to both the `_buildTextField` path and the `_buildWithSuggestions` path (same forwarding in both `TextField` invocations).

#### Grow point G-INPUT-2 — `enableSuggestions: bool = true`
- Pass-through to underlying `TextField`. Default preserves current behavior.
- Doc comment **must** note this is the platform keyboard's spellcheck suggestion list, **distinct** from flessel's existing `suggestions: List<String>?` autocomplete dropdown feature. These two props are easy to confuse.
- Applies to both `_buildTextField` and `_buildWithSuggestions` paths.

#### Grow point G-INPUT-3 — `textInputAction: TextInputAction?`
- Pass-through to underlying `TextField`. Default `null` — TextField resolves to its own default based on `keyboardType`.
- Applies to both `_buildTextField` and `_buildWithSuggestions` paths.

#### Rejected grow point
- **`inputFormatters: List<TextInputFormatter>?`** — rejected. Zero production usage. Violates "only grow what's needed" principle.

#### Call-site retargeting
All 7 sites are mechanical class renames after grow points land:

| Site | Change |
|---|---|
| `settings_screen.dart:76` | `VesselTextInput(...)` → `FlesselTextInput(...)` — all props preserved |
| `round_screen.dart:316` | rename only |
| `round_screen.dart:332` | rename only |
| `round_screen.dart:355` | rename only |
| `controls_list_screen.dart:710` | rename only |
| `controls_list_screen.dart:718` | rename only |
| `bug_report_sheet.dart:83` | rename only |

#### Prop parity notes
- Flessel's `keyboardType: TextInputType = text` (non-nullable, default `text`) vs. vessel's `TextInputType?` (nullable, implicit `text` inside TextField) — behavioral parity. All call sites that pass `null` or omit the prop get `text` either way.
- Flessel's `enabled`, `textCapitalization`, `size`, `onChanged` are new capabilities beyond vessel — defaults preserve current behavior.

#### Example app
Existing Inputs section extended with:
- Password-style demo (`autocorrect: false`, `enableSuggestions: false`, `obscureText`)
- Multi-field Row demo showing `textInputAction: next`/`done`

#### consumer.claude.md
Update `FlesselTextInput` inventory line to mention new `autocorrect`, `enableSuggestions`, `textInputAction` props.

- **Status**: `DONE`

### 14. VesselDropdown

- **Location**: `front/lib/shared/ui/inputs/vessel_dropdown.dart`
- **Base**: `StatelessWidget`
- **Current vessel props**: `items: List<VesselDropdownItem<T>>`, `value`, `onChanged`, `label?`, `hint?`, `expandedInsets: EdgeInsets?`
- **Flessel equivalent**: `FlesselDropdown<T>`
- **Flessel props**: `items: List<FlesselDropdownItem<T>>`, `value`, `onChanged`, `label?`, `hint?`, `size: FlesselSize = m`, `expanded: bool = false`
- **Decision**: `EXTEND_FLESSEL` — not to add new props, but to fix a flessel library bug that blocks clean migration

#### Behavioral differences
| Aspect | VesselDropdown | FlesselDropdown |
|---|---|---|
| Underlying widget | Material 3 `DropdownMenu<T>` | Hand-rolled `OverlayPortal` + `CompositedTransformFollower` |
| Width default | Always fills parent (`width: constraints.maxWidth`) | `expanded: false` → sized to widest item; `expanded: true` → fills parent |
| Size tier | none | `FlesselSize` tier |
| Trigger interaction | Material dropdown (hover/focus/press/semantics/disabled cursor free) | `GestureDetector` — see Finding 3 below |

#### Call-site audit (2 production sites)

| Site | Props set |
|---|---|
| `controls_list_screen.dart:728` — demo Fruit picker | `value`, `onChanged`, **`label: 'Fruit'`**, `items` |
| `bug_report_sheet.dart:67` — bug type picker | `value`, `onChanged`, `items` |

#### Finding 1 — `expandedInsets` drop
Zero production usage. Vestigial prop in vessel. Drop from any grow point proposal. The original matrix row's "SWITCH or EXTEND_FLESSEL" ambiguity is resolved: no flessel extension needed for this prop.

#### Finding 2 — Flessel bug: `label` and `hint` declared but never rendered
`FlesselDropdown` declares `label: String?` ("Placeholder text shown inside the field") and `hint: String?` ("Hint text shown when no value is selected") in its constructor and doc comments — but the `build()` method does not reference `widget.label` or `widget.hint` anywhere. The trigger row only renders the selected item's label via `IndexedStack`. These props are silently ignored.

**Impact**: `controls_list_screen.dart:728` passes `label: 'Fruit'` → silently dropped on migration. Even though that file is slated for deletion (see Legacy Screen Note below), the props must work for future consumers of the flessel library.

#### Finding 3 — Flessel TODO: accessibility gap (NOT addressed in this row)
`flessel_dropdown.dart:88-89` flags: `// TODO: Replace GestureDetector with Material InkWell — missing hover state, focus/keyboard navigation, press feedback, semantic button role, disabled cursor.`
Migrating from vessel (Material DropdownMenu, a11y-complete) to flessel (GestureDetector, a11y-incomplete) is an accessibility regression. Per meatbag's directive ("todo we dont touch now"), this is **deferred** as an open flessel library improvement, not addressed in row 14. Tracked separately — not a grow point here.

#### Grow point G-DROP-1 — Render `label` and `hint` inline in `FlesselDropdown`
- **Scope**: fix both `label` and `hint` rendering. Both are declared together; fixing only one leaves the library inconsistent.
- **Style**: **inline placeholder** — per meatbag directive ("fix both, inline"). Not a floating label like `FlesselTextInput`.
- **Rendering semantics**:
  - When a value is selected: trigger row shows the selected item's label (current behavior preserved).
  - When no value is selected AND `hint` is non-null: trigger row shows `hint` text in a dimmed/placeholder style (using `t.textSecondary` or equivalent) instead of the `IndexedStack` empty state.
  - When `label` is non-null: shown as inline placeholder text inside the trigger row, rendered in the same dimmed/placeholder style as hint. The exact interaction between `label` and `hint` (whether `label` takes precedence when both are set, or they render differently) to be resolved during implementation. Recommendation: `label` is the field-identity (e.g., "Fruit"), `hint` is the call-to-action (e.g., "Pick one"). When both are set, show label when a value exists; show hint when no value exists.
- **Applies to**: the trigger `Row(children: [Expanded(child: IndexedStack(...)) ...])` in `build()`.

#### Call-site retargeting (2 sites)

| Site | Change |
|---|---|
| `controls_list_screen.dart:728` | `VesselDropdown<String>(... label: 'Fruit' ...)` → `FlesselDropdown<String>(... label: 'Fruit', expanded: true ...)`. Rename `VesselDropdownItem` → `FlesselDropdownItem` (E11). **Note: file is legacy, will be deleted**; retargeting here only matters for keeping the file compilable during migration. |
| `bug_report_sheet.dart:67` | `VesselDropdown<BugReportType>(...)` → `FlesselDropdown<BugReportType>(..., expanded: true)`. Rename items to `FlesselDropdownItem`. |

Both call sites must add `expanded: true` because vessel's default was "fill parent width" (via `LayoutBuilder + constraints.maxWidth`) while flessel's default is "size to widest item". Preserving current visual layout requires the explicit `expanded: true`.

#### Flessel example app
- Update existing Dropdown section in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart`:
  - Dropdown with `label` set (post-fix rendering)
  - Dropdown with `hint` and no selected value (post-fix rendering)
  - `expanded: true` vs. `expanded: false` comparison

#### consumer.claude.md
No new props to document — the fix makes existing (broken) props actually work. Note in the changelog/commit that G-DROP-1 fixes the label/hint rendering bug.

#### Ordering dependency
- E11 (`VesselDropdownItem<T>` data class) renames bundle with row 14.

- **Status**: `DONE`

### 15. VesselInputRow / ProjectInputRow

- **Location**: `front/lib/shared/ui/inputs/vessel_input_row.dart`
- **Class name note**: mixed-prefix — the widget is `ProjectInputRow` (not `VesselInputRow`), the data class is `VesselInputRowField`. Both retire together.
- **Base**: `StatelessWidget`
- **Current props**: `fields: List<VesselInputRowField>`, `spacing: double = 12`, `exclusive: bool = false`
- **Flessel equivalent**: none
- **Purpose**: horizontal row of labeled input fields with equal spacing; `exclusive` mode clears sibling controllers on focus gain (mutually-exclusive numeric input pattern)
- **Decision**: `DELETE`

#### Call-site audit
Zero production usage. Both existing usages are in the legacy srpski_card `controls_list_screen.dart` (slated for deletion):
- `controls_list_screen.dart:1213` — non-exclusive Day/Week/Month demo
- `controls_list_screen.dart:1238` — exclusive Day/Week/Month demo

#### Rationale
With zero production usage outside the legacy screen, nothing of value is being lost. The `exclusive` focus-clearing logic is demo-only — if the pattern ever appears in real production code, a dedicated flessel primitive can be proposed at that point with evidence of need.

#### Rejected alternative
Original matrix proposal listed `ADD_TO_FLESSEL` as a fallback "if the pattern is used heavily enough". Rejected post-audit: adding a generic `FlesselInputRow` primitive just to cover two demo usages in a soon-to-be-deleted legacy screen is pure over-abstraction.

#### Call-site retargeting
- `front/lib/shared/ui/inputs/vessel_input_row.dart` — delete file entirely
- `controls_list_screen.dart:1213, 1238` — delete the demo sections, along with the private demo state (`_dayController`, `_weekController`, `_monthController`, `_dayExclusiveController`, `_weekExclusiveController`, `_monthExclusiveController` on `_ControlsListScreenState`). Or these vanish with the legacy screen if strategy A (early deletion) is chosen.

#### Ordering dependency
- E10 (`VesselInputRowField` data class) retires in the same file deletion — bundled with this row's execution.
- Execution is independent of the legacy-screen deletion strategy (either strategy A or B works).

- **Status**: `DONE`

### 16. VesselRadioTile

- **Source**: `front/lib/shared/ui/inputs/vessel_radio_tile.dart`
- **Base**: `StatelessWidget`
- **Current props**:
  - `value: T` (required)
  - `groupValue: T` (required)
  - `onChanged: ValueChanged<T?>?`
  - `label: String` (required)
  - `contentPadding: EdgeInsets = EdgeInsets.zero`
- **Flessel equivalent**: `FlesselRadioTile<T>` — lives in `.vessel/packages/flessel/lib/src/controls/inputs/flessel_toggles.dart:273-315` (exported via `flessel.dart:46`)
- **Flessel props**:
  - `value: T` (required)
  - `groupValue: T` (required)
  - `onChanged: ValueChanged<T?>?`
  - `label: String` (required)
  - `contentPadding: EdgeInsets = EdgeInsets.zero`
  - `size: FlesselSize = FlesselSize.m` (new, defaulted)
- **Gap analysis**: flessel is a **strict superset**. All vessel props are present with matching types and defaults; flessel adds `size` on top with a sensible default.
- **Decision**: `SWITCH` (clean — no grow points)

#### Call-site audit

| File | Line | Production? | Props used |
|---|---|---|---|
| `front/lib/pages/settings_screen.dart` | 237 | **YES** — AppTheme picker | `value`, `groupValue`, `label`, `onChanged` |
| `front/lib/pages/controls_list_screen.dart` | 823, 831, 839 | Legacy (excluded per memory) | `value`, `groupValue`, `label`, `onChanged` |

Zero production usage of `contentPadding`. No gap between what production needs and what flessel provides.

#### Call-site retargeting

| File | Change |
|---|---|
| `settings_screen.dart:237` | `VesselRadioTile<AppTheme>` → `FlesselRadioTile<AppTheme>`; swap import to `package:flessel/flessel.dart` |
| `controls_list_screen.dart:823, 831, 839` | Transitional same swap (file slated for deletion post-migration) |

#### Post-migration dead code

Delete `front/lib/shared/ui/inputs/vessel_radio_tile.dart` once all call sites have been migrated.

#### Visual/behavior diffs accepted

- Flessel wraps the tile in `ConstrainedBox(minHeight: FlesselLayout.controlMinHeight(FlesselSize.m))`. Vessel has no such constraint — flessel enforces a min height that vessel doesn't. Standard flessel-baseline trade-off.
- Label typography: flessel uses `FlesselFonts.controlM` (Montserrat Semibold, m tier); vessel uses `VesselFonts.textControlInput`. Likely similar but not bit-identical.
- Both wrap `RadioGroup + RadioListTile` with `VisualDensity.compact` and `dense: true`. Core behavior matches.

#### Library-hygiene note (informational, not blocking)

`FlesselRadioTile` is **not currently showcased** in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart`. Row 16 has no API change, so the "grow points must update the example app" rule does not trigger. Flagged for separate attention — meatbag may want to add a demo page entry independently of the migration.

- **Status**: `DONE`

### 17. ProjectRadioGrid

- **Source**: `front/lib/shared/ui/inputs/vessel_radio_grid.dart` (mixed-prefix naming: file `vessel_radio_grid.dart` contains class `ProjectRadioGrid`)
- **Base**: `StatelessWidget`
- **Current props**:
  - `options: List<VesselRadioGridOption<T>>` (required)
  - `selectedValue: T` (required)
  - `onChanged: ValueChanged<T>?`
  - `columns: int = 2`
  - `spacing: double = 12`
  - `runSpacing: double = 12`
- **Current option class `VesselRadioGridOption<T>`**:
  - `value: T` (required)
  - `label: String` (required)
  - `icon: IconData?`
- **Flessel equivalent**: `FlesselButtonGrid<T>` — `.vessel/packages/flessel/lib/src/controls/inputs/flessel_button_grid.dart`
- **Flessel props**:
  - `options: List<FlesselButtonGridOption<T>>` (required)
  - `selectedValue: T` (required)
  - `onChanged: ValueChanged<T>?`
  - `columns: int = 2`
  - `spacing: double = FlesselLayout.gapM` (= 12)
  - `runSpacing: double = FlesselLayout.gapM` (= 12)
  - `size: FlesselSize = FlesselSize.m` (new, defaulted)
- **Flessel option class `FlesselButtonGridOption<T>`**: identical field set — `value: T`, `label: String`, `icon: IconData?`
- **Gap analysis**: **strict superset.** Every vessel prop is present with matching types and defaults; flessel's `gapM` literal matches vessel's hardcoded `12`. Flessel adds `size: FlesselSize` on top.
- **Decision**: `SWITCH`

#### Implementation quality (informational)

Flessel version is strictly better engineered:
- Vessel hardcodes padding `EdgeInsets.symmetric(vertical: 12, horizontal: 8)`, border radius `8`, border width `1.5`, icon size `20`, gap `8`, label font literal `VesselFonts.textControlInput`
- Flessel uses theme properties (`theme.controlBorderRadius`, `theme.controlBorderWidth`), layout tokens (`FlesselLayout.inputPaddingH`, `FlesselLayout.gapS`, `FlesselLayout.iconSize(size)`), `FlesselFonts.control*` scaled to size tier, and computes vertical padding dynamically for precise text centering within `controlMinHeight(size)`

#### Naming rename justification

Flessel already has `FlesselRadioTile` (see row 16) for classic radio-list UI. This grid-style selector looks and behaves like a button group laid out in a grid — "ButtonGrid" is a more accurate UI concept than "RadioGrid" and fits flessel's naming rule ("Flessel prefix + UI concept, not Flutter widget name"). No behavioral consequence; the rename is purely nominal.

#### Call-site audit

| File | Line | Production? | Usage |
|---|---|---|---|
| `front/lib/pages/controls_list_screen.dart` | 851, 880 | Legacy (excluded per memory) | 2 demo grids (2-col with icons, 3-col no icons) |

**Zero production call sites.** The only consumers live in the legacy controls screen. The consequence: the retargeting work is minimal and `vessel_radio_grid.dart` becomes immediately dead code after the legacy file's two usages are swapped.

This row is still framed as **SWITCH** rather than DELETE because:
1. Flessel already has the equivalent widget (`FlesselButtonGrid`), already showcased in the flessel example app.
2. The vessel version is simply a worse implementation of the same concept.
3. Framing as DELETE would misleadingly imply the concept is being dropped — it isn't; only the duplicate local copy is.

#### Call-site retargeting

| File | Lines | Change |
|---|---|---|
| `controls_list_screen.dart` (legacy) | 851, 880 | `ProjectRadioGrid<T>` → `FlesselButtonGrid<T>`; `VesselRadioGridOption` → `FlesselButtonGridOption`; swap import to `package:flessel/flessel.dart` |

Mechanical 1:1 rename — no prop changes, no restructuring.

#### Post-migration dead code

Delete `front/lib/shared/ui/inputs/vessel_radio_grid.dart` (both the `ProjectRadioGrid` class and the `VesselRadioGridOption` data class go together).

#### Library-hygiene status

`FlesselButtonGrid` is already showcased in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart` — no flessel example app update required for this row.

#### Ordering dependency

Execution is independent of legacy-screen deletion strategy. If strategy B (delete legacy at end of migration), the transitional retarget happens as described. If strategy A (delete legacy early), the legacy file is gone by the time this row executes and the only remaining action is deleting `vessel_radio_grid.dart`.

- **Status**: `DONE`

### 18. VesselSliderInput

- **Source**: `front/lib/shared/ui/inputs/vessel_slider_input.dart`
- **Base**: `StatefulWidget`
- **Current props**:
  - `value: int` (required)
  - `min: int = 0`
  - `max: int = 100`
  - `onChanged: ValueChanged<int>?`
  - `mode: VesselSliderInputMode = .counter`
  - `label: String?` ← **original matrix-proposed gap**
  - `zoned: bool = false`
  - `zones: List<SliderZoneConfig>?`
  - `showButtons: bool = false`
  - `showInput: bool = true`
  - `step: int = 1`
  - `inputSuffix: String?`
  - `expandedButtons: bool = false`
- **Support types**: `enum VesselSliderInputMode { counter }` (single-case), `class SliderZoneConfig` (identical in both projects), utilities `defaultCounterZones`, `counterZonesForTarget()`
- **Flessel equivalent**: `FlesselSliderInput` — `.vessel/packages/flessel/lib/src/controls/inputs/flessel_slider_input.dart`
- **Flessel props**:
  - `value: int` (required)
  - `min: int = 0`
  - `max: int = 100`
  - `onChanged: ValueChanged<int>?`
  - `mode: SliderInputMode = .counter`
  - `zoned: bool = false`
  - `zones: List<SliderZoneConfig>?`
  - `showButtons: bool = false`
  - `showInput: bool = true`
  - `step: int = 1`
  - `inputSuffix: String?`
  - `expandedButtons: bool = false`
  - `size: FlesselSize = FlesselSize.m` (new, defaulted)
- **Flessel enum**: `SliderInputMode { counter }` (pre-existing deviation from "Flessel" naming — not a row 18 concern)
- **Gap analysis**: `label: String?` only. Everything else matches or flessel is a superset (adds `size`). Support types (`SliderZoneConfig`, `defaultCounterZones`, `counterZonesForTarget`) exist identically in both libraries; no prop-surface gap at the utility level.
- **Decision**: `SWITCH` (flipped from original EXTEND_FLESSEL proposal — see audit below)

#### Decision flip rationale

The matrix originally proposed `EXTEND_FLESSEL` with a grow point to add `label: String?` to `FlesselSliderInput`. Call-site audit revealed **zero production usage** of `label` on the slider itself. Per the audit-before-propose pattern (same as row 13's dropped `inputFormatters`), the grow point is **dropped**.

Adding `label` to `FlesselSliderInput` would be preserving a vessel API shape that no production code actually exercises. The external-wrapping pattern — caller puts a `Text` above the slider if a label is desired — is already how production works.

#### Call-site audit

`VesselSliderInput` has **three distinct call sites**:

| File | Lines | Production? | Props used | Uses `label`? |
|---|---|---|---|---|
| `front/lib/shared/ui/inputs/vessel_time_slider.dart` | 46, 61 | Internal (sibling vessel widget — row 19) | `value`, `min`, `max`, `inputSuffix`, `showButtons`, `expandedButtons`, `showInput`, `onChanged`, `step` | **NO** |
| `front/lib/pages/controls_list_screen.dart` (legacy) | 931, 941, 953 | Legacy (excluded per memory) | `value`, `min`, `max`, `mode`, `zoned`, `showButtons`, `onChanged` | **NO** |

**Zero direct production call sites.** The only non-legacy caller is the sibling `VesselTimeSlider` (row 19), which wraps `VesselSliderInput` and renders its own external label via its own `label: String?` prop. The vessel wrapper already handles the label requirement one level up; the slider itself has never needed it.

#### Implementation quality (informational)

Flessel version is strictly better engineered:
- Flessel derives `trackHeight`, `thumbRadius` from `size` via `FlesselLayout.sliderTrackHeight{S,M,L}` / `sliderThumbRadius{S,M,L}`. Vessel hardcodes `trackHeight: 8`, `thumbRadius: 18`.
- Flessel uses `FlesselInputStyles.decoration()` for the counter input. Vessel hand-rolls `OutlineInputBorder` + padding literals.
- Flessel uses `FlesselLayout.gapXs` between sections. Vessel uses `SizedBox(height: 4)`.
- Flessel renders a seamless two-tone full-width track (clipped RRect). Vessel renders track-over-background with a visible border ring.
- Flessel uses `Icons.remove` / `Icons.add` (Material) for +/- buttons via `FlesselButtonGroup`. Vessel uses `PhosphorIconsRegular.minus` / `plus` via `ProjectButtonGroup`. Accepted visual diff — Material minus/plus glyphs instead of Phosphor, matching flessel's baseline.

#### Call-site retargeting

| File | Lines | Change |
|---|---|---|
| `vessel_time_slider.dart` | 46, 61 | `VesselSliderInput` → `FlesselSliderInput`; swap import to `package:flessel/flessel.dart`. Props map 1:1 — no `label` used. |
| `controls_list_screen.dart` (legacy) | 931, 941, 953 | `VesselSliderInput` → `FlesselSliderInput`; `VesselSliderInputMode.counter` → `SliderInputMode.counter`. Mechanical. |

Per the execution ordering decision below, the `vessel_time_slider.dart` row of this table is **not actually exercised** — it's superseded by row 19.

#### Ordering dependency (row 19 executes before row 18)

**Meatbag directive:** execute row 19 before row 18.

Consequence: by the time row 18 executes, `vessel_time_slider.dart` has already been deleted as part of row 19. The only remaining `VesselSliderInput` call sites are the 3 in the legacy demo file. This avoids redundant retargeting of `vessel_time_slider.dart`.

Effective row 18 retargeting (after row 19 has run):

| File | Lines | Change |
|---|---|---|
| `controls_list_screen.dart` (legacy) | 931, 941, 953 | `VesselSliderInput` → `FlesselSliderInput`; `VesselSliderInputMode.counter` → `SliderInputMode.counter` |

#### Post-migration dead code

Delete `front/lib/shared/ui/inputs/vessel_slider_input.dart` — removes the class, the enum `VesselSliderInputMode`, the data class `SliderZoneConfig`, and the utility functions `defaultCounterZones` / `counterZonesForTarget()` as a bundle. All four have zero external references outside this file (verified by grep), so the deletion is self-contained.

#### Library-hygiene status

`FlesselSliderInput` is already showcased in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart` — no flessel example app update required for this row.

- **Status**: `DONE`

### 19. VesselTimeSlider

- **Source**: `front/lib/shared/ui/inputs/vessel_time_slider.dart`
- **Base**: `StatelessWidget`
- **Current props**:
  - `value: int` (required)
  - `onChanged: ValueChanged<int>?`
  - `max: int = 480`
  - `showButtons: bool = false`
  - `showInput: bool = true`
  - `label: String?` ← **original matrix-proposed gap**
- **Internals**: wraps two `VesselSliderInput` in a `Row` (hours column + minutes column). Renders optional external label above the Row via a conditional branch. Column spacing: hardcoded `SizedBox(width: 8)`.
- **Flessel equivalent**: `FlesselTimeSlider` — `.vessel/packages/flessel/lib/src/controls/inputs/flessel_time_slider.dart`
- **Flessel props**:
  - `value: int` (required)
  - `onChanged: ValueChanged<int>?`
  - `max: int = 480`
  - `showButtons: bool = false`
  - `showInput: bool = true`
  - `size: FlesselSize = FlesselSize.m` (new, defaulted)
- **Flessel internals**: wraps two `FlesselSliderInput` with `size` propagated. Column spacing: `FlesselGap.s()` (= 8). No label branch.
- **Gap analysis**: `label: String?` only. Every other prop matches. Flessel is a superset (adds `size`).
- **Decision**: `SWITCH` (flipped from original EXTEND_FLESSEL proposal — see audit below)

#### Decision flip rationale

The matrix originally proposed `EXTEND_FLESSEL` with a grow point to add `label: String?` to `FlesselTimeSlider`, paired with row 18 on the shared `label` gap. Row 18's audit dropped `label` as unused in production. Row 19's audit now confirms the same: `label` has **zero production usage** on `VesselTimeSlider` as well. Per the audit-before-propose pattern (third time triggered: rows 13, 18, 19), the grow point is **dropped**.

#### Call-site audit

| File | Lines | Production? | Props used | Uses `label`? |
|---|---|---|---|---|
| `front/lib/pages/controls_list_screen.dart` (legacy) | 969, 977 | Legacy (excluded per memory) | `value`, `max`, `showButtons`, `onChanged` | **NO** |

**Zero production call sites.** The only file in the entire project that imports `vessel_time_slider.dart` is the legacy demo (verified by grep of import statements). Neither legacy call site uses `label` or `showInput`; `max: 480` is passed explicitly but equals the default.

`VesselTimeSlider` is effectively dead in production — it exists only to support the legacy demo. Its internal usage of `VesselSliderInput` (row 18) is likewise dead-tree.

#### Implementation quality (informational)

- Flessel propagates `size` down to both child `FlesselSliderInput` widgets, giving consistent sizing with the rest of the form.
- Flessel uses `FlesselGap.s()` instead of vessel's hardcoded `SizedBox(width: 8)`.
- Flessel has no label branch — external callers that need a label wrap the widget in a column with a `Text` above, matching the wrapping pattern established by row 18.

#### Call-site retargeting

| File | Lines | Change |
|---|---|---|
| `controls_list_screen.dart` (legacy) | 969, 977 | `VesselTimeSlider` → `FlesselTimeSlider`; swap import to `package:flessel/flessel.dart`. No `label` to translate. Mechanical. |

#### Ordering dependency (executes BEFORE row 18)

**Meatbag directive:** row 19 runs before row 18.

Execution sequence:
1. Row 19 retargets the 2 legacy `VesselTimeSlider` call sites to `FlesselTimeSlider`.
2. `vessel_time_slider.dart` becomes dead and is deleted as part of row 19's cleanup.
3. Deleting `vessel_time_slider.dart` automatically removes its 2 internal `VesselSliderInput` call sites — which would otherwise have needed row 18 retargeting.
4. Row 18 then runs, with only the 3 legacy demo `VesselSliderInput` call sites remaining to retarget.

This avoids redundant retargeting work on `vessel_time_slider.dart`.

#### Post-migration dead code

Delete `front/lib/shared/ui/inputs/vessel_time_slider.dart`.

#### Library-hygiene status

`FlesselTimeSlider` is already showcased in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart` — no flessel example app update required.

- **Status**: `DONE`

### 20. VesselDatePicker

- **Source**: `front/lib/shared/ui/inputs/vessel_date_picker.dart`
- **Base**: `StatelessWidget`
- **Current props**:
  - `label: String` (**required and non-nullable** — original matrix description was wrong)
  - `selectedDate: DateTime?` (required)
  - `onDateSelected: ValueChanged<DateTime>` (required)
  - `placeholder: String?`
  - `firstDate: DateTime?`
  - `lastDate: DateTime?`
  - `initialDate: DateTime?`
- **Internals**: renders a `Column` with `Text(label)` on top (using `VesselFonts.textBodyAccent`) and a tappable `Container` picker field below. Picker field hardcodes `padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)`. Uses Phosphor calendar icon.
- **Flessel equivalent**: `FlesselDatePicker` — `.vessel/packages/flessel/lib/src/controls/inputs/flessel_date_picker.dart`
- **Flessel props**:
  - `selectedDate: DateTime?` (required)
  - `onDateSelected: ValueChanged<DateTime>` (required)
  - `placeholder: String?`
  - `firstDate: DateTime?`
  - `lastDate: DateTime?`
  - `initialDate: DateTime?`
  - `size: FlesselSize = FlesselSize.m` (new, defaulted)
- **Flessel internals**: single tappable container picker field — **no label rendering**. Uses `FlesselLayout.controlMinHeight(size)`, `FlesselLayout.inputPaddingH`, theme border/colors, `Icons.calendar_today` (Material), `_controlFont(size)` for text. Note: pre-existing cleanliness debt in flessel — vertical padding formula uses a magic `17.0` literal. Not row 20's concern.
- **Gap analysis**: vessel renders an external label above the picker via a Column wrapping; flessel does not. Otherwise flessel is a superset (adds `size`).
- **Decision**: `SWITCH` (flipped from original EXTEND_FLESSEL proposal — see audit below)

#### Decision flip rationale

Matrix originally proposed `EXTEND_FLESSEL` with a `label: String?` grow point. Call-site audit revealed **zero production usage** — `VesselDatePicker` is only consumed by the legacy demo file. Per the audit-before-propose pattern (fourth consecutive trigger: rows 13, 18, 19, 20), the grow point is **dropped**.

The decision is SWITCH because flessel already has the equivalent picker widget. The label-rendering concern, since it's never exercised by production, is handled at the call sites via external column wrapping — matching the pattern established in rows 18/19.

#### Call-site audit

| File | Lines | Production? | Props used |
|---|---|---|---|
| `front/lib/pages/controls_list_screen.dart` (legacy) | 899, 908 | Legacy (excluded per memory) | `label`, `selectedDate`, `placeholder`, `firstDate`, `onDateSelected` |

**Zero production call sites.** Only the legacy demo imports `vessel_date_picker.dart`. Both demo call sites pass `label`, but neither is production code.

This is the fourth consecutive row in the slider/picker family with zero production usage. The vessel slider/picker widgets were built for the legacy demo and never adopted by real screens.

#### Call-site retargeting

For each of the 2 legacy call sites, wrap `FlesselDatePicker` in a `Column` with an external `Text` for the label:

```dart
// Before:
VesselDatePicker(
  label: 'Start Date',
  selectedDate: _demoStartDate,
  placeholder: 'Select date',
  onDateSelected: (date) => setState(() => _demoStartDate = date),
)

// After:
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('Start Date', style: FlesselFonts.contentBodyAccent),
    const FlesselGap.xxs(),
    FlesselDatePicker(
      selectedDate: _demoStartDate,
      placeholder: 'Select date',
      onDateSelected: (date) => setState(() => _demoStartDate = date),
    ),
  ],
)
```

Font mapping: vessel's `VesselFonts.textBodyAccent` → `FlesselFonts.contentBodyAccent` (both are the emphasized body alias — closest equivalent).

Label-to-field gap: vessel uses `SizedBox(height: 4)`, flessel equivalent is `FlesselGap.xxs()` (= 2). Minor visual tweak — meatbag can adjust when touching designs later.

#### Post-migration dead code

Delete `front/lib/shared/ui/inputs/vessel_date_picker.dart`.

#### Library-hygiene status

`FlesselDatePicker` is already showcased in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart` — no flessel example app update required.

- **Status**: `DONE`

### 21. VesselHourPicker

- **Source**: `front/lib/shared/ui/inputs/vessel_hour_picker.dart`
- **Base**: `StatelessWidget`
- **Current props**:
  - `label: String` (**required and non-nullable** — original matrix description was wrong)
  - `description: String?`
  - `selectedHour: int` (required)
  - `onHourSelected: ValueChanged<int>` (required)
- **Internals**: outer `Column` with `Text(label)` (using `VesselFonts.textBodyAccent`) → optional `Text(description)` (using `VesselFonts.textCaption`) → tappable picker field. Picker field hardcodes `padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)`, Phosphor clock icon size 20. Opens `showVesselBottomSheet<int>` with `_HourPickerSheet` — a 4-col GridView of 24 hours with selection highlight via `theme.accentColor`.
- **Flessel equivalent**: `FlesselHourPicker` — `.vessel/packages/flessel/lib/src/controls/inputs/flessel_hour_picker.dart`
- **Flessel props**:
  - `selectedHour: int` (required)
  - `onHourSelected: ValueChanged<int>` (required)
  - `size: FlesselSize = FlesselSize.m` (new, defaulted)
- **Flessel internals**: single `GestureDetector` wrapping a themed `Container` — **no label, no description rendering**. Uses `Icons.schedule` (Material) instead of Phosphor clock. Opens `showFlesselBottomSheet<int>` with same-pattern `_HourPickerSheet`. Same pre-existing magic `17.0` vertical padding formula in flessel (cleanliness debt, not row 21's concern).
- **Gap analysis**: vessel has `label: String` (required) and `description: String?`; flessel has neither. Otherwise flessel is a superset (adds `size`).
- **Decision**: `SWITCH` (flipped from original EXTEND_FLESSEL proposal — see audit below)

#### Decision flip rationale

Matrix originally proposed `EXTEND_FLESSEL` with two grow points: `label: String?` and `description: String?`. Call-site audit revealed **zero production usage** — `VesselHourPicker` is only consumed by the legacy demo file. Per the audit-before-propose pattern (**fifth consecutive trigger**: rows 13, 18, 19, 20, 21), both grow points are **dropped**.

The decision is SWITCH because flessel already has the equivalent picker widget. Label and description rendering, since they're never exercised by production, are handled at the single legacy call site via external column wrapping.

#### Call-site audit

| File | Lines | Production? | Props used |
|---|---|---|---|
| `front/lib/pages/controls_list_screen.dart` (legacy) | 919 | Legacy (excluded per memory) | `label`, `description`, `selectedHour`, `onHourSelected` |

**Zero production call sites.** The single legacy call site uses both `label` AND `description`, but neither is production.

This is the fifth consecutive row in the slider/picker family with zero production usage (rows 18, 19, 20, 21). The sub-pattern is ironclad: the entire vessel slider/picker family was built for the legacy demo and never adopted by real screens.

#### Call-site retargeting

The single legacy call site at `controls_list_screen.dart:919` rewrites as:

```dart
// Before:
VesselHourPicker(
  label: 'Day start hour',
  description: 'Pick when the day begins',
  selectedHour: _selectedHour,
  onHourSelected: (h) => setState(() => _selectedHour = h),
)

// After:
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('Day start hour', style: FlesselFonts.contentBodyAccent),
    const FlesselGap.xxs(),
    Text('Pick when the day begins', style: FlesselFonts.contentCaption),
    const FlesselGap.s(),
    FlesselHourPicker(
      selectedHour: _selectedHour,
      onHourSelected: (h) => setState(() => _selectedHour = h),
    ),
  ],
)
```

Font mapping:
- `VesselFonts.textBodyAccent` → `FlesselFonts.contentBodyAccent`
- `VesselFonts.textCaption` → `FlesselFonts.contentCaption`

Spacing mapping:
- vessel's `SizedBox(height: 4)` between label and description → `FlesselGap.xxs()` (= 2)
- vessel's `SizedBox(height: 8)` between description and field → `FlesselGap.s()` (= 8)

#### Post-migration dead code

Delete `front/lib/shared/ui/inputs/vessel_hour_picker.dart` (removes both `VesselHourPicker` and the inner `_HourPickerSheet`).

#### Library-hygiene gap (informational, NOT blocking)

`FlesselHourPicker` is **NOT** currently showcased in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart` — unlike rows 16-20 where the flessel example app already demonstrated each widget. Row 21 has no API change, so the "grow points must update the example app" rule does not trigger. Flagged as informational — the flessel example app has a coverage gap for `FlesselHourPicker` that meatbag may want to address separately. This is the second such case in this migration (first was `FlesselRadioTile` in row 16).

- **Status**: `DONE`

### 22. VesselCheckbox

- **Location**: `front/lib/shared/ui/inputs/vessel_toggles.dart`
- **Current props**: `value: bool` (required), `onChanged: ValueChanged<bool?>?` (required)
- **Flessel equivalent**: `FlesselCheckbox`
- **Flessel props**: `value: bool?` (required), `onChanged: ValueChanged<bool?>?` (required), `tristate: bool = false`
- **Decision**: `SWITCH`
- **Call-site audit**: zero production call sites. Only 1 bare usage in legacy `controls_list_screen.dart:744` and 1 internal use inside `VesselCheckboxLabeled` (row 24) — both are retargeted transparently when those rows execute.
- **Note**: vessel's `value` is `bool`; flessel's is `bool?` for tristate support. Type widening is trivially safe (every `bool` fits `bool?`). Flessel's `tristate: false` default preserves vessel behavior. Vessel's `onChanged` is already `ValueChanged<bool?>?`, identical to flessel's — no callback signature change.
- **Part of**: toggle-family bundle (rows 22–25), all four widgets live in `vessel_toggles.dart`.
- **Status**: `DONE`

### 23. VesselSwitch

- **Location**: `front/lib/shared/ui/inputs/vessel_toggles.dart`
- **Current props**: `value: bool` (required), `onChanged: ValueChanged<bool>?` (required)
- **Flessel equivalent**: `FlesselSwitch`
- **Flessel props**: `value: bool` (required), `onChanged: ValueChanged<bool>?` (required)
- **Decision**: `SWITCH`
- **Call-site audit**: zero production call sites. Only 1 bare usage in legacy `controls_list_screen.dart:785` and 1 internal use inside `VesselSwitchLabeled` (row 25) — both are retargeted transparently when those rows execute.
- **Note**: prop surfaces are an exact match. Pure rename.
- **Part of**: toggle-family bundle (rows 22–25).
- **Status**: `DONE`

### 24. VesselCheckboxLabeled

- **Location**: `front/lib/shared/ui/inputs/vessel_toggles.dart`
- **Current props**: `value: bool?`, `onChanged: ValueChanged<bool?>?`, `label: String`, `subtitle: String?`, `labelPosition: VesselLabelPosition = right`, `fullWidth: bool = false`
- **Flessel equivalent**: `FlesselCheckboxLabeled`
- **Flessel props**: `value: bool?`, `onChanged: ValueChanged<bool?>?`, `label: String`, `subtitle: String?`, `labelPosition: LabelPosition = right`, `fullWidth: bool = false`, `tristate: bool = false`, `size: FlesselSize = m`
- **Decision**: `SWITCH`
- **Call-site audit**: zero production call sites. Only 3 legacy usages in `controls_list_screen.dart:752, 761, 771`.
- **Call-site mapping**: `VesselLabelPosition.left/right` → `LabelPosition.left/right` (same semantics, same defaults). No callable changes.
- **Note**: flessel is a strict superset — same required props, same defaults, two additive optional props (`tristate`, `size`) with behavior-preserving defaults.
- **Part of**: toggle-family bundle (rows 22–25). Drives E6 (`VesselLabelPosition` enum retirement).
- **Status**: `DONE`

### 25. VesselSwitchLabeled

- **Location**: `front/lib/shared/ui/inputs/vessel_toggles.dart`
- **Current props**: `value: bool`, `onChanged: ValueChanged<bool>?`, `label: String`, `labelPosition: VesselLabelPosition = left`, `fullWidth: bool = false`
- **Flessel equivalent**: `FlesselSwitchLabeled`
- **Flessel props**: `value: bool`, `onChanged: ValueChanged<bool>?`, `label: String`, `labelPosition: LabelPosition = left`, `fullWidth: bool = false`, `size: FlesselSize = m`
- **Decision**: `SWITCH`
- **Call-site audit**: zero production call sites. Only 3 legacy usages in `controls_list_screen.dart:793, 802, 812`.
- **Call-site mapping**: `VesselLabelPosition.left/right` → `LabelPosition.left/right`. Same default (`left`).
- **Note**: strict superset with one enum rename and one additive optional (`size`).
- **Part of**: toggle-family bundle (rows 22–25). Drives E6 (`VesselLabelPosition` enum retirement).
- **Status**: `DONE`

### Toggle-family bundle note (rows 22–25)

The entire `vessel_toggles.dart` file has **zero production call sites across all four widgets**. Only the legacy `controls_list_screen.dart` exercises them. This is the second consecutive legacy-only family (after the slider/picker family, rows 18–21). Execution implications:
- When execution unleashes come, rows 22–25 can share a single execution commit: retarget 12 legacy references (4 symbol classes + 3 enum call sites + imports), delete `vessel_toggles.dart`, delete `VesselLabelPosition` enum (row E6).
- Zero flessel grow points. Zero `flessel/example/` changes. Zero `consumer.claude.md` changes.
- Reinforces the "delete legacy screen early" strategic question — early deletion would eliminate all row 22–25 execution work entirely.

### 26. VesselInputStyles

- **Location**: `front/lib/shared/ui/inputs/vessel_input_styles.dart`
- **Type**: static utility class (InputDecoration and text style provider, 44 lines)
- **Source surface**: `decoration({context, label, hint})`, `textStyle(context)`, private `_border(context)`
- **Flessel counterpart**: `FlesselInputStyles` — already exists at `.vessel/packages/flessel/lib/src/controls/inputs/flessel_input_styles.dart`, exported from `package:flessel/flessel.dart` (line 39), used internally by `FlesselTextInput`, `FlesselDropdown`, `FlesselSliderInput`, `FlesselDatePicker`, `FlesselHourPicker`, and demoed heavily in the flessel example app.
- **Flessel signature**: `decoration({required context, String? label, String? hint, FlesselSize size = FlesselSize.m})`, `textStyle(context, {FlesselSize size = FlesselSize.m})` — strict superset with optional `size` tier.
- **Decision**: `DELETE`
- **Rationale**: inputs using flessel controls no longer need the helper. `FlesselTextInput` and friends consume `FlesselInputStyles` internally; consumers who need raw-`TextField`+styling can import `FlesselInputStyles` directly from the flessel barrel.
- **Call-site audit**:
  - `vessel_input_row.dart:119-120` — internal to row 15 (`VesselInputRow / ProjectInputRow`, already `DELETE APPROVED`); dies with its parent.
  - `controls_list_screen.dart:692-693, 700-701` — two raw `TextField` demos in the legacy screen.
  - **Zero production call sites outside row 15's dying widget and the legacy screen.**
- **Behavioral deltas on execution** (all visually affect legacy file only):
  - Vessel `labelText` (Material floating label) → flessel `hintText: label ?? hint` with `isCollapsed: true` (placeholder only, no float).
  - Vessel hardcoded padding → flessel `TextPainter`-measured padding hitting `FlesselLayout.controlMinHeight(size)` exactly.
  - Vessel `isDense: true` → flessel `isCollapsed: true`.
- **Execution plan** (deferred):
  1. Row 15 execution removes the `vessel_input_row.dart` caller as a side effect of deleting its parent widget.
  2. Row 26 execution retargets legacy `controls_list_screen.dart:692-693, 700-701` — 1:1 class rename `VesselInputStyles` → `FlesselInputStyles`, accept floating-label → placeholder visual delta (legacy screen, slated for deletion).
  3. Delete `vessel_input_styles.dart`.
  4. No flessel grow points. No `flessel/example/` or `consumer.claude.md` updates.
- **Ordering**: row 26 can execute together with or after row 15. No hard constraint.
- **Status**: `DONE`

### 27. VesselLangButton

- **Location**: `front/lib/shared/ui/lang_button/vessel_lang_button.dart`
- **Base**: `ConsumerWidget`
- **Current props**: `langCode: String`, `label: String`, `onPressed: VoidCallback?`
- **Dependencies**: `CountryFlag` (`country_flags` package), `themeProvider` (riverpod), `VesselButtonStyleResolver` (row 8), `VesselThemes`
- **Decision**: `DELETE` (flipped from `LANGWIJ_COMPOSITE`)
- **Rationale**: the widget was built but **never adopted**. Zero production call sites across the entire repo.
- **Call-site audit (six search passes, all with `.vessel/` excluded)**:
  - `VesselLangButton` (case-sensitive and case-insensitive) — only self-refs + matrix/plan inventory lines
  - `vessel_lang_button` / `lang_button` (path tokens) — only self-refs + matrix/plan
  - `export` / `show VesselLangButton` — no barrel file exposes it; only barrel-style exports in `front/` are theme files and `VesselButtonSize` re-export from `vessel_buttons.dart`
  - `front/test/widget_test.dart` — 19-line smoke test on `main.dart`, no reference
  - `front/integration_test/` — directory does not exist
  - `lang_button/` directory contents — only `vessel_lang_button.dart`, no barrel, no siblings
- **What production "lang button" scenarios actually do**: three screens render country flags without using this widget. `lang_picker_screen.dart:92`, `language_screen.dart:392` and `:543`, `quiz_bottom_sheets.dart:216` all call `CountryFlag.fromCountryCode(...)` inline inside custom tile/sheet patterns. **None** route through `VesselLangButton`.
- **Upstream unlock**: row 8 (`VesselButtonStyleResolver`, `DELETE APPROVED`) currently lists this file as an ACTIVE user. With row 27 flipping to DELETE, row 8's blocker chain collapses — its `rows 1-7 + row 27` list shrinks to `rows 1-7`. The row 8 detailed section has been updated to reflect this.
- **Grow points needed**: **none**. The earlier `LANGWIJ_COMPOSITE` proposal raised an `EXTEND_FLESSEL` discussion point about `FlesselButton.leading: Widget?` to host a `CountryFlag`. That discussion was **premature** — no caller would have needed it. Dropped.
- **Layout constants**: `VesselLayout.langFlagWidth` (64.0) and `langFlagHeight` (44.0) are **still production-used** by `lang_picker_screen.dart` and `language_screen.dart` (NOT by this dead widget — the widget hardcoded different values `32.0`/`22.0` in local constants). These layout constants are NOT retired by row 27; they live on until a dedicated layout-retirement pass or a future `LangwijLangTile` composite.
- **Forward flag — future matrix row candidate**: the three screens (`lang_picker_screen.dart`, `language_screen.dart`, `quiz_bottom_sheets.dart`) share near-identical `CountryFlag` + label tile patterns. Candidate for a `LangwijLangTile` composite row added to the matrix before Phase 3 execution. Not in scope for row 27 — flagging for meatbag consideration.
- **Execution plan**:
  1. Delete `front/lib/shared/ui/lang_button/vessel_lang_button.dart`
  2. Delete the now-empty parent directory `front/lib/shared/ui/lang_button/`
  3. No imports to clean up (zero callers)
  4. `flutter analyze` should be clean
- **Flessel impact**: none. No grow points. No `flessel/example/` updates. No `consumer.claude.md` updates.
- **This is the sixth instance** of the audit-before-propose pattern — matrix pre-proposals continue to reflect planning-time guesses that don't match real call-site data.
- **Status**: `DONE`

### 28. VesselNote

- **Location**: `front/lib/shared/ui/note/vessel_note.dart`
- **Current props**: `text: String` (required), `accented: bool = false`
- **Flessel equivalent**: `FlesselNote`
- **Flessel props**: `text: String` (required), `contentSized: bool = false`, `accented: bool = false`
- **Decision**: `SWITCH` — **flessel stays as-is, no grow**
- **Call-site audit**:
  - 7 production: `language_screen.dart:173,179,186,526`, `round_screen.dart:184,193`, `result_screen.dart:139`
  - 2 legacy: `controls_list_screen.dart:1117,1121`
  - Only `language_screen.dart:173` passes `accented: true` (native-language note emphasis)
- **Accepted visual regressions** (meatbag directive — keep flessel fully, no grow):
  - **Font size 14px → 12px**: vessel `VesselFonts.textNote = _bodyM` (Montserrat 14) vs flessel default `FlesselFonts.contentS` (Montserrat 12). All 7 production notes will render 2px smaller. Per-call-site mitigation available without growing flessel: pass `contentSized: true` to reach `FlesselFonts.contentM` (Montserrat 14) using the existing flessel API. **Execution-time decision** whether to preserve size uniformly or accept 12px.
  - **Accent: color palette → font weight only**: vessel `accented: true` swaps 3 theme colors (`noteAccentBackground`, `noteAccentBorderColor`, `noteAccentTextColor`) — each theme defines a darker/stronger accent (platinum→gunMetal, darkNavyA06→darkNavy, etc.). Flessel `accented: true` only swaps font weight (contentSAccent/contentMAccent). `language_screen.dart:173` will lose its color-based native-language emphasis — **no mitigation without growing flessel; regression fully accepted**.
- **Prop mapping**: pure 1:1 rename. `text` and `accented` signatures identical. Optional `contentSized` is additive.
- **Flessel impact**: none. No grow points. No `flessel/example/` updates. No `consumer.claude.md` updates. `FlesselThemeData` unchanged.
- **Orphaned vessel theme properties** (flagged for later theme-retirement phase, not this row):
  - `noteTextColor` (5 themes) — unused after row 28 execution
  - `noteAccentBackground`, `noteAccentBorderColor`, `noteAccentTextColor` (5 themes) — all unused after row 28 execution
- **Execution plan** (deferred to Phase 3):
  1. Retarget all 9 call sites: `VesselNote` → `FlesselNote`
  2. `language_screen.dart:173` keeps `accented: true` — accepts color→weight regression
  3. Per-call-site `contentSized: true` (or not) decided at execution time to preserve 14px
  4. Delete `front/lib/shared/ui/note/vessel_note.dart`
  5. `flutter analyze` clean
- **Status**: `DONE`

### 29. VesselProgressBar

- **Location**: `front/lib/shared/ui/progress_bar/vessel_progress_bar.dart`
- **Current props**: `value: double` (required), `mode: VesselProgressBarMode = compact`
- **Flessel equivalent**: `FlesselProgressBar`
- **Flessel props**: `value: double` (required), `mode: FlesselProgressBarMode = compact`
- **Decision**: `SWITCH` — byte-for-byte twin at the widget layer
- **Widget code comparison**: structurally identical. Same `StatelessWidget` base, identical build logic (`ClipRRect` → `LinearProgressIndicator` with clamped value, `AlwaysStoppedAnimation` color, `minHeight` from theme). Identical theme property names used: `progressBarFilled`, `progressBarUnfilled`, `progressBarBorderRadius`, `progressBarCompactHeight`, `progressBarDetailedHeight`. Only difference is class/enum prefix.
- **Enum mapping**: `VesselProgressBarMode {compact, detailed}` → `FlesselProgressBarMode {compact, detailed}` — same variants, same default, enum rename only. Drives row E4.
- **Theme value drift** (Phase 4 concern, NOT blocking row 29):
  - theme01, theme03 — heights + colors identical between vessel and flessel
  - theme02 — heights identical, colors differ (vessel `darkNavy/darkNavyA12` vs flessel `lightForeground/lightForegroundA12`)
  - theme04 — heights identical, colors differ (vessel `deepWalnut/silverdust` vs flessel `darkNavy/darkNavyA12`)
  - theme05 — heights identical, unfilled color differs (vessel `deepWalnutA12` vs flessel `silverdust`)
  - Color drift only manifests once the vessel theme system is retired in Phase 4. Row 29's widget/enum rename is clean regardless. **Phase 4 audit task**: reconcile theme02/04/05 progress-bar colors — decide which version is canonical.
- **Call-site audit**:
  - `vocab_level_card.dart:78-80` — production, mode `detailed` (row 47 LANGWIJ_COMPOSITE target, absorbed)
  - `vocab_deck_tile.dart:82-84` — production, mode `compact` (row 46 LANGWIJ_COMPOSITE target, absorbed)
  - `language_screen.dart:564-566` — production direct, mode `detailed`
  - `controls_list_screen.dart:197-199` — legacy, mode `compact`
  - 3 production + 1 legacy. Only `language_screen.dart` needs a direct rename — the other two production sites get absorbed into rows 46/47 composites.
- **Flessel impact**: **none**. No grow points. No `flessel/example/` updates. No `consumer.claude.md` updates. `FlesselThemeData` unchanged.
- **E4 natural corollary**: row E4 (`VesselProgressBarMode` enum → DELETE, currently `PROPOSED`) has zero non-row-29 usages and is replaced 1:1 by `FlesselProgressBarMode`. Same pattern as E6 for rows 24/25. Flagged for potential bundled approval.
- **Execution plan** (deferred to Phase 3):
  1. Retarget `language_screen.dart:564-566`: `VesselProgressBar` → `FlesselProgressBar`, `VesselProgressBarMode.detailed` → `FlesselProgressBarMode.detailed`
  2. Retarget legacy `controls_list_screen.dart:197-199` similarly
  3. Row 46 (VocabDeckTile) execution absorbs its `VesselProgressBar` usage
  4. Row 47 (VocabLevelCard) execution absorbs its `VesselProgressBar` usage
  5. Delete `front/lib/shared/ui/progress_bar/vessel_progress_bar.dart` (widget + enum in same file)
  6. `flutter analyze` clean
- **Status**: `DONE`

### 30. VesselScaffold

- **Location**: `front/lib/shared/ui/screen_layout/vessel_scaffold.dart`
- **Current props**: `title: String`, `child: Widget`, `actions: List<Widget>?`, `leading: Widget?`, `showBottomNav: bool`, `onSettingsDisabledTap: VoidCallback?`
- **Flessel equivalent**: `FlesselScaffold`
- **Flessel props (pre-grow)**: `child: Widget`, `title: String?`, `onBackPressed: VoidCallback?`, `onAcceptPressed: VoidCallback?`, `bottomNavBar: Widget?`, `useAppBar: bool`, `appBarActions: List<Widget>?`
- **Call-site audit** (10 production, legacy `controls_list_screen.dart:98` excluded):

  | # | File:line | title | child | actions | leading | showBottomNav | onSettingsDisabledTap |
  |---|---|:-:|:-:|:-:|:-:|:-:|:-:|
  | 1 | agreement_group_list_screen.dart:96 | l10n | Y | — | `BackButton(->tools)` | true | — |
  | 2 | vocab_deck_list_screen.dart:101 | l10n | Y | — | — | true | — |
  | 3 | vocab_deck_list_screen.dart:124 | l10n | Y | — | — | true | — |
  | 4 | tools_screen.dart:29 | l10n | Y | — | — | true | — |
  | 5 | settings_screen.dart:177 | l10n | Y | — | — | true | `_handleTitleTap` |
  | 6 | round_screen.dart:139 | var | Y | `[IconButton(X)]` | — | default=false | — |
  | 7 | result_screen.dart:38 | l10n | Y | — | — | default=false | — |
  | 8 | language_screen.dart:45 | l10n | Y | — | — | true | — |
  | 9 | lang_picker_screen.dart:34 | var | Y | — | — | explicit=false | — |
  | 10 | group_list_screen.dart:326 | var | Y | — | `BackButton(->tools)` | true | — |

  Rollup: `title` 10/10, `child` 10/10, `actions` 1/10 (round_screen only), `leading` 2/10 (both identical `BackButton(onPressed: () => context.go(AppRoutes.tools))`), `showBottomNav: true` 7/10, `onSettingsDisabledTap` 1/10 (settings_screen — plumbed to `VesselNavBar`'s disabled settings icon at `vessel_navbar.dart:91`, NOT the title; method name `_handleTitleTap` is misleading).

- **Per-prop migration**:
  - `title` -> `title` + grow points G1 (uppercase opt) / G2 (center opt)
  - `child` -> `child`
  - `actions` -> `appBarActions` (rename)
  - `leading: BackButton(onPressed: X)` -> `onBackPressed: X` (both `leading` sites migrate losslessly; the pre-proposed `leading: Widget?` grow point is **dropped** — audit confirmed flessel's callback handles every production case)
  - `showBottomNav: true` (7 sites) -> `bottomNavBar: const LangwijMainNavBar()` (composite from row 38)
  - `showBottomNav: false`/default (3 sites) -> `bottomNavBar: null`
  - `onSettingsDisabledTap` (1 site) -> absorbed into `LangwijMainNavBar` as internal nav-item configuration (row 38); no longer a scaffold concern

- **Grow points / library changes (G1–G5, all bundled with row 30)**:
  - **G1 — Optional title uppercasing.** `flessel_topbar.dart` hardcodes `.toUpperCase()` at lines 123/130/137. Add `bool uppercaseTitle = false` to `FlesselTopBar` + plumb through `FlesselScaffold`. Default `false` = neutral library default; langwij opts in.
  - **G2 — Optional title centering.** `flessel_topbar.dart:138` hardcodes `centerTitle: true`. Add `bool? centerTitle` (default `null` = Material platform default: left on Android/Windows/Linux, center on iOS). Plumbed through `FlesselScaffold`.
  - **G3 — Remove title animation entirely.** Delete from `flessel_topbar.dart`: `animateTitle` param, `_exitController`/`_enterController`/`_exitFade`/`_enterFade`/`_enterSlide`, `_previousTitle`/`_currentTitle`, `initState`/`dispose`, the `AnimatedBuilder`/`FadeTransition`/`SlideTransition`/`Stack` rendering. Convert `StatefulWidget` -> `StatelessWidget` (remove `TickerProviderStateMixin`). Title becomes plain `Text(displayTitle, style: titleStyle)` (with G1 uppercase applied when enabled). Scan confirmed zero external callers of `animateTitle` — library-internal cleanup.
  - **G4 — Platform-adaptive back button.** Replace `flessel_topbar.dart:106-111` `IconButton(icon: Icon(Icons.arrow_back, color: iconColor), onPressed: ...)` with Material's `BackButton(color: iconColor, onPressed: ...)` — already platform-adaptive (arrow_back on Android/Windows/Linux, arrow_back_ios on iOS/macOS). No new param.
  - **G5 — Delete `isWindows` bottom-nav gate.** Remove platform special-casing from `flessel_scaffold.dart` at lines 31, 51, 58 (and the `import 'package:flessel/src/utils/platform_utils.dart';` at line 3). Flessel makes no platform decisions; consumers pass `bottomNavBar: null` where they don't want it. Scan confirmed no external callers affected; `PlatformUtils` stays (still used by `flessel_navbar_constants.dart:19`, out of scope).

- **Post-grow flessel API shape**:
  ```dart
  class FlesselTopBar extends StatelessWidget implements PreferredSizeWidget {
    const FlesselTopBar({
      super.key,
      this.title,
      this.onBackPressed,
      this.actions,
      this.uppercaseTitle = false,
      this.centerTitle,         // bool?, null = Material default
      this.overlay = false,
    });
  }

  class FlesselScaffold extends StatelessWidget {
    const FlesselScaffold({
      super.key,
      required this.child,
      this.title,
      this.onBackPressed,
      this.onAcceptPressed,
      this.bottomNavBar,
      this.useAppBar = true,
      this.appBarActions,
      this.uppercaseTitle = false,
      this.centerTitle,         // bool?, null = Material default
    });
  }
  ```

- **Execution dependency**: row 30 must be bundled with row 38 (VesselNavBar -> `LangwijMainNavBar` composite) and row 39 (VesselNavBarIcon) in Phase 3. The 7 `showBottomNav: true` call sites cannot migrate until `LangwijMainNavBar` exists. Row 38 also absorbs the `onSettingsDisabledTap` dev-access hack.

- **Execution-time call-site verification (Phase 3)**: 3 sites currently rely on Material AppBar's automatic back button; `FlesselTopBar` only shows a back button when `onBackPressed != null` (`flessel_topbar.dart:106-111`). Each site needs verification during execution:
  - `lang_picker_screen.dart:34` — almost certainly needs `onBackPressed: () => context.pop()` (sub-screen returning a value via `context.pop(pack.code)`)
  - `round_screen.dart:139` — has explicit `X` action as primary exit; decide whether auto-back is still desired
  - `result_screen.dart:38` — end-of-flow screen; decide whether back is desired at all

- **Example app**: Update scaffold/topbar demo section in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart` — showcase `uppercaseTitle: true` vs `false`, `centerTitle: true/false/null` (platform default). Verify title no longer animates (G3 cleanup).

- **Decision**: `EXTEND_FLESSEL` (5 grow points/library changes G1–G5)
- **Status**: `DONE`

### 31. VesselSnackBar

- **Location**: `front/lib/shared/ui/snackbar/vessel_snackbar.dart`
- **Type**: utility class with `VesselSnackBar._()` private ctor, `static SnackBar of(BuildContext, String)`, `static void show(BuildContext, String)`
- **Flessel equivalent**: `FlesselSnackBar` — byte-for-byte twin except class name, theme accessor (`VesselThemes` -> `FlesselThemes`), and font accessor (`VesselFonts.textSnackbar` -> `FlesselFonts.contentM`)
- **Font equivalence confirmed**:
  - `VesselFonts.textSnackbar` -> `_bodyM` -> `GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.normal)` (`front/lib/app/theme/vessel_fonts.dart:23-24, 145`)
  - `FlesselFonts.contentM` -> `_m14` -> `GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.normal)` (`.vessel/packages/flessel/lib/src/theme/flessel_fonts.dart:30-31, 79`)
  - Identical at runtime — no font regression.
- **Call-site audit** (2 production, 2 legacy excluded):

  | # | File:line | Method | Message arg |
  |---|---|---|---|
  | 1 | settings_screen.dart:155 | `.show(context, msg)` | `l10n.settings_validateSuccess` |
  | 2 | settings_screen.dart:160 | `.show(context, msg)` | `l10n.settings_validateError(e.message)` |
  | L | controls_list_screen.dart:1099 | label in demo `Text` | excluded (legacy) |
  | L | controls_list_screen.dart:1106 | `.show(context, msg)` | excluded (legacy) |

  Rollup: `.show(context, String)` 2/2 production. `.of(context, String)` 0/2 production — zero direct usages of the `SnackBar`-returning variant. `of()` preserved in flessel source anyway (utility class symmetry, zero cost).
- **Theme value drift** (same pattern as row 29): snackbar theme properties (`snackbarBackground`, `snackbarTextColor`, `snackbarBorderRadius`) across all 5 themes:

  | Theme | vessel (bg / text / radius) | flessel (bg / text / radius) | drift |
  |---|---|---|:-:|
  | 01 | pureBlack / pureWhite / 8.0 | pureBlack / pureWhite / 8.0 | — |
  | 02 | darkNavy / mintCream / 8.0 | lightForeground / oldlace / 8.0 | **yes** |
  | 03 | pureBlack / pureWhite / 4.0 | pureBlack / pureWhite / 4.0 | — |
  | 04 | deepWalnut / oldlace / 8.0 | darkNavy / mintCream / 8.0 | **yes** |
  | 05 | deepWalnut / oldlace / 8.0 | deepWalnut / oldlace / 8.0 | — |

  Drift flagged for **Phase 4 theme retirement audit** (deferred, does not affect row 31 widget-level decision).
- **Decision**: `SWITCH` (zero grow points). Utility class with identical runtime behavior.
- **Execution plan** (Phase 3):
  1. `settings_screen.dart:155` — `VesselSnackBar.show` -> `FlesselSnackBar.show`
  2. `settings_screen.dart:160` — `VesselSnackBar.show` -> `FlesselSnackBar.show`
  3. Replace import in `settings_screen.dart`: `vessel_snackbar.dart` -> `package:flessel/flessel.dart`
  4. Legacy `controls_list_screen.dart:1099/1106` — transitional retarget OR leave until legacy file deletion (per the open legacy-file strategic question)
  5. Delete `front/lib/shared/ui/snackbar/vessel_snackbar.dart`
  6. `flutter analyze` clean
- **Status**: `DONE`

### 32. VesselTagChip

- **Location**: `front/lib/shared/ui/tag/vessel_tag_chip.dart` (lines 10-66; the same file also contains `VesselTagColorPreview` on lines 69-112, handled by row 33)
- **Base**: `StatelessWidget`
- **Current props**: `tag: Tag` (domain), `onTap: VoidCallback?`, `showName: bool = true`
- **Flessel equivalent (pre-audit proposal)**: `FlesselTag` primitive wrapped in a `LangwijTagChip` composite
- **Call-site audit** (0 production, 4 legacy excluded):

  | # | Location | Type |
  |---|---|---|
  | 1 | `controls_list_screen.dart:26` | import (legacy) |
  | 2 | `controls_list_screen.dart:1075` | construction (legacy, `Tag(id: '1', name: 'Design', color: TagColor.color1)`) |
  | 3 | `controls_list_screen.dart:1076` | construction (legacy, `Tag(id: '2', name: 'Urgent', color: TagColor.color2)`) |
  | 4 | `controls_list_screen.dart:1077` | construction (legacy, `Tag(id: '3', name: 'Review', color: TagColor.color3)`) |
  | 5 | `controls_list_screen.dart:1078` | construction (legacy, `Tag(id: '4', name: 'No Color', color: TagColor.none)`) |

  Audit passes: case-insensitive `TagChip|tagChip` whole-repo sweep; file-import trace; test directory (`front/test/widget_test.dart`, no hits); flessel example app and other vessel dirs; all confirmed zero additional hits. **Production call sites: 0.** All 4 legacy constructions use hardcoded demo data, not real tags from the data layer.

- **Decision**: `DELETE` (flipped from pre-proposed `LANGWIJ_COMPOSITE` by the audit-before-proposal pattern, 6th fire)
- **Rationale**: The interactive tag chip variant has zero production adoption. The matrix pre-proposal of a `LangwijTagChip` composite reflected a planning-time assumption that tags are an active feature surfaced via interactive chips — the audit invalidates that. This is the first time the audit-before-proposal pattern has flipped a `LANGWIJ_COMPOSITE` proposal (previous fires flipped `EXTEND_FLESSEL` grow points). The discipline applies equally to composite proposals.
- **Dead-family sub-pattern**: Tag family (rows 32-34) appears legacy-only. `VesselTagLabel` preliminary scan shows the same legacy-only footprint — to be confirmed at row 34's own audit. Rows 33 and 34 get their own rigorous audits; do not pre-decide them here.
- **Coordination with rows 33/34**:
  - Row 33 (`VesselTagColorPreview`) lives in the **same file** as row 32. File-level deletion cannot happen until row 33 is resolved.
  - Row 34 (`VesselTagLabel`) lives in a separate file (`vessel_tag_label.dart`). Out of scope for row 32 execution.
  - Entity types `Tag` and `TagColor` in `front/lib/entities/tag/tag.dart` — NOT in scope. Domain entities may still be used by the data layer; row 32 removes only the display widget.
- **Execution plan** (Phase 3, row 32 scope only):
  1. Delete `VesselTagChip` class body (`vessel_tag_chip.dart:10-66`)
  2. Delete `VesselFonts.textVesselTagChip` getter (`vessel_fonts.dart:141`) — verify zero other callers before deletion (current grep shows only the class itself references it)
  3. Delete the 4 legacy constructions in `controls_list_screen.dart:1075-1078` (leaf demo content, trivially removable). Leave the import at line 26 until row 33 also resolves to DELETE, then both go with the full file deletion
  4. File-level deletion of `vessel_tag_chip.dart` — **deferred** to row 33 coordination
  5. Theme properties `tagBorderRadius`, `tagBorderWidth`, `tagChipBorder`, `controlAccentForeground` — **do NOT touch in row 32**. May still be consumed by rows 33/34. Phase 4 theme retirement handles these
  6. `flutter analyze` clean
- **Status**: `DONE`

### 33. VesselTagColorPreview

- **Location**: `front/lib/shared/ui/tag/vessel_tag_chip.dart` (lines 69-112; same file as row 32 `VesselTagChip`)
- **Base**: `StatelessWidget`
- **Current props**: `tagColor: TagColor` (domain enum), `isSelected: bool = false`, `onTap: VoidCallback?`
- **Purpose**: fixed 32×32 px colored square swatch for the tag color picker. Transparent state (`TagColor.none`) renders a prohibit icon inside a bordered outline; selected state swaps to a 3px accent border.
- **Flessel equivalent (pre-audit proposal)**: `LangwijTagColorPreview` composite, or alternately `ADD_TO_FLESSEL` as a generic `FlesselColorSwatch(color, isSelected, onTap, size)` primitive.
- **Call-site audit** (0 production; legacy and stale blueprints excluded):

  | # | Location | Type |
  |---|---|---|
  | 1 | `front/lib/shared/ui/tag/vessel_tag_chip.dart:69` | source definition |
  | 2 | `front/lib/pages/controls_list_screen.dart:1088-1092` | construction (legacy, excluded) |
  | 3 | `.vessel/blueprints/front/screen/form_screen.dart:175` | stale blueprint template (uses obsolete `color`/`isTransparent` signature, does not compile against current widget) |
  | 4 | `.vessel/blueprints/front/screen/list_screen.dart:203` | stale blueprint template (same obsolete signature) |

  The blueprints under `.vessel/blueprints/` are AI reference scaffolding, not runtime code. Per `.vessel/CHANGELOG.md:14` ("moved to example app"), vessel moved these widgets out of library code in an earlier refactor — the blueprints still carry the old pre-extraction signature (`color: Color, isTransparent: bool`) rather than the current srpski_card signature (`tagColor: TagColor`). They would not compile if executed. Blueprint hygiene is out of scope for this migration row. **Production call sites: 0.**

- **Decision**: `DELETE` (flipped from pre-proposed `LANGWIJ_COMPOSITE` by the audit-before-proposal pattern, 7th fire; 2nd fire against a `LANGWIJ_COMPOSITE` proposal after row 32)
- **Rationale**: Both pre-proposed options (`LangwijTagColorPreview` composite or `FlesselColorSwatch` primitive) assumed a demand signal. Audit shows zero production adoption — the single use is a legacy demo swatch grid in the tag color picker row. No composite, no new flessel primitive. Phase 3 cleanup removes the widget entirely.
- **Tag family sub-pattern — confirmed at 2/3 rows**: Rows 32 and 33 both zero-production. Row 34 `VesselTagLabel` is the last row to audit; preliminary scan suggested the same footprint but rigorous audit is still pending at its own row.
- **Coordination with row 32**:
  - Row 32 deferred file-level deletion of `vessel_tag_chip.dart` pending row 33. With row 33 also `DELETE`, full-file deletion is now unblocked.
  - `front/lib/pages/controls_list_screen.dart:26` import — orphan after both rows execute; delete together with row 32's leaf deletions (not separately).
- **Execution plan** (Phase 3, row 33 scope):
  1. Delete `VesselTagColorPreview` class body (`vessel_tag_chip.dart:69-112`)
  2. Delete the legacy construction in `controls_list_screen.dart:1088-1092` (swatch grid leaf)
  3. With rows 32 and 33 both resolved `DELETE`, unlink the entire file `front/lib/shared/ui/tag/vessel_tag_chip.dart`
  4. Delete the now-orphan import at `controls_list_screen.dart:26` (coordinated with row 32's import cleanup)
  5. Theme properties `tagBorderRadius`, `tagBorderWidth`, `tagChipBorder`, `accentColor`, `controlAccentForeground` — **do NOT touch in row 33**. `VesselTagLabel` (row 34) may still consume them. Phase 4 theme retirement handles these.
  6. `flutter analyze` clean
- **Status**: `DONE`

### 34. VesselTagLabel

- **Location**: `front/lib/shared/ui/tag/vessel_tag_label.dart` (145 lines; separate file from rows 32-33)
- **Base**: `StatelessWidget`
- **Current props**: `tag: Tag` (domain), `size: VesselTagLabelSize {icon, tiny, regular, cluster}` (default `regular`)
- **Purpose**: display-only tag label intended for reports and stats (distinct from `VesselTagChip` which is interactive)
- **Flessel equivalent (pre-audit proposal)**: `LangwijTagLabel` composite wrapping `FlesselTag`, with `LangwijTagLabelSize` enum kept as-is per E5.
- **Matrix description error — all four rendering-mode descriptions were wrong in the pre-audit proposal**:

  | Mode | Matrix pre-audit claim | Actual rendering in `vessel_tag_label.dart` |
  |---|---|---|
  | `icon` | just the color dot | 2-letter abbreviation text in bordered rect, no dot, no phosphor icon (uses `_getAbbreviation` helper) |
  | `tiny` | dot + abbreviated label | full uppercase name, no abbreviation, no icon, small padding |
  | `regular` | dot + full name | `PhosphorIconsRegular.tag` icon + full uppercase name, larger padding |
  | `cluster` | stacked/grouped rendering | single-line clipped badge using a **different theme color system** (`getBgColor/getBorderColor/getTextColor`, `badgeBorderRadius`, `badgeBorderWidth`) |

  Had this row been executed on the matrix pre-proposal without source verification, the `LangwijTagLabel` composite would have rendered dots where the widget shows text, omitted the phosphor icon in regular mode, and missed the distinct cluster color system entirely. Another fire of the matrix-description-error pattern first surfaced on rows 20/21 (required props mislabeled as nullable).

- **Call-site audit** (0 production; legacy excluded):

  Only 5 files reference `VesselTagLabel` anywhere in the repo (`files_with_matches` sweep):

  | # | Location | Type |
  |---|---|---|
  | 1 | `MIGRATION_MATRIX.md` | planning doc |
  | 2 | `MIGRATION_PLAN.md` | planning doc |
  | 3 | `.vessel/CHANGELOG.md:14` | vessel changelog ("moved to example app") |
  | 4 | `front/lib/shared/ui/tag/vessel_tag_label.dart` | source definition |
  | 5 | `front/lib/pages/controls_list_screen.dart` | construction (legacy, excluded) |

  Verification passes: `front/lib/features/` → zero matches. `.vessel/blueprints/` → zero matches (unlike row 33, no stale blueprint references here). Per-mode legacy usage in `controls_list_screen.dart`:
  - 4× `VesselTagLabelSize.icon` (lines 1001, 1005, 1009, 1013)
  - 4× `VesselTagLabelSize.tiny` (lines 1026, 1030, 1034, 1038)
  - 4× `VesselTagLabelSize.regular` (lines 1051, 1055, 1059, 1063)
  - **0× `VesselTagLabelSize.cluster`** — the `cluster` mode and the entire `_buildClusterBadge` helper (`vessel_tag_label.dart:36-38, 88-113`) are dead code even within the legacy screen.

  **Production call sites: 0.**

- **Decision**: `DELETE` (flipped from pre-proposed `LANGWIJ_COMPOSITE` by the audit-before-proposal pattern, 8th fire; 3rd fire against a `LANGWIJ_COMPOSITE` proposal after rows 32 and 33)
- **Rationale**: Pre-proposal assumed the widget is used in "reports and stats" screens; audit proves no production screen touches it. The `cluster` mode is additionally dead even inside the legacy demo. Phase 3 cleanup removes the widget entirely along with its dead code path.
- **Tag family sub-pattern — fully confirmed at 3/3 rows**: `VesselTagChip` (row 32), `VesselTagColorPreview` (row 33), and `VesselTagLabel` (row 34) all zero-production. The entire `front/lib/shared/ui/tag/` directory (`vessel_tag_chip.dart` + `vessel_tag_label.dart`) gets unlinked in Phase 3. Matches the slider/picker family pattern (rows 18-21, 4/4 confirmed).
- **E5 `VesselTagLabelSize` enum**: flipped to `DELETE` in the same edit. No production consumer of any enum variant; dies with the widget.
- **Coordination with rows 32/33**:
  - With rows 32, 33, 34 all resolved `DELETE`, the whole `front/lib/shared/ui/tag/` directory disappears in Phase 3.
  - Legacy imports in `controls_list_screen.dart` (row 32's `vessel_tag_chip.dart` import plus row 34's `vessel_tag_label.dart` import) — delete together as one cleanup at Phase 3 execution.
- **Execution plan** (Phase 3, row 34 scope):
  1. Delete entire file `front/lib/shared/ui/tag/vessel_tag_label.dart` (class body + `VesselTagLabelSize` enum + helpers, all 145 lines)
  2. Delete the 12 legacy constructions in `controls_list_screen.dart:999-1065` (4 icon + 4 tiny + 4 regular rows, plus surrounding section headers as they become orphaned)
  3. Delete the orphan import of `vessel_tag_label.dart` from `controls_list_screen.dart`
  4. Verify `VesselFonts.textTagIcon` has zero other callers before deleting its getter (earlier grep suggests it's unique to this widget; confirm at execution time — same pattern as row 32's `textVesselTagChip`)
  5. `VesselFonts.textButton` — shared, **do NOT touch**
  6. Theme properties `tagBorderRadius`, `tagBorderWidth`, `badgeBorderRadius`, `badgeBorderWidth`, and `TagColor.getBgColor/getBorderColor/getTextColor` helpers — **do NOT touch in row 34**. Phase 4 theme retirement handles these
  7. Entity types `Tag`, `TagColor` in `front/lib/entities/tag/tag.dart` — **NOT in scope** (domain layer)
  8. `PhosphorIconsRegular.tag` — shared icon lib, **NOT in scope**
  9. `flutter analyze` clean
- **Status**: `DONE`

### 35. VesselHeader

- **Location**: `front/lib/shared/ui/text/vessel_header.dart` (22 lines)
- **Base**: `StatelessWidget`
- **Current props**: `text: String` (single prop, no defaults)
- **Actual implementation**: `Text(text, style: VesselFonts.textSubtitle.copyWith(color: theme.textPrimary))`. Note: uses `textSubtitle`, **not** `contentTitle` or `pageTitle` as the matrix pre-audit rationale implied.
- **Flessel equivalent**: none. `FlesselFonts.contentTitle` (= `contentXxlAccent`) and `FlesselFonts.pageTitle` (= `contentXxxlAccent`) exist as named font aliases in `flessel_fonts.dart:94-95`, but there is no `FlesselHeader` widget class (grep-confirmed zero matches in `.vessel/packages/flessel/`).
- **Call-site audit** (0 production; legacy excluded):

  Only 4 files reference `VesselHeader` anywhere in the repo (`files_with_matches` sweep):

  | # | Location | Type |
  |---|---|---|
  | 1 | `MIGRATION_MATRIX.md` | planning doc |
  | 2 | `MIGRATION_PLAN.md` | planning doc |
  | 3 | `front/lib/shared/ui/text/vessel_header.dart` | source definition |
  | 4 | `front/lib/pages/controls_list_screen.dart` | 3 constructions (legacy, excluded) |

  Legacy uses at `controls_list_screen.dart:106, 260, 1206` — all hardcoded demo strings (`'Cards'`, `'Section Header'`, `'Legacy'`). `.vessel/blueprints/` → zero matches. `front/lib/features/`, `front/lib/screens/`, `front/lib/app/` → zero matches. **Production call sites: 0.**

- **Decision**: `DELETE` (matrix primary decision confirmed; `ADD_TO_FLESSEL` alternative fork ruled out by audit)
- **Rationale correction**: the matrix pre-audit rationale implied there were call sites to retarget with idiomatic `Text(text, style: FlesselFonts.contentTitle)` one-liners. Audit proves there are zero such call sites. The correct rationale is simpler: the widget has zero production adoption, so no retargeting is needed — just delete the file and the 3 legacy demo constructions. The `contentTitle` / `pageTitle` mapping discussion in the original matrix text is moot.
- **`ADD_TO_FLESSEL` alternative ruled out**: no demand. Adding a named `FlesselHeader(text, level)` primitive to flessel without a single production consumer violates the audit-before-proposal discipline — flessel stays lean. If future product code needs a header, `Text(text, style: FlesselFonts.contentTitle)` is the idiomatic one-liner; a named primitive can be added later if real demand emerges. This is an audit-confirmed rule-out, not a decision flip, so the audit-before-proposal fire count stays at 8.
- **Execution plan** (Phase 3, row 35 scope):
  1. Delete entire file `front/lib/shared/ui/text/vessel_header.dart` (22 lines)
  2. Delete 3 legacy constructions in `controls_list_screen.dart` at lines 106, 260, 1206 (hardcoded `'Cards'`, `'Section Header'`, `'Legacy'` demo strings)
  3. Delete the orphan import of `vessel_header.dart` from `controls_list_screen.dart`
  4. `VesselFonts.textSubtitle` — **do NOT touch in row 35**. Likely shared across other widgets; Phase 4 font retirement handles unused getters after the broader migration completes
  5. `VesselThemeData.textPrimary` — core theme property, definitely shared; **NOT in scope**
  6. `flutter analyze` clean
- **Status**: `DONE`

### 36. VesselTile

- **Location**: `front/lib/shared/ui/tile/vessel_tile.dart` (41 lines)
- **Base**: `StatelessWidget`
- **Current props**: `child: Widget` (required), `onTap: VoidCallback?`
- **Flessel equivalent**: `FlesselTile` (`.vessel/packages/flessel/lib/src/controls/tile/flessel_tile.dart`, 44 lines)
- **Flessel props**: `child: Widget` (required), `onTap: VoidCallback?` — **API twin**
- **Theme props**: both widgets use `tileBorderRadius`, `tileBackground`, `tileBorderColor`, `tileBorderWidth` — same prop names. All four exist in `FlesselThemeData` (`flessel_themes.dart:74-77`).
- **Implementation difference (non-breaking)**: `VesselTile` uses bare `Ink(...)` (requires a Material ancestor to render ripples); `FlesselTile` uses `Container(...) + Material(type: transparency) + InkWell(...)` (self-contained, ripples work regardless of ancestor context). This is a subtle isolation improvement, not a regression.
- **Call-site audit** (1 production, legacy excluded):

  5 files reference `VesselTile` (`files_with_matches` sweep):

  | # | Location | Type |
  |---|---|---|
  | 1 | `MIGRATION_MATRIX.md` | planning doc |
  | 2 | `MIGRATION_PLAN.md` | planning doc |
  | 3 | `front/lib/shared/ui/tile/vessel_tile.dart` | source definition |
  | 4 | `front/lib/features/vocab/widgets/vocab_deck_tile.dart:7, :36` | **production** |
  | 5 | `front/lib/pages/controls_list_screen.dart:148` | legacy (excluded) |

  **Production call sites: 1** (`vocab_deck_tile.dart`). Per-prop usage map:
  - `child`: Stack with 3 `Positioned` children (header row with icon + stats, title text, word list text)
  - `onTap`: conditional `item.cardCount > 0 ? onTap : null` (disables tap on empty decks)

  Both props used. No unused props. No grow points needed.

- **Theme value drift across 5 themes** (deferred to Phase 4 per established pattern from rows 29, 31):

  | Theme | Prop | Vessel value | Flessel value | Drift? |
  |---|---|---|---|---|
  | 01 | tileBackground | `alabaster` | `alabaster` | ✓ |
  | 01 | tileBorderColor | `platinum` | `platinum` | ✓ |
  | 01 | tileBorderWidth | `2.0` | `1.0` | **DRIFT** |
  | 01 | tileBorderRadius | `8.0` | `8.0` | ✓ |
  | 02 | tileBackground | `mintCream` | `dustyGrape` | **DRIFT** |
  | 02 | tileBorderColor | `darkNavy` | `dustyGrape` | **DRIFT** |
  | 02 | tileBorderWidth | `2.0` | `1.0` | **DRIFT** |
  | 02 | tileBorderRadius | `8.0` | `8.0` | ✓ |
  | 03 | tileBackground | `pureWhite` | `pureWhite` | ✓ |
  | 03 | tileBorderColor | `gunMetal` | `platinum` | **DRIFT** |
  | 03 | tileBorderWidth | `2.0` | `1.0` | **DRIFT** |
  | 03 | tileBorderRadius | `4.0` | `8.0` | **DRIFT** |
  | 04 | tileBackground | `dustgray` | `mintCream` | **DRIFT** |
  | 04 | tileBorderColor | `silverdust` | `darkNavyA12` | **DRIFT** |
  | 04 | tileBorderWidth | `2.0` | `1.0` | **DRIFT** |
  | 04 | tileBorderRadius | `8.0` | `8.0` | ✓ |
  | 05 | tileBackground | `dustyGrape` | `dustgray` | **DRIFT** |
  | 05 | tileBorderColor | `dustyGrape` | `silverdust` | **DRIFT** |
  | 05 | tileBorderWidth | `2.0` | `1.0` | **DRIFT** |
  | 05 | tileBorderRadius | `8.0` | `8.0` | ✓ |

  **Universal drift: `tileBorderWidth` is `2.0` in all vessel themes and `1.0` in all flessel themes.** After the switch, the production `VocabDeckTile` will render with thinner 1px borders.

- **Theme-ID remapping concern (flagged for Phase 4, NOT simple value drift)**: themes 02, 04, 05 show palette-entry patterns suggesting theme IDs got shuffled between vessel and flessel:
  - Vessel theme_02 (`mintCream`/`darkNavy`) ≈ Flessel theme_04 (`mintCream`/`darkNavyA12`)
  - Vessel theme_04 (`dustgray`/`silverdust`) = Flessel theme_05 (`dustgray`/`silverdust`) — exact palette-entry match
  - Vessel theme_05 (`dustyGrape`/`dustyGrape`) = Flessel theme_02 (`dustyGrape`/`dustyGrape`) — exact palette-entry match

  If confirmed, users with a saved `theme_02` preference would see flessel's theme_02 after migration — which has vessel's theme_05 aesthetic. Phase 4 theme retirement will need to audit theme IDENTITY, not just values, for themes 02/04/05. **Not blocking row 36** (the widget swap is code-level and theme-agnostic) but important context Phase 4 cannot skip. Not yet verified by reading palette hex values — this is a suspicion based on pattern-matching palette entry names across themes.

- **Decision**: `SWITCH` (matrix primary decision confirmed)
- **Rationale**: API twin, theme prop twins, single production caller with both props in use, implementation slightly more robust in flessel. Standard SWITCH. Theme value drift and theme-ID remapping are orthogonal concerns handled in Phase 4.
- **Row 46 coordination** (`VocabDeckTile` → `LangwijVocabDeckTile` composite): row 36 and row 46 can execute in either order. Row 36 is a narrow type-name swap inside `vocab_deck_tile.dart`; row 46 later rewrites the class as a composite. Either ordering is fine — no blocking dependency.
- **Execution plan** (Phase 3, row 36 scope):
  1. In `front/lib/features/vocab/widgets/vocab_deck_tile.dart`:
     - Line 7: replace `import '../../../shared/ui/tile/vessel_tile.dart';` with flessel import (or remove if `FlesselTile` comes from the main flessel barrel already imported elsewhere in the file)
     - Line 36: `VesselTile(` → `FlesselTile(`
  2. In `front/lib/pages/controls_list_screen.dart:148`: `VesselTile(` → `FlesselTile(` (transitional; the legacy file is slated for deletion anyway)
  3. Delete entire file `front/lib/shared/ui/tile/vessel_tile.dart` (41 lines)
  4. Theme value drift — **do NOT touch in row 36**. Phase 4 reconciliation
  5. Theme-ID remapping concern — **do NOT touch in row 36**. Flag at Phase 4 entry
  6. Theme props `tileBorderRadius`, `tileBackground`, `tileBorderColor`, `tileBorderWidth` stay in `VesselThemeData` during the transition (other widgets may still use them; Phase 4 retirement handles)
  7. `flutter analyze` clean
- **Status**: `DONE`

### 37. VesselAnswerTile

- **Location**: `front/lib/shared/ui/answer_tile/vessel_answer_tile.dart`
- **Base**: `StatelessWidget`
- **Current props**: `label: String`, `onTap: VoidCallback?`
- **Purpose**: tappable tile for quiz answer options
- **Build method (verified from source)**: `Material(roundAnswerTileBackground) + InkWell(NoSplash.splashFactory, highlightColor: Colors.transparent) + Container(border: roundAnswerTileBorderColor/Width, radius: tileBorderRadius) + Center + Padding(VesselLayout.gapS) + Text(label, VesselFonts.textRoundAnswer color: textPrimary, TextAlign.center)`. Ripple is explicitly disabled.
- **Font**: `VesselFonts.textRoundAnswer` = `_bodyXLAccented` = **20px Montserrat Bold** → exact match `FlesselFonts.contentXxlAccent` (20px bold)
- **Flessel equivalent**: none directly (`FlesselTile` is a generic tappable container without centered text or bold 20px style)
- **Call-site audit** (legacy + blueprints excluded):

  | File | Count | Props passed |
  |---|---|---|
  | `front/lib/pages/round_screen.dart` | 2 (lines 531, 554) | `label`, `onTap` — both shape-identical, inside `.map()` chains for Serbian-shown and English-shown branches |
  | `front/lib/pages/controls_list_screen.dart` | 1 | — legacy, excluded |
  | `.vessel/blueprints/` | 0 | — |

  → **2 production call sites, both pass only `label + onTap`**
- **Matrix-description errors caught during audit**:
  - Original sketch mapped font to `FlesselFonts.contentM` (14px regular); correct mapping is `FlesselFonts.contentXxlAccent` (20px bold).
  - Original rationale claimed "quiz answer feedback is likely to evolve" as justification — **incorrect**. Correct/wrong feedback is already implemented in `round_screen.dart:765-784` as a separate floating animated label using `roundAnswerTileCorrectColor` / `WrongColor`, NOT on the tile. The tile has no state and no planned state.
  - Sketch omitted `NoSplash` ripple-disabled behavior and the theme-01-specific bg distinction.
- **Theme-value comparison** (`tile*` vs `roundAnswerTile*`):

  | Theme | `tileBackground` | `roundAnswerTileBackground` | `tileBorderColor` | `roundAnswerTileBorderColor` |
  |---|---|---|---|---|
  | 01 | alabaster | **platinum** (different) | platinum | platinum |
  | 02 | mintCream | mintCream | darkNavy | darkNavy |
  | 03 | pureWhite | pureWhite | gunMetal | gunMetal |
  | 04 | dustgray | dustgray | silverdust | silverdust |
  | 05 | dustyGrape | dustyGrape | dustyGrape | dustyGrape |

  Border widths: all answer tiles `2.0` — share the universal `tileBorderWidth` 2.0→1.0 drift flagged at row 36. Border radius: already shares `tileBorderRadius` in source.
- **Decision**: `LANGWIJ_COMPOSITE`
- **Target**: `front/lib/shared/ui/langwij_answer_tile.dart`
- **Rationale (corrected)**:
  1. Two production call sites pass `label + onTap` with identical styling → DRY justifies a composite today, independent of any future evolution.
  2. "Quiz answer option tile" is a product-specific concept, not a flessel primitive. Belongs in the langwij layer, consistent with row 38's `LangwijMainNavBar` pattern.
  3. Matrix's "likely to evolve" argument is rejected — correct/wrong feedback is already rendered as a separate overlay in `round_screen.dart`, not on the tile. The tile's API is stable at `label + onTap`.
- **Alternative considered and rejected**: `DELETE` — would inline `FlesselTile + Padding + Center + Text(contentXxlAccent)` at 2 adjacent `.map()` call sites (~18 lines of duplicated styling), lose the "quiz answer tile" semantic name at call sites, and does not simplify Phase 3 theme cleanup.
- **Implementation sketch (corrected)**:

  ```dart
  class LangwijAnswerTile extends StatelessWidget {
    const LangwijAnswerTile({super.key, required this.label, this.onTap});
    final String label;
    final VoidCallback? onTap;

    @override
    Widget build(BuildContext context) {
      return FlesselTile(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(FlesselLayout.gapS),
          child: Center(
            child: Text(
              label,
              style: FlesselFonts.contentXxlAccent,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }
  ```
- **Cosmetic changes accepted** (approved during proposal):
  1. **Ripple added on tap** — flessel's default `InkWell` ripple replaces vessel's `NoSplash`. Correct/wrong feedback overlay renders immediately on selection, so ripple is barely noticeable. Alternative would be a `disableRipple` prop on flessel tile (over-engineered for 1 caller) or raw Material+InkWell (violates consumer rules).
  2. **Theme 01 bg change**: answer tiles become `alabaster` (from `platinum`) — both near-white. Other themes unchanged.
- **Dependencies**: depends on row 36 (`VesselTile` SWITCH) execution being done first, since `LangwijAnswerTile` wraps `FlesselTile`.
- **Phase 4 theme cleanup follow-ups**:
  - Delete `roundAnswerTileBackground`, `roundAnswerTileBorderColor`, `roundAnswerTileBorderWidth` (absorbed into generic `tile*`, subject to the universal `tileBorderWidth` 2.0→1.0 drift from row 36).
  - **Keep** `roundAnswerTileCorrectColor` / `roundAnswerTileWrongColor` — used by `round_screen.dart` floating feedback overlay, NOT the tile. Migrate these to an app-level theme extension during Phase 4 theme retirement.
  - Delete `VesselFonts.textRoundAnswer` (replaced inline by `FlesselFonts.contentXxlAccent`).
- **Status**: `DONE`

### 38. VesselNavBar

- **Location**: `front/lib/shared/ui/bottom_navbar/vessel_navbar.dart` (100 lines)
- **Base**: `StatelessWidget`
- **Current props**: `onSettingsDisabledTap: VoidCallback?`
- **Build method (verified from source)**: `Container(border: top only) + SafeArea(top:false) + SizedBox(VesselLayout.navbarHeight=36) + Row(spaceAround) + 4 hardcoded VesselNavBarIcon`. 4 tabs: Language (`globe`/`globe.fill`), Vocabulary (`books`/`books.fill`), Tools (`puzzlePiece`/`puzzlePiece.fill`), Settings (`gearSix`/`gearSix.fill`). Active detection reads `GoRouterState.of(context).uri.path`. Tools tab matches three routes (`/tools`, `/conjugations`, `/agreement`). `onSettingsDisabledTap` is wired ONLY when current tab is Settings (the disabled icon is the trigger surface).
- **Direct call-site audit** (legacy + blueprints excluded):

  | File | Count | Notes |
  |---|---|---|
  | `front/lib/shared/ui/screen_layout/vessel_scaffold.dart` | 1 (line 45) | Internal — wired via `bottomNavigationBar: showBottomNav ? VesselNavBar(onSettingsDisabledTap: ...) : null` |
  | Direct screen usage | 0 | — |
  | `.vessel/CHANGELOG.md` | 1 | Submodule changelog, excluded |

- **Effective production usage** (via row 30's `VesselScaffold` audit — 7 scaffolds set `showBottomNav: true`):
  1. `agreement_group_list_screen.dart:96`
  2. `vocab_deck_list_screen.dart:101`
  3. `vocab_deck_list_screen.dart:124`
  4. `tools_screen.dart:29`
  5. `settings_screen.dart:177` — **only site that wires `onSettingsDisabledTap`**
  6. `language_screen.dart:45`
  7. `group_list_screen.dart:326`

- **`onSettingsDisabledTap` semantic** (`settings_screen.dart:41-47`): hidden dev-access easter egg — tap the disabled Settings nav icon `AppConstants.devAccessTapCount = 10` times to open the dev password sheet (`_showDevPasswordSheet`). On password match: sets `devSectionEnabledProvider` (riverpod) + persists via `saveDevSectionEnabled`. Multiple consumers watch the riverpod provider (e.g., `dictionary_provider.dart:86` to gate dev-only dictionary entries). Method name `_handleTitleTap` is misleading — confirmed at row 30.

- **Flessel API verification** (`.vessel/packages/flessel/lib/src/controls/navbar/`):
  - `FlesselNavBar({required List<FlesselNavBarItem> items, required int currentIndex, FlesselSize size = FlesselSize.l})`
  - `FlesselNavBarItem({required IconData icon, IconData? activeIcon, required String tooltip, VoidCallback? onTap, VoidCallback? onDisabledTap})`
  - Renders identical structure (`Container + SafeArea + SizedBox + Row`), uses identical theme keys (`navbarBackground`, `navbarBorderColor`, `navbarBorderWidth`), iterates items using `i == currentIndex` for the disabled-active state.

- **Structural differences vessel ↔ flessel**:

  | Aspect | Vessel | Flessel | Notes |
  |---|---|---|---|
  | Height | hardcoded `36.0` | `navbarHeight(size)` → 36/40/46/56 | composite passes `FlesselSize.xs` to preserve 36px |
  | Disabled icon color | `navbarDisabledIconColor` (separate prop) | reuses `navbarIconColor` for both states | only theme 01 actually used a distinct value |
  | Per-tab data | hardcoded inline | `items: List<FlesselNavBarItem>` | composite job |
  | Active detection | hardcoded route checks | `currentIndex: int` | composite computes from router |
  | Shadow | none | optional `navbarShadow: List<BoxShadow>?` | all 5 flessel themes set `null`, no functional difference |

- **Theme value drift (full 5-theme navbar comparison)**:

  | Theme | `navbarIconColor` (vessel→flessel) | `navbarDisabledIconColor` (vessel) | `navbarBorderWidth` (vessel→flessel) |
  |---|---|---|---|
  | 01 | pureBlackA67 → gunMetal | **gunMetal (different from enabled)** | **1.5 → 2.0** |
  | 02 | darkNavy → lightForeground (theme-ID remap) | darkNavy (same as enabled) | 2.0 → 2.0 |
  | 03 | gunMetal → gunMetal | gunMetal | 2.0 → 2.0 |
  | 04 | deepWalnut → darkNavy (theme-ID remap) | deepWalnut | 2.0 → 2.0 |
  | 05 | deepWalnut → deepWalnut | deepWalnut | 2.0 → 2.0 |

  **Theme-ID remapping pattern continues** (started at row 36): vessel `theme_02` (mintCream/darkNavy) ≈ flessel `theme_04`; vessel `theme_04` (porcleain/deepWalnut) ≈ flessel `theme_05`; vessel `theme_05` (spaceIndigo/black) ≈ flessel `theme_02` (with icon-color difference suggesting vessel `theme_05`'s `deepWalnut` icon on `spaceIndigo` bg may be a pre-existing vessel bug). Phase 4 must explicitly remap based on accumulated palette evidence (row 36 tile + row 38 navbar) rather than assuming `theme_NN` ↔ `theme_NN`.

- **Matrix description verification**: all original matrix claims confirmed accurate. No matrix-description errors caught.

- **Decision**: `EXTEND_FLESSEL` (3 grow points G1–G3, Option 1: lean counter mechanic) **+** `LANGWIJ_COMPOSITE`
- **Target composite**: `front/lib/shared/ui/langwij_main_nav_bar.dart`

- **Grow points (Option 1 — lean: counter mechanic only, no flessel state holder)**:
  - **G1** — Add `FlesselNavBarItem.secretTapCount: int?` (null = disabled). New optional field on the item data class.
  - **G2** — Add `FlesselNavBarItem.onSecretTapsReached: VoidCallback?`. Fires once when threshold is reached; counter resets after firing. Per-item, scoped to a single navbar instance.
  - **G3** — Convert `FlesselNavBar` from `StatelessWidget` to `StatefulWidget`. State holds `Map<int, int> _secretTapCounts` keyed by item index. When an item's `onDisabledTap` fires AND `secretTapCount != null`, increment that item's counter; on reach → fire `onSecretTapsReached?.call()`, reset counter to 0. The existing `onDisabledTap` callback is **also** still called as today (the secret-tap mechanic is additive, not a replacement). State persists for the lifetime of the navbar instance — naturally resets when user navigates away.

- **Rationale (Option 1 chosen over Option 2 — lean over rich)**:
  1. The thing that gets re-implemented per app is the **counter mechanic**; state holders and persistence vary across apps anyway. Flessel centralizing the counter saves the most boilerplate.
  2. Counter + callback is pure UI mechanics with no domain knowledge — zero rule-stretching ("dev mode" stays an app concept, never enters flessel).
  3. Zero refactor cost in srpski_card: existing `devSectionEnabledProvider` riverpod state stays untouched, `dictionary_provider.dart:86` consumer untouched, persistence (`saveDevSectionEnabled`) untouched. Only `_handleTitleTap` moves out of settings_screen state into the navbar item config.
  4. Option 2 (flessel-owned `FlesselDevModeScope` InheritedWidget + `ValueListenable<bool>` state holder) remains **additive** — can be built later if a future app's pattern would actually benefit from a shared state-holder rather than its own preferred mechanism. No API conflict.

- **Composite implementation sketch**:
  ```dart
  // front/lib/shared/ui/langwij_main_nav_bar.dart
  class LangwijMainNavBar extends StatelessWidget {
    const LangwijMainNavBar({super.key, this.onDevAccessTapsReached});
    final VoidCallback? onDevAccessTapsReached;

    int _currentIndexFor(String path) {
      if (path == AppRoutes.language) return 0;
      if (path == AppRoutes.home) return 1;
      if (path == AppRoutes.tools ||
          path == AppRoutes.conjugations ||
          path == AppRoutes.agreement) return 2;
      if (path == AppRoutes.settings) return 3;
      return -1;
    }

    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;
      final currentPath = GoRouterState.of(context).uri.path;
      return FlesselNavBar(
        size: FlesselSize.xs,
        currentIndex: _currentIndexFor(currentPath),
        items: [
          FlesselNavBarItem(
            icon: PhosphorIconsRegular.globe,
            activeIcon: PhosphorIconsFill.globe,
            tooltip: l10n.navLanguage,
            onTap: () => context.go(AppRoutes.language),
          ),
          FlesselNavBarItem(
            icon: PhosphorIconsRegular.books,
            activeIcon: PhosphorIconsFill.books,
            tooltip: l10n.navVocabulary,
            onTap: () => context.go(AppRoutes.home),
          ),
          FlesselNavBarItem(
            icon: PhosphorIconsRegular.puzzlePiece,
            activeIcon: PhosphorIconsFill.puzzlePiece,
            tooltip: l10n.navTools,
            onTap: () => context.go(AppRoutes.tools),
          ),
          FlesselNavBarItem(
            icon: PhosphorIconsRegular.gearSix,
            activeIcon: PhosphorIconsFill.gearSix,
            tooltip: l10n.navSettings,
            onTap: () => context.go(AppRoutes.settings),
            secretTapCount: AppConstants.devAccessTapCount,
            onSecretTapsReached: onDevAccessTapsReached,
          ),
        ],
      );
    }
  }
  ```

- **Settings screen wiring (Phase 3)**:
  ```dart
  // settings_screen.dart, in build():
  return FlesselScaffold(
    title: l10n.settingsTitle,
    bottomNavBar: LangwijMainNavBar(
      onDevAccessTapsReached: _showDevPasswordSheet,
    ),
    child: ...,
  );
  ```
  - **Delete** `_settingsTapCount` field (counter now lives in flessel navbar state)
  - **Delete** `_handleTitleTap` method
  - **Keep** `_showDevPasswordSheet` unchanged
  - **Keep** `devSectionEnabledProvider` riverpod state and `saveDevSectionEnabled` persistence unchanged
  - Other 6 scaffold sites use `bottomNavBar: const LangwijMainNavBar()` (no callback)

- **Cosmetic changes accepted** (approved during proposal):
  1. **Theme 01 disabled-icon color collapses**: vessel theme 01 distinguishes `pureBlackA67` (enabled) from `gunMetal` (disabled-current tab). Flessel uses one color for both. Post-migration, theme 01's active tab will look identical to other tabs in icon color; the filled-icon variant (`activeIcon`) remains the only visual distinction. Other 4 themes already used identical colors.
  2. **Theme 01 border width drift**: vessel `1.5` → flessel `2.0`. Slightly thicker top border in theme 01 only.
  3. **Navbar height preserved at 36px** via `FlesselSize.xs` — smallest flessel size, matches current visual exactly.

- **Dependencies / ordering**:
  - Bundles with **row 30** (VesselScaffold EXTEND_FLESSEL) Phase 3 execution. The 7 scaffold migrations from row 30 use `bottomNavBar: const LangwijMainNavBar()` for the 6 non-settings sites and `LangwijMainNavBar(onDevAccessTapsReached: _showDevPasswordSheet)` for settings_screen.
  - Bundles with **row 39** (VesselNavBarIcon). Pre-audit shows the only file referencing `VesselNavBarIcon` is `vessel_navbar.dart` itself; once that file is deleted in this row, row 39 → `DELETE` is essentially predetermined. Row 39 still gets its own audit.
  - Grow points G1-G3 must land in flessel **before** the composite is wired, since the composite uses the new `secretTapCount` / `onSecretTapsReached` fields.

- **Phase 4 theme cleanup follow-ups**:
  - **Delete `navbarDisabledIconColor`** from vessel theme — collapses into `navbarIconColor` (cosmetic change in theme 01 only).
  - Theme 01 border width drift `1.5 → 2.0` (other themes already 2.0).
  - **Theme-ID remapping investigation** continues to accumulate evidence (now 3 layers: row 36 tile bg/border, row 38 navbar bg/border + icon palette). Phase 4 must explicitly map vessel theme IDs → flessel theme IDs based on accumulated palette evidence.

- **Example app**: Update navbar demo section in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart` — add a `FlesselNavBarItem` with `secretTapCount: 5` + `onSecretTapsReached` callback that shows a snackbar. Demonstrates the hidden-counter mechanic for documentation purposes.

- **Status**: `DONE`

### 39. VesselNavBarIcon

- **Location**: `front/lib/shared/ui/bottom_navbar/vessel_navbar_icon.dart` (75 lines)
- **Base**: `StatelessWidget`
- **Current props**: `icon: IconData`, `activeIcon: IconData?`, `tooltip: String`, `isEnabled: bool`, `enabledColor: Color`, `disabledColor: Color`, `onPressed: VoidCallback?`, `onDisabledTap: VoidCallback?`
- **Build method (verified during row 38 audit)**: 3 modes — enabled+onPressed (`Material+InkWell` with both splash/highlight transparent), disabled+onDisabledTap (`GestureDetector` with `HitTestBehavior.opaque`), disabled+no callback (`AbsorbPointer + Tooltip`). All variants share `Padding(VesselLayout.navbarIconPadding) + Icon(size: 28)` core.
- **Call-site audit** (legacy + blueprints excluded):

  | File | Count | Notes |
  |---|---|---|
  | `front/lib/shared/ui/bottom_navbar/vessel_navbar_icon.dart` | 1 | Definition file — gets deleted |
  | `front/lib/shared/ui/bottom_navbar/vessel_navbar.dart` | 4 | Internal — one per hardcoded tab inside `VesselNavBar`. Parent file gets deleted as part of row 38's Phase 3. |
  | Direct screen usage (production) | **0** | — |
  | `front/lib/pages/controls_list_screen.dart` (legacy demo) | **0** | Not even the legacy screen imports it |
  | `.vessel/blueprints/` | 0 | — |
  | `.vessel/CHANGELOG.md` | 0 | — |

  → **Zero production callers, zero legacy callers. The widget exists only as an internal helper for `VesselNavBar`.**

- **Flessel API check**: `FlesselNavBarIcon` IS exported from `flessel.dart:51` and used directly in `flessel/example/lib/main.dart:115`. A SWITCH path exists in principle. **However, no srpski_card code would use it** — `LangwijMainNavBar` (row 38's composite) wraps `FlesselNavBar` directly, which manages its own `FlesselNavBarIcon` instances internally. Nothing to migrate.
- **Matrix description verification**: matrix's "DELETE if all call sites are inside VesselNavBar" alternative is **fully satisfied** by audit. The SWITCH conjecture is moot — zero direct call sites means zero migration target.
- **Decision**: `DELETE` (matrix alternative path wins)
- **Target**: none. File `vessel_navbar_icon.dart` gets unlinked alongside `vessel_navbar.dart` in row 38's Phase 3 execution.
- **Phase 3 execution dependency**:
  - Bundles with **row 38** (`VesselNavBar` → `LangwijMainNavBar` + flessel grow points G1-G3). When row 38 deletes `vessel_navbar.dart`, `vessel_navbar_icon.dart` becomes orphaned and is deleted in the same commit.
  - The full directory `front/lib/shared/ui/bottom_navbar/` becomes empty after both files are unlinked → directory itself can be removed.
- **Phase 4 cleanup follow-up**: `VesselLayout.navbarIconPadding` is used only by `vessel_navbar_icon.dart` per this row's scope. Becomes orphaned when the file is deleted; should be removed during Phase 4 vessel-layout retirement. **Verify orphaning at Phase 4 time** — per-row scope did not include grepping all `VesselLayout.*` constants.
- **Status**: `DONE`

### 40. showVesselBottomSheet

- **Location**: `front/lib/shared/ui/bottom_sheet/vessel_bottom_sheet.dart`
- **Type**: top-level function (first non-widget row in the migration)
- **Current params**: `context`, `builder`, `padding`, `isScrollControlled`, `useDraggableSheet`, `draggableInitialSize`, `draggableMinSize`, `draggableMaxSize`, `isDismissible`
- **Flessel equivalent**: `showFlesselBottomSheet<T>` at `.vessel/packages/flessel/lib/src/controls/sheet/flessel_bottom_sheet.dart`
- **Flessel params**: `context`, `builder`, `isScrollControlled`, `useDraggableSheet`, `draggableInitialSize`, `draggableMinSize`, `draggableMaxSize`
- **Gap (pre-audit)**: flessel lacks `padding: EdgeInsetsGeometry?` and `isDismissible: bool`
- **Call-site audit** (full production sweep):

  | # | File:line | `padding` | `isDismissible` | `useDraggableSheet` | Notes |
  |---|---|---|---|---|---|
  | 1 | `front/lib/pages/settings_screen.dart:51` | — | **`false`** | — | dev password gate (the row 38 composite's consumer) |
  | 2 | `front/lib/pages/round_screen.dart:398` | — | — | — | exit-round confirm |
  | 3 | `front/lib/pages/language_screen.dart:202` | — | — | — | language reset confirm |
  | 4 | `front/lib/shared/ui/bottom_sheet/quiz_bottom_sheets.dart:43` | — | — | — | mode selection, builder wraps `ConstrainedBox → Column` |
  | 5 | `front/lib/shared/ui/bottom_sheet/quiz_bottom_sheets.dart:297` | — | — | — | question count, builder wraps `ConstrainedBox → Column` |
  | 6 | `front/lib/shared/ui/bottom_sheet/bug_report_sheet.dart:21` | — | — | — | wraps `_BugReportSheetContent` (row 41 composite input) |
  | — | `front/lib/pages/controls_list_screen.dart:1156` | — | — | — | **EXCLUDED** — legacy demo |
  | — | `front/lib/shared/ui/inputs/vessel_hour_picker.dart:28` | — | — | — | **EXCLUDED** — `VesselHourPicker` has zero production callers per row 21; this call is transitively legacy |

  **Per-param production usage:**
  - `padding: EdgeInsetsGeometry?` → **0 / 6** → DROP (9th audit-pattern fire)
  - `isDismissible: bool = true` → **1 / 6** (only `settings_screen.dart:51` passes `false`) → KEEP as grow point G1
  - `useDraggableSheet` (+ 3 draggable sizing params) → **0 / 6** (pre-existing flessel carryover, not part of this proposal; out of scope)

- **Matrix "Padding override risk" resolution**: matrix flagged `padding` as an ad-hoc override risk per the consumer rule *"NEVER pass ad-hoc overrides (iconSize, padding, margin, etc.) to bypass a control's built-in sizing"*. Audit validates the concern empirically: **0 / 6** production callers override padding. Proposal dropped.

- **Architectural finding — auto-wrap vs caller-responsibility split**:
  - **Vessel**: auto-wraps builder output inside the function: `SafeArea(top: false) → Padding(EdgeInsets.all(theme.bottomSheetPadding)) → builder(ctx)`. Applies in BOTH draggable and non-draggable branches.
  - **Flessel (current)**: only `SafeArea(top: false)`; no `Padding` wrap in either branch. Doc comment says *"Content should use `theme.bottomSheetPadding` for consistent padding"* — pushes responsibility to the caller.
  - **All 6 production vessel callers rely on auto-wrap**; none add a manual `Padding` anywhere in their builder.

- **Decision**: `EXTEND_FLESSEL` + **Option A** (align flessel internal behavior to vessel)
  - **Grow point G1**: add `isDismissible: bool = true` to `showFlesselBottomSheet<T>` (pass-through to `showModalBottomSheet`).
  - **Internal behavior change**: wrap `builder(ctx)` with `Padding(EdgeInsets.all(theme.bottomSheetPadding))` inside `showFlesselBottomSheet`'s body in BOTH draggable and non-draggable branches, matching vessel.
  - **Doc comment update**: *"Content is auto-padded by `theme.bottomSheetPadding`. Do not add an outer `Padding` around the builder's return value."*
  - **Dropped proposal**: `padding: EdgeInsetsGeometry?` override — 0/6 production demand. 9th audit-pattern fire. If a future app ever needs zero or custom padding, add an explicit `useDefaultPadding: bool = true` escape hatch then — audit-driven additions only.

- **Rationale for Option A over Option B (manual `Padding` wraps at 6 sites)**:
  1. Zero production callers override the default → the default IS the effective contract; auto-application hides nothing.
  2. Flessel is fresh-installed with zero other consumers → internal behavior change is safe; no external breakage.
  3. Vessel's auto-wrap pattern has proven across 6 diverse sheets (text confirms, dev password, bug report composite, quiz mode grid, quiz count grid, lang reset).
  4. Phase 3 call-site diff scope reduces to a pure `showVesselBottomSheet → showFlesselBottomSheet` symbol rename; 6 builders stay byte-identical for padding.
  5. Meatbag explicitly approved Option A.

- **Flessel API after row 40**:
  ```dart
  Future<T?> showFlesselBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext context) builder,
    bool isScrollControlled = true,
    bool isDismissible = true,          // G1 (new)
    bool useDraggableSheet = false,
    double draggableInitialSize = 0.5,
    double draggableMinSize = 0.3,
    double draggableMaxSize = 0.9,
  });
  ```
  Internal body (both branches):
  ```dart
  SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.all(theme.bottomSheetPadding),
      child: builder(ctx),
    ),
  )
  ```

- **Matrix description verification**: matrix correctly identified both gaps (`padding` + `isDismissible`) and correctly flagged the padding override risk as a discussion point. No matrix-description errors to correct on this row.

- **Phase 3 execution dependency**:
  - Bundles with **row 41** (`showBugReportSheet` → `LANGWIJ_COMPOSITE`). Row 41's composite will call `showFlesselBottomSheet` after row 40 lands.
  - Shares `settings_screen.dart` with **row 38** (navbar dev-access composite) — sequential edits within Phase 3, no conflict.
  - Pure symbol rename for the 6 production call sites: `showVesselBottomSheet` → `showFlesselBottomSheet`, plus `VesselThemes.of(...)` → `FlesselThemes.of(...)` and `VesselFonts.*` → `FlesselFonts.*` inside each builder body. `settings_screen.dart:51` keeps `isDismissible: false`.

- **Example app**: Update bottom sheet demo section in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart` — add `isDismissible: false` demo variant. Verify auto-padding wrap renders correctly in existing sheet demos (padding change is internal, no API demo needed — visual verification only).

- **Phase 4 cleanup debt flagged**: `bottomSheetPadding` is duplicated — defined both as `FlesselLayout.bottomSheetPadding = 16.0` (static const, `flessel_layout.dart:186`) AND as a per-theme `FlesselThemeData.bottomSheetPadding` field (all 5 themes set to 16.0, identical to the layout constant). Phase 4 should collapse one side. Lean: delete the per-theme field and use `FlesselLayout.bottomSheetPadding` directly (matches the pattern used by other layout constants). Not acted on in row 40 — out of scope.

- **Status**: `DONE`

### 41. showBugReportSheet

- **Location**: `front/lib/shared/ui/bottom_sheet/bug_report_sheet.dart`
- **Type**: top-level function + private `_BugReportSheetContent` StatefulWidget (117 lines total)
- **Source surface**:
  - `showBugReportSheet(BuildContext context, {required CardModel card}) → Future<void>` — thin 4-line wrapper that calls `showVesselBottomSheet` with `builder: (ctx) => _BugReportSheetContent(card: card)`.
  - `_BugReportSheetContent` — StatefulWidget holding `BugReportType _selectedType = badTranslation` and a `TextEditingController _messageController` (disposed in dispose()).
  - Build method: `Column(stretch)` with title / card-context text / dropdown / multi-line textarea / Row(cancel + submit).
  - **Submit is a no-op + pop** (explicit code comment: *"No-op for now. Persistence comes later."*). Cancel also pops. Both buttons just close the sheet.

- **Call-site audit** (full production sweep):

  | # | File:line | Props passed | Notes |
  |---|---|---|---|
  | 1 | `front/lib/pages/result_screen.dart:256` | `card: card` | onPressed of the bug-report `VesselDangerButton` sitting next to the card result |

  **Production callers: 1 / 1.** Zero legacy (no `controls_list_screen.dart` import). Zero blueprint references. Clean single-caller migration.

- **Domain dependencies** (allowed at the langwij layer, forbidden inside flessel):
  - `CardModel` (from `front/lib/entities/card/card_model.dart`) — required param, used for `targetAnswer` + `nativeText` string format.
  - `BugReportType` enum (from `./bug_report_type.dart`: `enum BugReportType { badTranslation, uiBug }`) — dropdown generic type + initial state default. **Stays in its current file; not renamed; not moved.**
  - `AppLocalizations` (l10n) — 6 keys, all confirmed to exist in `app_en.arb`:

    | Key | English value |
    |---|---|
    | `bugReport_title` | "Report Issue" |
    | `bugReport_cardContext` | "{targetAnswer} → {nativeAnswer}" |
    | `bugReport_typeBadTranslation` | "Bad translation" |
    | `bugReport_typeUiBug` | "UI bug" |
    | `bugReport_messagePlaceholder` | "Describe the issue..." |
    | `bugReport_submit` | "Submit" |
    | `cancel` | "Cancel" |

  No riverpod. No service layer. No provider state beyond the local form state.

- **Decision**: `LANGWIJ_COMPOSITE`
  - **Target file**: `front/lib/shared/ui/bottom_sheet/langwij_bug_report_sheet.dart` (keeps the existing `bottom_sheet/` subdirectory convention)
  - **New public function**: `Future<void> showLangwijBugReportSheet(BuildContext context, {required CardModel card})`
  - **New private widget**: `_LangwijBugReportForm extends StatefulWidget` — replaces `_BugReportSheetContent` (row 42 absorbed here)

- **Meatbag-directed decisions** (locked this row):
  1. **Font** — use closest existing flessel primitives; no Iosevka preservation, no flessel font additions. Meatbag quote: *"fuck current design of reports, just use closest flessels fonts"*.
     - `VesselFonts.textSheetTitle` (Iosevka 20 w700) → **`FlesselFonts.contentTitle`** (Montserrat 20 bold, alias of `contentXxlAccent`). Same size, same weight, different family. Visible font-family change accepted.
     - `VesselFonts.textBodyAccent` (Montserrat 14 bold) → **`FlesselFonts.contentBodyAccent`** (clean rename).
  2. **TextInputAction** — drop the explicit `textInputAction: TextInputAction.newline` entirely. Meatbag quote: *"input -- wat? FUck the param"*. Flutter's `TextField` defaults `textInputAction` to `newline` when `keyboardType: TextInputType.multiline` OR `maxLines != 1`, so behavior is preserved. Row 41 no longer depends on row 13's G-INPUT-3 grow point.
  3. **No grow points for row 41**. Meatbag quote: *"Flessel and just flessel, that screen doesnt even fukcing work properly. No work here besides full swithcing to fucking flessel"*. Row 41 is pure glue — composes what flessel already has today. No flessel additions in this row.

- **Flessel primitive dependencies** (all in current flessel — no row-13 or row-14 wait):
  - `showFlesselBottomSheet<void>` — row 40 (already APPROVED; adds `isDismissible` default + auto-wraps builder content in `Padding(EdgeInsets.all(theme.bottomSheetPadding))`). Row 41 doesn't override either.
  - `FlesselDropdown<BugReportType>` — current flessel already has `expanded: bool = false` (row 41 passes `expanded: true` to match vessel's fill-parent behavior per row 14's finding). Row 41 doesn't pass `label` or `hint`, so row 14's G-DROP-1 rendering fix is not a prerequisite.
  - `FlesselDropdownItem<BugReportType>` — already exists in current flessel (no E11 rename dependency).
  - `FlesselTextInput` — current flessel already supports `controller`, `hint`, `maxLines`, `minLines`, `keyboardType`. All row 41 needs.
  - `FlesselButton` + `FlesselAccentButton` — assumed APPROVED via earlier button rows (4-5). API surface (`label: String`, `onPressed: VoidCallback`) to be verified during Phase 3 execution before editing.
  - `FlesselGap.m()` / `FlesselGap.l()` — clean rename. `FlesselGap.m()` also replaces `VesselGap.hm()` in the button Row (both 12px tier `m`); flessel's gap sets width AND height but the Row's cross-axis is dominated by button heights → no visual difference.
  - `FlesselThemes.of(context)` + `t.textPrimary` — clean replacement.
  - `FlesselFonts.contentTitle` / `FlesselFonts.contentBodyAccent` — per meatbag's font decision above.

- **Implementation sketch (locked)**:
  ```dart
  // front/lib/shared/ui/bottom_sheet/langwij_bug_report_sheet.dart

  import 'package:flessel/flessel.dart';
  import 'package:flutter/material.dart';

  import '../../../entities/card/card_model.dart';
  import '../../../l10n/app_localizations.dart';
  import 'bug_report_type.dart';

  /// Opens a bug-report bottom sheet for a specific card.
  ///
  /// [card] — the card being reported (shown as context in the sheet).
  /// Submit is a no-op for now; both buttons close the sheet.
  Future<void> showLangwijBugReportSheet(
    BuildContext context, {
    required CardModel card,
  }) {
    return showFlesselBottomSheet<void>(
      context: context,
      builder: (_) => _LangwijBugReportForm(card: card),
    );
  }

  class _LangwijBugReportForm extends StatefulWidget {
    const _LangwijBugReportForm({required this.card});

    final CardModel card;

    @override
    State<_LangwijBugReportForm> createState() => _LangwijBugReportFormState();
  }

  class _LangwijBugReportFormState extends State<_LangwijBugReportForm> {
    BugReportType _selectedType = BugReportType.badTranslation;
    final _messageController = TextEditingController();

    @override
    void dispose() {
      _messageController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final t = FlesselThemes.of(context);
      final l10n = AppLocalizations.of(context)!;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.bugReport_title,
            style: FlesselFonts.contentTitle.copyWith(color: t.textPrimary),
          ),
          const FlesselGap.m(),
          Text(
            l10n.bugReport_cardContext(widget.card.targetAnswer, widget.card.nativeText),
            style: FlesselFonts.contentBodyAccent.copyWith(color: t.textPrimary),
          ),
          const FlesselGap.m(),
          FlesselDropdown<BugReportType>(
            value: _selectedType,
            onChanged: (v) => setState(() => _selectedType = v),
            expanded: true,
            items: [
              FlesselDropdownItem(
                value: BugReportType.badTranslation,
                label: l10n.bugReport_typeBadTranslation,
              ),
              FlesselDropdownItem(
                value: BugReportType.uiBug,
                label: l10n.bugReport_typeUiBug,
              ),
            ],
          ),
          const FlesselGap.m(),
          FlesselTextInput(
            controller: _messageController,
            hint: l10n.bugReport_messagePlaceholder,
            maxLines: 4,
            minLines: 3,
            keyboardType: TextInputType.multiline,
          ),
          const FlesselGap.l(),
          Row(
            children: [
              Expanded(
                child: FlesselButton(
                  label: l10n.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const FlesselGap.m(),
              Expanded(
                child: FlesselAccentButton(
                  label: l10n.bugReport_submit,
                  onPressed: () {
                    // No-op for now. Persistence comes later.
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
  ```

- **Call-site retargeting** (1 site):

  | Site | Change |
  |---|---|
  | `front/lib/pages/result_screen.dart:256` | Import `bug_report_sheet.dart` → `langwij_bug_report_sheet.dart`; `showBugReportSheet(context, card: card)` → `showLangwijBugReportSheet(context, card: card)`. No param changes. |

- **Files delta**:
  - **Create**: `front/lib/shared/ui/bottom_sheet/langwij_bug_report_sheet.dart`
  - **Delete**: `front/lib/shared/ui/bottom_sheet/bug_report_sheet.dart` (absorbs row 42)
  - **Keep**: `front/lib/shared/ui/bottom_sheet/bug_report_type.dart` (enum still imported by new file)
  - **Update**: `front/lib/pages/result_screen.dart:256`

- **Matrix description verification**: matrix correctly identified the domain entity dependency (`CardModel`), named the composite function correctly, and listed the flessel primitives accurately (`FlesselDropdown`, `FlesselTextInput`, `FlesselButton`, `FlesselAccentButton`). Matrix did NOT flag (but audit did): (a) the Iosevka sheet-title font gap, (b) the dropdown `expanded: true` requirement carrying forward from row 14, (c) the 6 l10n keys that flow with the composite. No material matrix-description errors to correct — just under-specification, now documented.

- **Antipatterns check**:
  - **Magic literals**: none. All numeric/color/font values come from `FlesselThemeData` / `FlesselFonts` / `FlesselLayout`. The card context line uses the inline glyph `→` which is a language-agnostic display separator (no l10n semantics); accepted.
  - **Raw types / enum boundaries**: `BugReportType` is a clean enum flowing through `FlesselDropdown<BugReportType>` generically. No untyped strings.
  - **State ownership**: `_selectedType` + `_messageController` owned by the form widget. Single owner, no parallel state, no provider duplication.
  - **Layer boundaries**: composite lives in the langwij layer (allowed to use `CardModel`, `AppLocalizations`, `BugReportType`). Flessel library stays untouched — no riverpod/l10n/domain leaks into flessel.
  - **Feature creep**: submit stays no-op + pop. Did NOT add an `onSubmit` callback. Did NOT refactor the form layout. Did NOT promote form state to a provider. Pure migration.

- **Phase 3 execution dependency chain**:
  1. Row 40 (`showFlesselBottomSheet` + `isDismissible` + auto-pad) — required prerequisite
  2. Rows 4-5 (`FlesselButton` + `FlesselAccentButton`) — assumed APPROVED; API surface to verify
  3. Row 41 file creation + row 42 absorption + `result_screen.dart:256` retarget — single bundle
  4. No row-13 / row-14 wait (meatbag dropped the `textInputAction` param; `FlesselDropdown` / `FlesselDropdownItem` already satisfy row 41's needs without the row-14 rendering fix)

- **Phase 4 debt inherited (not created by this row)**:
  - Row 40's `bottomSheetPadding` duplication (layout constant vs per-theme field)
  - `VesselFonts.textSheetTitle` (Iosevka 20 w700) orphans when all 4 consumer sheets migrate (row 41 + 3 screen-level sheets in settings/round/language); deletable during Phase 4 vessel-fonts retirement.
  - `VesselFonts.textBodyAccent` orphans when this row's call site is the last consumer of that font style — **to verify at Phase 4 time**, not scoped here.

- **Status**: `DONE`

### 42. _BugReportSheetContent (private)

- **Location**: `front/lib/shared/ui/bottom_sheet/bug_report_sheet.dart` (same file as row 41's source)
- **Type**: private `StatefulWidget` + `State<_BugReportSheetContent>` inside `bug_report_sheet.dart`
- **Decision**: `DELETE` — absorbed into row 41's file creation
- **Rationale**: private helper. Replaced in the new `langwij_bug_report_sheet.dart` by `_LangwijBugReportForm` (same state shape: `BugReportType _selectedType = badTranslation` + `TextEditingController _messageController`; same dispose logic; same build-method layout, just using flessel primitives per row 41's sketch).
- **Execution**: no separate commit. When row 41's Phase 3 creates `langwij_bug_report_sheet.dart` and deletes `bug_report_sheet.dart`, `_BugReportSheetContent` disappears with the file.
- **Status**: `DONE`

### 43. showModeBottomSheet + showCountBottomSheet

- **Location**: `front/lib/shared/ui/bottom_sheet/quiz_bottom_sheets.dart`
- **Type**: two public functions (`showModeBottomSheet`, `showCountBottomSheet`) + 5 private helpers + 1 domain value class
- **Decision**: `LANGWIJ_COMPOSITE`
- **Status**: `DONE`

**Scope correction (caught during row 43 audit).** Matrix row title originally listed only `showModeBottomSheet`. The actual scope of this row is the **entire** `quiz_bottom_sheets.dart` file:

- Two public functions — `showModeBottomSheet` **and** `showCountBottomSheet`. Matrix detail text did allude to "a grid (for count selection)", but the row title and row 44's enumeration missed items.
- Five private helpers, all absorbed via row 44: `_ModeTileData`, `_ModeTileRow`, `_ModeTile`, `_CountTileGrid`, `_CountTile`. Row 44 originally listed 4, missing `_ModeTileData` (`quiz_bottom_sheets.dart:132-146`).
- One domain value class `ModeSelection` (`quiz_bottom_sheets.dart:15-20`) — stays as domain, but moves out of this UI file.

**Call-site audit** (production only, legacy `controls_list_screen.dart` excluded):

| Caller | Mode sheet | Count sheet | Notes |
|---|---|---|---|
| `front/lib/pages/vocab_deck_list_screen.dart` | `:337` | `:352` | full param surface — implicit `showAllModes: true`, all 4 lang params passed |
| `front/lib/pages/group_list_screen.dart` | `:459` | `:471` | `showAllModes: false`, `targetLangCode: LangCodes.serbian` only |
| `front/lib/pages/agreement_group_list_screen.dart` | `:155` | `:167` | `showAllModes: false`, `targetLangCode: LangCodes.serbian` only |

Both functions paired in all 3 callers (count called after mode when `!isTest`). Legacy excluded: `controls_list_screen.dart:1183+1196`.

**Per-param usage for `showModeBottomSheet`** (n=3):

| Param | Default | Production usage | Keep? |
|---|---|---|---|
| `context` | required | 3/3 | yes |
| `l10n` | required | 3/3 | yes |
| `showAllModes` | `true` | 1 implicit-true + 2 explicit-false | yes |
| `targetLangCode` | required | 3/3 | yes |
| `nativeLangCode` | `''` | 1/3 non-default | yes |
| `nativeLangName` | `''` | 1/3 non-default | yes |
| `targetLangName` | `''` | 1/3 non-default | yes |

**Per-param usage for `showCountBottomSheet`** (n=3): only `totalCount` (required, 3/3).

**No grow points pre-proposed** — matrix description said only "built from FlesselTiles". Nothing to drop on the grow-point axis. Audit clean for grow points, but caught scope enumeration errors (above) and font/layout/theme mapping gaps (below).

**Target file** (single file, chosen over two-file split):

- `front/lib/shared/ui/bottom_sheet/langwij_quiz_bottom_sheets.dart`
- Holds both public functions + all 5 private helpers
- Rationale: count sheet always called after mode sheet; tile helpers are structurally similar; splitting would fragment coupled code.

**Function renames**:

- `showModeBottomSheet` → `showLangwijModeSelectionSheet`
- `showCountBottomSheet` → `showLangwijQuestionCountSheet` (new — matrix did not enumerate this function)

**Theme growth — 3 NEW props in `FlesselThemeData`** (dedicated `tileAccent*` chosen over reusing `controlAccent*`; meatbag rationale: reusing controlAccent couples tile accent to button accent, blocking future divergence — dedicated props preserve designer freedom):

- `tileAccentBackground: Color`
- `tileAccentForeground: Color`
- `tileAccentBorderColor: Color`

Default-tile colors still use existing flessel props (`tileBackground`/`tileBorderColor`/`textPrimary`). All 5 flessel themes get the 3 new fields populated. Initial values per theme can match each theme's `controlAccent*` pair (border = bg for solid look) as starting defaults, but the dedicated props let theme designers diverge tile-accent from button-accent later without an API change.

**Font mappings** (no flessel font growth):

- `VesselFonts.textModeTileSectionHeader` (Iosevka 18 w900) → `FlesselFonts.contentXlAccent` (Montserrat 18 bold) — loses Iosevka family, keeps size + weight character (row 41 precedent: closest flessel font beats adding product-specific styles).
- `VesselFonts.textModeTileLabel` (Montserrat 14 bold) → `FlesselFonts.contentMAccent` (Montserrat 14 bold) — direct match.

**Layout — introduce `LangwijLayout`** (option L1 approved — rows 45-48 will reuse the same class for vocab tile dimensions, amortizing the new-file cost now):

- New file: `front/lib/shared/ui/layout/langwij_layout.dart` (exact path locked at execution; alternative `front/lib/shared/langwij/langwij_layout.dart` also acceptable).
- Constants to add for this row:
  - `LangwijLayout.modeTileIconSize = 45.0` (no flessel equivalent — flessel icon sizes max at `iconXl = 28`)
  - `LangwijLayout.modeTileFlagWidth = 45.0` (no flessel flag constants)
  - `LangwijLayout.modeTileFlagHeight = 28.0` (no flessel flag constants)
  - `LangwijLayout.modeTileFlagBorderRadius = 4.0` (coincidental match with `FlesselLayout.badgeBorderRadius = 4.0` — semantic mismatch, keep dedicated)
  - `LangwijLayout.quizSheetMinHeight = 360.0` (shared by both mode + count sheets; no flessel equivalent)
- Dropped from VesselLayout without porting: `modeTileGap = 12.0` → `FlesselLayout.gapM` (direct value match, generic semantic).
- Tile inner padding (currently `EdgeInsets.all(VesselLayout.gapM)`) → `FlesselLayout.gapM`.

**Domain class move** (approved):

- `ModeSelection` (`quiz_bottom_sheets.dart:15-20`, 2 fields: `QuizMode mode`, `bool isTest`) moves to `front/lib/features/quiz/mode_selection.dart` next to its sibling `QuizMode` enum. Domain value objects belong with their domain enum, not co-located with a UI function.

**Bottom sheet infrastructure**: leverages row 40's approved `showFlesselBottomSheet` auto-padding wrap — composite does NOT add `SafeArea`/`Padding` inside its builder (flessel handles it). `isDismissible` stays default (no production caller passes `false`).

**Flessel controls/primitives used**:

- `showFlesselBottomSheet<T>` (row 40 dependency)
- `FlesselGap.s()` / `FlesselGap.l()` (replaces `VesselGap.s`, `VesselGap.l`, `VesselGap.hs`; flessel's gap is axis-agnostic)
- `FlesselTextButton` (cancel action — row 4 dependency)
- Phosphor icons re-exported by flessel: `PhosphorIconsRegular.cards`, `PhosphorIconsRegular.pencilSimpleLine`, `PhosphorIconsRegular.chartPieSlice`, `PhosphorIconsRegular.chartPie`, `PhosphorIconsFill.chartPolar`
- `FlesselThemes.of(context)` → `FlesselThemeData`
- `FlesselFonts.contentXlAccent`, `FlesselFonts.contentMAccent`
- `FlesselTile(accent:)` (G-TILE-ACCENT-1 — new param, consumes `tileAccent*` theme fields)

**Grow point G-TILE-ACCENT-1 — `FlesselTile({accent: bool = false})`**:

New param on `FlesselTile`. When `accent: true`, the tile's `Container` uses `t.tileAccentBackground` + `t.tileAccentBorderColor` instead of `t.tileBackground` + `t.tileBorderColor`. Default `false` preserves current behavior. Consumes the 3 `tileAccent*` theme fields added above — without this grow point, those fields would be dead in flessel (theme props with no widget to use them). Per consumer rule: "If a needed control doesn't exist, first create it as a Flessel control, then use it."

Composite uses `FlesselTile(accent: data.isAccent, onTap: ..., child: ...)` for both default and accent tile variants. Foreground text color is still read at the composite level (`data.isAccent ? t.tileAccentForeground : t.textPrimary`) since `FlesselTile` does not control child text color. Cosmetic change: `FlesselTile`'s `InkWell` ripple replaces vessel's raw `GestureDetector` tap (accepted, same pattern as row 37's `LangwijAnswerTile`).

**External package dependency**:

- `country_flags` — product dependency for rendering language flags. Flessel cannot import it per consumer rules. Langwij composite imports it directly. No change to flessel.

**Dependencies**:

- Row 40 (`showFlesselBottomSheet` internal padding wrap) — APPROVED, must execute before row 43
- Rows 4-5 (`FlesselTextButton`) — APPROVED
- G-TILE-ACCENT-1 (`FlesselTile` accent param + 3 `tileAccent*` theme fields) — must land in flessel before composite can use `FlesselTile(accent: true)`
- Execution order per plan line 2185: bottom sheets in order 40 → 41 → 43

**Phase 4 debt noted**:

- 6 vessel `modeTile*` theme props retire entirely (`modeTileBackground`/`Foreground`/`BorderColor` + 3 accent variants). Phase 4 VesselThemeData cleanup removes them.
- 6 vessel layout constants retire (`modeTileGap`/`modeTileIconSize`/`modeTileFlagWidth`/`modeTileFlagHeight`/`modeTileFlagBorderRadius`/`modeSheetMinHeight`) — mapped to `FlesselLayout.gapM` + 5 `LangwijLayout.*` fields.
- 2 vessel font styles retire (`textModeTileSectionHeader`, `textModeTileLabel`) — mapped to flessel grid.
- Initial population values of flessel's new `tileAccent*` props per theme need designer review in Phase 4 (starting defaults match each theme's `controlAccent*`, but theme-ID remapping between vessel/flessel means visual parity with current vessel quiz sheets is not guaranteed — that is a separate Phase 4 palette reconciliation problem, not a row 43 blocker).

### 44. _ModeTileData, _ModeTileRow, _ModeTile, _CountTileGrid, _CountTile (private)

- **Location**: `front/lib/shared/ui/bottom_sheet/quiz_bottom_sheets.dart`
- **Decision**: `DELETE` (absorbed into #43)
- **Status**: `DONE`

**Helper count correction**: matrix originally listed 4 helpers, actual is **5** — `_ModeTileData` (`quiz_bottom_sheets.dart:132-146`, the tile prop bag passed to `_ModeTileRow`) was missing from the enumeration. Caught during row 43 audit.

**Rationale**: all 5 private helpers are absorbed as private implementation details in the new `langwij_quiz_bottom_sheets.dart` file (row 43). No separate file deletion — the whole `quiz_bottom_sheets.dart` file is replaced as part of row 43's execution.

### 45. VocabDailyActivityCard

- **Location**: `front/lib/features/vocab/widgets/vocab_daily_activity_card.dart`
- **Base**: `StatelessWidget`
- **Props (preserved in migration)**: `asyncStats: AsyncValue<DailyActivityStats>`, `l10n: AppLocalizations`
- **Domain model**: `DailyActivityStats` (stays in `front/lib/shared/repositories/daily_activity_repository.dart`)
- **Call-site audit**: 1/1 production caller at `vocab_deck_list_screen.dart:137`, wrapped in `Padding(bottom: VesselLayout.vocabDailyCardBottomGap=12)` at lines 133-138. Zero legacy callers (`controls_list_screen.dart` does not import), zero blueprint references.
- **Decision**: `LANGWIJ_COMPOSITE`
- **Target**: `front/lib/features/vocab/widgets/langwij_vocab_daily_activity_card.dart` (new file, langwij layer)
- **Rename**: `VocabDailyActivityCard` → `LangwijVocabDailyActivityCard`

**Primitive mapping** (pure flessel swap, no flessel extensions required):

| Source primitive | Flessel primitive | Notes |
|---|---|---|
| `VesselCard({child})` plain | `FlesselCard({child})` defaults | Bare, no overrides. Row 9 grow points (`onTap`, `padding`, `margin`) not consumed. |
| `VesselThemes.of(context).textPrimary` | `FlesselThemes.of(context).textPrimary` | Direct. |
| `VesselThemes.of(context).textSecondary` | `FlesselThemes.of(context).textSecondary` | Direct. |
| `VesselFonts.textListItem` (Montserrat 14/400) | `FlesselFonts.contentBody` (alias → `contentM`) | Direct. |
| `VesselFonts.textCaption` (Montserrat 12/400) | `FlesselFonts.contentCaption` (alias → `contentS`) | Direct. |
| `SizedBox(height: VesselLayout.vocabDailyCardTitleGap=4)` | `const FlesselGap.xs()` (`FlesselLayout.gapXs=4`) | Direct. `vocabDailyCardTitleGap` loses its sole usage here — retires in the same commit. |
| `.when(data:, loading:, error:)` async triad | Same (riverpod at langwij layer) | Triad preserved verbatim. No collapse into a single empty-state branch (out of row 45 scope). |

**Accepted escape hatch (area 3 — Layout; area 8 — Quality gate):**

The migrated widget retains `SizedBox(width: double.infinity)` around the inner `Column` inside `FlesselCard.child`.

- **What**: raw `SizedBox` used as a cross-axis stretch constraint, not for inter-widget spacing.
- **Why it's needed**: `ListView.builder` passes loose cross-axis constraints (min 0, max listWidth). `FlesselCard`'s internal `Container` in the headerless path does not stretch — without the `SizedBox`, the card shrinks to its child's intrinsic width. Visual regression.
- **Why the fix isn't in row 45**: the proper fix (unconditional stretch in the headerless path, or honoring the existing `stretch: bool` parameter without a header) belongs inside `FlesselCard` itself. That change is out of row 45 scope.
- **Tracked fix direction**: row 9 amendment or a new row for `FlesselCard` stretch. Once landed, the `SizedBox(width: double.infinity)` wrapper gets deleted from `LangwijVocabDailyActivityCard` in a follow-up edit.
- **Status**: explicitly accepted per `rules/core.claude.md` quality gate — antipattern named, tracked, and deferred, not hidden.

**Caller edit — `vocab_deck_list_screen.dart`:**

- Line 20: import path `vocab_daily_activity_card.dart` → `langwij_vocab_daily_activity_card.dart`.
- Lines 133-138: **delete the `Padding(bottom: VesselLayout.vocabDailyCardBottomGap)` wrapper entirely**. Enforces consumer rule #4 (no external sizing wrappers around flessel controls). The `itemBuilder`'s `index == 0` branch returns `LangwijVocabDailyActivityCard(asyncStats: asyncStats, l10n: l10n)` directly, no `Padding` ancestor.

**Layout constant retirement (same commit):**

- `VesselLayout.vocabDailyCardBottomGap=12.0` — sole usage was the caller `Padding` wrapper being deleted → retires from `vessel_layout.dart`.
- `VesselLayout.vocabDailyCardTitleGap=4.0` — sole usage was the `SizedBox(height:)` replaced with `FlesselGap.xs()` → also retires.

**Execution scope (Phase 3):**

1. Create `front/lib/features/vocab/widgets/langwij_vocab_daily_activity_card.dart`. Imports: `flutter/material.dart`, `flutter_riverpod/flutter_riverpod.dart`, `package:flessel/flessel.dart`, `../../../l10n/app_localizations.dart`, `../../../shared/repositories/daily_activity_repository.dart`. Class `LangwijVocabDailyActivityCard extends StatelessWidget` with same `asyncStats` + `l10n` props. Build method: `FlesselCard` → `SizedBox(width: double.infinity)` → `Column(crossAxisAlignment: start, mainAxisSize: min)` → title `Text` + `FlesselGap.xs()` + `.when()` triad yielding detail `Text`s. Fonts via `FlesselFonts.contentBody` / `contentCaption` with `copyWith(color: t.textPrimary / t.textSecondary)`.
2. Edit `vocab_deck_list_screen.dart` line 20 (import rename) and lines 133-138 (delete `Padding` wrapper, inline the new constructor call + class rename).
3. Delete `front/lib/features/vocab/widgets/vocab_daily_activity_card.dart`.
4. Delete `VesselLayout.vocabDailyCardBottomGap` and `VesselLayout.vocabDailyCardTitleGap` constants from `vessel_layout.dart`.

**Row 9 call-site table housekeeping** (applied when row 9 gets its post-48 audit rewrite, not in row 45 execution): the row 9 entry at line 301 for `vocab_daily_activity_card.dart:23` becomes stale — `LangwijVocabDailyActivityCard` is born composing `FlesselCard` directly, so the row 9 VesselCard → FlesselCard retargeting has no work to do for this file. Row 9 rewrite should annotate the entry or drop it.

**Dependencies**: none. Row 45 executes independently against current flessel `main`. Row 9 ordering is irrelevant — row 45 consumes only `FlesselCard` defaults, no row 9 grow points.

**Nine-area audit verdict:**

- **1 Theme**: pass — direct theme prop usage via `FlesselThemes.of(context)`.
- **2 Fonts**: pass — `FlesselFonts` aliases, `copyWith(color: ...)` only.
- **3 Layout**: **accepted escape hatch** — `SizedBox(width: double.infinity)` tracked as deferred debt (see subsection above).
- **4 Controls**: pass — `FlesselCard` the only control used, no ad-hoc overrides, no raw Material/Flutter in consuming screen. Domain types (`AsyncValue<DailyActivityStats>`, `AppLocalizations`) are allowed at the langwij layer (not flessel library code).
- **5 Copy**: pass — all user-facing text from `l10n.dailyActivityTitle`, `l10n.dailyActivityEmpty`, `l10n.correctCount(...)`, `l10n.wrongCount(...)`, `l10n.wordsCount(...)`.
- **6 Architecture**: pass — widget consumes upstream async data, no mutations, no invalidation knowledge, no multi-step ops.
- **7 Flessel library boundary**: N/A — langwij layer, not flessel library code.
- **8 Quality gate**: **accepted** — same antipattern as area 3, consciously tracked.
- **9 State ownership**: pass — no new state, upstream-owned via provider.

- **Status**: `DONE`

### 46. VocabDeckTile

- **Location**: `front/lib/features/vocab/widgets/vocab_deck_tile.dart`
- **Base**: `StatelessWidget`
- **Props (preserved)**: `item: VocabDeckTileData`, `l10n: AppLocalizations`, `width: double`, `onTap: VoidCallback`
- **Domain model**: `VocabDeckTileData` (stays in `vocab_deck_tile_data.dart`, shared with row 47)
- **Call-site audit**: 1/1 production caller inside `VocabLevelCard` Wrap (row 47). Legacy callers in `controls_list_screen.dart` excluded. All 4 props used at the sole call site.
- **Decision**: `LANGWIJ_COMPOSITE`
- **Target**: `front/lib/features/vocab/widgets/langwij_vocab_deck_tile.dart`
- **Rename**: `VocabDeckTile` → `LangwijVocabDeckTile`

**Primitive mapping**:

| Source | Flessel | Notes |
|---|---|---|
| `VesselTile({child, onTap})` | `FlesselTile({child, onTap})` | Twin. Conditional `onTap` (null when `cardCount == 0`) preserved. |
| `VesselProgressBar(value, mode: compact)` | `FlesselProgressBar(value, mode: compact)` | Twin. |
| `VesselFonts.textTileContent` (Montserrat 12/400) | `FlesselFonts.contentCaption` | Exact match. |
| `VesselFonts.textTileCounter` (Montserrat 12/bold) | `FlesselFonts.contentSAccent` | Exact match. |
| `VesselFonts.textTileHeader` (Iosevka 18/w900) | `FlesselFonts.displayM` (Iosevka 14/w800) | D1(b) snap — smaller/lighter, accepted visual regression. |
| `VesselFonts.textProgressPercentage` (Montserrat 11/bold) | `FlesselFonts.contentXsAccent` (Montserrat 10/bold) | D2(c) snap — 1pt smaller, accepted visual regression. |
| `t.tileForeground` | `t.textPrimary` | Verified identical across all 5 vessel themes. Duplicate retires. |
| `t.textPrimaryDimmed` | `t.textPrimary.withValues(alpha: t.disabledOpacity)` | Inline derivation. Sole usage in codebase. Vessel getter retires. |
| `Stack` + 3 `Positioned` children | Raw Flutter, stays | Internal positioned layout owned by the langwij composite. |
| `DeckIcons.fromString` / `.fallback` | Stays (langwij-domain utility) | Already in `shared/lib/deck_icons.dart`. |
| `l10n.vocab_termsCount(cardCount)` | Stays | Single localized string. |

**Flessel grow — `FlesselIconContainer` (D3(a))**:

New flessel primitive: a themed decorated box wrapping an icon. Provides the "icon in a colored rounded box" pattern currently hardcoded as `Container(decoration: BoxDecoration(...)) → Icon(...)` in the vessel widget.

Grow points:
- **G-ICON-1**: new widget `FlesselIconContainer` in `lib/src/controls/icon_container/`. Takes `icon: IconData`, optional `iconSize: double` (defaults to `FlesselLayout.iconM`). Renders themed background box + icon using theme fields below.
- **G-ICON-2**: `FlesselThemeData.iconContainerBackground` (Color) — 5-theme mapping: theme01=pureBlackA12, theme02=powderTeal, theme03=platinum, theme04=silverdust, theme05=spaceIndigo.
- **G-ICON-3**: `FlesselThemeData.iconContainerForeground` (Color) — 5-theme mapping: theme01=gunMetal, theme02=darkNavy, theme03=gunMetal, theme04=deepWalnut, theme05=deepWalnut.
- **G-ICON-4**: `FlesselThemeData.iconContainerBorderRadius` (double) — 5-theme mapping: theme01=8, theme02=8, theme03=4, theme04=8, theme05=8.
- **G-ICON-5**: `FlesselLayout.iconContainerPadding` (double) = 8.0. Internal padding between box edge and icon.

Barrel export added to `lib/flessel.dart`. Consumer rules `consumer.claude.md` controls inventory updated.

**Example app**: Add new "Icon Container" section in `.vessel/packages/flessel/example/lib/pages/controls_list_screen.dart` — register in `_sectionGroups` under Layout group. Demo: `FlesselIconContainer` with default icon, custom `iconSize` variant. Register section key in `_sectionKeys`.

**Layout constant disposition (D4(a) — all to LangwijLayout)**:

17 VesselLayout constants → LangwijLayout fields:

| VesselLayout source | LangwijLayout target | Value |
|---|---|---|
| `vocabTileHeight` | `vocabTileHeight` | 180.0 |
| `vocabTileMinWidth` | `vocabTileMinWidth` | 120.0 |
| `vocabTileIconSize` | `vocabTileIconSize` | 40.0 |
| `deckIconTopOffset` | `vocabTileIconTopOffset` | -2.0 |
| `vocabTileHeaderTop` | `vocabTileHeaderTop` | 49.0 |
| `vocabTileHeaderLeft` | `vocabTileHeaderLeft` | 8.0 |
| `vocabTileHeaderRight` | `vocabTileHeaderRight` | 8.0 |
| `vocabTileHeaderGap` | `vocabTileHeaderGap` | 10.0 |
| `vocabTileHeaderRowGap` | `vocabTileHeaderRowGap` | 2.0 |
| `vocabTileNameTop` | `vocabTileNameTop` | 8.0 |
| `vocabTileNameLeft` | `vocabTileNameLeft` | 10.0 |
| `vocabTileNameRight` | `vocabTileNameRight` | 8.0 |
| `vocabTileWordsTop` | `vocabTileWordsTop` | 116.0 |
| `vocabTileWordsLeft` | `vocabTileWordsLeft` | 8.0 |
| `vocabTileWordsRight` | `vocabTileWordsRight` | 8.0 |
| `vocabTileProgressPercentGap` | `vocabTileProgressPercentGap` | 4.0 |
| `vocabTileProgressPercentWidth` | `vocabTileProgressPercentWidth` | 30.0 |

`vocabTileGap` (12) → `FlesselLayout.gapM` direct — no LangwijLayout field, vessel constant retires.
`deckIconPadding` (8) → `FlesselLayout.iconContainerPadding` (G-ICON-5) — vessel constant retires.

**Envelope sizing (D5(a))**: `LangwijVocabDeckTile` wraps `FlesselTile` in `SizedBox(width: width, height: LangwijLayout.vocabTileHeight)`. Legitimate — the composite owns its dimensions. Not tracked as debt.

**Caller edit — `vocab_level_card.dart` (row 47 source file)**:

- Import: `vocab_deck_tile.dart` → `langwij_vocab_deck_tile.dart`.
- Single call site: `VocabDeckTile(...)` → `LangwijVocabDeckTile(...)`. Props unchanged.
- If rows 46+47 execute together, the rename is absorbed into row 47's full rewrite.

**Vessel retirement scope (same commit)**:

- Delete `front/lib/features/vocab/widgets/vocab_deck_tile.dart`.
- 19 VesselLayout constants retire (17 → LangwijLayout, `vocabTileGap` → FlesselLayout.gapM, `deckIconPadding` → FlesselLayout.iconContainerPadding).
- 3 VesselThemeData fields retire: `deckIconBackground/Color/BorderRadius` → FlesselThemeData icon container fields.
- 1 VesselThemeData field confirmed duplicate: `tileForeground` (= `textPrimary` across all 5 themes).
- 1 VesselThemeData getter retires: `textPrimaryDimmed`.
- 4 VesselFonts aliases retire: `textTileHeader/Content/Counter`, `textProgressPercentage`.

**Execution scope (Phase 3)**:

1. **Flessel grow** (separate commit or same): create `FlesselIconContainer` widget + add 3 fields to `FlesselThemeData` + 5 theme file mappings + 1 field to `FlesselLayout` + barrel export + `consumer.claude.md` inventory update.
2. Create `front/lib/features/vocab/widgets/langwij_vocab_deck_tile.dart`. Class `LangwijVocabDeckTile extends StatelessWidget`, same 4 props. Build: `SizedBox(width, height)` → `FlesselTile(onTap: item.cardCount > 0 ? onTap : null)` → `Stack` with 3 `Positioned` children (header row with `FlesselIconContainer` + stats column, title text, words text). `FlesselProgressBar(compact)` inside the stats column.
3. Add 17 vocabTile constants to `LangwijLayout`.
4. Edit `vocab_level_card.dart`: import rename + `VocabDeckTile` → `LangwijVocabDeckTile`.
5. Delete `vocab_deck_tile.dart`.
6. Retire vessel constants/fields/fonts listed above.

**Dependencies**: row 46 flessel grow (G-ICON-1 through G-ICON-5) must land before the composite can import `FlesselIconContainer`. Row 46 execution should precede row 47 (VocabLevelCard migration references the new `LangwijVocabDeckTile` name).

**Nine-area audit verdict**:

- **1 Theme**: pass — 3 new fields added to `FlesselThemeData` via grow proposal; `tileForeground` → `textPrimary` direct, `textPrimaryDimmed` derived inline.
- **2 Fonts**: pass — 2 exact matches + 2 accepted snaps (D1 displayM, D2 contentXsAccent).
- **3 Layout**: pass — 17 constants to `LangwijLayout`, 2 to `FlesselLayout` (gapM reuse + iconContainerPadding grow).
- **4 Controls**: pass — `FlesselTile`, `FlesselProgressBar`, `FlesselIconContainer` (new). Raw `Stack`/`Positioned`/`Row`/`Column`/`Text`/`SizedBox` composition inside the langwij composite.
- **5 Copy**: pass — single `l10n.vocab_termsCount(count)`.
- **6 Architecture**: pass — stateless, pure derivation from props.
- **7 Flessel boundary**: pass — composite in `front/lib/features/vocab/widgets/`, no Riverpod or domain imports in flessel.
- **8 Quality gate**: pass — no untracked antipatterns. Envelope `SizedBox` is legitimate (composite owns its dimensions).
- **9 State ownership**: n/a — stateless.

- **Status**: `DONE`

### 47. VocabLevelCard

- **Location**: `front/lib/features/vocab/widgets/vocab_level_card.dart`
- **Base**: `StatelessWidget`
- **Props (preserved)**: `item: VocabLevelData`, `l10n: AppLocalizations`, `isExpanded: bool`, `onToggle: VoidCallback`, `onDeckTap: void Function(VocabDeckModel deck, int cardCount)`
- **Domain model**: `VocabLevelData` (stays in `vocab_deck_tile_data.dart`, shared with row 46 + 48)
- **Call-site audit**: 1/1 production caller at `vocab_deck_list_screen.dart` inside `ListView.builder`, wrapped in `Padding(bottom: VesselLayout.vocabLevelCardBottomGap=12)`. All 5 props used.
- **Decision**: `LANGWIJ_COMPOSITE`
- **Target**: `front/lib/features/vocab/widgets/langwij_vocab_level_card.dart`
- **Rename**: `VocabLevelCard` → `LangwijVocabLevelCard`

**Primitive mapping**:

| Source | Flessel | Notes |
|---|---|---|
| `VesselCard(padding: EdgeInsets.all(16))` | `FlesselCard(child: ...)` defaults | `vocabLevelCardPadding=16` equals `FlesselLayout.cardPadding=16`. Drop param, use defaults. |
| `VesselProgressBar(detailed)` | `FlesselProgressBar(detailed)` | Twin. |
| `VesselFonts.textLevelHeader` (Iosevka 28/w600) | `FlesselFonts.displayXl` (Iosevka 32/w700) | D1(a) snap — 4pt larger, heavier weight, accepted visual regression. |
| `VesselFonts.textLevelCounter` (Montserrat 14/bold) | `FlesselFonts.contentBodyAccent` | Exact match. |
| `VesselFonts.textCaption` (Montserrat 12/400) | `FlesselFonts.contentCaption` | Exact match. |
| `t.textPrimary` | `t.textPrimary` | Direct. |
| `t.textSecondary` | `t.textSecondary` | Direct. |
| `Icon(lock, size: 16)` | `Icon(lock, size: FlesselLayout.iconS)` | Hardcoded `16` replaced with layout constant. |
| `GestureDetector(onTap, behavior: opaque)` | Stays | Invisible interaction wrapper inside composite. |
| `VocabDeckTile(...)` | `LangwijVocabDeckTile(...)` (row 46) | — |
| `VocabLevelStatsRow(...)` | `LangwijVocabLevelStatsRow(...)` (row 48) | — |
| `LayoutBuilder` → tile column math | Stays | Uses `LangwijLayout.vocabTileMinWidth` + `FlesselLayout.gapM` (row 46). |

**VesselCard → FlesselCard alignment note**: VesselCard uses Flutter `Card` widget (default margin 4px all sides). FlesselCard uses `Container(margin: bottom 18)`. Bottom spacing shifts from 4 (Card margin) + 12 (caller Padding) = 16 to FlesselCard's built-in 18. Acceptable — 2px delta, caller Padding deleted per consumer rule #4.

**Layout constant disposition**:

Maps to FlesselGap (vessel constants retire):

| Vessel | FlesselGap | Context |
|---|---|---|
| `vocabHeaderToProgressGap` (8) | `FlesselGap.s()` | Vertical, in header Column |
| `vocabProgressPercentGap` (4) | `FlesselGap.xs()` | Horizontal, in progress Row |
| `vocabDescSpacingAfter` (8) | `FlesselGap.s()` | Vertical, after description |
| `vocabTilesToStatsGap` (16) | `FlesselGap.l()` | Vertical, tiles → stats |

Retires without replacement:

| Vessel | Reason |
|---|---|
| `vocabLevelCardPadding` (16) | Equals `FlesselLayout.cardPadding`, FlesselCard default handles it |
| `vocabLevelCardBottomGap` (12) | Caller Padding wrapper deleted, FlesselCard internal `cardMarginBottom=18` handles spacing |

New LangwijLayout fields (3):

| Vessel | LangwijLayout | Value | Reason |
|---|---|---|---|
| `vocabProgressSpacingAfter` | `vocabProgressSpacingAfter` | 18.0 | Between FlesselGap.l(16) and .xl(24) — no tier match |
| `vocabProgressWordsWidth` | `vocabProgressWordsWidth` | 30.0 | Width constraint for card-count text column |
| `vocabProgressPercentWidth` | `vocabProgressPercentWidth` | 30.0 | Width constraint for percentage text column |

Reused from row 46 (already in LangwijLayout / FlesselLayout):
- `vocabTileMinWidth` (120) → `LangwijLayout.vocabTileMinWidth`
- `vocabTileGap` (12) → `FlesselLayout.gapM`

**Caller edit — `vocab_deck_list_screen.dart`**:

- Import: `vocab_level_card.dart` → `langwij_vocab_level_card.dart`.
- Lines 148-167: **delete the `Padding(bottom: VesselLayout.vocabLevelCardBottomGap)` wrapper entirely**. Return `LangwijVocabLevelCard(...)` directly from `itemBuilder`.
- `VocabLevelCard` → `LangwijVocabLevelCard`. Props unchanged.

**Vessel retirement scope (same commit)**:

- Delete `front/lib/features/vocab/widgets/vocab_level_card.dart`.
- 8 VesselLayout constants retire: `vocabLevelCardPadding`, `vocabLevelCardBottomGap`, `vocabHeaderToProgressGap`, `vocabProgressPercentGap`, `vocabDescSpacingAfter`, `vocabTilesToStatsGap`, `vocabProgressSpacingAfter`, `vocabProgressWordsWidth`, `vocabProgressPercentWidth`. (9 total — 6 retire outright, 3 move to LangwijLayout.)
- 3 VesselFonts aliases retire: `textLevelHeader`, `textLevelCounter`, `textCaption` (textCaption may still have other consumers — check at execution time; if shared, it retires only when last consumer migrates).

**Execution scope (Phase 3)**:

1. Create `front/lib/features/vocab/widgets/langwij_vocab_level_card.dart`. Class `LangwijVocabLevelCard extends StatelessWidget`, same 5 props. Build: `FlesselCard` → `Column(crossAxisAlignment: start)` → `GestureDetector(onTap: onToggle)` wrapping header section (name Row with optional lock icon + `FlesselGap.s()` + progress Row with `FlesselProgressBar(detailed)`) + conditional expanded body (`FlesselGap` spacers + optional description + `LayoutBuilder` → `Wrap` of `LangwijVocabDeckTile` children + `FlesselGap.l()` + `LangwijVocabLevelStatsRow`).
2. Add 3 constants to `LangwijLayout` (`vocabProgressSpacingAfter`, `vocabProgressWordsWidth`, `vocabProgressPercentWidth`).
3. Edit `vocab_deck_list_screen.dart`: import rename, delete Padding wrapper, class rename.
4. Delete `vocab_level_card.dart`.
5. Retire vessel constants/fonts listed above.

**Dependencies**: rows 46 (`LangwijVocabDeckTile`) and 48 (`LangwijVocabLevelStatsRow`) must execute first — row 47 imports both.

**Nine-area audit verdict**:

- **1 Theme**: pass — `textPrimary`, `textSecondary` direct, no new fields needed.
- **2 Fonts**: pass — 1 accepted snap (D1 displayXl), 2 exact matches (contentBodyAccent, contentCaption).
- **3 Layout**: pass — 4 to FlesselGap, 3 new LangwijLayout, 2 reuse row 46, 2 retire outright.
- **4 Controls**: pass — `FlesselCard`, `FlesselProgressBar`, `LangwijVocabDeckTile` (row 46), `LangwijVocabLevelStatsRow` (row 48). Raw `GestureDetector`/`Icon`/`Wrap`/`LayoutBuilder` composition inside composite.
- **5 Copy**: pass — `l10n` passed through to child widgets.
- **6 Architecture**: pass — stateless, `isExpanded` driven by screen's `levelFoldOverridesProvider`.
- **7 Flessel boundary**: pass.
- **8 Quality gate**: pass — lock icon `size: 16` fixed to `FlesselLayout.iconS`.
- **9 State ownership**: n/a — stateless, expand/collapse state owned by screen.

- **Status**: `DONE`

### 48. VocabLevelStatsRow

- **Location**: `front/lib/features/vocab/widgets/vocab_level_stats_row.dart`
- **Base**: `StatelessWidget`
- **Props (preserved)**: `item: VocabLevelData`, `l10n: AppLocalizations`
- **Domain model**: `VocabLevelData` (stays in `vocab_deck_tile_data.dart`, shared with rows 46-47)
- **Call-site audit**: 1/1 production caller inside `VocabLevelCard` expanded body (row 47). All 2 props used.
- **Decision**: `LANGWIJ_COMPOSITE`
- **Target**: `front/lib/features/vocab/widgets/langwij_vocab_level_stats_row.dart`
- **Rename**: `VocabLevelStatsRow` → `LangwijVocabLevelStatsRow`

**Primitive mapping**:

| Source | Flessel | Notes |
|---|---|---|
| Container outline date badge | `FlesselTag(label: dateText)` | No color. Visual regression accepted — loses `cardBackground` fill, becomes neutral tag. |
| Container filled retention badge | `FlesselTag(label: levelLabel)` | No color. Visual regression accepted — retention color coding deferred. |
| `SizedBox(width: chipSpacing=4)` | `FlesselGap.xs()` | Between the two tags. |
| `VesselAccentButton(label, null, small, margin: zero)` | `FlesselAccentButton(label, null, FlesselSize.s, margin: EdgeInsets.zero)` | Size: small→s. |
| `VesselFonts.textProgressChip` (Montserrat 11/bold) | Not referenced | `FlesselTag` owns its font internally. |
| `t.textPrimary/cardBackground/cardBorderWidth/badgeBorderRadius` | Not referenced | `FlesselTag` owns its theming internally. |
| `t.retentionNone/Weak/Good/Strong/retentionText` | **DEFERRED** | Retention color fields added to `FlesselThemeData` in a future row. Badges render as neutral `FlesselTag` until then. |
| `retentionColor(level, t)` | Dropped | No colors for now. |
| `retentionLabel(level, l10n)` | Inlined private helper | 4-case switch on `RetentionLevel` → `l10n` strings. Drops screen→feature import. |
| `formatRelativeDate(date, l10n)` | Keep import from `group_list_screen.dart` | Signature `(DateTime, AppLocalizations)` — no `VesselThemeData` dependency. Layer violation (feature importing screen) noted but out of row 48 scope. |
| `chipPaddingH/V` (6/4) | Not referenced | `FlesselTag` owns its internal padding via `FlesselLayout.chipPaddingH`. |

**Deferred: retention color grow**

5 vessel theme fields (`retentionNone/Weak/Good/Strong`, `retentionText`) will become flessel grow proposals with generic status-level names when retention coloring is revisited. 3 consumers across the app (group_list_screen, agreement_group_list_screen, this widget) will adopt the new fields at that time. For now, both badges render as plain neutral `FlesselTag`.

**Execution scope (Phase 3)**:

1. Create `front/lib/features/vocab/widgets/langwij_vocab_level_stats_row.dart`. Class `LangwijVocabLevelStatsRow extends StatelessWidget`, same 2 props. Build: `Row` → `FlesselTag(label: dateText)` + `FlesselGap.xs()` + `FlesselTag(label: levelLabel)` + `Spacer()` + `FlesselAccentButton(label: l10n.vocab_train, onPressed: null, size: FlesselSize.s, margin: EdgeInsets.zero)`. Private `_retentionLabel(RetentionLevel, AppLocalizations)` helper inlined.
2. Delete `front/lib/features/vocab/widgets/vocab_level_stats_row.dart`.
3. No separate caller edit — sole caller is `VocabLevelCard` (row 47), which migrates to `LangwijVocabLevelCard` and references `LangwijVocabLevelStatsRow` directly.

**Vessel retirement scope (same commit)**:

- Delete `vocab_level_stats_row.dart`.
- No VesselLayout constants retire from row 48 specifically (`chipPaddingH/V/chipSpacing` still used by other consumers).
- `VesselFonts.textProgressChip` — no longer referenced by this widget (check for other consumers at execution time).

**Dependencies**: row 47 imports row 48. No flessel grow required — uses existing `FlesselTag` + `FlesselAccentButton`.

**Nine-area audit verdict**:

- **1 Theme**: pass — no direct theme reads. Retention colors deferred, tracked.
- **2 Fonts**: pass — no direct font reads. `FlesselTag`/`FlesselAccentButton` own theirs.
- **3 Layout**: pass — `FlesselGap.xs()` only.
- **4 Controls**: pass — `FlesselTag` x2 + `FlesselAccentButton`.
- **5 Copy**: pass — `l10n.vocab_train` + 4 `l10n.retention*` strings via inlined helper.
- **6 Architecture**: pass — stateless, pure. `formatRelativeDate` screen-import noted.
- **7 Flessel boundary**: pass.
- **8 Quality gate**: pass — no antipatterns.
- **9 State ownership**: n/a.

- **Status**: `DONE`

---

## Location question for LANGWIJ_COMPOSITE widgets

There are two candidate locations for `Langwij*` widgets in `front/lib/`:

- **(A)** Keep the existing structure: shared composites under `front/lib/shared/ui/langwij_*.dart`, feature composites under `front/lib/features/<feature>/widgets/langwij_*.dart`
- **(B)** Create a dedicated `front/lib/shared/langwij/` directory for all langwij composites (feature-local composites still under `features/<feature>/widgets/`)
- **(C)** Follow the old vessel organization (`shared/ui/tag/`, `shared/ui/card/`, etc.) but with `langwij_*.dart` file names — e.g. `shared/ui/tag/langwij_tag_chip.dart`

My recommendation: **(A)** for minimal disruption — the existing `shared/ui/` structure is clean and the file renames from `vessel_*.dart` to `langwij_*.dart` are straightforward. Meatbag picks at execution time.

## Theme / fonts / layout notes

Per the Phase 0 Q13 resolution: theme properties, font styles, and layout constants are **not** pre-matrix'd upfront. They surface **per-widget during execution**. When a widget migration touches a theme prop or layout constant that flessel lacks or that has no obvious mapping, that moment is when the proposal + approval happens.

Known rough counts (for awareness, not commitment):

- **VesselThemeData → FlesselThemeData**: approximately 60 generic props map 1:1 (colors, borders, backgrounds). Approximately 140 product-specific props (Badge, DeckIcon, RoundAnswerTile, TestBadge, Retention, 5-color Tag palette, Toggle sections) need disposition per-property when their consuming widget is migrated. Expected disposition mix: GROW_FLESSEL for generic additions (success color, tristate color), derivation from existing flessel props where possible, deletion where the current usage is vestigial.
- **VesselFonts → FlesselFonts**: approximately 30 named styles. Product-specific names like `textAppBarTitle`, `textTileHeader`, `textLevelHeader` map to closest `FlesselFonts` tier (content/controls/display). No AppFonts layer; call sites reference `FlesselFonts.*` directly.
- **VesselLayout → FlesselLayout (or LangwijLayout)**: approximately 50 constants. Generic ones (`gapXxs..gapXxl`, `screenPadding`, `listItemGap`) map directly to `FlesselLayout`. Product-specific ones (`vocabTileHeight`, `langFlagWidth`, `roundOptionTileAspectRatio`) get per-constant disposition via the layout policy in `MIGRATION_PLAN.md`.

## Execution order (recommended)

When Phase 3 starts, dependency order for migration:

1. **Primitives first** (no dependents): Gap, Divider, Snackbar, ProgressBar, Note, Tile, Checkbox, Switch, Radio tile, Labeled toggles
2. **Buttons**: all 6 variants + ProjectButtonGroup
3. **Inputs with EXTEND_FLESSEL needs**: TextInput, SliderInput, TimeSlider, DatePicker, HourPicker
4. **Cards**: Card (with EXTEND_FLESSEL), AttentionCard
5. **Scaffold + Navbar**: Scaffold, NavBar (LANGWIJ_COMPOSITE), NavBarIcon
6. **Tags**: Chip, ColorPreview, Label (all LANGWIJ_COMPOSITE)
7. **Bottom sheets**: showVesselBottomSheet (EXTEND), showBugReportSheet, showModeBottomSheet
8. **Lang button**: ~~LangButton~~ (row 27 DELETE — zero call sites, no migration work)
9. **Feature composites**: VocabDailyActivityCard, VocabDeckTile, VocabLevelCard, VocabLevelStatsRow
10. **Text/header**: VesselHeader (DELETE)
11. **Answer tile**: VesselAnswerTile
12. **InputRow**: VesselInputRow (DELETE)
13. **Support classes**: all DELETE items

---

End of matrix. Awaiting per-row approvals.
