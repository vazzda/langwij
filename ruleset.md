## Meta

Overarching principles. Apply across all groups, all projects, all platforms.

- Composition is one thing -- structure and contracts are inseparable, not separate categories
- Principle-only -- platform mapping is the implementer's responsibility
- OOP + SOLID at every unit, every granularity, no exceptions
- Every project assumes a 10-year support cycle -- no prototype exceptions
- Every granularity, same rigor -- no size threshold, no complexity threshold

## B -- Boundaries

**B1. Layer separation.** Data, service, UI are distinct layers. Specific pattern (MVC, MVVM, MVP) is per-project, documented in `arch.md`. The separation is non-negotiable.

**B2. Top-down dependency direction.** High-level modules never import low-level modules. UI depends on services, services depend on repositories. Never reversed. Lower layers communicate upward only through reactive mechanisms (streams, signals, observers, callbacks).

**B3. Encapsulation.** Public API is the only way in. No reading internal state. No skipping accessors. No reaching past a module's public interface. Platform conventions for private/public are law, not suggestion.

**B4. Framework-native DI.** Use the platform's dependency injection mechanism. Constructor injection where no framework mechanism exists. No hand-rolled service locators. No global singletons.

**B5. Layered service decomposition.** Feature services orchestrate — they call computation services and assemble results. Computation services derive metrics — they call read services and apply formulas. Read services protect data access — they handle cross-cutting concerns (day-start-hour, period boundaries) so no layer above touches raw data semantics. A feature service that contains a formula it didn't write is too thick.

### B -- Antipatterns

- **Cache Leaker** -- reading or writing persistence keys outside the owning service. Cache format is a service implementation detail.
- **Timing Smuggler** -- importing or referencing internal timing constants from a consumer. If a caller needs to wait, the service returns when ready.
- **Provider Puppeteer** -- a consumer directly mutating a state provider owned by a service. Consumers read; only the owning service writes.
- **Lifecycle Squatter** -- a consumer managing domain-level lifecycle (recheck, refresh, reconnect) in its own hooks. The service observes its own lifecycle.
- **Layer Tourist** -- a consumer importing types from an external dependency that the service wraps. The service translates external types into domain types.
- **Constructor Leak** -- a unit requiring parameters that only make sense if you know another unit's internals.
- **Sequence Assumption** -- code that only works if another module's methods are called in a specific order. If skipping one silently corrupts state, the design is wrong.

## C -- Contracts

**C1. Abstractions from day one.** Every boundary gets an interface/abstract contract immediately. No waiting for second use. No waiting for pain. One implementation still gets an interface.

**C2. Immutable by default.** Data leaving a module is read-only. If you need to change it, go through the owning service. Mutable state exists only inside the owning module.

**C3. Composition over inheritance.** Inheritance is a framework obligation, never a design choice. Interfaces for polymorphism, composition for reuse. Framework-mandated inheritance is the only exception.

**C4. Uniform rigor.** A private field inside a class gets the same encapsulation rigor as a module's public API. A 20-line helper follows SOLID as strictly as a top-level service. No size threshold, no complexity threshold.

**C5. Visual component API is content and intent.** A UI component owns its visual decisions — theme colors, font selection, spacing. The caller passes content (data, labels) and semantic intent (variant, format, size tier). Passing visual properties (TextStyle, Color, dimensions) from caller to component is not composition — it is a layout template with zero encapsulated decisions. If the caller makes all the visual choices, there is no component.

### C -- Antipatterns

- **Shared Primitive Obsession** -- two modules passing raw strings/ints/maps between them instead of typed contracts. The raw value means something to both sides, but neither side defines what.
- **Style Parrot** -- a UI component that takes every visual property as a parameter and makes no decisions of its own. The caller controls colors, fonts, and spacing; the "component" just arranges them. Extraction without encapsulation.

## S -- State

**S1. Single owner.** Every piece of state has exactly one owner. Derive from existing sources. No parallel state. One owner per concept. If multiple call sites must "remember" to update a flag, the design is wrong.

