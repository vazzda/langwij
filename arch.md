## Architecture

Classel — see [classel.md](classel.md)

Project structure: [fsd-map.md](fsd-map.md) — the exact current structure of the project. Read it before navigating the codebase. Any structural change (file move, slice add/remove, directory rename) must be reflected there immediately.

## Stack
- Language: Dart
- Framework: Flutter
- State management: Riverpod (flutter_riverpod)
- Persistence: SQLite via sqflite (structured data — all tables, settings, progress, activity)
- Navigation: GoRouter (go_router)
- Localization: Flutter gen-l10n (AppLocalizations)
- UI library: Flessel (internal design system)
- Architecture: Classel

## Layer pattern
Service Layer Pattern (MVC-adjacent):
- Screen: watches providers, calls services, handles navigation
- Service: business logic, orchestrates repositories, owns state mutations and provider writes
- Repository: DB access only, no business logic
- Provider: reactive state containers — derived providers are public API, raw StateProviders are internal

Service visibility levels:
- `*Service` — public API, exported through barrel
- `*InternalService` — private, never exported. Owns revision signals and internal providers.

## State flow model
Push-subscribe via Riverpod:
- Services write to StateProviders (push)
- Screens watch derived Providers (subscribe)
- No pull/polling from screens — all state is reactive

Revision signal convention: `<Entity>InternalService.revision` — a `StateProvider<int>` incremented on every data mutation. Single owner (the mutation site), many watchers. Consumers watch it as a dependency trigger rather than relying on explicit invalidation.

## Dependency direction
Top-down:
- Screens depend on providers and services
- Services depend on repositories and models
- Models depend on nothing
- Lower layers communicate upward through Riverpod's reactive providers

## Encapsulation conventions
- Dart underscore prefix for file-private members
- Riverpod providers: derived Provider = public API, raw StateProvider = internal (convention, not enforced)
- Service methods are the mutation API — screens never write providers directly
- Barrel files per slice — consumers import the barrel, never internal files

## Error handling strategy
- Services catch and log via `debugPrint`
- No project-wide error reporting framework
- User-facing errors surfaced via return values and snackbar messages
- No project-wide Result type — errors use a mix of return values and try/catch

## Naming conventions
- Files: snake_case, grouped by domain in `<level>/<slice>/<segment>/`
- Classes: PascalCase, prefixed by domain
- Providers: static fields on service classes (not top-level)
- Constants: camelCase for string keys, PascalCase for classes
- Localization keys: snake_case with feature prefix

## Localization

Source: `lib/l10n/app_en.arb` — the only file to edit.
Generated: `app_localizations.dart`, `app_localizations_en.dart` — same directory, never hand-edit.
Extension: `app_localizations_ext.dart` — hand-written extension methods on `AppLocalizations`.
Regeneration: automatic on build, hot reload, hot restart (`generate: true` in pubspec).
Access: `final l10n = AppLocalizations.of(context)!;`

## Tooling

- Static analysis: `dart analyze`

## Known violations (pending migration)

- **Segment naming**: codebase uses `services/` (plural) — classel standard is `service/` (singular)
