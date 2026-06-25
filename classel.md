# Classel Architecture

**Classel** — class-based, layered, composed. OOP-dominant architecture for Flutter + Riverpod, built on FSD (Feature-Sliced Design). Named for the core principle: classes are the unit of composition, visibility, and API surface.

---

## Core Principle

**Composition over brevity.** Readable composition is the highest priority. Never optimize line count, import count, file count, or folder depth over clear, granular, consistently structured composition. "It's tiny", "it's just one line", "they share the same imports" are never architectural arguments. If something can be composed — compose it. If something can be separated — separate it. Size does not determine the pattern.

## Terminology

FSD calls its top-level divisions "layers." Classel does not.

**Layer** in software engineering means layered architecture — responsibility boundaries where each layer has defined rules about what it can do and what it can access. Upper layers use lower layers, never the reverse:

- **ui** — uses service and model
- **service** — uses repository and model
- **repository** — uses model
- **model** — uses nothing

This is an established concept. It gets the established word.

FSD's top-level divisions are renamed to **levels** in Classel. They describe project-wide vertical hierarchy — what can import what. Not the same concept as layered architecture, not the same word.

**Boot** replaces FSD's "app" level. "App" is too overloaded — it is a Flutter widget class, a common prefix for app-level services, and a natural slice name for app-infrastructure shared code. "Boot" is clear, short, unambiguous — the code that runs once at startup before any feature code. Same precedent as renaming "layers" to "levels": when a term collides with an established concept, pick a better word.

## Structural Concepts

- **Level** — top-level directory in the project. One of: boot, pages, widgets, features, entities, shared. Import rule: a level can only import from levels strictly below it.
- **Slice** — individual module within a level. Has a barrel file and internal segments. Example: `group` is a slice in `entities`, `quiz` is a slice in `features`.
- **Subslice** — a nested slice within a slice. Own barrel file and own segments, scoped to the parent. Used when a slice owns multiple distinct concerns that would flatten into mixed segments. One level of nesting only — no sub-subslices. Sibling subslices within the same parent can import each other. A slice with subslices is a pure container — no segments at the slice root, only subslice folders and the slice barrel.
- **Segment** — internal folder within a slice. Named after the layer it represents. Folder names match layer names.
- **Layer** — architectural responsibility boundary. One of: model, repository, service, ui, @x. Governs what code is allowed to do — not where it sits. Segments are the physical folders; layers are the rules those folders follow.

**Barrel files:** a barrel is a `.dart` file named after its slice (`group.dart`, `config.dart`), containing only `export` statements. It re-exports selected internals — public models, service, and UI components — and hides everything else. Consumers import the barrel, never the internal files directly. Segments (model/, service/, repository/, ui/) are invisible to the outside. The `@x/` folder contains separate barrels for cross-import APIs — one per consumer entity, each exporting a single cross-import service class.

## FSD Levels (top to bottom)

- **boot** — application shell: initialization, routing. Imports everything, nothing imports it. No slices — flat files.
- **pages** — screen shells that compose features and widgets. Thin — no business logic, no direct provider declarations. One slice per screen group.
- **widgets** — reusable UI compositions that import from entities. Too smart for shared (entity-aware), too small for features (no standalone use case). Example: deck tile used across multiple pages.
- **features** — user actions / use cases. Own UI, service, and optionally model and repository. Cannot import other features. Export a widget through barrel. Example: quiz round management.
- **entities** — domain concepts. Own model, repository, service, ui, @x cross-import surfaces. Avoid importing other entities except through @x. Example: Group, Progress, Dictionary.
- **shared** — cross-cutting services, UI, models, repositories. No business domain. Imported freely by all levels above.

Import rule: a module can only import from levels strictly below. No lateral imports within the same level. Exception: entity @x — domain entities naturally reference each other. FSD prohibits lateral imports, so @x is the controlled compromise.

Slice rule: shared, widgets, features, entities, and pages MUST contain slices. No files directly in the level folder. Every module is a slice with a barrel file and segments. Boot is the exception — flat files, no slices.

## Allowed Segments

