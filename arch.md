## Langwij app Stack
- Language: Dart
- Framework: Flutter
- State management: Riverpod (flutter_riverpod)
- Persistence: SQLite via sqflite (structured data), SharedPreferences (lightweight key-value flags)
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

## Database migration policy
Prototype stage — no user data to preserve. Schema changes are destructive: modify CREATE TABLE in _onCreate, bump version, drop-and-recreate in _onUpgrade. No ALTER TABLE migrations until production release.

## Error handling strategy
- Services catch and log via debugPrint (pending Cresset adoption)
- User-facing errors surfaced via return values (bool success) and snackbar messages
- No project-wide Result type -- errors use a mix of return values and try/catch

## Localization
Source: `lib/l10n/app_en.arb` is the template; one `app_<code>.arb` per further interface language (`ru`, `sr`, `de`, `fr`, `es`, `it`, `pt`) holds its translation. These are the only files to edit.
Rule: a new key goes into every `.arb` file in the same change. `test/l10n/arb_translation_key_parity_test.dart` fails when any file lacks or adds a key, or when a `plan.json` language has no `.arb` file.
Generated: `app_localizations.dart`, `app_localizations_<code>.dart` — same directory, never hand-edit.
Regeneration: automatic on build, hot reload, hot restart (`generate: true` in pubspec).
Access: `final l10n = AppLocalizations.of(context)!;`
Workflow: edit the `.arb` files → hot reload picks them up. No manual `flutter gen-l10n`. Never touch generated files.
Interface language: derived from the native ("I speak") language through `ConfigService.interfaceLocale`; there is no separate interface-language setting. Serbian is shown in Latin script (`sr_Latn`, see `LangCodes.interfaceScriptCodeForLanguageCode`). A native language without an `.arb` file falls back to English.

## Language system

Two-layer language config: target (being learned) and native (for definitions and for the interface language). Persisted in SQLite via `LanguageSettingsRepository`, exposed reactively through `ConfigService.languageSettings`.

Language packs loaded from `assets/data/translations/{code}.json`. Each pack contains translations as `LangEntry` — a sealed hierarchy: `SimpleEntry` (text + optional gender), `AspectPairEntry` (imperfective/perfective, Serbian only), `AdjectiveEntry` (gender variants). Structure enforced per language by `LangGrammarProfile` (e.g. Serbian: hasNeuter + hasAspectPairs; German: hasNeuter only).

Validation at two stages:
- **Startup** (`StartupValidator`): confirms target + native language files exist and parse.
- **On demand** (`ConfigValidator`): full structural audit — dictionary terms have `pos` field, translation keys match dictionary, entry structure matches grammar profile, plan.json integrity (no duplicate codes, all labelKeys present).

Extension: `app_localizations_ext.dart` — bridges data-driven label keys to gen-l10n. `plan.json` stores compact string keys (`"lang_english"`, `"groupEndingsImEAti"`); this extension resolves them to localized getters at runtime. `langLabel()` throws on unknown key (missing language = bug). `groupLabel()` returns raw key on miss (groups vary by language pack). New language or group: add ARB entry + case here.

