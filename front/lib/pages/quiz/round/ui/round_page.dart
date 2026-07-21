import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/features/quiz/quiz.dart';
import 'package:langwij/features/quiz/ui/answer_tile.dart';
import 'package:langwij/features/quiz/ui/display_english.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import 'package:langwij/shared/app/layout/layout.dart';

import 'answer_feedback_card.dart';
import 'term_detail_card.dart';

class RoundPage extends ConsumerStatefulWidget {
  const RoundPage({super.key});

  @override
  ConsumerState<RoundPage> createState() => _RoundPageState();
}

class _RoundPageState extends ConsumerState<RoundPage> {
  final _writeController = TextEditingController();
  final _writeController2 = TextEditingController();
  final _writeFocusNode = FocusNode();
  final _random = Random();
  bool _hasFinalized = false;

  AnswerFeedback? _answerFeedback;

  final _answerFeedbackPopupNotifier =
      ValueNotifier<({int seq, int col, bool isCorrect})>((
    seq: 0,
    col: -1,
    isCorrect: true,
  ));

  @override
  void dispose() {
    _writeController.dispose();
    _writeController2.dispose();
    _writeFocusNode.dispose();
    _answerFeedbackPopupNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = FlesselThemes.of(context);
    final round = ref.watch(QuizService.round);
    final asyncGroups = ref.watch(GroupService.groups);

    ref.listen<RoundState?>(QuizService.round, (prev, next) {
      if (next != null && next.isFinished && !_hasFinalized) {
        _hasFinalized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await ref.read(QuizService.instance).persistRound();
          if (!context.mounted) return;
          context.go(AppRoutes.result);
        });
      }
    });

    if (round == null) {
      return const Scaffold(body: Center(child: FlesselSpinner()));
    }

    if (round.isFinished) {
      return const Scaffold(body: Center(child: FlesselSpinner()));
    }

    final card = round.currentCard!;

    GroupModel? group;
    if (round.allCards == null) {
      final groupsList = asyncGroups.valueOrNull;
      final lookupId = round.roundType == RoundType.agreement
          ? round.adjectiveGroupId
          : round.deckId;
      if (lookupId != null && groupsList != null) {
        try {
          group = groupsList.firstWhere((g) => g.id == lookupId);
        } catch (_) {
          group = null;
        }
      }
      if (round.roundType != RoundType.agreement && group == null) {
        return const Scaffold(body: Center(child: FlesselSpinner()));
      }
    }

    final title =
        round.deckName ??
        (group != null
            ? l10n.groupLabel(group.labelKey)
            : (round.roundType == RoundType.agreement
                  ? l10n.parentAgreement
                  : ''));
    final allCardsForOptions =
        round.allCards ??
        (round.roundType == RoundType.agreement ? round.queue : group!.cards);
    final promptText = _buildPromptText(card, round.mode, l10n);

    return FlesselScaffold(
      title: title,
      uppercaseTitle: true,
      appBarActions: [
        IconButton(
          icon: const Icon(PhosphorIconsRegular.x),
          tooltip: l10n.exitRound,
          onPressed: () => _showExitConfirm(context, ref, l10n),
        ),
      ],
      child: Padding(
        padding: FlesselLayout.screenPaddingInsets(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.correctCount(round.correctCount),
                  style: FlesselFonts.displayM.copyWith(color: t.accentColor),
                ),
                Text(
                  l10n.questionsLeft(round.queue.length),
                  style: FlesselFonts.displayM.copyWith(color: t.fg),
                ),
              ],
            ),
            const FlesselGap.l(),
            _answerFeedback != null &&
                    _answerFeedback!.isCorrect &&
                    !round.isTest &&
                    card is VocabCard
                ? TermDetailCard(card: card)
                : FlesselCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          promptText,
                          style: FlesselFonts.contentXxxlAccent.copyWith(
                            color: t.fg,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (card is VocabCard &&
                            (round.mode == QuizMode.targetShown
                                    ? card.targetNote
                                    : card.nativeNote) !=
                                null) ...[
                          const FlesselGap.s(),
                          FlesselNote(
                            text: round.mode == QuizMode.targetShown
                                ? card.targetNote!
                                : card.nativeNote!,
                          ),
                        ],
                        if (card is PairVocabCard &&
                            round.mode == QuizMode.write) ...[
                          const FlesselGap.s(),
                          FlesselNote(text: l10n.quiz_aspectPairPrompt),
                        ],
                      ],
                    ),
                  ),
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _AnswerFeedbackPopup(notifier: _answerFeedbackPopupNotifier),
                _buildInteractiveSection(
                  context,
                  round,
                  card,
                  allCardsForOptions,
                  ref,
                  l10n,
                  t,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveSection(
    BuildContext context,
    RoundState round,
    CardModel card,
    List<CardModel> allCardsForOptions,
    WidgetRef ref,
    AppLocalizations l10n,
    FlesselThemeData t,
  ) {
    if (_answerFeedback != null) {
      return AnswerFeedbackCard(
        feedback: _answerFeedback!,
        mode: round.mode,
        onNext: () => _onNextAfterFeedback(ref),
      );
    }

    if (round.mode == QuizMode.write) {
      if (card is PairVocabCard) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.quiz_aspectImperfective,
              style: FlesselFonts.contentL.copyWith(color: t.fg),
            ),
            const FlesselGap.s(),
            FlesselTextInput(
              controller: _writeController,
              focusNode: _writeFocusNode,
              autofocus: true,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const FlesselGap.m(),
            Text(
              l10n.quiz_aspectPerfective,
              style: FlesselFonts.contentL.copyWith(color: t.fg),
            ),
            const FlesselGap.s(),
            FlesselTextInput(
              controller: _writeController2,
              onSubmitted: (_) => _submitWritePair(ref),
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const FlesselGap.l(),
            FlesselButton(
              variant: FlesselVariant.accent,
              label: l10n.submit,
              onPressed: () => _submitWritePair(ref),
            ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.yourAnswer,
            style: FlesselFonts.contentL.copyWith(color: t.fg),
          ),
          const FlesselGap.s(),
          FlesselTextInput(
            controller: _writeController,
            focusNode: _writeFocusNode,
            onSubmitted: (_) => _submitWrite(context, ref),
            autofocus: true,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
          ),
          const FlesselGap.l(),
          FlesselButton(
            variant: FlesselVariant.accent,
            label: l10n.submit,
            onPressed: () => _submitWrite(context, ref),
          ),
        ],
      );
    }

    return _buildOptionsTileGrid(
      round.mode,
      card,
      allCardsForOptions,
      l10n,
    );
  }

  void _fireAnswerFeedbackPopup({required bool isCorrect, int col = -1}) {
    _answerFeedbackPopupNotifier.value = (
      seq: _answerFeedbackPopupNotifier.value.seq + 1,
      col: col,
      isCorrect: isCorrect,
    );
  }

  void _showExitConfirm(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final roundContext = context;
    final t = FlesselThemes.of(context);
    showFlesselBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.exitRound,
            style: FlesselFonts.contentXxlAccent.copyWith(color: t.fg),
          ),
          const FlesselGap.m(),
          Text(
            l10n.exitRoundConfirm,
            style: FlesselFonts.contentM.copyWith(color: t.fg),
          ),
          const FlesselGap.xl(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlesselTextButton(
                label: l10n.cancel,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
              const FlesselGap.s(),
              FlesselTextButton(
                variant: FlesselVariant.danger,
                label: l10n.exit,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  final originRoute = ref.read(QuizService.instance).endRound();
                  if (roundContext.mounted) {
                    roundContext.go(originRoute);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTestModeAnswer(
    WidgetRef ref, {
    required bool isCorrect,
    String? userTypedAnswer,
  }) {
    _fireAnswerFeedbackPopup(isCorrect: isCorrect);
    if (isCorrect) {
      ref.read(QuizService.round.notifier).answerCorrect();
    } else {
      ref
          .read(QuizService.round.notifier)
          .answerWrong(userTypedAnswer: userTypedAnswer);
    }
    _writeController.clear();
    _writeController2.clear();
    _requestWriteFocus();
  }

  void _showAnswerFeedbackDetail({
    required bool isCorrect,
    required String correctAnswer,
    String? correctAnswerDisplay,
    String? userTypedAnswer,
    String? userAnswerDisplay,
    ({String typed, String correct, bool ok})? pairImperfective,
    ({String typed, String correct, bool ok})? pairPerfective,
  }) {
    setState(() {
      _answerFeedback = AnswerFeedback(
        isCorrect: isCorrect,
        correctAnswer: correctAnswer,
        correctAnswerDisplay: correctAnswerDisplay,
        userTypedAnswer: userTypedAnswer,
        userAnswerDisplay: userAnswerDisplay,
        pairImperfective: pairImperfective,
        pairPerfective: pairPerfective,
      );
    });
  }

  void _onNextAfterFeedback(WidgetRef ref) {
    final feedback = _answerFeedback!;
    if (feedback.isCorrect) {
      ref.read(QuizService.round.notifier).answerCorrect();
    } else {
      ref
          .read(QuizService.round.notifier)
          .answerWrong(userTypedAnswer: feedback.userTypedAnswer);
    }
    setState(() {
      _answerFeedback = null;
    });
    _writeController.clear();
    _writeController2.clear();
    _requestWriteFocus();
  }

  void _requestWriteFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _writeFocusNode.requestFocus();
    });
  }

  String _buildPromptText(
    CardModel card,
    QuizMode mode,
    AppLocalizations l10n,
  ) {
    if (card is EndingCard) {
      return mode == QuizMode.targetShown
          ? '${card.pronoun} ${card.targetText}'
          : displayNativeForCard(card, l10n);
    }
    return mode == QuizMode.targetShown ? card.targetText : card.nativeText;
  }

  void _submitWritePair(WidgetRef ref) {
    final round = ref.read(QuizService.round);
    if (round == null || round.currentCard == null) return;
    final card = round.currentCard! as PairVocabCard;

    final raw1 = _writeController.text.trim();
    final raw2 = _writeController2.text.trim();
    final ok1 =
        normalizeForComparison(raw1) ==
        normalizeForComparison(card.imperfectiveText);
    final ok2 =
        normalizeForComparison(raw2) ==
        normalizeForComparison(card.perfectiveText);
    final isCorrect = ok1 && ok2;

    if (round.isTest) {
      _handleTestModeAnswer(
        ref,
        isCorrect: isCorrect,
        userTypedAnswer: isCorrect ? null : '$raw1 / $raw2',
      );
      return;
    }

    _showAnswerFeedbackDetail(
      isCorrect: isCorrect,
      correctAnswer: card.targetAnswer,
      userTypedAnswer: '$raw1 / $raw2',
      userAnswerDisplay: '$raw1 / $raw2',
      pairImperfective: isCorrect
          ? null
          : (typed: raw1, correct: card.imperfectiveText, ok: ok1),
      pairPerfective: isCorrect
          ? null
          : (typed: raw2, correct: card.perfectiveText, ok: ok2),
    );
    _writeController.clear();
    _writeController2.clear();
  }

  Widget _buildOptionsTileGrid(
    QuizMode mode,
    CardModel correctCard,
    List<CardModel> allCards,
    AppLocalizations l10n,
  ) {
    final List<Widget> tiles;
    if (mode == QuizMode.targetShown) {
      final optionCards = buildMultipleChoiceOptionCards(
        correctCard: correctCard,
        allCards: allCards,
        random: _random,
      );
      tiles = optionCards.indexed
          .map(
            (e) => LangwijAnswerTile(
              label: displayNativeForCard(e.$2, l10n),
              onTap: () => _onOptionSelectedSerbianShown(
                correctCard,
                e.$2,
                allCards,
                l10n,
              ),
            ),
          )
          .toList();
    } else {
      final options = buildMultipleChoiceOptions(
        mode: mode,
        correctAnswer: correctCard.targetAnswer,
        allCards: allCards,
        random: _random,
      );
      tiles = options.indexed
          .map(
            (e) => LangwijAnswerTile(
              label: e.$2,
              onTap: () => _onOptionSelectedEnglishShown(
                correctCard,
                e.$2,
                allCards,
                l10n,
              ),
            ),
          )
          .toList();
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: FlesselLayout.gapS,
      mainAxisSpacing: FlesselLayout.gapS,
      childAspectRatio: LangwijLayout.roundOptionTileAspectRatio,
      children: tiles,
    );
  }

  void _onOptionSelectedSerbianShown(
    CardModel correctCard,
    CardModel chosenCard,
    List<CardModel> allCards,
    AppLocalizations l10n,
  ) {
    final validAnswers = validAnswersForPrompt(
      currentCard: correctCard,
      mode: QuizMode.targetShown,
      allCards: allCards,
    );
    final isCorrect = validAnswers.contains(chosenCard.nativeText);
    _showAnswerFeedbackDetail(
      isCorrect: isCorrect,
      correctAnswer: correctCard.nativeText,
      correctAnswerDisplay: displayNativeForCard(correctCard, l10n),
      userAnswerDisplay: displayNativeForCard(chosenCard, l10n),
    );
  }

  void _onOptionSelectedEnglishShown(
    CardModel correctCard,
    String chosen,
    List<CardModel> allCards,
    AppLocalizations l10n,
  ) {
    final validAnswers = validAnswersForPrompt(
      currentCard: correctCard,
      mode: QuizMode.nativeShown,
      allCards: allCards,
    );
    final isCorrect = validAnswers.contains(chosen);
    _showAnswerFeedbackDetail(
      isCorrect: isCorrect,
      correctAnswer: correctCard.targetAnswer,
      correctAnswerDisplay: correctCard.targetAnswer,
      userAnswerDisplay: chosen,
    );
  }

  void _submitWrite(BuildContext context, WidgetRef ref) {
    final round = ref.read(QuizService.round);
    if (round == null || round.currentCard == null) return;
    final card = round.currentCard!;
    final allCards = round.allCards ?? [];
    final correctAnswer = round.mode == QuizMode.targetShown
        ? card.nativeText
        : card.targetAnswer;
    final raw = _writeController.text.trim();
    final normalized = normalizeForComparison(raw);
    final validAnswers = validAnswersForPrompt(
      currentCard: card,
      mode: round.mode,
      allCards: allCards,
    );
    final isCorrect = validAnswers
        .any((a) => normalizeForComparison(a) == normalized);

    if (round.isTest) {
      _handleTestModeAnswer(
        ref,
        isCorrect: isCorrect,
        userTypedAnswer: isCorrect ? null : raw,
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final display = round.mode == QuizMode.targetShown
        ? displayNativeForCard(card, l10n)
        : correctAnswer;
    _showAnswerFeedbackDetail(
      isCorrect: isCorrect,
      correctAnswer: correctAnswer,
      correctAnswerDisplay: display,
      userTypedAnswer: raw,
      userAnswerDisplay: raw,
    );
    _writeController.clear();
  }
}

const _answerFeedbackPopupEnterMs = 100;
const _answerFeedbackPopupHoldMs = 250;
const _answerFeedbackPopupExitMs = 100;
const _answerFeedbackPopupDuration = Duration(
  milliseconds:
      _answerFeedbackPopupEnterMs +
      _answerFeedbackPopupHoldMs +
      _answerFeedbackPopupExitMs,
);

class _AnswerFeedbackPopup extends StatefulWidget {
  const _AnswerFeedbackPopup({required this.notifier});

  final ValueNotifier<({int seq, int col, bool isCorrect})> notifier;

  @override
  State<_AnswerFeedbackPopup> createState() => _AnswerFeedbackPopupState();
}

class _AnswerFeedbackPopupState extends State<_AnswerFeedbackPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _col = -1;
  bool _isCorrect = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _answerFeedbackPopupDuration,
    );
    widget.notifier.addListener(_onEvent);
  }

  void _onEvent() {
    _col = widget.notifier.value.col;
    _isCorrect = widget.notifier.value.isCorrect;
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onEvent);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (!_controller.isAnimating && _controller.value == 0.0) {
              return const SizedBox.shrink();
            }

            const totalMs =
                _answerFeedbackPopupEnterMs +
                _answerFeedbackPopupHoldMs +
                _answerFeedbackPopupExitMs;
            const enterEnd = _answerFeedbackPopupEnterMs / totalMs;
            const holdEnd =
                (_answerFeedbackPopupEnterMs + _answerFeedbackPopupHoldMs) /
                totalMs;

            final v = _controller.value;
            final double opacity;
            final double offsetY;

            if (v <= enterEnd) {
              final p = v / enterEnd;
              opacity = p;
              offsetY = -10.0 * p;
            } else if (v <= holdEnd) {
              opacity = 1.0;
              offsetY = -10.0;
            } else {
              final p = (v - holdEnd) / (1.0 - holdEnd);
              opacity = 1.0 - p;
              offsetY = -10.0 - (40.0 * p);
            }

            final labelText = _isCorrect ? l10n.correct : l10n.wrong;
            final labelColor = _isCorrect ? t.accentColor : t.dangerColor;
            final label = Text(
              labelText.toUpperCase(),
              style: FlesselFonts.contentXxxlAccent.copyWith(
                color: labelColor,
              ),
            );

            final Widget positioned;
            if (_col < 0) {
              positioned = Center(child: label);
            } else {
              positioned = Row(
                children: [
                  Expanded(
                    child: _col == 0
                        ? Center(child: label)
                        : const SizedBox.shrink(),
                  ),
                  const FlesselGap.s(),
                  Expanded(
                    child: _col == 1
                        ? Center(child: label)
                        : const SizedBox.shrink(),
                  ),
                ],
              );
            }

            return FractionalTranslation(
              translation: const Offset(0, -1),
              child: Transform.translate(
                offset: Offset(0, offsetY),
                child: Opacity(opacity: opacity, child: positioned),
              ),
            );
          },
        ),
      ),
    );
  }
}