| Level | Allowed Layers (segments) |
|-------|--------------------------|
| boot | (no segments — flat files) |
| pages | model, repository, service, ui |
| widgets | model, repository, service, ui |
| features | model, repository, service, ui |
| entities | model, repository, service, ui, @x |
| shared | model, repository, service, ui |

## Project Structure

```
boot/
  initialization.dart                  <- calls service init methods at startup
  router.dart                          <- GoRouter route table

pages/
  vocab/
    vocab.dart                         <- barrel
    ui/
      vocab_deck_list_page.dart        <- main vocabulary screen
  quiz/
    quiz.dart                          <- barrel
    round/
      round.dart                       <- subslice barrel
      round_page.dart                  <- quiz round screen
    result/
      result.dart                      <- subslice barrel
      result_page.dart                 <- quiz result screen
  language/
    language.dart                      <- barrel
    language/
      language.dart                    <- subslice barrel
      language_page.dart               <- language management screen
      service/
        language_page_service.dart     <- page-scoped service
    picker/
      picker.dart                      <- subslice barrel
      lang_picker_page.dart            <- language picker screen
  tools/
    tools.dart                         <- barrel
    home/
      home.dart                        <- subslice barrel
      tools_page.dart                  <- tools hub screen
    conjugations/
      conjugations.dart                <- subslice barrel
      conjugations_page.dart           <- conjugation practice screen
    agreement/
      agreement.dart                   <- subslice barrel
      agreement_page.dart              <- agreement practice screen
  progress/
    progress.dart                      <- barrel
    ui/
      progress_page.dart               <- progress overview screen
  settings/
    settings.dart                      <- barrel
    ui/
      settings_page.dart               <- app settings screen

widgets/
  vocab/
    vocab.dart                         <- barrel
    deck_tile/
      deck_tile.dart                   <- subslice barrel
      vocab_deck_tile.dart             <- deck tile widget
      vocab_deck_tile_data.dart        <- deck tile display data
    level_card/
      level_card.dart                  <- subslice barrel
      vocab_level_card.dart            <- level card widget
      vocab_level_stats_row.dart       <- level stats row widget
    daily_activity_card/
      daily_activity_card.dart         <- subslice barrel
      vocab_daily_activity_card.dart   <- daily activity card widget

features/
  quiz/
    quiz.dart                          <- barrel (exports service, model, UI)
    model/
      missed_entry.dart                <- MissedEntry data class
      mode_selection.dart              <- ModeSelection data class
      round_state.dart                 <- RoundState data class
      round_type.dart                  <- RoundType enum
      vocab_card.dart                  <- VocabCard data class
    service/
      quiz_service.dart                <- QuizService (round lifecycle, state)
      quiz_options_service.dart        <- QuizOptionsService (round config)
      quiz_utils_service.dart          <- QuizUtilsService (answer comparison)
      card_generation_service.dart     <- CardGenerationService (card building)
      agreement_round_builder.dart     <- agreement round queue builder
    ui/
      answer_tile.dart                 <- answer display tile
      display_english.dart             <- English text display
      mode_selection_sheet.dart        <- quiz mode picker sheet

entities/
  dictionary/
    dictionary.dart                    <- barrel
    model/
      dictionary.dart                  <- Dictionary data class
      language_pack.dart               <- LanguagePack (per-language data)
      vocab_deck_model.dart            <- VocabDeckModel
      level.dart                       <- Level data class
      level_meta.dart                  <- LevelMeta
      level_tier.dart                  <- LevelTier enum
      term.dart                        <- Term data class
      lang_entry.dart                  <- LangEntry
      language_entry.dart              <- LanguageEntry
      translation_entry.dart           <- TranslationEntry
    repository/
      dictionary_repository.dart       <- DictionaryRepository (JSON asset loading)
      plan_repository.dart             <- PlanRepository (learning plan)
    service/
      dictionary_service.dart          <- DictionaryService (public reads)
      dictionary_internal_service.dart <- DictionaryInternalService (revision, internal providers)

  group/
    group.dart                         <- barrel
    model/
      card_model.dart                  <- CardModel data class
      group_model.dart                 <- GroupModel, GroupType, GroupCategory
      test_result.dart                 <- TestResult data class
    repository/
      group_repository.dart            <- GroupRepository (group loading)
      test_result_repository.dart      <- TestResultRepository (test scores)
    service/
      group_service.dart               <- GroupService (public reads + writes)
      group_internal_service.dart      <- GroupInternalService (revision, internal providers)

  progress/
    progress.dart                      <- barrel
    model/
      deck_progress.dart               <- DeckProgress data class
      progress_calculator.dart         <- ProgressCalculator (retention formulas)
      progress_constants.dart          <- ProgressConstants (caps, thresholds)
      quiz_mode.dart                   <- QuizMode enum
      retention_level.dart             <- RetentionLevel enum
      round_record.dart                <- RoundRecord data class
    repository/
      deck_progress_repository.dart    <- DeckProgressRepository (progress + round records)
      language_stats_repository.dart   <- LanguageStatsRepository (aggregate stats)
    service/
      progress_service.dart            <- ProgressService (public reads + writes)
      progress_internal_service.dart   <- ProgressInternalService (revision, internal providers)

  activity/
    activity.dart                      <- barrel
    model/
      daily_activity_stats.dart        <- DailyActivityStats data class
    repository/
      daily_activity_repository.dart   <- DailyActivityRepository (daily activity records)
    service/
      activity_service.dart            <- ActivityService (public reads + writes)
      activity_internal_service.dart   <- ActivityInternalService (revision, internal providers)

shared/
  app/                                   <- app-infrastructure subslice group
    app.dart                             <- barrel (re-exports all subslice barrels)
    config/
      config.dart                        <- barrel
      model/
        app_settings.dart                <- AppSettings data class
        decay_formula.dart               <- DecayFormula enum
        language_settings.dart           <- LanguageSettings data class
      repository/
        app_settings_repository.dart     <- AppSettingsRepository (SQLite)
        language_settings_repository.dart <- LanguageSettingsRepository (SQLite)
      service/
        config_service.dart              <- ConfigService (language, settings mutations)
        config_internal_service.dart     <- ConfigInternalService (revision, internal providers)
    constants/
      constants.dart                     <- barrel
      model/
        app_constants.dart               <- AppConstants (DB name, question counts, misc)
        app_routes.dart                  <- AppRoutes (route path strings)
        lang_codes.dart                  <- LangCodes (language code constants)
        lang_grammar_profile.dart        <- LangGrammarProfile (per-language grammar rules)
    database/
      database.dart                      <- barrel
      model/
        db_schema.dart                   <- DbSchema (table/column name constants)
      service/
        database_service.dart            <- DatabaseService (SQLite open + provider)
    layout/
      layout.dart                        <- barrel
      model/
        langwij_layout.dart              <- LangwijLayout (product-specific dimensions)
    theme/
      theme.dart                         <- barrel
      service/
        theme_service.dart               <- ThemeService (theme selection provider)
    validators/
      validators.dart                    <- barrel
      service/
        config_validator.dart            <- ConfigValidator (settings consistency checks)
        startup_validator.dart           <- StartupValidator (language pack validation)
```

