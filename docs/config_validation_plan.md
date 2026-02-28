# Config Validation + String Safety Plan

## Status: IMPLEMENTED

---

## Why this exists

Config files cross-reference each other. Typos silently break the app.
The requirement: ANY bad value in ANY config file crashes the app at startup
with a message naming the exact file, field, and bad value.
Not at use time. Not generic. At STARTUP.

---

## Config files and their cross-references

```
assets/data/dictionary.json
  └─ concepts[concept_id].pos — must be one of: verb, noun, adjective, other
       ├─ concept IDs referenced by: levels.json → groups[*].concepts[*]
       └─ concept IDs referenced by: translations/*.json → top-level keys

assets/data/levels.json
  ├─ groups[*].id — unique group IDs
  │    ├─ referenced by: levels.json → levels[*].groups[*]
  │    └─ referenced by: translations/*.json → meta.groups[key]
  └─ levels[*].id — unique level IDs
       ├─ referenced by: plan.json → courses[*].free[*]
       └─ referenced by: translations/*.json → meta.levels[key]

assets/data/translations/{code}.json (en, sr, ru, ...)
  ├─ top-level keys → must exist in dictionary.json concepts
  ├─ meta.levels[key] → key must exist in levels.json levels
  └─ meta.groups[key] → key must exist in levels.json groups

assets/data/plan.json
  ├─ languages[*].code → must have matching assets/data/translations/{code}.json
  ├─ languages[*].labelKey → ARB key (lang_english, lang_serbian, lang_russian, ...)
  ├─ public_languages[*] → must exist in languages[*].code
  ├─ ui_languages[*] → must exist in languages[*].code
  └─ courses[*].free[*] → must exist in levels.json levels[*].id
```

---

## Translation entry types (discriminated by key presence)

```
AspectPairEntry: has "imperfective" OR "perfective" key present
  required: imperfective (string), perfective (string)
  optional: note (string)

AdjectiveEntry: has "m" OR "f" OR "n" key present
  required: m (string), f (string), n (string)
  optional: note (string)

SimpleEntry: everything else
  required: text (string)
  optional: gender (string), note (string)
```

---

## Requirements

- **R1** — Any config typo = crash at startup with exact file + field + bad value
- **R2** — Language registry in one place (plan.json). Currently split between `_languagePacks` map in `dictionary_repository.dart` and `plan.json`.
- **R3** — No duplicate `_langLabel()` logic in screens. Currently identical function in `language_screen.dart` AND `settings_screen.dart`, both with silent `default: return labelKey` fallback.
- **R4** — DB identifiers as typed constants. Currently 50+ raw strings scattered across 6 repositories.
- **R5** — Language code string literals (`'en'`, `'sr'`, `'ru'`) eliminated from Dart code.

---

## Phase 1 — LangCodes constants (R5)

**New file**: `lib/entities/language/lang_codes.dart`

```dart
abstract final class LangCodes {
  static const String english = 'en';
  static const String serbian = 'sr';
  static const String russian = 'ru';
}
```

**Modified files**:
- `lib/entities/language/language_settings.dart` — `defaultSettings` uses `LangCodes.*`
- `lib/app/providers/database_provider.dart` — seed INSERTs use `LangCodes.*`
- `lib/pages/tools_screen.dart` — `if (langCode == LangCodes.serbian)`

No dependencies. Zero risk.

---

## Phase 2 — DbSchema constants (R4)

**New file**: `lib/shared/repositories/db_schema.dart`

```dart
abstract final class DbSchema {
  static const String tableAppSettings    = 'app_settings';
  static const String tableGroupProgress  = 'group_progress';
  static const String tableSessionRecords = 'session_records';
  static const String tableDailyActivity  = 'daily_activity';
  static const String tableLanguageStats  = 'language_stats';

  static const String colKey                 = 'key';
  static const String colValue               = 'value';
  static const String colTargetLang          = 'target_lang';
  static const String colGroupId             = 'group_id';
  static const String colDate                = 'date';
  static const String colScore               = 'score';
  static const String colMode                = 'mode';
  static const String colCorrect             = 'correct';
  static const String colWrong               = 'wrong';
  static const String colWordIds             = 'word_ids';
  static const String colTargetShownProgress = 'target_shown_progress';
  static const String colNativeShownProgress = 'native_shown_progress';
  static const String colWriteProgress       = 'write_progress';
  static const String colPeakRetention       = 'peak_retention';
  static const String colLastSessionDate     = 'last_session_date';
  static const String colConceptsTouchedIds  = 'concepts_touched_ids';
  static const String colPercentage          = 'percentage';
}
```

