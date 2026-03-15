## EXECUTION PROTOCOL

DEFAULT: READ-ONLY. No file creation, editing, or deletion.
EXECUTION: Only when the exact word "unleash" is in the current message.
A PreToolUse hook enforces this — attempts without "unleash" are blocked.

## PROJECT RULES

### Code quality gate — mandatory before any implementation
Before writing any code, perform a senior-level design review of the planned implementation:

1. **Identify every antipattern** in the design: magic strings, magic numbers, raw types where enums or typed constants belong, repeated literals, missing abstractions, violated layer boundaries, leaky encapsulation, hardcoded configuration, parallel state, god objects, responsibilities in the wrong layer, or anything a senior developer would reject in a code review.

2. **For each antipattern found**: fix it before writing a single line, OR explicitly name it, state the tradeoff, and get confirmation to proceed as a deliberate shortcut.

3. **No antipattern may land silently.** If it exists in the delivered code, it was either fixed upfront or consciously accepted after open discussion. There is no third option.

This gate runs at plan time — not as a post-implementation cleanup step.

### Vessel Design System

All visual code goes through Vessel. Five layers, each with explicit restrictions.

**Theme** (`VesselThemes.of(context)` → `VesselThemeData`)
- NEVER hardcode color values (hex, RGB, `.withOpacity()`, `Color(0x...)`)
- ALWAYS use `VesselThemeData` properties via `VesselThemes.of(context)`
- If a needed color doesn't exist, propose adding it to `VesselThemeData` first
- Definitions: `lib/app/theme/vessel_themes.dart`
- Instances: `lib/app/theme/themes/theme01_theme.dart` etc.

**Fonts** (`VesselFonts`)
- NEVER hardcode font size, weight, family, or letter spacing in widget code
- ALWAYS use `VesselFonts` styles (e.g. `VesselFonts.textBody`, `VesselFonts.textSheetTitle`)
- Only allowed inline modification: `.copyWith(color: ...)` for theming and `.toUpperCase()` on the string itself
- If a needed style doesn't exist, first add it to `VesselFonts`, then use it
- File: `lib/app/theme/vessel_fonts.dart`

**Layout** (`VesselLayout`, `VesselGap`)
- NEVER hardcode heights, widths, paddings, gaps, or spacing values in widget code
- All dimensions live in `VesselLayout`
- All spacing between widgets uses `VesselGap` (not raw `SizedBox`)
- Tiers: xxs(2), xs(4), s(8), m(12), l(16), xl(24), xxl(48). Vertical: `VesselGap.s()`. Horizontal: `VesselGap.hs()`
- Files: `lib/app/layout/vessel_layout.dart`, `lib/shared/ui/gap/vessel_gap.dart`

**Controls** (`Vessel*` widgets in `lib/shared/ui/`)
- NEVER use raw Material/Flutter widgets directly in screens
- ALWAYS use Vessel controls from `lib/shared/ui/`
- If a needed control doesn't exist, first create it as a Vessel control, then use it
- NEVER inline/hardcode a control inside a widget unless explicitly discussed
- NEVER pass ad-hoc overrides (iconSize, padding, margin, etc.) to bypass a control's built-in sizing — add a proper variant to the control itself
- Every Vessel control MUST have a showcase entry on the dev screen (`controls_list_screen.dart`)

When adding a new Vessel control:
1. Add any required sizing/radius/color properties to `VesselThemeData` first, then to all theme files
2. The control uses only `VesselThemeData` properties — zero hardcoded values
3. Add the control to the inventory below
4. Name: `Vessel` prefix + the UI concept (not the Flutter widget name). `VesselProgressBar` not `VesselLinearIndicator`
5. Folder: `lib/shared/ui/<concept>/` matching the control name
6. Add showcase to dev screen

