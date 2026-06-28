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

**Barrel files:** a barrel is a `.dart` file named after its slice (`group.dart`, `config.dart`), containing only `export` statements. It re-exports selected internals — public models and service — and hides everything else. Consumers import the barrel, never the internal files directly. Segments (model/, service/, repository/, ui/) are invisible to the outside. The `@x/` folder contains separate barrels for cross-import APIs — one per consumer entity, each exporting a single cross-import service class.

Barrel scope: model + service only. UI widgets are public but not barrel-exported — consumers import them directly by file path. Repositories and internal services are never importable from outside the slice. This keeps the barrel focused on hiding internals without forcing Flutter/Material dependencies into pure-logic consumers.

## FSD Levels (top to bottom)

- **boot** — application shell: initialization, routing. Imports everything, nothing imports it. No slices — flat files.
- **pages** — screen shells that compose features and widgets. Thin — no business logic, no direct provider declarations. One slice per screen group.
- **widgets** — reusable UI compositions that import from entities. Too smart for shared (entity-aware), too small for features (no standalone use case).
- **features** — user actions / use cases. Own UI, service, and optionally model and repository. Cannot import other features. Export model + service through barrel; UI imported directly by path.
- **entities** — domain concepts. Own model, repository, service, ui, @x cross-import surfaces. Avoid importing other entities except through @x.
- **shared** — cross-cutting services, UI, models, repositories. No business domain. Imported freely by all levels above.

Import rule: a module can only import from levels strictly below. No lateral imports within the same level. Exception: entity @x — domain entities naturally reference each other. FSD prohibits lateral imports, so @x is the controlled compromise.

### Import Matrix

| Level | Can import from | Cannot import from |
|---|---|---|
| `boot/` | pages, widgets, features, entities, shared | — (top level) |
| `pages/` | widgets, features, entities, shared | boot, other pages |
| `widgets/` | features, entities, shared | boot, pages, other widgets |
| `features/` | entities, shared | boot, pages, widgets, other features |
| `entities/` | shared, other entities via @x only | boot, pages, widgets, features |
| `shared/` | — (bottom level) | everything above |

No exceptions beyond entity @x. "Strictly below" means the matrix above — not adjacency, not "one level down," not "anything lower-sounding." If the cell says "cannot," no justification overrides it.

### Composition Rule

A slice name must be unique across all levels. If `group/` exists in `entities/`, no other level may have a slice named `group/`. Same concept at two levels is a structural violation — impossible to navigate, impossible to reason about ownership.

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

## Layer Definitions

- **model** — pure data classes. No dependencies, no Riverpod. Plain Dart.
- **repository** — pure data access: DB, file I/O, asset loading. No Riverpod, no business logic. Plain Dart. Suffix: `*Repository`.
- **service** — behavior: computation, orchestration, state. The ONLY layer permitted to touch Riverpod. May hold providers (static fields), mutations (static methods), or pure logic. One service class per visibility level. Suffix: `*Service`. This is the slice's public surface — reads, writes, reactive state, and domain logic.
- **ui** — presentation: the visual output of a slice. Widgets that watch services or receive data via constructor. No business logic beyond presentation. Renders Flessel controls.
- **@x** — cross-entity API surfaces. Entity-level only. The providing entity owns the @x file: `group/@x/progress.dart` means "group's public API for progress consumers." One-way gate: the provider exports, the consumer imports. The @x file belongs to the provider — it can access provider internals freely. It must NOT import from the consumer entity. One file per consumer entity. Exports the minimum needed — revision signals + specific methods. Keep @x usage to a minimum; it's a necessary compromise, not a recommended approach.

Service visibility levels:
- `GroupService` — public API, exported through barrel
- `GroupInternalService` — private, never exported. No external slice may import it.
- `GroupCrossProgressService` — exported through `@x/progress.dart` only

## Naming Conventions

| Concept | Suffix | Example |
|---------|--------|---------|
| Public service | `*Service` | `GroupService` |
| Internal service | `*InternalService` | `GroupInternalService` |
| Cross-import service | `*Cross{Consumer}Service` | `GroupCrossProgressService` |
| Repository | `*Repository` | `DeckProgressRepository` |
| Model | (entity name) | `GroupModel` |

## Key Rules