- **boot** — flat files, no slices. Initialization + routing. Imports everything, nothing imports it.
- **pages** — one slice per screen group. Composes features and widgets — no business logic. Segments: model, repository, service, ui.
- **widgets** — entity-aware reusable UI. Too smart for shared, too small for features. Segments: model, repository, service, ui.
- **features** — one slice per domain action group. Exports entry widget via barrel. Segments: model, repository, service, ui.
- **entities** — domain concepts. Full layered architecture. Segments: model, repository, service, ui, @x. One service class per visibility level.
- **shared** — cross-cutting, no business domain. Sliced by concern (config, database, theme). Segments: model, repository, service, ui. Imported freely by all levels above.

## Layer Definitions

- **model** — pure data classes. No dependencies, no Riverpod. Plain Dart.
- **repository** — pure data access: DB, file I/O, asset loading. No Riverpod, no business logic. Plain Dart. Suffix: `*Repository`.
- **service** — behavior: computation, orchestration, state. The ONLY layer permitted to touch Riverpod. May hold providers (static fields), mutations (static methods), or pure logic. One service class per visibility level. Suffix: `*Service`. This is the slice's public surface — reads, writes, reactive state, and domain logic.
- **ui** — presentation: the visual output of a slice. Widgets that watch services or receive data via constructor. No business logic beyond presentation. Renders Flessel controls.
- **@x** — cross-import barrels. Entity-level only. One file per consumer entity. Exports cross-import service classes. Exports the minimum needed — revision signals + specific methods. Keep @x usage to a minimum; it's a necessary compromise, not a recommended approach.

