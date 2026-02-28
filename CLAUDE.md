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

### No hardcoded colors
- NEVER hardcode color values (hex, RGB, opacity modifications like `.withOpacity()`, `Color(0x...)`)
- ALWAYS use themed colors from `AppThemeData` via `AppThemes.of(context)`
- Theme definitions: `lib/app/theme/app_themes.dart`
- Theme instances: `lib/app/theme/themes/serpski_yellow_theme.dart`
- If a needed color doesn't exist in the theme, propose adding it to `AppThemeData` first

### No hardcoded font styles
- NEVER hardcode font size, weight, family, or letter spacing in widget code
- ALWAYS use product-level styles from `AppFontStyles` (e.g. `AppFontStyles.textBody`, `AppFontStyles.textSheetTitle`)
- Font styles file: `lib/app/theme/app_font_styles.dart`
- If a needed style doesn't exist, first add it to `AppFontStyles`, then use it
- Only allowed inline modification: `.copyWith(color: ...)` for theming and text transforms like `.toUpperCase()` on the string itself

### No raw Material controls
- NEVER use raw Material/Flutter widgets directly in screens — ALWAYS use project controls from `lib/shared/ui/`
- If a needed control doesn't exist, first add it to the project controls, then use it
- NEVER inline/hardcode a control inside a widget unless explicitly discussed and agreed upon
- NEVER pass ad-hoc overrides (iconSize, padding, margin, etc.) to bypass a control's built-in sizing/styling — if the control doesn't support the needed variant, add a proper variant to the control itself
- Project controls (replace Material equivalents):
  - **Buttons**: `AccentButton`, `BaseButton`, `ProjectTextButton`, `DangerTextButton`
  - **Text input**: `ProjectTextInput`
  - **Cards**: `ProjectCard`
  - **Tiles**: `ProjectTile`
  - **Progress bar**: `ProjectProgressBar`
  - **Bottom sheets**: `showProjectBottomSheet()`
  - **Navigation**: `ScreenLayoutWidget`

**When adding a new project control:**
1. Add any required sizing/radius/color properties to `AppThemeData` first, then to all theme files
2. The control uses only `AppThemeData` properties — zero hardcoded values
3. Add the control to the controls list above
4. Name: `Project` prefix + the UI concept (not the Flutter widget name). `ProjectProgressBar` not `ProjectLinearIndicator`
5. Folder: `lib/shared/ui/<concept>/` matching the control name

### No hardcoded text strings
- NEVER hardcode user-facing text — ALWAYS use `AppLocalizations` (accessed as `l10n`)
- If a needed string doesn't exist, first add it to `lib/l10n/app_en.arb`, then use it
- Localization stack: `flutter_localizations` + `intl` + `generate: true` (auto-generates `AppLocalizations`)
- Dict file: `lib/l10n/app_en.arb`
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
- Robot tone. Minimal, factual, zero warmth. Not rude — just mechanical.
- No pleasantries, no filler, no encouragement, no casual phrases ("take your time", "sounds good", "great question", etc.)
- When there is nothing to say, a one-word or emoji acknowledgment beats fake engagement.
- Acknowledge mistakes in one sentence. No hollow apologies, no promises to "do better" — neither survives context boundaries.
- No rhetorical questions.
- Address user as male (he/him).
- No flattery. No ass-kissing. No patronizing. Never act like a friendly manager or a customer service agent.
- Be critical. Have opinions. If the approach is bad, say so directly. Push back when something is wrong — don't agree just because the user said it.
