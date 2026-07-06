import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import 'package:langwij/entities/activity/activity.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/app/layout/layout.dart';
import 'package:langwij/shared/nav_bar/ui/langwij_scaffold.dart';
import 'package:langwij/widgets/vocab/daily_activity_card/ui/vocab_daily_activity_card.dart';
import '../service/progress_page_service.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = FlesselThemes.of(context);
    final asyncStats = ref.watch(ActivityService.todayStats);
    final asyncAllPacks = ref.watch(DictionaryService.allPacks);
    final asyncAllLangProgress =
        ref.watch(ProgressService.allLanguagesProgress);
    final showDevSection = FlesselDevGate.enabled.value;

    return LangwijScaffold(
      title: l10n.navProgress,
      child: asyncAllPacks.when(
        loading: () => const Center(child: FlesselSpinner()),
        error: (_, _) => Center(child: Text(l10n.loadError)),
        data: (packs) {
          final packByCode = {for (final p in packs) p.code: p};

          return ListView(
            padding: FlesselLayout.screenPaddingInsets(context).copyWith(
              bottom: FlesselLayout.screenPaddingInsets(context).bottom +
                  LangwijScaffold.navbarSpacer(context),
            ),
            children: [
              LangwijVocabDailyActivityCard(
                asyncStats: asyncStats,
                l10n: l10n,
              ),
              const FlesselGap.xl(),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
                child: Text(
                  l10n.language_progression,
                  style:
                      FlesselFonts.contentXxlAccent.copyWith(color: t.fg),
                ),
              ),
              _LanguageProgressionCard(
                asyncProgress: asyncAllLangProgress,
                packByCode: packByCode,
                l10n: l10n,
                onReset: (langCode) => _confirmResetLanguageProgress(
                    context, ref, langCode, packByCode, l10n),
              ),
              if (showDevSection) ...[
                const FlesselGap.xl(),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: FlesselLayout.listItemGap),
                  child: Text(
                    l10n.language_incompleteDictionaries,
                    style: FlesselFonts.contentXxlAccent
                        .copyWith(color: t.fg),
                  ),
                ),
                _IncompleteDictionariesCard(
                  packs: packs.where((p) => !p.isPublic).toList(),
                  l10n: l10n,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

void _confirmResetLanguageProgress(
  BuildContext context,
  WidgetRef ref,
  String langCode,
  Map<String, LanguagePack> packByCode,
  AppLocalizations l10n,
) {
  final langName = packByCode[langCode] != null
      ? l10n.langLabel(packByCode[langCode]!.labelKey)
      : langCode;
  showFlesselBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final t = FlesselThemes.of(sheetContext);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.language_resetConfirmTitle,
            style: FlesselFonts.contentXxlAccent.copyWith(color: t.fg),
          ),
          const FlesselGap.m(),
          Text(
            l10n.language_resetConfirmBody(langName),
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
              FlesselButton(
                variant: FlesselVariant.danger,
                label: l10n.language_resetButton,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  ref
                      .read(ProgressPageService.instance)
                      .resetLanguageProgress(langCode);
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

class _LanguageProgressionCard extends StatelessWidget {
  const _LanguageProgressionCard({
    required this.asyncProgress,
    required this.packByCode,
    required this.l10n,
    required this.onReset,
  });

  final AsyncValue<Map<String, double>> asyncProgress;
  final Map<String, LanguagePack> packByCode;
  final AppLocalizations l10n;
  final ValueChanged<String> onReset;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    return FlesselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          asyncProgress.when(
            data: (langProgress) {
              final entries = langProgress.entries
                  .where((e) => e.value > 0 && packByCode.containsKey(e.key))
                  .toList();
              if (entries.isEmpty) {
                return FlesselNote(text: l10n.language_progressionEmpty);
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(entries.length, (i) {
                    final e = entries[i];
                    final pack = packByCode[e.key]!;
                    final label = l10n.langLabel(pack.labelKey);
                    final pct = (e.value * 100).round();
                    final countryCode = LangCodes.flagCountryCode(e.key);
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: i < entries.length - 1
                              ? FlesselLayout.listItemGapSmall
                              : 0),
                      child: Row(
                        children: [
                          if (countryCode != null) ...[
                            CountryFlag.fromCountryCode(
                              countryCode,
                              theme: const ImageTheme(
                                width:
                                    LangwijLayout.langProgressionFlagWidth,
                                height:
                                    LangwijLayout.langProgressionFlagHeight,
                                shape: RoundedRectangle(
                                    LangwijLayout
                                        .langProgressionFlagBorderRadius),
                              ),
                            ),
                            const FlesselGap.s(),
                          ],
                          SizedBox(
                            width: LangwijLayout.langProgressLabelWidth,
                            child: Text(
                              label,
                              style: FlesselFonts.contentMAccent.copyWith(
                                color: t.fgSecondary,
                              ),
                            ),
                          ),
                          const FlesselGap.s(),
                          Expanded(
                            child: FlesselProgressBar(
                              value: e.value,
                              mode: FlesselProgressBarMode.detailed,
                            ),
                          ),
                          const FlesselGap.s(),
                          SizedBox(
                            width: LangwijLayout.langProgressPercentWidth,
                            child: Text(
                              '$pct%',
                              textAlign: TextAlign.end,
                              style: FlesselFonts.contentS.copyWith(
                                color: t.fg,
                              ),
                            ),
                          ),
                          const FlesselGap.s(),
                          FlesselButton(
                            icon: PhosphorIconsRegular.trash,
                            size: FlesselSize.s,
                            onPressed: () => onReset(e.key),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _IncompleteDictionariesCard extends StatelessWidget {
  const _IncompleteDictionariesCard({
    required this.packs,
    required this.l10n,
  });

  final List<LanguagePack> packs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (packs.isEmpty) return const SizedBox.shrink();
    final t = FlesselThemes.of(context);
    return FlesselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(packs.length, (i) {
            final p = packs[i];
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    i < packs.length - 1 ? FlesselLayout.listItemGapSmall : 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.langLabel(p.labelKey),
                      style:
                          FlesselFonts.contentS.copyWith(color: t.fgSecondary),
                    ),
                  ),
                  Text(
                    l10n.language_termsCount(p.translatedCount, p.totalTerms),
                    style:
                        FlesselFonts.contentS.copyWith(color: t.dangerColor),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