Service visibility levels:
- `GroupService` — public API, exported through barrel
- `GroupInternalService` — private, never exported

## Naming Conventions

| Concept | Suffix | Example |
|---------|--------|---------|
| Public service | `*Service` | `GroupService` |
| Internal service | `*InternalService` | `GroupInternalService` |
| Cross-import service | `*Cross{Consumer}Service` | (not yet used) |
| Repository | `*Repository` | `DeckProgressRepository` |
| Model | (entity name) | `GroupModel` |

## Key Rules

- Providers CANNOT exist outside service classes
- Repositories CANNOT touch Riverpod
- Models CANNOT have dependencies
- Each class gets its own file. Every abstraction follows the same structural treatment — same file conventions, same naming pattern, same folder placement. A class with one static field is treated identically to a class with twenty. Size does not determine the pattern.
- No `src/` folder — barrel controls visibility, not folder depth
- Barrel file per slice — named after the slice (`group.dart`)
- `@x/` folder for cross-import barrels — one file per consumer entity
- Only layers documented in the Classel Architecture are allowed. No inventing new layers silently — if the existing types are insufficient, a new layer must be explicitly proposed and approved before use.
- Folders represent layers. No folder is allowed unless it maps to a layer documented in the Classel Architecture. No folder for convenience or organization without a documented concept behind it.
- Slices may contain subslices. A subslice follows the same structure as a slice — own barrel, own segments. One nesting level only: if a subslice needs its own subslices, it belongs at a higher level (feature or widget). Sibling subslices share parent scope and may import each other. Exclusive: a slice has EITHER segments OR subslices, never both. If any subslice exists, all content moves into subslices — including the slice's "main" concern.

## Reactive Contract

State changes propagate through the dependency graph — never through explicit invalidation.

A mutation service performs its work and bumps ONE revision signal. It names NO consumers. It does not know who watches it or what recomputes downstream. Every consumer declares its own dependency via `ref.watch`. Riverpod propagates automatically — from the bumped signal, through every watching provider, all the way to UI.

The mutation publishes "I changed." Nothing more.

Revision signal convention:
- `<Entity>InternalService.revision` — bumped on entity CRUD (create, update, delete)

**Anti-pattern: Provider Puppeteer.** A mutation that explicitly invalidates downstream consumers ("after recording a round, invalidate progress providers, activity providers, group providers..."). Fragile, grows with every new feature, source of most cache bugs. The reactive contract eliminates it — each entity bumps its own signal, Riverpod does the rest.

## Architectural Precedents

### Precedent 1: Convention + lint rules for enforcement

Compile-time module boundaries (multi-package monorepo) rejected as too heavy. Enforcement via:

- Barrel files per slice — each module exports only its public API
- `custom_lint` rules — flag imports that bypass barrel files across feature/entity boundaries
- Import-path linting: "if import path contains `/features/X/` and importing file is not under `/features/X/`, it must import the barrel and nothing else"

### Precedent 2: Cross-cutting config in shared

Language settings and app settings are consumed by nearly every entity. If they were entities, they would need @x for everything — a sign they're at the wrong level.

**Solution:** Config lives in shared. The config slice is self-contained — its own repository for persistence, its own service for state and lifecycle. Any entity imports freely — no @x needed.

### Precedent 3: One feature per domain action group

A feature slice covers a full domain action group — not individual operations. `quiz` (round lifecycle, mode selection, answer checking, card generation) is one feature. Not `quiz-round` + `quiz-options` + `quiz-cards`. Granularity follows user intent, not technical operations.

---

## Project

### Technology Stack

- Language: Dart
- Framework: Flutter
- State management: Riverpod (kept as reactive engine, demoted from architecture to implementation detail)
- Persistence: SQLite via sqflite (all structured data — dictionary metadata, progress, activity, settings)
- Navigation: GoRouter
- UI library: Flessel (internal design system)
- Localization: Flutter gen-l10n (AppLocalizations)
- Architecture: Classel