**S2. Established pattern conformance.** Once a project establishes a pattern for a concern (state flow, error handling, navigation, DI, anything), every new instance follows that same pattern. Not a similar one. Not a "better" one. The same one. Changing the pattern is a deliberate migration -- proposed, planned, applied everywhere. Never quiet drift.

**S3. Errors follow composition rules.** Errors respect layer boundaries. Each boundary translates errors into its own vocabulary. Internal error types do not leak. No special treatment -- errors obey every rule that data obeys. Specific mechanism (exceptions, Result types, error codes) is per-project, documented in `arch.md`.

### S -- Antipatterns

- **State Assembler** -- a consumer reading a module's internal state providers instead of the module's public derived providers. Raw state providers are implementation details.
- **Silent Swallower** -- catching an error and doing nothing with it. Empty catch blocks, ignored return values, log-and-continue without propagating. Hides information a higher layer needs.

## N -- Naming

**N1. Expressive names.** 3-5 roots/words in a name is normal and expected. Abbreviation is not a virtue. If someone asks "why this name?" the name itself should answer. If someone asks "what does this do?" the name should tell them.

**N2. Synchronized names.** Every reference to a concept uses the same name. Class, file, table, column, variable, route, localization key. No drift between layers.

**N3. Rename everywhere.** When a concept is renamed, every reference is updated in the same change. DB migrations, file renames, API changes, documentation. The cost of renaming is always less than the cost of a lying name over years. No aliases. No "too expensive."

### N -- Antipatterns

- **Name Miser** -- choosing the shortest name that technically works. `usr` instead of `userProfile`. `proc` instead of `processPaymentTransaction`.
- **Name Drift** -- a concept renamed in one place but not everywhere. Class says `HabitTracker`, file says `goal_manager`, table says `goals`. Each layer lies about what it contains.
- **Rename Coward** -- avoiding a rename because it's expensive. Migrations, refactors, breaking changes -- these are the price of honesty. Pay it.

## H -- Hygiene

**H1. No dead code.** Unused methods, unreachable branches, commented-out blocks, unused imports, unused parameters, unused variables -- all removed. No "just in case." No "might need later." Git is the archive, not the source file. Platform-mandated unused parameters get the idiomatic suppression marker.

**H2. Zero duplication tolerance.** If the same logic appears twice, extract immediately. Second occurrence means extraction was already late. Copy-paste is a missing abstraction.

**H3. No naked literals.** Every literal with domain meaning gets a named constant, enum value, or configuration property. No gray area. If the answer to "why this value?" requires domain knowledge, it is magic. Extract it.

**H4. Method SRP.** A method does one thing. If you describe what it does using "and," split it. "Validates input and transforms it and saves it" is three methods. Length is a symptom -- the "and" test is the diagnostic.

### H -- Antipatterns

- **Fossil** -- dead code left in the codebase "for reference" or "in case we need it." The reference is `git log`. The case is `git checkout`.
- **Naked Literal** -- a value with domain meaning sitting raw in implementation code instead of named at the appropriate abstraction level.

## D -- Documentation

**D1. Mandatory project files.** Every project has `arch.md` and `modulemap.md` in the project root. No file? Create it before writing code.

**D2. arch.md -- written first.** Created before any code. Sections: Stack, Layer pattern, State flow model, Dependency direction, Encapsulation conventions, Error handling strategy, Naming conventions. Changes rarely -- only when an architectural decision changes, applied as a deliberate migration.

**D3. modulemap.md -- module-first.** Organized by code module. Each module lists: what it owns, what screens/consumers it serves, its dependencies, its public API. This is the responsibility enumeration -- a growing list is the signal that a module needs splitting.

**D4. Same-commit updates.** When code changes a module's responsibilities, public API, or ownership -- `modulemap.md` is updated in the same commit. Never trailing. Stale documentation is a violation.
