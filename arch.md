## Langwij app Stack
- Language: Dart
- Framework: Flutter
- State management: Riverpod (flutter_riverpod)
- Persistence: SQLite via sqflite (structured data)
- Error reporting: Cresset (cressetRecordError) — not yet integrated, pending adoption
- Navigation: GoRouter (go_router)
- Localization: Flutter gen-l10n (AppLocalizations)
- UI library: Flessel (internal design system)
- Static analysis: `flutter analyze`, not `dart analyze`

## Architecture
Classel — see [classel.md](classel.md)
Project structure: [fsd-map.md](fsd-map.md) — the exact current structure of the project. Read it before navigating the codebase. Any structural change (file move, slice add/remove, directory rename) must be reflected there immediately.
Coding princips: [ruleset.md](ruleset.md)
Core rules: [meta.md](meta.md)

## Error handling strategy
- Services catch and log via debugPrint (pending Cresset adoption)
- User-facing errors surfaced via return values (bool success) and snackbar messages
- No project-wide Result type -- errors use a mix of return values and try/catch

## Localization
Source: `lib/l10n/app_en.arb` — the only file to edit.
Generated: `app_localizations.dart`, `app_localizations_en.dart` — same directory, never hand-edit.
Regeneration: automatic on build, hot reload, hot restart (`generate: true` in pubspec).
Access: `final l10n = AppLocalizations.of(context)!;`
Workflow: edit `app_en.arb` → hot reload picks it up. No manual `flutter gen-l10n`. Never touch generated files.

## Language system

Three-layer language config: target (being learned), native (for definitions), UI (interface). Persisted in SQLite via `LanguageSettingsRepository`, exposed reactively through `ConfigService.languageSettings`.

Language packs loaded from `assets/data/translations/{code}.json`. Each pack contains translations as `LangEntry` — a sealed hierarchy: `SimpleEntry` (text + optional gender), `AspectPairEntry` (imperfective/perfective, Serbian only), `AdjectiveEntry` (gender variants). Structure enforced per language by `LangGrammarProfile` (e.g. Serbian: hasNeuter + hasAspectPairs; German: hasNeuter only).

Validation at two stages:
- **Startup** (`StartupValidator`): confirms target + native language files exist and parse.
- **On demand** (`ConfigValidator`): full structural audit — dictionary terms have `pos` field, translation keys match dictionary, entry structure matches grammar profile, plan.json integrity (no duplicate codes, all labelKeys present).

Extension: `app_localizations_ext.dart` — bridges data-driven label keys to gen-l10n. `plan.json` stores compact string keys (`"lang_english"`, `"groupEndingsImEAti"`); this extension resolves them to localized getters at runtime. `langLabel()` throws on unknown key (missing language = bug). `groupLabel()` returns raw key on miss (groups vary by language pack). New language or group: add ARB entry + case here.

