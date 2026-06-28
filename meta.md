## Meta

Core rules. Apply across all groups, all projects, all platforms. These are non-negotiable.

## M1. Decompose first.

Every distinct operation gets its own named unit — method, function, class, component. No size threshold: even 3 lines with a single responsibility get extracted if they represent a distinct concept. "Only used once" is not a reason to inline. "Too small to extract" does not exist. A named unit is a unit the reader can skip, understand in isolation, and test. An inline block is none of these.

Composition is not about reuse. It is about naming. Every unnamed block of logic is a decision you hid from the reader. Extraction is how code explains itself.

The test: if you can describe what a block does in one phrase — that phrase is the function name you failed to write.

### M1 — Antipatterns

- **Inliner** — keeping logic inline because "it's only a few lines" or "it's only used once." Both arguments optimize for writing speed. Composition optimizes for reading speed. Reading happens a thousand times more.
- **God Method** — a method you can only describe with "and." Validates and transforms and saves. Fetches and filters and maps and renders. Each "and" is a missing extraction.
- **God File** — a file with multiple responsibilities held together by proximity, not cohesion. If deleting one section would leave the rest fully functional, those sections belong apart.
- **Descriptive Comment** — a comment explaining what the next block does. That comment is the name of the method you did not extract. `// calculate the weighted average` → `calculateWeightedAverage()`.

## M2. Name is the documentation.

Every public symbol — class, method, field, parameter, component — carries at least 3 semantic roots. No abbreviations, no acronyms, no initialisms unless industry-standard (HTTP, URL, ID). 3 roots is the floor, not the target. 5-6 roots is normal. A long name that reads like a sentence is correct; a short name that requires context to understand is a bug.

Private symbols may be shorter when scope is narrow (loop indices, lambdas, builder callbacks). Public API has no such exemption — it is read without the surrounding code, and it must stand alone.

### M2 — Antipatterns

- **Name Miser** — `getData()`, `handleEvent()`, `processItem()`. Get *what* data? Handle *which* event? Process *how*? Every vague verb is a reader forced to open the implementation.
- **Abbreviation Addict** — `usrProfSvc` instead of `userProfileService`. Saving keystrokes at the reader's expense. Autocomplete exists; telepathy does not.

## M3. Touch it — own it. Fix it — don't ask.

Touching a method obligates you to its signature, its name, its callers, and its siblings. Touching a file obligates you to its structure and its cohesion. Touching a module obligates you to its boundaries. A one-line fix inside a god method is not a fix — it is an endorsement.

When this obligation reveals a violation — a vague name, an inline block, a broken pattern — fix it. Do not ask whether to fix it. Do not flag it for discussion. Do not mention it as a "potential improvement." Include it in the plan, deliver it as part of the work.

The only valid question is "may I skip this refactoring?" Never "should I fix this?" The answer to the second is always yes. Shortcuts require explicit permission. Default: follow the chain.

### M3 — Antipatterns

- **Surgical Striker** — changing one line inside a 200-line method and calling it done. The method was broken before. Now it's broken and endorsed.
- **Boundary Hugger** — refusing to rename a public symbol because "other files import it." That is not a reason to stop. That is the list of files to update.
- **Permission Staller** — "I noticed this method could be renamed, would you like me to?" No. Rename it. The rules already said to.
- **Polite Ignorer** — noting a violation in commentary but not in code. Describing the problem is not solving the problem.
