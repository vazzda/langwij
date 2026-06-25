import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'language_page_service.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/shared/nav_bar/ui/main_nav_bar.dart';
import 'package:langwij/shared/app/layout/layout.dart';
import '../picker/lang_picker_page.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = FlesselThemes.of(context);
    final asyncLangSettings = ref.watch(ConfigService.languageSettings);
    final asyncAllPacks = ref.watch(DictionaryService.allPacks);
    final asyncAllLangProgress = ref.watch(ProgressService.allLanguagesProgress);
    final asyncCourseNote = ref.watch(DictionaryService.courseNote);
    final asyncSettings = ref.watch(ConfigService.appSettings);
    final showDevSection = FlesselDevGate.enabled.value;

    final langSettings = asyncLangSettings.valueOrNull;
    final settings = asyncSettings.valueOrNull;

    if (langSettings == null || settings == null) {
      return FlesselScaffold(
        title: l10n.navLanguage,
        uppercaseTitle: true,
        navBarItems: LangwijMainNavBar.items(context),
        navBarCurrentIndex: LangwijMainNavBar.currentIndex(context),
        notchedNavBar: true,
        navBarSize: FlesselSize.xs,
        floatingActionButton: LangwijMainNavBar.fab(context),
        child: const Center(child: FlesselSpinner()),
      );
    }

    return FlesselScaffold(
      title: l10n.navLanguage,
      uppercaseTitle: true,
      navBarItems: LangwijMainNavBar.items(context),
      navBarCurrentIndex: LangwijMainNavBar.currentIndex(context),
      notchedNavBar: true,
      navBarSize: FlesselSize.xs,
      floatingActionButton: LangwijMainNavBar.fab(context),
      child: asyncAllPacks.when(
        loading: () => const Center(child: FlesselSpinner()),
        error: (_, _) => Center(child: Text(l10n.loadError)),
        data: (packs) {
          final packByCode = {for (final p in packs) p.code: p};

          return ListView(
            padding: FlesselLayout.screenPaddingInsets(context).copyWith(
              bottom: FlesselLayout.screenPaddingInsets(context).bottom + FlesselLayout.navbarSpacer(context),
            ),
            children: [
              _LangPairSelector(
                packByCode: packByCode,
                nativeCode: langSettings.nativeLang,
                targetCode: langSettings.targetLang,
                l10n: l10n,
                onNativeSelected: (code) =>
                    ref.read(ConfigService.instance).setNativeLang(code),
                onTargetSelected: (code) =>
                    ref.read(ConfigService.instance).setTargetLang(code),
              ),
              ..._buildLanguageNotes(
                packByCode: packByCode,
                nativeCode: langSettings.nativeLang,
                targetCode: langSettings.targetLang,
                asyncCourseNote: asyncCourseNote,
                l10n: l10n,
              ),
              const FlesselGap.xl(),

              Padding(
                padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
                child: Text(
                  l10n.language_progression,
                  style: FlesselFonts.contentXxlAccent.copyWith(color: t.fg),
                ),
              ),
              _ProgressionCard(
                asyncProgress: asyncAllLangProgress,
                packByCode: packByCode,
                l10n: l10n,
                onReset: (langCode) => _confirmReset(context, ref, langCode, packByCode, l10n),
              ),
              const FlesselGap.xl(),

              Padding(
                padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
                child: Text(
                  l10n.settingsDecaySpeed,
                  style: FlesselFonts.contentXxlAccent.copyWith(color: t.fg),
                ),
              ),
              _DecayOption(
                title: l10n.decayRelaxed,
                description: l10n.decayRelaxedDesc,
                isSelected: settings.decayFormula == DecayFormula.relaxed,
                onTap: () => ref.read(ConfigService.instance).setDecayFormula(DecayFormula.relaxed),
              ),
              const FlesselGap.s(),
              _DecayOption(
                title: l10n.decayStandard,
                description: l10n.decayStandardDesc,
                isSelected: settings.decayFormula == DecayFormula.standard,
                onTap: () => ref.read(ConfigService.instance).setDecayFormula(DecayFormula.standard),
              ),
              const FlesselGap.s(),
              _DecayOption(
                title: l10n.decayIntensive,
                description: l10n.decayIntensiveDesc,
                isSelected: settings.decayFormula == DecayFormula.intensive,
                onTap: () => ref.read(ConfigService.instance).setDecayFormula(DecayFormula.intensive),
              ),
              const FlesselGap.s(),
              _DecayOption(
                title: l10n.decayHardcore,
                description: l10n.decayHardcoreDesc,
                isSelected: settings.decayFormula == DecayFormula.hardcore,
                onTap: () => ref.read(ConfigService.instance).setDecayFormula(DecayFormula.hardcore),
              ),

              if (showDevSection) ...[
                const FlesselGap.xl(),
                Padding(
                  padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
                  child: Text(
                    l10n.language_incompleteDictionaries,
                    style: FlesselFonts.contentXxlAccent.copyWith(color: t.fg),
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

List<Widget> _buildLanguageNotes({
  required Map<String, LanguagePack> packByCode,
  required String nativeCode,
  required String targetCode,
  required AsyncValue<String?> asyncCourseNote,
  required AppLocalizations l10n,
}) {
  final notes = <Widget>[];

  final nativePack = packByCode[nativeCode];
  if (nativePack?.nativeNote != null) {
    notes.add(const FlesselGap.l());
    notes.add(FlesselNote(text: nativePack!.nativeNote!, accented: true));
  }

  if (targetCode == nativeCode) {
    notes.add(const FlesselGap.l());
    notes.add(FlesselNote(text: l10n.language_sameAsLearning));
  }

  final courseNote = asyncCourseNote.valueOrNull;
  if (courseNote != null) {
    notes.add(const FlesselGap.l());
    notes.add(FlesselNote(text: courseNote));
  }

  return notes;
}

void _confirmReset(
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
                  ref.read(LanguagePageService.instance).resetLanguage(langCode);
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

class _LangPairSelector extends StatelessWidget {
  const _LangPairSelector({
    required this.packByCode,
    required this.nativeCode,
    required this.targetCode,
    required this.l10n,
    required this.onNativeSelected,
    required this.onTargetSelected,
  });

  final Map<String, LanguagePack> packByCode;
  final String nativeCode;
  final String targetCode;
  final AppLocalizations l10n;
  final ValueChanged<String> onNativeSelected;
  final ValueChanged<String> onTargetSelected;

  static const _arrowZoneWidth = LangwijLayout.langArrowZoneWidth;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.language_iSpeak.toUpperCase(),
                style: FlesselFonts.contentXxlAccent.copyWith(color: t.fgSecondary),
              ),
            ),
            const SizedBox(width: _arrowZoneWidth),
            Expanded(
              child: Text(
                l10n.language_iLearn.toUpperCase(),
                style: FlesselFonts.contentXxlAccent.copyWith(color: t.fgSecondary),
              ),
            ),
          ],
        ),
        const FlesselGap.xs(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _LangBox(
                selectedLabel: packByCode[nativeCode] != null
                    ? l10n.langLabel(packByCode[nativeCode]!.labelKey)
                    : nativeCode,
                langCode: nativeCode,
                onTap: () async {
                  final picked = await context.push<String>(
                    AppRoutes.langPicker,
                    extra: LangPickerMode.native,
                  );
                  if (picked != null) onNativeSelected(picked);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: FlesselLayout.gapS),
              child: Icon(
                nativeCode == LangCodes.serbian ||
                        (nativeCode == LangCodes.russian &&
                            targetCode == LangCodes.serbian)
                    ? PhosphorIconsFill.heart
                    : PhosphorIconsBold.arrowRight,
                color: t.fgSecondary,
                size: 20,
              ),
            ),
            Expanded(
              child: _LangBox(
                selectedLabel: packByCode[targetCode] != null
                    ? l10n.langLabel(packByCode[targetCode]!.labelKey)
                    : targetCode,
                langCode: targetCode,
                onTap: () async {
                  final picked = await context.push<String>(
                    AppRoutes.langPicker,
                    extra: LangPickerMode.target,
                  );
                  if (picked != null) onTargetSelected(picked);
                },
              ),
            ),
          ],
        ),
        const FlesselGap.l(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _QualityBlock(
                humanVerified: packByCode[nativeCode]?.humanVerified ?? 0,
              ),
            ),
            SizedBox(width: _arrowZoneWidth),
            Expanded(
              child: _QualityBlock(
                humanVerified: packByCode[targetCode]?.humanVerified ?? 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LangBox extends StatelessWidget {
  const _LangBox({
    required this.selectedLabel,
    required this.langCode,
    required this.onTap,
  });

  final String selectedLabel;
  final String langCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final countryCode = LangCodes.flagCountryCode(langCode);
    return GestureDetector(
      onTap: onTap,
      child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(LangwijLayout.langBoxPaddingLeft, LangwijLayout.langBoxPaddingTop, LangwijLayout.langBoxPaddingRight, LangwijLayout.langBoxPaddingBottom),
            decoration: BoxDecoration(
              color: t.surface01.regular.bg.colorValue,
              border: Border.all(
                color: t.surface02.regular.border,
                width: t.tileBorderWidth,
              ),
              borderRadius: BorderRadius.circular(t.tileBorderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (countryCode != null)
                  CountryFlag.fromCountryCode(
                    countryCode,
                    theme: const ImageTheme(
                      width: LangwijLayout.langFlagWidth,
                      height: LangwijLayout.langFlagHeight,
                      shape: RoundedRectangle(4),
                    ),
                  )
                else
                  Icon(PhosphorIconsRegular.caretDown, color: t.fgSecondary, size: 18),
                const FlesselGap.xs(),
                Text(
                  selectedLabel,
                  style: FlesselFonts.contentLAccent
                      .copyWith(color: t.fg),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
  }
}

class _QualityBlock extends StatelessWidget {
  const _QualityBlock({required this.humanVerified});

  final int humanVerified;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final aiPct = 100 - humanVerified;
    final humanFirst = humanVerified >= 80;

    final humanRow = _qualityRow(
      icon: humanFirst
          ? PhosphorIconsFill.smiley
          : PhosphorIconsBold.smiley,
      label: l10n.language_qualityHuman(humanVerified),
      style: humanFirst
          ? FlesselFonts.contentSAccent
          : FlesselFonts.contentS,
      color: t.fg,
    );

    final aiRow = _qualityRow(
      icon: humanFirst
          ? PhosphorIconsBold.robot
          : PhosphorIconsFill.robot,
      label: l10n.language_qualityAi(aiPct),
      style: humanFirst
          ? FlesselFonts.contentS
          : FlesselFonts.contentSAccent,
      color: t.fg,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: FlesselLayout.gapS,
        vertical: FlesselLayout.gapXs,
      ),
      decoration: BoxDecoration(
        color: t.surface01.regular.bg.colorValue,
        border: Border.all(
          color: t.surface02.regular.border,
          width: t.tileBorderWidth,
        ),
        borderRadius: BorderRadius.circular(t.tileBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (humanFirst) ...[humanRow, const FlesselGap.xxs(), aiRow]
          else ...[aiRow, const FlesselGap.xxs(), humanRow],
        ],
      ),
    );
  }

  static const double _iconSize = 25.0;

  static Widget _qualityRow({
    required IconData icon,
    required String label,
    required TextStyle style,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: _iconSize, color: color),
        const FlesselGap.s(),
        Expanded(
          child: Text(
            label,
            style: style.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _ProgressionCard extends StatelessWidget {
  const _ProgressionCard({
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
                          bottom: i < entries.length - 1 ? FlesselLayout.listItemGapSmall : 0),
                      child: Row(
                        children: [
                          if (countryCode != null) ...[
                            CountryFlag.fromCountryCode(
                              countryCode,
                              theme: const ImageTheme(
                                width: LangwijLayout.langProgressionFlagWidth,
                                height: LangwijLayout.langProgressionFlagHeight,
                                shape: RoundedRectangle(2),
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

class _DecayOption extends StatelessWidget {
  const _DecayOption({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);

    return FlesselCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isSelected
                      ? FlesselFonts.contentMAccent
                          .copyWith(color: t.fg)
                      : FlesselFonts.contentM.copyWith(color: t.fg),
                ),
                const FlesselGap.xxs(),
                Text(
                  description,
                  style: FlesselFonts.contentS.copyWith(color: t.fgSecondary),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              PhosphorIconsRegular.checkCircle,
              color: t.accentColor,
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
                bottom: i < packs.length - 1 ? FlesselLayout.listItemGapSmall : 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.langLabel(p.labelKey),
                      style: FlesselFonts.contentS.copyWith(color: t.fgSecondary),
                    ),
                  ),
                  Text(
                    l10n.language_termsCount(p.translatedCount, p.totalTerms),
                    style: FlesselFonts.contentS.copyWith(color: t.dangerColor),
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