### Project Description

Langwij is a vocabulary and grammar learning app. Users study word decks and conjugation tables through quiz rounds, track progress per deck, and monitor daily activity.

#### Features

- **Dictionary** — language packs loaded from JSON assets. Vocabulary organized into levels, decks, and terms. Supports multiple target/native language pairs.
- **Groups** — card groups: vocabulary word decks and conjugation/agreement tables. Each group produces quiz cards.
- **Quiz** — training and test rounds with three modes (target shown, native shown, write). Mode selection, answer checking, multiple choice options, round lifecycle.
- **Progress** — per-deck progress tracking with score formulas, mode caps, retention levels, round history.
- **Activity** — daily activity logging: rounds played, terms touched, streaks.
- **Language management** — target/native/UI language selection, language reset (wipes progress + activity for a language).

#### Screens

- **VocabDeckListPage** — browse vocabulary decks grouped by level, see progress per deck
- **ConjugationsPage** — browse conjugation tables by group, see progress
- **AgreementPage** — browse adjective agreement practice groups
- **RoundPage** — active quiz round: display card, accept answer, advance queue
- **ResultPage** — round results: score, missed entries, bug report
- **ProgressPage** — overall progress overview with activity stats
- **LanguagePage** — language settings, language reset
- **LangPickerPage** — language selection picker
- **ToolsPage** — tools hub (conjugations, agreement)
- **SettingsPage** — app settings, dev section, theme selection

#### Repos

- **DictionaryRepository** — JSON asset loading for language packs
- **PlanRepository** — learning plan persistence
- **GroupRepository** — group loading from dictionary data
- **TestResultRepository** — test score persistence (SQLite)
- **DeckProgressRepository** — deck_progress + round_records tables (SQLite)
- **LanguageStatsRepository** — aggregate progress stats across languages (SQLite)
- **DailyActivityRepository** — daily_activity table (SQLite)
- **AppSettingsRepository** — app_settings table (SQLite)
- **LanguageSettingsRepository** — language_settings table (SQLite)

### Concrete Example: Quiz Round Flow

This example validates the architecture end-to-end. A quiz round starts from a deck list, goes through mode selection, plays cards, and persists results.

#### FSD level placement

**shared:**
- `ConfigService.languageSettings` — cross-cutting language config
- `DatabaseService` — SQLite provider
- `AppConstants`, `AppRoutes` — app-wide constants

**entities:**
- **Group entity** — owns group model, card model, group repo. Public: `GroupService`.
- **Progress entity** — owns deck progress, round records, progress formulas. Public: `ProgressService`.
- **Activity entity** — owns daily activity stats, activity repo. Public: `ActivityService`.
- **Dictionary entity** — owns language packs, vocab deck models. Public: `DictionaryService`.

**feature: quiz**
```
features/
  quiz/
    quiz.dart                          <- barrel, exports service + model + UI
    model/
      round_state.dart                 <- RoundState (queue, scores, origin)
      mode_selection.dart              <- ModeSelection (mode + isTest)
    service/
      quiz_service.dart                <- QuizService (round provider, persist, end)
    ui/
      mode_selection_sheet.dart        <- mode picker bottom sheet
```

**pages:**
```dart
// VocabDeckListPage — selects group, shows mode sheet, navigates to round
QuizService.selectGroup(ref, group);
context.go(AppRoutes.quizRound);

// RoundPage — watches QuizService.round, calls answerCorrect/answerWrong
// ResultPage — watches QuizService.round for results, calls persistRound
```

#### Reactivity chain

```
QuizService.persistRound(ref) -> calls ProgressService.recordRound + ActivityService.addRound
  ProgressService.recordRound -> writes to repo, bumps ProgressInternalService.revision
    | ref.watch
  ProgressService.allProgress (watches revision -> recomputes)
    | ref.watch
  VocabDeckListPage (watches allProgress -> rebuilds deck tiles with new scores)
```

Every arrow is a `ref.watch()`. Riverpod propagates automatically. No manual subscriptions, no invalidation lists.
