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
│   │   ├── services/
│   │   │   ├── activity_internal_service.dart        revision signal, internal providers
│   │   │   └── activity_service.dart                 mutations + public providers
│   │   └── activity.dart                            barrel
│   │
│   ├── dictionary/                                language packs, decks, terms
│   │   ├── @x/
│   │   │   └── progress.dart                        cross-entity API for progress consumers
│   │   ├── model/
│   │   │   ├── deck_meta.dart                       DeckMeta
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
│   │   ├── services/
│   │   │   ├── dictionary_internal_service.dart      revision signal, internal providers
│   │   │   └── dictionary_service.dart               public reads
│   │   └── dictionary.dart                          barrel
│   │
│   ├── group/                                     card groups: vocab decks + conjugation tables
│   │   ├── model/
│   │   │   ├── adjective_card.dart                  AdjectiveCard implements CardModel
│   │   │   ├── card_model.dart                      CardModel interface
│   │   │   ├── ending_card.dart                     EndingCard implements CardModel
│   │   │   ├── group_model.dart                     GroupModel, GroupType, GroupCategory enums
│   │   │   ├── noun_card.dart                       NounCard implements CardModel
│   │   │   ├── phrase_card.dart                     PhraseCard implements CardModel
│   │   │   ├── test_result.dart                     TestResult data class
│   │   │   └── word_card.dart                       WordCard implements CardModel
│   │   ├── repository/
│   │   │   ├── group_repository.dart                group loading from dictionary data
│   │   │   └── test_result_repository.dart           test score persistence (SQLite)
│   │   ├── services/
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
│       ├── services/
│       │   ├── progress_internal_service.dart        revision signal, internal providers
│       │   └── progress_service.dart                 public reads + writes
│       └── progress.dart                            barrel
│
├── features/                                    — cross-cutting product features
│   ├── dev_tools/                                 dev infrastructure
│   │   ├── dev_tools.dart                         barrel
│   │   └── services/
│   │       ├── seed_loader_service.dart              SeedLoaderService (JSON → DB seed loading)
│   │       └── dev_data_service.dart                 DevDataService (wipe + seed + revision orchestration)
│   │
│   └── quiz/                                      quiz round lifecycle
│       ├── model/
│       │   ├── missed_entry.dart                    MissedEntry (card + user typed answer)
│       │   ├── mode_selection.dart                  ModeSelection (mode + isTest)
│       │   ├── round_state.dart                     RoundState (queue, scores, origin route)
│       │   ├── round_type.dart                      RoundType enum (vocabulary, conjugations, agreement)
│       │   └── vocab_card.dart                      VocabCard extends CardModel
│       ├── services/
│       │   ├── agreement_round_builder_service.dart  AgreementRoundBuilderService (agreement queue builder)
│       │   ├── card_generation_service.dart          CardGenerationService (vocab card building)
│       │   ├── quiz_options_service.dart             QuizOptionsService (multiple choice options)
│       │   ├── quiz_round_state_notifier_service.dart QuizRoundStateNotifierService (round state Notifier)
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
│   │   │   ├── service/
│   │   │   │   └── language_page_service.dart          LanguagePageService
│   │   │   └── ui/
│   │   │       └── language_page.dart                  language settings screen
│   │   └── picker/                                  language picker subslice
│   │       └── ui/
│   │           └── lang_picker_page.dart               language picker screen
│   │
│   ├── progress/                                  progress overview
│   │   └── ui/
│   │       └── progress_page.dart                   progress stats screen
│   │
│   ├── quiz/                                      quiz screens (subslices)
│   │   ├── result/                                  quiz result subslice
│   │   │   └── ui/
│   │   │       └── result_page.dart                    quiz result screen
│   │   └── round/                                   quiz round subslice
│   │       └── ui/
│   │           └── round_page.dart                     quiz round screen
│   │
│   ├── settings/                                  app settings
│   │   └── ui/
│   │       └── settings_page.dart                   settings screen
│   │
│   ├── tools/                                     tools hub (subslices)
│   │   ├── agreement/                               agreement practice subslice
│   │   │   └── ui/
│   │   │       └── agreement_page.dart                 agreement practice screen
│   │   ├── conjugations/                            conjugation practice subslice
│   │   │   └── ui/
│   │   │       └── conjugations_page.dart              conjugation practice screen
│   │   └── home/                                    tools hub subslice
│   │       └── ui/
│   │           └── tools_page.dart                     tools hub screen
│   │
│   ├── specialized/                               specialized vocabulary
│   │   └── ui/
│   │       └── specialized_vocab_page.dart            specialized vocab deck screen
│   │
│   └── vocab/                                     vocabulary deck list
│       └── ui/
│           └── vocab_deck_list_page.dart             deck list screen
│
├── widgets/                                     — reusable composed widgets
│   └── vocab/                                     vocabulary display widgets (subslices)
│       ├── daily_activity_card/                     activity card subslice
│       │   └── ui/
│       │       └── vocab_daily_activity_card.dart      daily activity card widget
│       ├── deck_card/                               deck card subslice
│       │   ├── model/
│       │   │   ├── vocab_deck_card_data.dart            VocabDeckCardData
│       │   │   └── vocab_level_data.dart                VocabLevelData
│       │   ├── ui/
│       │   │   └── vocab_deck_card.dart                 LangwijVocabDeckCard widget
│       │   └── deck_card.dart                         barrel (exports model/)
│       ├── level_card/                              level card subslice
│       │   └── ui/
│       │       ├── vocab_level_card.dart                LangwijVocabLevelCard widget
│       │       └── vocab_level_stats_row.dart           LangwijVocabLevelStatsRow widget
│       └── vocab.dart                               slice barrel (re-exports deck_card)
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
│   │   │   ├── services/
│   │   │   │   ├── config_internal_service.dart          revision signal, DB + repo providers
│   │   │   │   └── config_service.dart                   public reads + mutations
│   │   │   └── config.dart                              barrel
│   │   │
│   │   ├── database/                                  SQLite infrastructure
│   │   │   ├── model/
│   │   │   │   └── db_schema.dart                       DbSchema (table + column name constants)
│   │   │   ├── services/
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
│   │   │   ├── services/
│   │   │   │   └── theme_service.dart                   ThemeService (theme ID provider, load/save)
│   │   │   └── theme.dart                               barrel
│   │   │
│   │   ├── validators/                                startup validation
│   │   │   ├── model/
│   │   │   │   ├── config_validation_error.dart          ConfigValidationError
│   │   │   │   └── core_validation_ids.dart              CoreValidationIds
│   │   │   ├── services/
│   │   │   │   ├── config_validation_service.dart        ConfigValidationService (settings consistency checks)
│   │   │   │   └── startup_validation_service.dart       StartupValidationService (language pack validation)
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
│   │   ├── services/
│   │   │   ├── dev_section_gate_notifier_service.dart DevSectionGateNotifierService
│   │   │   └── dev_section_service.dart             DevSectionService (FlesselDevGate init)
│   │   └── dev_section.dart                         barrel
│   │
│   └── nav_bar/                                   bottom navigation bar
│       └── ui/
│           ├── langwij_scaffold.dart                 LangwijScaffold (app scaffold with shared navbar + app bar actions)
│           └── main_nav_bar.dart                    LangwijMainNavBar (navbar items + index resolver)
│
└── l10n/                                        — localization (outside FSD — Flutter convention)
    ├── app_en.arb                                 English strings (source of truth)
    ├── app_localizations.dart                     generated l10n
    ├── app_localizations_en.dart                  generated English
    └── app_localizations_ext.dart                 hand-written extension methods
```

---

## Known Accepted Deviations

### Naming: `services/` plural (10 instances)

All service segment folders use plural `services/` instead of classel-standard singular `service/`. Accepted as-is — not scheduled for rename. Affects: entities (4), features/quiz (1), shared slices (5).
