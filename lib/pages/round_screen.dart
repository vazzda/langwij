import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../entities/card/card_model.dart';
import '../entities/card/vocab_card.dart';
import '../entities/group/group_model.dart';
import '../l10n/app_localizations.dart';
import '../app/providers/groups_provider.dart';
import '../features/quiz/display_english.dart' show displayNativeForCard;
import '../features/quiz/quiz_mode.dart';
import '../features/quiz/quiz_options.dart';
import '../features/quiz/quiz_utils.dart';
import '../features/quiz/services/quiz_round_service.dart';
import '../features/quiz/round_notifier.dart';
import '../features/quiz/round_state.dart';
import '../app/router/app_router.dart';
import '../app/theme/vessel_themes.dart';
import '../shared/ui/buttons/vessel_buttons.dart';
import '../shared/ui/bottom_sheet/vessel_bottom_sheet.dart';
import 'package:srpski_card/shared/lib/group_label.dart';
import '../shared/ui/card/vessel_card.dart';
import '../shared/ui/note/vessel_note.dart';
import '../shared/ui/screen_layout/vessel_scaffold.dart';
import '../shared/ui/inputs/vessel_text_input.dart';
import '../shared/ui/answer_tile/vessel_answer_tile.dart';
import '../shared/ui/gap/vessel_gap.dart';
import '../app/layout/vessel_layout.dart';

class RoundScreen extends ConsumerStatefulWidget {
  const RoundScreen({super.key});

  @override
  ConsumerState<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends ConsumerState<RoundScreen> {
  final _writeController = TextEditingController();
  final _writeController2 = TextEditingController();
  final _writeFocusNode = FocusNode();
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

  /// Per-form wrong feedback for PairVocabCard. Non-null when showing pair feedback.
  ({String typed, String correct, bool ok})? _pairImperfective;
  ({String typed, String correct, bool ok})? _pairPerfective;

  final _correctLabelNotifier = ValueNotifier<({int seq, int col})>((
    seq: 0,
    col: -1,
  ));

  @override
  void dispose() {
    _writeController.dispose();
    _writeController2.dispose();
    _writeFocusNode.dispose();
    _correctLabelNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = VesselThemes.of(context);
    final round = ref.watch(roundProvider);
    final asyncGroups = ref.watch(groupsProvider);

    ref.listen<RoundState?>(roundProvider, (prev, next) {
      if (next != null && next.isFinished && !_hasFinalized) {
        _hasFinalized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await ref.read(quizRoundServiceProvider).persistRound();
          if (!context.mounted) return;
          context.go(AppRoutes.result);
        });
      }
    });

    if (round == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (round.isFinished) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final card = round.currentCard!;

    // Vocab rounds carry their own allCards; legacy/agreement need group lookup.
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
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    }

    final title =
        round.deckName ??
        (group != null
            ? groupLabel(l10n, group.labelKey)
            : (round.roundType == RoundType.agreement
                  ? l10n.parentAgreement
                  : ''));
    final allCardsForOptions =
        round.allCards ??
        (round.roundType == RoundType.agreement ? round.queue : group!.cards);
    final promptText = _buildPromptText(card, round.mode, l10n);
    final correctAnswer = round.mode == QuizMode.targetShown
        ? card.nativeText
        : card.targetAnswer;