**Modified files**:
- `lib/app/providers/database_provider.dart` — CREATE TABLE DDL uses string interpolation with `DbSchema.*`
- `lib/shared/repositories/language_settings_repository.dart`
- `lib/shared/repositories/group_progress_repository.dart`
- `lib/shared/repositories/language_stats_repository.dart`
- `lib/shared/repositories/daily_activity_repository.dart`
- `lib/shared/repositories/app_settings_repository.dart`

No dependencies. Zero risk.

---

## Phase 3 — Language registry into plan.json (R2)

### Current problem

Language registry is split across three places:
1. `_languagePacks` map in `dictionary_repository.dart` — compile-time, maps code → labelKey
2. `availableUiLanguages` list in `dictionary_repository.dart` — compile-time
3. `public_languages` in `plan.json` — runtime

### New plan.json structure

```json
{
  "languages": [
    { "code": "en", "labelKey": "lang_english" },
    { "code": "sr", "labelKey": "lang_serbian" },
    { "code": "ru", "labelKey": "lang_russian" }
  ],
  "public_languages": ["en", "sr"],
  "ui_languages": ["en"],
  "courses": {
    "sr→en": { "free": ["survival"] },
    "sr→ru": { "free": ["survival"] }
  }
}
```

**BREAKING CHANGE**: courses moved under `"courses"` key (previously top-level entries).
`PlanRepository._load()` must be updated to parse `data['courses']` instead of iterating all keys.

### New file: `lib/entities/plan/language_entry.dart`

```dart
class LanguageEntry {
  const LanguageEntry({ required this.code, required this.labelKey });
  final String code;
  final String labelKey;
}
```

### Modified: `lib/shared/repositories/plan_repository.dart`
- Parse new structure (languages, public_languages, ui_languages, courses)
- Add `getLanguages()` → `Future<List<LanguageEntry>>`
- Add `getUiLanguages()` → `Future<Set<String>>`
- Courses now parsed from `data['courses']` not top-level entries

### Modified: `lib/shared/repositories/dictionary_repository.dart`
- REMOVE `_languagePacks` map
- REMOVE `availableUiLanguages` constant
- REMOVE `availableLanguages` getter
- `loadLanguagePack()` receives `labelKey` from caller (via `LanguageEntry`), does not look it up internally
- If called with unregistered code: `throw StateError('Unknown language code "$code"')` — belt-and-suspenders, validator catches this at startup first

### Modified: `lib/app/providers/dictionary_provider.dart`
- `allPacksProvider` reads language list from `planRepositoryProvider`, not from repository internals

### Modified: `lib/pages/settings_screen.dart`
- Replace `availableUiLanguages` import with plan provider data

---

## Phase 4 — Kill _langLabel() switches (R3)

### Current problem

`language_screen.dart` and `settings_screen.dart` both contain:
```dart
String _langLabel(AppLocalizations l10n, String labelKey) {
  switch (labelKey) {
    case 'lang_english': return l10n.lang_english;
    case 'lang_serbian': return l10n.lang_serbian;
    case 'lang_russian': return l10n.lang_russian;
    default: return labelKey; // SILENT — displays raw string
  }
}
```

Also both have `pack?.labelKey ?? 'lang_$code'` fallback that silently constructs fake keys.

### New file: `lib/l10n/app_localizations_ext.dart`

```dart
extension AppLocalizationsLangLabel on AppLocalizations {
  String langLabel(String labelKey) {
    switch (labelKey) {
      case 'lang_english': return lang_english;
      case 'lang_serbian': return lang_serbian;
      case 'lang_russian': return lang_russian;
      default: throw ArgumentError(
        'langLabel: unknown labelKey "$labelKey" — add it to app_en.arb and this extension',
      );
    }
  }
}
```

