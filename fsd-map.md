# FSD Map — Langwij Front

Structural map of `lib/`. Every level, every slice, every file.
Generated from actual filesystem + import analysis.

## Structure

```
lib/
├── boot/                                        — app-level wiring, no domain
│   ├── initialization.dart                        AppInitialization: DB open, config load, splash, dev gate, theme
│   └── router.dart                                GoRouter route table
│
├── main.dart                                    — entry point: ProviderScope + runApp
│
├── entities/                                    — domain core: models, repos, services
│   ├── activity/                                  daily learning activity tracking
│   │   ├── model/
│   │   │   └── daily_activity_stats.dart             DailyActivityStats data class
│   │   ├── repository/
│   │   │   └── daily_activity_repository.dart         daily_activity table CRUD
│   │   ├── services/                              ⚠️ NAMING: plural — classel standard is service/
│   │   │   ├── activity_internal_service.dart        revision signal, internal providers
│   │   │   └── activity_service.dart                 mutations + public providers
│   │   └── activity.dart                            barrel
│   │
│   ├── dictionary/                                language packs, decks, terms
│   │   ├── model/
│   │   │   ├── dictionary.dart                      Dictionary data class
│   │   │   ├── lang_entry.dart                      LangEntry
│   │   │   ├── language_entry.dart                   LanguageEntry
│   │   │   ├── language_pack.dart                    LanguagePack (per-language asset data)
│   │   │   ├── level.dart                           Level data class
│   │   │   ├── level_meta.dart                      LevelMeta
│   │   │   ├── level_tier.dart                      LevelTier enum
│   │   │   ├── term.dart                            Term data class
│   │   │   ├── translation_entry.dart               TranslationEntry
│   │   │   └── vocab_deck_model.dart                VocabDeckModel
│   │   ├── repository/
│   │   │   ├── dictionary_repository.dart            JSON asset loading
│   │   │   └── plan_repository.dart                  learning plan persistence
│   │   ├── services/                              ⚠️ NAMING: plural
│   │   │   ├── dictionary_internal_service.dart      revision signal, internal providers
│   │   │   └── dictionary_service.dart               public reads
│   │   └── dictionary.dart                          barrel
│   │
│   ├── group/                                     card groups: vocab decks + conjugation tables
│   │   ├── model/
│   │   │   ├── card_model.dart                      CardModel data class
│   │   │   ├── group_model.dart                     GroupModel, GroupType, GroupCategory enums
│   │   │   └── test_result.dart                     TestResult data class
│   │   ├── repository/
│   │   │   ├── group_repository.dart                group loading from dictionary data
│   │   │   └── test_result_repository.dart           test score persistence (SQLite)
│   │   ├── services/                              ⚠️ NAMING: plural
│   │   │   ├── group_internal_service.dart           revision signal, internal providers
│   │   │   └── group_service.dart                    public reads + writes
│   │   └── group.dart                               barrel
│   │
│   └── progress/                                  per-deck progress + retention tracking
│       ├── model/
│       │   ├── deck_progress.dart                   DeckProgress data class
│       │   ├── progress_calculator.dart             retention formulas
│       │   ├── progress_constants.dart              caps, thresholds, base contribution
│       │   ├── quiz_mode.dart                       QuizMode enum (targetShown, nativeShown, write)
│       │   ├── retention_level.dart                 RetentionLevel enum
│       │   └── round_record.dart                    RoundRecord data class
│       ├── repository/
│       │   ├── deck_progress_repository.dart         deck_progress + round_records tables
│       │   └── language_stats_repository.dart        aggregate stats across languages
│       ├── services/                              ⚠️ NAMING: plural
│       │   ├── progress_internal_service.dart        revision signal, internal providers
│       │   └── progress_service.dart                 public reads + writes
│       └── progress.dart                            barrel
│
├── features/                                    — cross-cutting product features
│   └── quiz/                                      quiz round lifecycle
│       ├── model/
│       │   ├── missed_entry.dart                    MissedEntry (card + user typed answer)
│       │   ├── mode_selection.dart                  ModeSelection (mode + isTest)
│       │   ├── round_state.dart                     RoundState (queue, scores, origin route)
│       │   ├── round_type.dart                      RoundType enum (vocabulary, conjugations, agreement)
│       │   └── vocab_card.dart                      VocabCard extends CardModel
│       ├── services/                              ⚠️ NAMING: plural
│       │   ├── agreement_round_builder.dart         agreement round queue builder
│       │   ├── card_generation_service.dart          CardGenerationService (vocab card building)
│       │   ├── quiz_options_service.dart             QuizOptionsService (multiple choice options)
│       │   ├── quiz_service.dart                     QuizService (round provider, persist, end, nav state)
│       │   └── quiz_utils_service.dart               QuizUtilsService (answer normalization/comparison)
│       ├── ui/
│       │   ├── answer_tile.dart                     answer display tile
│       │   ├── display_english.dart                  English text display widget
│       │   └── mode_selection_sheet.dart             quiz mode picker bottom sheet
│       └── quiz.dart                                barrel
│
├── pages/                                       — screen-level slices
│   ├── language/                                  language management (subslices)
│   │   ├── language/                                language settings subslice
│   │   │   ├── language.dart                          subslice barrel
│   │   │   ├── language_page.dart                     ⚠️ STRUCTURE: page at subslice root, not in ui/
│   │   │   └── language_page_service.dart             ⚠️ STRUCTURE: service at subslice root, not in service/
│   │   ├── picker/                                  language picker subslice
│   │   │   ├── picker.dart                            subslice barrel
│   │   │   └── lang_picker_page.dart                  ⚠️ STRUCTURE: page at subslice root, not in ui/
│   │   └── language.dart                            slice barrel
│   │
│   ├── progress/                                  progress overview
│   │   ├── ui/
│   │   │   └── progress_page.dart                   progress stats screen
│   │   └── progress.dart                            barrel
│   │
│   ├── quiz/                                      quiz screens (subslices)
│   │   ├── result/                                  quiz result subslice
│   │   │   ├── result.dart                            subslice barrel
│   │   │   └── result_page.dart                       ⚠️ STRUCTURE: page at subslice root, not in ui/
│   │   ├── round/                                   quiz round subslice
│   │   │   ├── round.dart                             subslice barrel
│   │   │   └── round_page.dart                        ⚠️ STRUCTURE: page at subslice root, not in ui/
│   │   └── quiz.dart                                slice barrel
│   │
│   ├── settings/                                  app settings
│   │   ├── ui/
│   │   │   └── settings_page.dart                   settings screen
│   │   └── settings.dart                            barrel
│   │
│   ├── tools/                                     tools hub (subslices)
│   │   ├── agreement/                               agreement practice subslice
│   │   │   ├── agreement.dart                         subslice barrel
│   │   │   └── agreement_page.dart                    ⚠️ STRUCTURE: page at subslice root, not in ui/
│   │   ├── conjugations/                            conjugation practice subslice
│   │   │   ├── conjugations.dart                      subslice barrel
│   │   │   └── conjugations_page.dart                 ⚠️ STRUCTURE: page at subslice root, not in ui/
│   │   ├── home/                                    tools hub subslice
│   │   │   ├── home.dart                              subslice barrel
│   │   │   └── tools_page.dart                        ⚠️ STRUCTURE: page at subslice root, not in ui/
│   │   └── tools.dart                               slice barrel
│   │
│   └── vocab/                                     vocabulary deck list
│       ├── ui/
│       │   └── vocab_deck_list_page.dart             deck list screen
│       └── vocab.dart                               barrel
│
├── widgets/                                     — reusable composed widgets
│   └── vocab/                                     vocabulary display widgets (subslices)
│       ├── daily_activity_card/                     activity card subslice
│       │   ├── daily_activity_card.dart                subslice barrel
│       │   └── vocab_daily_activity_card.dart          ⚠️ STRUCTURE: widget at subslice root, not in ui/
│       ├── deck_tile/                               deck tile subslice
│       │   ├── deck_tile.dart                         subslice barrel
│       │   ├── vocab_deck_tile.dart                    ⚠️ STRUCTURE: widget at subslice root, not in ui/
│       │   └── vocab_deck_tile_data.dart               ⚠️ STRUCTURE: model at subslice root, not in model/
│       ├── level_card/                              level card subslice
│       │   ├── level_card.dart                        subslice barrel
│       │   ├── vocab_level_card.dart                   ⚠️ STRUCTURE: widget at subslice root, not in ui/
│       │   └── vocab_level_stats_row.dart              ⚠️ STRUCTURE: widget at subslice root, not in ui/
│       └── vocab.dart                               slice barrel
│
├── shared/                                      — infrastructure, no domain
│   ├── app/                                       app-infrastructure subslice group
│   │   ├── config/                                  app + language settings
│   │   │   ├── model/
│   │   │   │   ├── app_settings.dart                    AppSettings data class
│   │   │   │   ├── decay_formula.dart                   DecayFormula enum
│   │   │   │   ├── lang_codes.dart                      LangCodes (language code constants)
│   │   │   │   ├── lang_grammar_profile.dart            LangGrammarProfile (per-language grammar rules)
│   │   │   │   └── language_settings.dart               LanguageSettings data class
│   │   │   ├── repository/
│   │   │   │   ├── app_settings_repository.dart          app_settings table CRUD
│   │   │   │   └── language_settings_repository.dart     language_settings table CRUD
│   │   │   ├── services/                              ⚠️ NAMING: plural
│   │   │   │   ├── config_internal_service.dart          revision signal, DB + repo providers
│   │   │   │   └── config_service.dart                   public reads + mutations
│   │   │   └── config.dart                              barrel
│   │   │
│   │   ├── database/                                  SQLite infrastructure
│   │   │   ├── model/
│   │   │   │   └── db_schema.dart                       DbSchema (table + column name constants)
│   │   │   ├── services/                              ⚠️ NAMING: plural
│   │   │   │   └── database_service.dart                DatabaseService (open, migration, provider)
│   │   │   └── database.dart                            barrel
│   │   │
│   │   ├── layout/                                    product layout constants
│   │   │   ├── model/
│   │   │   │   └── langwij_layout.dart                  LangwijLayout (product-specific dimensions)
│   │   │   └── layout.dart                              barrel
│   │   │
│   │   ├── routing/                                   route path constants
│   │   │   ├── model/
│   │   │   │   └── app_routes.dart                      AppRoutes (route path strings)
│   │   │   └── routing.dart                             barrel
│   │   │
│   │   ├── theme/                                     theme persistence
│   │   │   ├── services/                              ⚠️ NAMING: plural
│   │   │   │   └── theme_service.dart                   ThemeService (theme ID provider, load/save)
│   │   │   └── theme.dart                               barrel
│   │   │
│   │   ├── validators/                                startup validation
│   │   │   ├── services/                              ⚠️ NAMING: plural
│   │   │   │   ├── config_validator.dart                ConfigValidator (settings consistency checks)
│   │   │   │   └── startup_validator.dart               StartupValidator (language pack validation)
│   │   │   └── validators.dart                          barrel
│   │   │
│   │   └── app.dart                                   barrel (re-exports all subslice barrels)
│   │
│   ├── bug_report/                                bug report sheet
│   │   ├── model/
│   │   │   └── bug_report_type.dart                 BugReportType enum
│   │   ├── ui/
│   │   │   └── bug_report_sheet.dart                bug report bottom sheet
│   │   └── bug_report.dart                          barrel
│   │
│   ├── date_format/                               date formatting utilities
│   │   ├── model/
│   │   │   └── relative_date.dart                   RelativeDate helper
│   │   └── date_format.dart                         barrel
│   │
│   ├── deck_icons/                                deck icon mappings
│   │   ├── model/
│   │   │   └── deck_icons.dart                      DeckIcons (deck ID → icon mapping)
│   │   └── deck_icons.dart                          barrel
│   │
│   ├── dev_section/                               dev mode gate + tools
│   │   ├── services/                              ⚠️ NAMING: plural
│   │   │   └── dev_section_service.dart             DevSectionService (FlesselDevGate init)
│   │   └── dev_section.dart                         barrel
│   │
│   ├── nav_bar/                                   ⚠️ PLACEMENT: arguably boot-level, not shared
│   │   ├── ui/
│   │   │   └── main_nav_bar.dart                    MainNavBar (bottom navigation bar builder)
│   │   └── nav_bar.dart                             barrel
│
└── l10n/                                        — localization (outside FSD — Flutter convention)
    ├── app_en.arb                                 English strings (source of truth)
    ├── app_localizations.dart                     generated l10n
    ├── app_localizations_en.dart                  generated English
    └── app_localizations_ext.dart                 hand-written extension methods
```

---

## Violations Summary

### ⚠️ Naming violations (11 instances)

3. **Segment folder naming** — all `services/` folders use plural. Classel standard is `service/` (singular). Affects: every entity (4), every feature (1), every shared slice with services (5), pages/language (1).

### ⚠️ Structural violations (12 instances)

4. **Pages without ui/ segment** — 7 page subslices have page files directly at subslice root instead of in `ui/`: quiz/round, quiz/result, language/language, language/picker, tools/home, tools/conjugations, tools/agreement.

5. **Page service without service/ segment** — `pages/language/language/language_page_service.dart` sits at subslice root instead of in `service/`.

6. **Widgets without segments** — 4 widget subslice files sit at subslice root instead of in `ui/` or `model/`: deck_tile (2 ui + 1 model), level_card (2 ui), daily_activity_card (1 ui).

### ⚠️ Placement questions (pending decision)

7. **shared/nav_bar/** — builds the app's bottom navigation bar. Arguably belongs in `boot/` (app-wide wiring) rather than `shared/` (cross-cutting infrastructure).

8. **shared/app/routing/app_routes.dart** — route definitions arguably belong in `boot/` alongside the router.