    return VesselScaffold(
      title: title,
      actions: [
        IconButton(
          icon: const Icon(PhosphorIconsRegular.x),
          tooltip: l10n.exitRound,
          onPressed: () => _showExitConfirm(context, ref, l10n),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(VesselLayout.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.correctCount(round.correctCount),
                  style: VesselFonts.textScore.copyWith(color: t.accentColor),
                ),
                Text(
                  l10n.questionsLeft(round.queue.length),
                  style: VesselFonts.textScore.copyWith(color: t.textPrimary),
                ),
              ],
            ),
            const VesselGap.l(),
            VesselCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    promptText,
                    style: VesselFonts.textPrompt.copyWith(
                      color: t.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (card is VocabCard &&
                      (round.mode == QuizMode.targetShown
                              ? card.targetNote
                              : card.nativeNote) !=
                          null) ...[
                    const VesselGap.s(),
                    VesselNote(
                      text: round.mode == QuizMode.targetShown
                          ? card.targetNote!
                          : card.nativeNote!,
                    ),
                  ],
                  if (card is PairVocabCard &&
                      round.mode == QuizMode.write) ...[
                    const VesselGap.s(),
                    VesselNote(text: l10n.quiz_aspectPairPrompt),
                  ],
                ],
              ),
            ),
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _CorrectLabel(notifier: _correctLabelNotifier),
                _buildInteractiveSection(
                  context,
                  round,
                  card,
                  correctAnswer,
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
    String correctAnswer,
    List<CardModel> allCardsForOptions,
    WidgetRef ref,
    AppLocalizations l10n,
    VesselThemeData t,
  ) {
    if (_wrongFeedback != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_pairImperfective != null && _pairPerfective != null) ...[
            Text(
              _pairImperfective!.ok ? l10n.correct : l10n.wrong,
              style: VesselFonts.textContentHeader.copyWith(
                color: _pairImperfective!.ok ? t.accentColor : t.dangerColor,
              ),
            ),
            const VesselGap.s(),
            Text(
              '${l10n.quiz_aspectImperfective} ${_pairImperfective!.typed.isEmpty ? l10n.emptyAnswer : _pairImperfective!.typed}',
              style: VesselFonts.textBodyLarge.copyWith(
                color: _pairImperfective!.ok ? t.textPrimary : t.dangerColor,
              ),
            ),
            if (!_pairImperfective!.ok) ...[
              const VesselGap.xs(),
              Text(
                '${l10n.correctAnswerLabel} ${_pairImperfective!.correct}',
                style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
              ),
            ],
            const VesselGap.l(),
            Text(
              _pairPerfective!.ok ? l10n.correct : l10n.wrong,
              style: VesselFonts.textContentHeader.copyWith(
                color: _pairPerfective!.ok ? t.accentColor : t.dangerColor,
              ),
            ),
            const VesselGap.s(),
            Text(
              '${l10n.quiz_aspectPerfective} ${_pairPerfective!.typed.isEmpty ? l10n.emptyAnswer : _pairPerfective!.typed}',
              style: VesselFonts.textBodyLarge.copyWith(
                color: _pairPerfective!.ok ? t.textPrimary : t.dangerColor,
              ),
            ),
            if (!_pairPerfective!.ok) ...[
              const VesselGap.xs(),
              Text(
                '${l10n.correctAnswerLabel} ${_pairPerfective!.correct}',
                style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
              ),
            ],
          ] else ...[
            Text(
              l10n.wrong,
              style: VesselFonts.textContentHeader.copyWith(
                color: t.dangerColor,
              ),
            ),
            const VesselGap.s(),
            Text(
              '${round.mode == QuizMode.write ? l10n.youWrote : l10n.youPicked} ${(_wrongUserAnswerDisplay ?? '').isEmpty ? l10n.emptyAnswer : _wrongUserAnswerDisplay}',
              style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
            ),
            const VesselGap.s(),
            Text(
              '${l10n.correctAnswerLabel} ${_wrongFeedbackDisplay ?? _wrongFeedback}',
              style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
            ),
          ],
          const VesselGap.xl(),
          VesselAccentButton(
            label: l10n.next,
            onPressed: () => _onNextAfterWrong(ref),
          ),
        ],
      );
    }

    if (round.mode == QuizMode.write) {
      if (card is PairVocabCard) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.quiz_aspectImperfective,
              style: VesselFonts.textBodyLarge.copyWith(
                color: t.textPrimary,
              ),
            ),
            const VesselGap.s(),
            VesselTextInput(
              controller: _writeController,
              focusNode: _writeFocusNode,
              autofocus: true,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const VesselGap.m(),
            Text(
              l10n.quiz_aspectPerfective,
              style: VesselFonts.textBodyLarge.copyWith(
                color: t.textPrimary,
              ),
            ),
            const VesselGap.s(),
            VesselTextInput(
              controller: _writeController2,
              onSubmitted: (_) => _submitWritePair(context, ref),
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const VesselGap.l(),
            VesselAccentButton(
              label: l10n.submit,
              onPressed: () => _submitWritePair(context, ref),
            ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.yourAnswer,
            style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
          ),
          const VesselGap.s(),
          VesselTextInput(
            controller: _writeController,
            focusNode: _writeFocusNode,
            onSubmitted: (_) => _submitWrite(context, ref),
            autofocus: true,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
          ),
          const VesselGap.l(),
          VesselAccentButton(
            label: l10n.submit,
            onPressed: () => _submitWrite(context, ref),
          ),
        ],
      );
    }

    return _buildOptionsTileGrid(
      context,
      round.mode,
      card,
      correctAnswer,
      allCardsForOptions,
      ref,
      l10n,
    );
  }

  void _fireCorrectLabel({int col = -1}) {
    _correctLabelNotifier.value = (
      seq: _correctLabelNotifier.value.seq + 1,
      col: col,
    );
  }

  void _showExitConfirm(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final roundContext = context;
    final t = VesselThemes.of(context);
    showVesselBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.exitRound,
            style: VesselFonts.textSheetTitle.copyWith(color: t.textPrimary),
          ),
          const VesselGap.m(),
          Text(
            l10n.exitRoundConfirm,
            style: VesselFonts.textSheetContent.copyWith(color: t.textPrimary),
          ),
          const VesselGap.xl(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              VesselTextButton(
                label: l10n.cancel,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
              const VesselGap.hs(),
              VesselDangerTextButton(
                label: l10n.exit,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  final originRoute = ref
                      .read(quizRoundServiceProvider)
                      .endRound();
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

  void _onNextAfterWrong(WidgetRef ref) {
    ref
        .read(roundProvider.notifier)
        .answerWrong(userTypedAnswer: _wrongUserTypedAnswer);
    setState(() {
      _wrongFeedback = null;
      _wrongFeedbackDisplay = null;
      _wrongUserTypedAnswer = null;
      _wrongUserAnswerDisplay = null;
      _pairImperfective = null;
      _pairPerfective = null;
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

  void _submitWritePair(BuildContext context, WidgetRef ref) {
    final round = ref.read(roundProvider);
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

    if (ok1 && ok2) {
      _fireCorrectLabel();
      ref.read(roundProvider.notifier).answerCorrect();
      _requestWriteFocus();
    } else {
      setState(() {
        _wrongFeedback = card.targetAnswer;
        _wrongFeedbackDisplay = null;
        _wrongUserTypedAnswer = '$raw1 / $raw2';
        _wrongUserAnswerDisplay = null;
        _pairImperfective = (
          typed: raw1,
          correct: card.imperfectiveText,
          ok: ok1,
        );
        _pairPerfective = (typed: raw2, correct: card.perfectiveText, ok: ok2);
      });
    }
    _writeController.clear();
    _writeController2.clear();
  }

  Widget _buildOptionsTileGrid(
    BuildContext context,
    QuizMode mode,
    CardModel correctCard,
    String correctAnswer,
    List<CardModel> allCards,
    WidgetRef ref,
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
            (e) => VesselAnswerTile(
              label: displayNativeForCard(e.$2, l10n),
              onTap: () => _onOptionSelectedSerbianShown(
                context,
                ref,
                correctCard,
                e.$2,
                allCards,
                l10n,
                col: e.$1 % 2,
              ),
            ),
          )
          .toList();
    } else {
      final options = buildMultipleChoiceOptions(
        mode: mode,
        correctAnswer: correctAnswer,
        allCards: allCards,
        random: _random,
      );
      tiles = options.indexed
          .map(
            (e) => VesselAnswerTile(
              label: e.$2,
              onTap: () => _onOptionSelectedEnglishShown(
                context,
                ref,
                correctCard,
                e.$2,
                allCards,
                l10n,
                col: e.$1 % 2,
              ),
            ),
          )
          .toList();
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: VesselLayout.gapS,
      mainAxisSpacing: VesselLayout.gapS,
      childAspectRatio: VesselLayout.roundOptionTileAspectRatio,
      children: tiles,
    );
  }

  void _onOptionSelectedSerbianShown(
    BuildContext context,
    WidgetRef ref,
    CardModel correctCard,
    CardModel chosenCard,
    List<CardModel> allCards,
    AppLocalizations l10n, {
    required int col,
  }) {
    final validAnswers = validAnswersForPrompt(
      currentCard: correctCard,
      mode: QuizMode.targetShown,
      allCards: allCards,
    );
    if (validAnswers.contains(chosenCard.nativeText)) {
      _fireCorrectLabel(col: col);
      ref.read(roundProvider.notifier).answerCorrect();
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
    CardModel correctCard,
    String chosen,
    List<CardModel> allCards,
    AppLocalizations l10n, {
    required int col,
  }) {
    final validAnswers = validAnswersForPrompt(
      currentCard: correctCard,
      mode: QuizMode.nativeShown,
      allCards: allCards,
    );
    if (validAnswers.contains(chosen)) {
      _fireCorrectLabel(col: col);
      ref.read(roundProvider.notifier).answerCorrect();
    } else {
      setState(() {
        _wrongFeedback = correctCard.targetAnswer;
        _wrongFeedbackDisplay = correctCard.targetAnswer;
        _wrongUserTypedAnswer = null;
        _wrongUserAnswerDisplay = chosen;
      });
    }
  }

  void _submitWrite(BuildContext context, WidgetRef ref) {
    final round = ref.read(roundProvider);
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
    if (isCorrect) {
      _fireCorrectLabel();
      ref.read(roundProvider.notifier).answerCorrect();
      _requestWriteFocus();
    } else {
      final l10n = AppLocalizations.of(context)!;
      final display = round.mode == QuizMode.targetShown
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

// =============================================================================
// Correct label animation (private to round screen)
// =============================================================================

const _correctLabelEnterMs = 100;
const _correctLabelHoldMs = 250;
const _correctLabelExitMs = 100;
const _correctLabelDuration = Duration(
  milliseconds:
      _correctLabelEnterMs + _correctLabelHoldMs + _correctLabelExitMs,
);

class _CorrectLabel extends StatefulWidget {
  const _CorrectLabel({required this.notifier});

  final ValueNotifier<({int seq, int col})> notifier;

  @override
  State<_CorrectLabel> createState() => _CorrectLabelState();
}

class _CorrectLabelState extends State<_CorrectLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _col = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _correctLabelDuration,
    );
    widget.notifier.addListener(_onEvent);
  }

  void _onEvent() {
    _col = widget.notifier.value.col;
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
    final t = VesselThemes.of(context);
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
                _correctLabelEnterMs +
                _correctLabelHoldMs +
                _correctLabelExitMs;
            const enterEnd = _correctLabelEnterMs / totalMs;
            const holdEnd =
                (_correctLabelEnterMs + _correctLabelHoldMs) / totalMs;

            final v = _controller.value;
            final double opacity;
            final double offsetY;

            if (v <= enterEnd) {
              // Stage 1: fade in + rise from tile area
              final p = v / enterEnd;
              opacity = p;
              offsetY = -10.0 * p;
            } else if (v <= holdEnd) {
              // Stage 2: hold
              opacity = 1.0;
              offsetY = -10.0;
            } else {
              // Stage 3: fade out + rise further
              final p = (v - holdEnd) / (1.0 - holdEnd);
              opacity = 1.0 - p;
              offsetY = -10.0 - (40.0 * p);
            }

            final label = Text(
              l10n.correct.toUpperCase(),
              style: VesselFonts.textContentHeader.copyWith(
                color: t.roundAnswerTileCorrectColor,
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
                  const SizedBox(width: VesselLayout.gapS),
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