Unknown label key = crash at the point the button renders. Not a silent raw string.
When adding a new language: add ARB key + add case here. Forgetting = visible crash.

### Modified: `lib/pages/language_screen.dart`
- Delete `_langLabel()` function
- Use `l10n.langLabel(pack.labelKey)` everywhere
- Remove `?? 'lang_$code'` fallbacks — after Phase 3, `allPacksProvider` always loads every registered language, so `packByCode[code]` is never null. If it is null, throw.

### Modified: `lib/pages/settings_screen.dart`
- Same changes as language_screen.dart

---

## Phase 5 — ConfigValidator + startup wiring (R1) ← THE CORE

This is what makes the system bulletproof. Everything else is prep.

### ConfigValidationError

```dart
class ConfigValidationError implements Exception {
  const ConfigValidationError(this.message);
  final String message;
  @override
  String toString() => 'ConfigValidationError: $message';
}
```

### ConfigValidator

**New file**: `lib/shared/validators/config_validator.dart`

Static method `validateAll()` takes all raw decoded JSON maps and validates every
field and every cross-reference. Throws `ConfigValidationError` with exact file,
field path, and bad value on any issue.

#### dictionary.json validation
- `concepts` key exists and is a Map
- Each concept entry: `pos` field exists, value is one of `{'verb', 'noun', 'adjective', 'other'}`
- Outputs: `Set<String> conceptIds`

Error format examples:
```
dictionary.json: missing required key "concepts"
dictionary.json: concept "eat_vrb" missing required field "pos"
dictionary.json: concept "buy" has invalid pos "vreb". Allowed: verb, noun, adjective, other
```

#### levels.json validation
- `groups` key exists and is a List
- Each group: `id` (string, non-duplicate), `concepts` (list) — every ID must exist in conceptIds
- `levels` key exists and is a List
- Each level: `id` (string, non-duplicate), `groups` (list) — every ID must exist in groupIds
- Outputs: `Set<String> groupIds`, `Set<String> levelIds`

Error format examples:
```
levels.json: missing required key "groups"
levels.json: groups[3] missing required field "id"
levels.json: duplicate group id "daily_routines"
levels.json: group "daily_routines".concepts[2] = "wak_up" does not exist in dictionary.json
levels.json: level "foundation".groups[1] = "dailly_life" does not exist in groups
```

#### plan.json validation
- `languages` key exists and is a List
- Each entry: `code` (string) and `labelKey` (string) both present
- `public_languages` exists — every code must be in declared language codes
- `ui_languages` exists — every code must be in declared language codes
- `courses` key exists and is a Map
- Each course: `free` key exists and is a List — every level ID must exist in levelIds
- NOTE: language code → translation file check happens in StartupValidator (file load step),
  not here. ConfigValidator only works with already-loaded maps.

Error format examples:
```
plan.json: missing required key "languages"
plan.json: languages[2] missing required field "code"
plan.json: public_languages[1] = "de" not declared in languages
plan.json: ui_languages[0] = "fr" not declared in languages
plan.json: courses."sr→en" missing required key "free"
plan.json: courses."sr→en".free[0] = "surrvival" does not exist in levels.json
```

#### Translation file validation (per language code)
- Each non-`meta` key: must exist in conceptIds
- Each entry value: detect type by key presence, validate required fields:
  - Has `imperfective` or `perfective` → AspectPairEntry: both required
  - Has `m`, `f`, or `n` → AdjectiveEntry: all three required
  - Otherwise → SimpleEntry: `text` required
- `meta.levels[key]`: key must exist in levelIds, entry must have `name` field
- `meta.groups[key]`: key must exist in groupIds, entry must have `name` field

Error format examples:
```
translations/sr.json: key "eat_vrb" does not exist in dictionary.json
translations/sr.json: "jesti" has "imperfective" but missing "perfective"
translations/sr.json: "perective" key is unknown — did you mean "perfective"? (optional nice-to-have)
translations/sr.json: "lep" (adjective) missing required field "f"
translations/sr.json: "hello" (simple) missing required field "text"
translations/sr.json: meta.levels["surrvival"] does not exist in levels.json
translations/sr.json: meta.groups["daily_routins"] missing required field "name"
```

