import 'package:flutter/material.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/entities/progress/progress.dart';

class AnswerFeedback {
  const AnswerFeedback({
    required this.isCorrect,
    required this.correctAnswer,
    this.correctAnswerDisplay,
    this.userTypedAnswer,
    this.userAnswerDisplay,
    this.pairImperfective,
    this.pairPerfective,
  });

  final bool isCorrect;
  final String correctAnswer;
  final String? correctAnswerDisplay;
  final String? userTypedAnswer;
  final String? userAnswerDisplay;
  final ({String typed, String correct, bool ok})? pairImperfective;
  final ({String typed, String correct, bool ok})? pairPerfective;
}

class AnswerFeedbackCard extends StatelessWidget {
  const AnswerFeedbackCard({
    super.key,
    required this.feedback,
    required this.mode,
    required this.onNext,
  });

  final AnswerFeedback feedback;
  final QuizMode mode;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;

    return FlesselCard(
      margin: FlesselSize.none,
      colorVariant: feedback.isCorrect
          ? FlesselVariant.success
          : FlesselVariant.danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (feedback.pairImperfective != null &&
              feedback.pairPerfective != null) ...[
          Text(
            feedback.pairImperfective!.ok ? l10n.correct : l10n.wrong,
            style: FlesselFonts.contentXxxlAccent.copyWith(
              color: feedback.pairImperfective!.ok
                  ? t.accentColor
                  : t.dangerColor,
            ),
          ),
          const FlesselGap.s(),
          Text(
            '${l10n.quiz_aspectImperfective} ${feedback.pairImperfective!.typed.isEmpty ? l10n.emptyAnswer : feedback.pairImperfective!.typed}',
            style: FlesselFonts.contentL.copyWith(
              color:
                  feedback.pairImperfective!.ok ? t.fg : t.dangerColor,
            ),
          ),
          if (!feedback.pairImperfective!.ok) ...[
            const FlesselGap.xs(),
            Text(
              '${l10n.correctAnswerLabel} ${feedback.pairImperfective!.correct}',
              style: FlesselFonts.contentL.copyWith(color: t.fg),
            ),
          ],
          const FlesselGap.l(),
          Text(
            feedback.pairPerfective!.ok ? l10n.correct : l10n.wrong,
            style: FlesselFonts.contentXxxlAccent.copyWith(
              color: feedback.pairPerfective!.ok
                  ? t.accentColor
                  : t.dangerColor,
            ),
          ),
          const FlesselGap.s(),
          Text(
            '${l10n.quiz_aspectPerfective} ${feedback.pairPerfective!.typed.isEmpty ? l10n.emptyAnswer : feedback.pairPerfective!.typed}',
            style: FlesselFonts.contentL.copyWith(
              color:
                  feedback.pairPerfective!.ok ? t.fg : t.dangerColor,
            ),
          ),
          if (!feedback.pairPerfective!.ok) ...[
            const FlesselGap.xs(),
            Text(
              '${l10n.correctAnswerLabel} ${feedback.pairPerfective!.correct}',
              style: FlesselFonts.contentL.copyWith(color: t.fg),
            ),
          ],
        ] else ...[
          Text(
            feedback.isCorrect ? l10n.correct : l10n.wrong,
            style: FlesselFonts.contentXxxlAccent.copyWith(
              color: feedback.isCorrect ? t.accentColor : t.dangerColor,
            ),
          ),
          const FlesselGap.s(),
          Text(
            '${mode == QuizMode.write ? l10n.youWrote : l10n.youPicked} ${(feedback.userAnswerDisplay ?? '').isEmpty ? l10n.emptyAnswer : feedback.userAnswerDisplay}',
            style: FlesselFonts.contentL.copyWith(color: t.fg),
          ),
          if (!feedback.isCorrect) ...[
            const FlesselGap.s(),
            Text(
              '${l10n.correctAnswerLabel} ${feedback.correctAnswerDisplay ?? feedback.correctAnswer}',
              style: FlesselFonts.contentL.copyWith(color: t.fg),
            ),
          ],
        ],
          const FlesselGap.xl(),
          FlesselButton(
            variant: FlesselVariant.accent,
            label: l10n.next,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