- Providers CANNOT exist outside service classes
- Repositories CANNOT touch Riverpod
- Models CANNOT have dependencies
- Each class gets its own file.
- `@x/` folder for cross-import barrels — one file per consumer entity, owned by the providing entity
- Only layers documented in the Classel Architecture are allowed. No inventing new layers silently — if the existing types are insufficient, a new layer must be explicitly proposed and approved before use.
- Folders represent layers. No folder is allowed unless it maps to a layer documented in the Classel Architecture. No folder for convenience or organization without a documented concept behind it.
- Slices may contain subslices. A subslice follows the same structure as a slice — own barrel, own segments. One nesting level only: if a subslice needs its own subslices, it belongs at a higher level (feature or widget). Sibling subslices share parent scope and may import each other. Exclusive: a slice has EITHER segments OR subslices, never both. If any subslice exists, all content moves into subslices — including the slice's "main" concern.

## Reactive Contract

State changes propagate through the dependency graph — never through explicit invalidation.

A mutation service performs its work and bumps ONE revision signal. It names NO consumers. It does not know who watches it or what recomputes downstream. Every consumer declares its own dependency via `ref.watch`. Riverpod propagates automatically — from the bumped signal, through every watching provider, all the way to UI.

The mutation publishes "I changed." Nothing more.

Revision signal convention:
- `<Entity>InternalService.revision` — bumped on entity CRUD (create, update, delete)
- `<Entity>InternalService.dataRevision` — bumped on logged data mutations (time entries, check-ins)

**Anti-pattern: Provider Puppeteer.** A mutation that explicitly invalidates downstream consumers ("after recording a round, invalidate progress providers, activity providers, group providers..."). Fragile, grows with every new feature, source of most cache bugs. The reactive contract eliminates it — each entity bumps its own signal, Riverpod does the rest.

## Example Structure

Full project structure: [fsd-map.md](fsd-map.md)

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
      ui/
        round_page.dart                <- quiz round screen
    result/
      result.dart                      <- subslice barrel
      ui/
        result_page.dart               <- quiz result screen

features/
  quiz/
    quiz.dart                          <- barrel (exports model + service)
    model/
      round_state.dart                 <- RoundState data class
      mode_selection.dart              <- ModeSelection data class
    service/
      quiz_service.dart                <- QuizService (round lifecycle, state)
    ui/
      mode_selection_sheet.dart        <- quiz mode picker sheet

entities/
  group/
    group.dart                         <- barrel
    model/
      group_model.dart                 <- GroupModel, GroupType, GroupCategory
    repository/
      group_repository.dart            <- GroupRepository (group loading)
    service/
      group_service.dart               <- GroupService (public reads + writes)
      group_internal_service.dart      <- GroupInternalService (revision, internal providers)

shared/
  app/
    app.dart                           <- barrel (re-exports all subslice barrels)
    config/
      config.dart                      <- barrel
      model/
        app_settings.dart              <- AppSettings data class
      repository/
        app_settings_repository.dart   <- AppSettingsRepository (SQLite)
      service/
        config_service.dart            <- ConfigService (language, settings mutations)
    database/
      database.dart                    <- barrel
      service/
        database_service.dart          <- DatabaseService (SQLite open + provider)
    theme/
      theme.dart                       <- barrel
      service/
        theme_service.dart             <- ThemeService (theme selection provider)
```

## Architectural Precedents

### Precedent 1: Convention + lint rules for enforcement

Compile-time module boundaries (multi-package monorepo) rejected as too heavy. Enforcement via:

- Barrel files per slice — each module exports its model + service public API
- `custom_lint` rules — flag imports that bypass barrel files across feature/entity boundaries
- Import-path linting: "if import path contains `/features/X/` or `/entities/X/` and importing file is not under that slice, model and service imports must go through the barrel. UI imports may reference the file directly. Repository and internal service imports are always forbidden from outside the slice."

### Precedent 2: Cross-cutting config in shared

Language settings and app settings are consumed by nearly every entity. If they were entities, they would need @x for everything — a sign they're at the wrong level.

**Solution:** Config lives in shared. The config slice is self-contained — its own repository for persistence, its own service for state and lifecycle. Any entity imports freely — no @x needed.

### Precedent 3: One feature per domain action group

A feature slice covers a full domain action group — not individual operations. `quiz` (round lifecycle, mode selection, answer checking, card generation) is one feature. Not `quiz-round` + `quiz-options` + `quiz-cards`. Granularity follows user intent, not technical operations.

### Precedent 4: Fine-grained split for multi-entity features

Features that span multiple entities or serve distinct use cases get their own slices — not one monolith. Each slice is independently composable.