### StartupValidator

**New file**: `lib/shared/validators/startup_validator.dart`

Execution order:
1. Load `assets/data/plan.json`
2. Fail-fast: extract `languages[]` array — throw `ConfigValidationError` if missing
3. Extract language codes from `languages[*].code`
4. Load `assets/data/dictionary.json`
5. Load `assets/data/levels.json`
6. For each language code: load `assets/data/translations/{code}.json`
   - If file not found: throw `ConfigValidationError('plan.json declares language "$code" but assets/data/translations/$code.json was not found')`
7. Call `ConfigValidator.validateAll(planData, dictData, levelsData, translationsByCode)`

### main.dart wiring

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StartupValidator.validate(); // bad config = throw here, runApp never called
  runApp(const ProviderScope(child: App()));
}
```

Bad config → Flutter error handler shows full exception on screen in debug (red screen).
App never reaches any navigator or screen. Never silently broken.

---

## Hot restart failure examples (what the user sees)

| Typo | Error shown |
|------|-------------|
| `"rus"` instead of `"ru"` in plan.json languages | `plan.json declares language "rus" but assets/data/translations/rus.json was not found` |
| `"surrvival"` in plan.json courses.free | `plan.json: courses."sr→en".free[0] = "surrvival" does not exist in levels.json` |
| `"eat_vrb"` as key in sr.json | `translations/sr.json: key "eat_vrb" does not exist in dictionary.json` |
| `"perective"` instead of `"perfective"` in sr.json | `translations/sr.json: "jesti" has "imperfective" but missing "perfective"` |
| Missing `pos` in dictionary.json | `dictionary.json: concept "buy" missing required field "pos"` |
| `"vreb"` as pos value | `dictionary.json: concept "buy" has invalid pos "vreb". Allowed: verb, noun, adjective, other` |
| Level ID typo in meta | `translations/sr.json: meta.levels["surrvival"] does not exist in levels.json` |

---

## Execution order

| Phase | Depends on | Risk |
|-------|-----------|------|
| 1 — LangCodes | nothing | zero |
| 2 — DbSchema | nothing | zero |
| 3 — Language registry | nothing | medium (plan.json breaking change) |
| 4 — Kill _langLabel() | Phase 3 | low |
| 5 — ConfigValidator | Phase 3 | low (new code only) |

Phases 1 and 2 are independent, can be done in parallel.
Phases 3 → 4 → 5 must be done in order.

---

## All files touched

### New files
- `lib/entities/language/lang_codes.dart`
- `lib/shared/repositories/db_schema.dart`
- `lib/entities/plan/language_entry.dart`
- `lib/l10n/app_localizations_ext.dart`
- `lib/shared/validators/config_validator.dart`
- `lib/shared/validators/startup_validator.dart`

### Modified files
- `assets/data/plan.json` — new structure (languages, ui_languages, courses key)
- `lib/main.dart` — call StartupValidator.validate() before runApp
- `lib/entities/language/language_settings.dart` — LangCodes defaults
- `lib/app/providers/database_provider.dart` — DbSchema + LangCodes
- `lib/pages/tools_screen.dart` — LangCodes.serbian
- `lib/shared/repositories/language_settings_repository.dart` — DbSchema
- `lib/shared/repositories/group_progress_repository.dart` — DbSchema
- `lib/shared/repositories/language_stats_repository.dart` — DbSchema
- `lib/shared/repositories/daily_activity_repository.dart` — DbSchema
- `lib/shared/repositories/app_settings_repository.dart` — DbSchema
- `lib/shared/repositories/plan_repository.dart` — new plan.json structure
- `lib/shared/repositories/dictionary_repository.dart` — remove _languagePacks, availableUiLanguages
- `lib/app/providers/dictionary_provider.dart` — language list from plan
- `lib/pages/language_screen.dart` — kill _langLabel(), use extension
- `lib/pages/settings_screen.dart` — kill _langLabel(), use extension, use plan for ui_languages