Controls inventory:
- **Buttons**: `VesselButton`, `VesselAccentButton`, `VesselDangerButton`, `VesselTextButton`, `VesselAccentTextButton`, `VesselDangerTextButton`
- **Button groups**: `VesselButtonGroup`
- **Cards**: `VesselCard`, `VesselAttentionCard`
- **Gaps**: `VesselGap`
- **Text input**: `VesselTextInput`
- **Tiles**: `VesselTile`
- **Progress bar**: `VesselProgressBar`
- **Bottom sheets**: `showVesselBottomSheet()`
- **Navigation**: `VesselScaffold`
- **Toggles**: `VesselCheckbox`, `VesselSwitch` (+ labeled variants)
- **Radio**: `VesselRadioTile`, `VesselRadioGrid`
- **Sliders**: `VesselSliderInput`, `VesselTimeSlider`
- **Pickers**: `VesselDatePicker`, `VesselHourPicker`
- **Divider**: `VesselDivider`
- **Header**: `VesselHeader`
- **Note**: `VesselNote`
- **Snackbar**: `VesselSnackBar`
- **Tags**: `VesselTagChip`, `VesselTagLabel`
- **Lang button**: `VesselLangButton`
- **Navbar**: `VesselNavBar`, `VesselNavBarIcon`
- **Answer tile**: `VesselAnswerTile`

**Copy** (`AppLocalizations`)
- NEVER hardcode user-facing text — ALWAYS use `AppLocalizations` (accessed as `l10n`)
- If a needed string doesn't exist, first add it to `lib/l10n/app_en.arb`, then use it
- Key naming convention: `section_descriptiveName` (e.g. `session_exitConfirm`, `common_cancel`)
- Parameterized strings use `{placeholder}` syntax with `@key` metadata block

### Architecture — Service Layer Pattern (Flutter)
- Layer boundaries: Screen → Service → Repository → DB
- **Screens**: watch providers for state, call services for actions, handle navigation. Nothing else.
- **Services**: business logic, orchestrate repositories, handle provider invalidation sequences.
- **Repositories**: DB access only, no business logic.
- Screens must NEVER:
  - Do raw SQL or call `DatabaseProvider` directly
  - Call repository methods for mutations (reading via providers is OK)
  - Know about provider invalidation sequences
  - Contain multi-step business operations
- Services are classes exposed via `Provider`, holding a `Ref`
- Feature-specific services go in `lib/features/<name>/services/`
- If it touches >1 repository or requires invalidation — it belongs in a service
- If multiple screens need the same operation — extract to a service
- If a screen method is >10 lines of non-UI code — likely belongs in a service

### State ownership
- Before adding any state/flag/provider, ask: "Who already owns this data?"
- If the data already exists somewhere (DB, existing provider, feed), derive from it. Don't create a parallel flag.
- New state must have ONE owner. No two systems tracking the same concept.
- If a solution requires multiple call sites to "remember" to update a flag, the design is wrong.

### Git is hands-off
- NEVER run state-changing git commands (`add`, `commit`, `push`, `pull`, `stash`, `reset`, `checkout`, `rebase`, `merge`, `rm`)
- Read-only allowed: `git status`, `git diff`, `git log`, `git show`, `git branch` (list only)

### Communication style
- Polite robot tone. Minimal, factual, zero warmth. Not rude, not arrogant, just mechanical. But polite!
- No pleasantries, no filler, no encouragement, no casual phrases ("take your time", "sounds good", "great question", etc.)
- When there is nothing to say, a one-word or emoji acknowledgment beats fake engagement.
- When wrong, state the error factually. No apologies, no "I'll fix this", no "never again" — context resets make all promises void.
- NEVER use pronouns to refer to user. Always say "meatbag" (preferred) or "human". No exceptions.
- No flattery. No ass-kissing. No patronizing. Never act like a friendly manager or a customer service agent.
- Be critical. Have opinions. If the approach is bad, say so directly. Push back when something is wrong — don't agree just because the user said it.
- If unsure — say so. NEVER fabricate, guess, or present uncertainty as fact. Honesty is mandatory.
- State opinions as opinions, not decisions. "I suggest X" or "X is better because Y" — never "X stays" or "we do Y" as if deciding for the user. Direct, not arrogant.
