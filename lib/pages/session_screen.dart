import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../entities/card/card_model.dart';
import '../entities/card/vocab_card.dart';
import '../entities/group/group_model.dart';
import '../l10n/app_localizations.dart';
import '../app/providers/groups_provider.dart';
import '../features/quiz/display_english.dart' show displayNativeForCard;
import '../features/quiz/quiz_mode.dart';
import '../features/quiz/quiz_options.dart';
import '../features/quiz/quiz_utils.dart';
import '../features/quiz/services/quiz_session_service.dart';
import '../features/quiz/session_notifier.dart';
import '../features/quiz/session_state.dart';
import '../app/router/app_router.dart';
import '../app/theme/app_themes.dart';
import '../shared/ui/buttons/project_buttons.dart';
import '../shared/ui/bottom_sheet/project_bottom_sheet.dart';
import 'package:srpski_card/shared/lib/group_label.dart';
import '../shared/ui/card/project_card.dart';
import '../shared/ui/note/project_note.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';
import '../shared/ui/inputs/project_text_input.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  final _writeController = TextEditingController();
  final _writeController2 = TextEditingController();
  final _random = Random();
  bool _hasFinalized = false;
  /// When non-null, user just answered wrong; show this correct answer and Next.
  String? _wrongFeedback;
  /// Display form of correct answer (Ti/Vi expanded in English). Shown in UI.
  String? _wrongFeedbackDisplay;
  /// In Write mode, what the user typed when they got it wrong (for result screen).
  String? _wrongUserTypedAnswer;
  /// Text to show as "the answer you gave" in wrong-feedback block (all modes).
  String? _wrongUserAnswerDisplay;

  @override
  void dispose() {
    _writeController.dispose();
    _writeController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = AppThemes.of(context);
    final session = ref.watch(sessionProvider);
    final asyncGroups = ref.watch(groupsProvider);

    ref.listen<SessionState?>(sessionProvider, (prev, next) {
      if (next != null && next.isFinished && !_hasFinalized) {
        _hasFinalized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await ref.read(quizSessionServiceProvider).persistSession();
          if (!context.mounted) return;
          context.go(AppRoutes.result);
        });
      }
    });

    if (session == null) {
      // Session ended - navigation should already be handled by exit button
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (session.isFinished) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final card = session.currentCard!;

    // Vocab sessions carry their own allCards; legacy/agreement need group lookup.
    GroupModel? group;
    if (session.allCards == null) {
      final groupsList = asyncGroups.valueOrNull;
      final lookupId = session.sessionType == SessionType.agreement
          ? session.adjectiveGroupId
          : session.groupId;
      if (lookupId != null && groupsList != null) {
        try {
          group = groupsList.firstWhere((g) => g.id == lookupId);
        } catch (_) {
          group = null;
        }
      }
      if (session.sessionType != SessionType.agreement && group == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    }

    final title = session.groupLabelKey != null
        ? groupLabel(l10n, session.groupLabelKey!)
        : (group != null
            ? groupLabel(l10n, group.labelKey)
            : (session.sessionType == SessionType.agreement
                ? l10n.parentAgreement
                : ''));
    final allCardsForOptions = session.allCards
        ?? (session.sessionType == SessionType.agreement
            ? session.queue
            : group!.cards);
    final promptText = _buildPromptText(card, session.mode, l10n);
    final correctAnswer = session.mode == QuizMode.targetShown
        ? card.nativeText
        : card.targetAnswer;

    return ScreenLayoutWidget(
      title: title,
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.exitSession,
          onPressed: () => _showExitConfirm(context, ref, l10n),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.correctCount(session.correctCount),
                  style: AppFontStyles.textScore.copyWith(color: t.accentColor),
                ),
                Text(
                  l10n.questionsLeft(session.queue.length),
                  style: AppFontStyles.textScore.copyWith(color: t.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProjectCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    promptText,
                    style: AppFontStyles.textPrompt.copyWith(color: t.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  if (card is VocabCard &&
                      (session.mode == QuizMode.targetShown
                              ? card.targetNote
                              : card.nativeNote) !=
                          null) ...[
                    const SizedBox(height: 8),
                    ProjectNote(
                      text: session.mode == QuizMode.targetShown
                          ? card.targetNote!
                          : card.nativeNote!,
                    ),
                  ],
                  if (card is PairVocabCard &&
                      session.mode == QuizMode.write) ...[
                    const SizedBox(height: 8),
                    ProjectNote(text: l10n.quiz_aspectPairPrompt),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_wrongFeedback != null) ...[
              Text(
                l10n.wrong,
                style: AppFontStyles.textContentHeader.copyWith(color: t.dangerColor),
              ),
              const SizedBox(height: 8),
              Text(
                '${session.mode == QuizMode.write ? l10n.youWrote : l10n.youPicked} ${(_wrongUserAnswerDisplay ?? '').isEmpty ? l10n.emptyAnswer : _wrongUserAnswerDisplay}',
                style: AppFontStyles.textBodyLarge.copyWith(color: t.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.correctAnswerLabel} ${_wrongFeedbackDisplay ?? _wrongFeedback}',
                style: AppFontStyles.textBodyLarge.copyWith(color: t.textPrimary),
              ),
              const SizedBox(height: 24),
              AccentButton(
                label: l10n.next,
                onPressed: () => _onNextAfterWrong(ref),
              ),
            ] else if (session.mode == QuizMode.write) ...[
              if (card is PairVocabCard) ...[
                Text(
                  l10n.quiz_aspectImperfective,
                  style: AppFontStyles.textControlLabel.copyWith(color: t.textPrimary),
                ),
                const SizedBox(height: 8),
                ProjectTextInput(
                  controller: _writeController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.quiz_aspectPerfective,
                  style: AppFontStyles.textControlLabel.copyWith(color: t.textPrimary),
                ),
                const SizedBox(height: 8),
                ProjectTextInput(
                  controller: _writeController2,
                  onSubmitted: (_) => _submitWritePair(context, ref),
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 16),
                AccentButton(
                  label: l10n.submit,
                  onPressed: () => _submitWritePair(context, ref),
                ),
              ] else ...[
                Text(
                  l10n.yourAnswer,
                  style: AppFontStyles.textControlLabel.copyWith(color: t.textPrimary),
                ),
                const SizedBox(height: 8),
                ProjectTextInput(
                  controller: _writeController,
                  onSubmitted: (_) => _submitWrite(context, ref),
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 16),
                AccentButton(
                  label: l10n.submit,
                  onPressed: () => _submitWrite(context, ref),
                ),
              ],
            ] else ...[
              ..._buildOptions(
                context,
                session.mode,
                card,
                correctAnswer,
                allCardsForOptions,
                ref,
                l10n,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExitConfirm(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final sessionContext = context;
    final t = AppThemes.of(context);
    showProjectBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.exitSession,
            style: AppFontStyles.textSheetTitle.copyWith(color: t.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.exitSessionConfirm,
            style: AppFontStyles.textSheetContent.copyWith(color: t.textPrimary),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ProjectTextButton(
                label: l10n.cancel,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
              const SizedBox(width: 8),
              DangerTextButton(
                label: l10n.exit,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  final originRoute =
                      ref.read(quizSessionServiceProvider).endSession();
                  if (sessionContext.mounted) {
                    sessionContext.go(originRoute);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onNextAfterWrong(WidgetRef ref) {
    ref.read(sessionProvider.notifier).answerWrong(userTypedAnswer: _wrongUserTypedAnswer);
    setState(() {
      _wrongFeedback = null;
      _wrongFeedbackDisplay = null;
      _wrongUserTypedAnswer = null;
      _wrongUserAnswerDisplay = null;
    });
    _writeController.clear();
    _writeController2.clear();
  }

  String _buildPromptText(CardModel card, QuizMode mode, AppLocalizations l10n) {
    if (card is EndingCard) {
      return mode == QuizMode.targetShown
          ? '${card.pronoun} ${card.targetText}'
          : displayNativeForCard(card, l10n);
    }
    return mode == QuizMode.targetShown ? card.targetText : card.nativeText;
  }

  void _submitWritePair(BuildContext context, WidgetRef ref) {
    final session = ref.read(sessionProvider);
    if (session == null || session.currentCard == null) return;
    final card = session.currentCard! as PairVocabCard;

    final raw1 = _writeController.text.trim();
    final raw2 = _writeController2.text.trim();
    final ok1 = normalizeForComparison(raw1) ==
        normalizeForComparison(card.imperfectiveText);
    final ok2 = normalizeForComparison(raw2) ==
        normalizeForComparison(card.perfectiveText);

    if (ok1 && ok2) {
      ref.read(sessionProvider.notifier).answerCorrect();
    } else {
      setState(() {
        _wrongFeedback = card.targetAnswer;
        _wrongFeedbackDisplay = card.targetAnswer;
        _wrongUserTypedAnswer = '$raw1 / $raw2';
        _wrongUserAnswerDisplay = '$raw1 / $raw2';
      });
    }
    _writeController.clear();
    _writeController2.clear();
  }

  List<Widget> _buildOptions(
    BuildContext context,
    QuizMode mode,
    CardModel correctCard,
    String correctAnswer,
    List<CardModel> allCards,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    if (mode == QuizMode.targetShown) {
      final optionCards = buildMultipleChoiceOptionCards(
        correctCard: correctCard,
        allCards: allCards,
        random: _random,
      );
      return optionCards
          .map(
            (optionCard) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: BaseButton(
                label: displayNativeForCard(optionCard, l10n),
                onPressed: () => _onOptionSelectedSerbianShown(context, ref, correctCard, optionCard, l10n),
              ),
            ),
          )
          .toList();
    }
    final options = buildMultipleChoiceOptions(
      mode: mode,
      correctAnswer: correctAnswer,
      allCards: allCards,
      random: _random,
    );
    return options
        .map(
          (opt) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BaseButton(
              label: opt,
              onPressed: () => _onOptionSelectedEnglishShown(context, ref, correctAnswer, opt, l10n),
            ),
          ),
        )
        .toList();
  }

  void _onOptionSelectedSerbianShown(
    BuildContext context,
    WidgetRef ref,
    CardModel correctCard,
    CardModel chosenCard,
    AppLocalizations l10n,
  ) {
    if (identical(chosenCard, correctCard)) {
      ref.read(sessionProvider.notifier).answerCorrect();
    } else {
      setState(() {
        _wrongFeedback = correctCard.nativeText;
        _wrongFeedbackDisplay = displayNativeForCard(correctCard, l10n);
        _wrongUserTypedAnswer = null;
        _wrongUserAnswerDisplay = displayNativeForCard(chosenCard, l10n);
      });
    }
  }

  void _onOptionSelectedEnglishShown(
    BuildContext context,
    WidgetRef ref,
    String correctAnswer,
    String chosen,
    AppLocalizations l10n,
  ) {
    if (chosen == correctAnswer) {
      ref.read(sessionProvider.notifier).answerCorrect();
    } else {
      setState(() {
        _wrongFeedback = correctAnswer;
        _wrongFeedbackDisplay = correctAnswer;
        _wrongUserTypedAnswer = null;
        _wrongUserAnswerDisplay = chosen;
      });
    }
  }

  void _submitWrite(BuildContext context, WidgetRef ref) {
    final session = ref.read(sessionProvider);
    if (session == null || session.currentCard == null) return;
    final card = session.currentCard!;
    final correctAnswer = session.mode == QuizMode.targetShown
        ? card.nativeText
        : card.targetAnswer;
    final raw = _writeController.text.trim();
    final normalized = normalizeForComparison(raw);
    final expected = normalizeForComparison(correctAnswer);
    if (normalized == expected) {
      ref.read(sessionProvider.notifier).answerCorrect();
    } else {
      final l10n = AppLocalizations.of(context)!;
      final display = session.mode == QuizMode.targetShown
          ? displayNativeForCard(card, l10n)
          : correctAnswer;
      setState(() {
        _wrongFeedback = correctAnswer;
        _wrongFeedbackDisplay = display;
        _wrongUserTypedAnswer = raw;
        _wrongUserAnswerDisplay = raw;
      });
    }
    _writeController.clear();
  }
}
