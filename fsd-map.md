# FSD Map — Langwij Front

Structural map of `lib/`. Every level, every slice, every file.
Generated from actual filesystem + import analysis.

## Structure

```
lib/
├── boot/                                        — app-level wiring, no domain
│   ├── initialization.dart                        AppInitialization: DB open, config load, splash, dev gate
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
│   │   │   ├── grammatical_gender.dart              GrammaticalGender enum (gender of a noun)
│   │   │   ├── lang_entry.dart                      LangEntry
│   │   │   ├── language_entry.dart                   LanguageEntry
│   │   │   ├── language_pack.dart                    LanguagePack (per-language asset data)
│   │   │   ├── level.dart                           Level data class
│   │   │   ├── level_meta.dart                      LevelMeta
│   │   │   ├── level_tier.dart                      LevelTier enum
│   │   │   ├── part_of_speech.dart                  PartOfSpeech enum (type of a word)
│   │   │   ├── plan_note.dart                       PlanNote (title and text of a note of plan.json)
│   │   │   ├── term.dart                            Term data class
│   │   │   ├── translation_entry.dart               TranslationEntry
│   │   │   ├── verb_aspect.dart                     VerbAspect enum (aspect of a verb that stands alone)
│   │   │   ├── vocab_deck_model.dart                VocabDeckModel
│   │   │   ├── vocabulary_level_segment.dart        VocabularyLevelSegment (segment id + its level ids)
│   │   │   └── vocabulary_level_segment_meta.dart   VocabularyLevelSegmentMeta (segment name)
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
│   │   ├── model/
│   │   │   └── progress_seed.dart                   ProgressSeed (typed developer seed; coverage of each deck's terms)
│   │   └── services/
│   │       ├── seed_loader_service.dart              SeedLoaderService (seed asset → progress tables)
│   │       └── dev_data_service.dart                 DevDataService (wipe + seed + revision orchestration)
│   │
│   ├── pronunciation/                             term audio + web lookup cascade
│   │   ├── model/
│   │   │   ├── pronunciation_config.dart            per-language speech locales + define queries
│   │   │   └── pronunciation_route.dart             PronunciationRoute enum (voice → define → translate)
│   │   ├── services/
│   │   │   └── pronunciation_service.dart           PronunciationService (3-tier cascade owner)
│   │   └── pronunciation.dart                       barrel
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
│   │   │   └── ui/
│   │   │       └── language_page.dart                  language selection screen
│   │   └── picker/                                  language picker subslice
│   │       └── ui/
│   │           └── lang_picker_page.dart               language picker screen
│   │
│   ├── progress/                                  progress overview
│   │   ├── service/
│   │   │   └── progress_page_service.dart           ProgressPageService (reset language progress)
│   │   └── ui/
│   │       └── progress_page.dart                   progress stats + language progression screen
│   │
│   ├── quiz/                                      quiz screens (subslices)
│   │   ├── result/                                  quiz result subslice
│   │   │   └── ui/
│   │   │       └── result_page.dart                    quiz result screen
│   │   └── round/                                   quiz round subslice
│   │       └── ui/
│   │           ├── round_page.dart                     quiz round screen
│   │           ├── term_example.dart                   TermExample widget (a term's example behind its label, its marked word in bold)
│   │           ├── term_info_section.dart              TermInfoSection widget (a term's frequency, type and specifics, line under line)
│   │           └── term_title.dart                     TermTitle widget (the word of a card as its title, capitalised)
│   │
│   ├── settings/                                  app settings
│   │   └── ui/
│   │       └── settings_page.dart                   settings screen
│   │
│   ├── tools/                                     tools — drill levels for conjugations + agreement
│   │   └── home/                                    tools page subslice
│   │       └── ui/
│   │           └── tools_page.dart                     tools page with foldable drill levels
│   │
│   ├── specialized/                               specialized vocabulary
│   │   └── ui/
│   │       └── specialized_vocab_page.dart            specialized vocab deck screen
│   │
│   └── vocab/                                     main vocabulary screen
│       ├── model/
│       │   └── vocab_fold_state.dart                VocabFoldState (unfolded segment + unfolded level)
│       ├── service/
│       │   ├── vocab_fold_state_notifier_service.dart VocabFoldStateNotifierService (fold state for one app run, started from the training history)
│       │   └── vocab_page_service.dart              VocabPageService (fold state provider, segment sections)
│       └── ui/
│           └── vocab_deck_list_page.dart             foldable segments with their level cards
│
├── widgets/                                     — reusable composed widgets
│   ├── drill/                                     drill practice display widgets (subslices)
│   │   ├── group_card/                              drill group card subslice
│   │   │   ├── model/
│   │   │   │   ├── drill_group_card_data.dart           DrillGroupCardData
│   │   │   │   └── drill_level_data.dart                DrillLevelData
│   │   │   ├── ui/
│   │   │   │   └── drill_group_card.dart                LangwijDrillGroupCard widget
│   │   │   └── group_card.dart                        barrel (exports model/)
│   │   ├── level_card/                              drill level card subslice
│   │   │   └── ui/
│   │   │       └── drill_level_card.dart               LangwijDrillLevelCard widget
│   │   └── drill.dart                               slice barrel (re-exports group_card)
│   └── vocab/                                     vocabulary display widgets (subslices)
│       ├── daily_activity_card/                     activity card subslice
│       │   └── ui/
│       │       └── vocab_daily_activity_card.dart      daily activity card widget
│       ├── deck_card/                               deck card subslice
│       │   ├── model/
│       │   │   ├── vocab_deck_card_data.dart            VocabDeckCardData
│       │   │   ├── vocab_deck_study_phase.dart          VocabDeckStudyPhase enum (not started, studying, training)
│       │   │   └── vocab_level_data.dart                VocabLevelData
│       │   ├── service/
│       │   │   └── vocab_level_data_builder_service.dart VocabLevelDataBuilderService (level + deck display data)
│       │   ├── ui/
│       │   │   ├── vocab_deck_card.dart                 LangwijVocabDeckCard widget
│       │   │   └── vocab_deck_icon.dart                 LangwijVocabDeckIcon widget (deck glyph in a box on the controls surface)
│       │   └── deck_card.dart                         barrel (exports model/ + service/)
│       ├── elements/                                elements shared by the vocab widgets
│       │   └── ui/
│       │       ├── vocab_counted_name_list.dart         LangwijVocabCountedNameList widget (term count + names; preview or full)
│       │       ├── vocab_mastery_star.dart              LangwijVocabMasteryStar widget (one star of the practice box, by kind)
│       │       └── vocab_mastery_stars.dart             LangwijVocabMasteryStars widget (practice box: finished practices as stars; collapsed or expanded)
│       ├── level_accordion/                         level accordion subslice
│       │   └── ui/
│       │       ├── vocab_level_accordion.dart           LangwijVocabLevelAccordion widget (a segment's levels as one block)
│       │       └── vocab_level_accordion_item.dart      LangwijVocabLevelAccordionItem widget (one level + its decks)
│       ├── segment_section/                         segment section subslice
│       │   ├── model/
│       │   │   └── vocab_segment_section_data.dart      VocabSegmentSectionData
│       │   ├── ui/
│       │   │   └── vocab_segment_section.dart           LangwijVocabSegmentSection widget
│       │   └── segment_section.dart                   barrel (exports model/)
│       ├── training_summary/                        training summary subslice
│       │   └── ui/
│       │       └── vocab_training_summary.dart          LangwijVocabTrainingSummary widget (what the mode sheet is about to train: title, counted names, studied and mastery bars, practice box, test button)
│       └── vocab.dart                               slice barrel (re-exports deck_card, segment_section)
│
├── shared/                                      — infrastructure, no domain
│   ├── app/                                       app-infrastructure subslice group
│   │   ├── config/                                  app + language settings
│   │   │   ├── model/
│   │   │   │   ├── app_settings.dart                    AppSettings data class
│   │   │   │   ├── decay_formula.dart                   DecayFormula enum
│   │   │   │   ├── lang_codes.dart                      LangCodes (language code constants, flag + interface script lookups)
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
│   │   ├── ui/
│   │   │   └── developer_gate_config_builder.dart   DeveloperGateConfigBuilder (password-gate config for the developer section)
│   │   └── dev_section.dart                         barrel
│   │
│   ├── flag/                                      country flag in a border
│   │   └── ui/
│   │       └── flag.dart                            LangwijFlag widget + LangwijFlagSize (the three sizes a flag is drawn at)
│   │
│   ├── keep_in_view/                              scroll-into-view for unfolded items
│   │   └── ui/
│   │       └── keep_unfolded_in_view.dart           LangwijKeepUnfoldedInView (keeps a newly unfolded item's top on screen)
│   │
│   └── nav_bar/                                   bottom navigation bar
│       ├── model/
│       │   └── main_nav_destination.dart            MainNavDestination enum (bottom-bar destinations + route paths)
│       └── ui/
│           ├── langwij_scaffold.dart                 LangwijScaffold (app scaffold with shared navbar + app bar actions)
│           └── main_nav_bar.dart                    LangwijMainNavBar (navbar items + index resolver)
│
└── l10n/                                        — localization (outside FSD — Flutter convention)
    ├── app_en.arb                                 English strings (template, source of truth for keys)
    ├── app_<code>.arb                             translations: ru, sr, de, fr, es, it, pt
    ├── app_localizations.dart                     generated l10n
    ├── app_localizations_<code>.dart              generated per language: en, ru, sr, de, fr, es, it, pt
    └── app_localizations_ext.dart                 hand-written extension methods
```

---

## Known Accepted Deviations

### Naming: `services/` plural (10 instances)

All service segment folders use plural `services/` instead of classel-standard singular `service/`. Accepted as-is — not scheduled for rename. Affects: entities (4), features/quiz (1), shared slices (5).
