import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_ext.dart';
import '../features/language/services/language_reset_service.dart';
import '../app/providers/all_languages_progress_provider.dart';
import '../app/providers/app_settings_provider.dart';
import '../app/providers/dev_section_provider.dart';
import '../app/providers/dictionary_provider.dart';
import '../app/providers/language_settings_provider.dart';
import '../app/providers/plan_provider.dart';
import '../app/router/app_router.dart';
import '../shared/repositories/models/decay_formula.dart';
import '../app/theme/vessel_themes.dart';
import '../entities/language/lang_codes.dart';
import '../entities/language/language_pack.dart';
import '../shared/ui/bottom_sheet/vessel_bottom_sheet.dart'; // used by _confirmReset
import '../shared/ui/buttons/vessel_buttons.dart';
import '../shared/ui/card/vessel_card.dart';
import '../shared/ui/note/vessel_note.dart';
import '../shared/ui/progress_bar/vessel_progress_bar.dart';
import '../shared/ui/screen_layout/vessel_scaffold.dart';
import '../shared/ui/gap/vessel_gap.dart';
import '../app/layout/vessel_layout.dart';
import 'lang_picker_screen.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = VesselThemes.of(context);
    final langSettings = ref.watch(languageSettingsProvider);
    final asyncAllPacks = ref.watch(allPacksProvider);
    final asyncAllLangProgress = ref.watch(allLanguagesProgressProvider);
    final asyncCourseNote = ref.watch(courseNoteProvider);
    final settings = ref.watch(appSettingsProvider);
    final showDevSection = ref.watch(devSectionEnabledProvider);

    return VesselScaffold(
      title: l10n.navLanguage,
      showBottomNav: true,
      child: asyncAllPacks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // ignore: unnecessary_underscores
        error: (_, __) => Center(child: Text(l10n.loadError)),
        data: (packs) {
          final packByCode = {for (final p in packs) p.code: p};

          return ListView(
            padding: const EdgeInsets.all(VesselLayout.screenPadding),
            children: [
              _LangPairSelector(
                packByCode: packByCode,
                nativeCode: langSettings.nativeLang,
                targetCode: langSettings.targetLang,
                l10n: l10n,
                onNativeSelected: (code) =>
                    ref.read(languageSettingsProvider.notifier).setNativeLang(code),
                onTargetSelected: (code) =>
                    ref.read(languageSettingsProvider.notifier).setTargetLang(code),
              ),
              ..._buildLanguageNotes(
                packByCode: packByCode,
                nativeCode: langSettings.nativeLang,
                targetCode: langSettings.targetLang,
                asyncCourseNote: asyncCourseNote,
                l10n: l10n,
              ),
              const VesselGap.xl(),

              // Progression
              Padding(
                padding: const EdgeInsets.only(bottom: VesselLayout.listItemGap),
                child: Text(
                  l10n.language_progression,
                  style: VesselFonts.textSectionHeader.copyWith(color: t.textPrimary),
                ),
              ),
              _ProgressionCard(
                asyncProgress: asyncAllLangProgress,
                packByCode: packByCode,
                l10n: l10n,
                onReset: (langCode) => _confirmReset(context, ref, langCode, packByCode, l10n),
              ),
              const VesselGap.xl(),

              // Decay / learning pace
              Padding(
                padding: const EdgeInsets.only(bottom: VesselLayout.listItemGap),
                child: Text(
                  l10n.settingsDecaySpeed,
                  style: VesselFonts.textSectionHeader.copyWith(color: t.textPrimary),
                ),
              ),
              _DecayOption(
                title: l10n.decayRelaxed,
                description: l10n.decayRelaxedDesc,
                isSelected: settings.decayFormula == DecayFormula.relaxed,
                onTap: () => ref
                    .read(appSettingsProvider.notifier)
                    .setDecayFormula(DecayFormula.relaxed),
              ),
              const VesselGap.s(),
              _DecayOption(
                title: l10n.decayStandard,
                description: l10n.decayStandardDesc,
                isSelected: settings.decayFormula == DecayFormula.standard,
                onTap: () => ref
                    .read(appSettingsProvider.notifier)
                    .setDecayFormula(DecayFormula.standard),
              ),
              const VesselGap.s(),
              _DecayOption(
                title: l10n.decayIntensive,
                description: l10n.decayIntensiveDesc,
                isSelected: settings.decayFormula == DecayFormula.intensive,
                onTap: () => ref
                    .read(appSettingsProvider.notifier)
                    .setDecayFormula(DecayFormula.intensive),
              ),
              const VesselGap.s(),
              _DecayOption(
                title: l10n.decayHardcore,
                description: l10n.decayHardcoreDesc,
                isSelected: settings.decayFormula == DecayFormula.hardcore,
                onTap: () => ref
                    .read(appSettingsProvider.notifier)
                    .setDecayFormula(DecayFormula.hardcore),
              ),

              // Incomplete dictionaries (dev mode only)
              if (showDevSection) ...[
                const VesselGap.xl(),
                Padding(
                  padding: const EdgeInsets.only(bottom: VesselLayout.listItemGap),
                  child: Text(
                    l10n.language_incompleteDictionaries,
                    style: VesselFonts.textSectionHeader.copyWith(color: t.textPrimary),
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

  // Native language note
  final nativePack = packByCode[nativeCode];
  if (nativePack?.nativeNote != null) {
    notes.add(const VesselGap.l());
    notes.add(VesselNote(text: nativePack!.nativeNote!, accented: true));
  }

  // Same language warning
  if (targetCode == nativeCode) {
    notes.add(const VesselGap.l());
    notes.add(VesselNote(text: l10n.language_sameAsLearning));
  }

  // Course-specific note
  final courseNote = asyncCourseNote.valueOrNull;
  if (courseNote != null) {
    notes.add(const VesselGap.l());
    notes.add(VesselNote(text: courseNote));
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
  showVesselBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final t = VesselThemes.of(sheetContext);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.language_resetConfirmTitle,
            style: VesselFonts.textSheetTitle.copyWith(color: t.textPrimary),
          ),
          const VesselGap.m(),
          Text(
            l10n.language_resetConfirmBody(langName),
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
              VesselDangerButton(
                label: l10n.language_resetButton,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  ref.read(languageResetServiceProvider).resetLanguage(langCode);
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

  // Width of the arrow zone (icon 20 + padding 8×2) — keeps labels aligned with boxes.
  static const _arrowZoneWidth = VesselLayout.langArrowZoneWidth;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Labels row
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.language_iSpeak.toUpperCase(),
                style: VesselFonts.textLangPickerLabel.copyWith(color: t.textSecondary),
              ),
            ),
            const SizedBox(width: _arrowZoneWidth),
            Expanded(
              child: Text(
                l10n.language_iLearn.toUpperCase(),
                style: VesselFonts.textLangPickerLabel.copyWith(color: t.textSecondary),
              ),
            ),
          ],
        ),
        const VesselGap.xs(),
        // Boxes row
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
              padding: const EdgeInsets.symmetric(horizontal: VesselLayout.gapS),
              child: Icon(
                nativeCode == LangCodes.serbian ||
                        (nativeCode == LangCodes.russian &&
                            targetCode == LangCodes.serbian)
                    ? PhosphorIconsFill.heart
                    : PhosphorIconsBold.arrowRight,
                color: t.textSecondary,
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
        const VesselGap.l(),
        // Quality row
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
    final t = VesselThemes.of(context);
    final countryCode = LangCodes.flagCountryCode(langCode);
    return GestureDetector(
      onTap: onTap,
      child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(VesselLayout.langBoxPaddingLeft, VesselLayout.langBoxPaddingTop, VesselLayout.langBoxPaddingRight, VesselLayout.langBoxPaddingBottom),
            decoration: BoxDecoration(
              color: t.cardBackground,
              border: Border.all(
                color: t.tileBorderColor,
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
                      width: VesselLayout.langFlagWidth,
                      height: VesselLayout.langFlagHeight,
                      shape: RoundedRectangle(4),
                    ),
                  )
                else
                  Icon(PhosphorIconsRegular.caretDown, color: t.textSecondary, size: 18),
                const VesselGap.xs(),
                Text(
                  selectedLabel,
                  style: VesselFonts.textLangPickerValue
                      .copyWith(color: t.textPrimary),
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
    final t = VesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final aiPct = 100 - humanVerified;
    final humanFirst = humanVerified >= 80;

    final humanRow = _qualityRow(
      icon: humanFirst
          ? PhosphorIconsFill.smiley
          : PhosphorIconsBold.smiley,
      label: l10n.language_qualityHuman(humanVerified),
      style: humanFirst
          ? VesselFonts.textQualityPrimary
          : VesselFonts.textQualitySecondary,
      color: t.textPrimary,
    );

    final aiRow = _qualityRow(
      icon: humanFirst
          ? PhosphorIconsBold.robot
          : PhosphorIconsFill.robot,
      label: l10n.language_qualityAi(aiPct),
      style: humanFirst
          ? VesselFonts.textQualitySecondary
          : VesselFonts.textQualityPrimary,
      color: t.textPrimary,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: VesselLayout.gapS,
        vertical: VesselLayout.gapXs,
      ),
      decoration: BoxDecoration(
        color: t.cardBackground,
        border: Border.all(
          color: t.tileBorderColor,
          width: t.tileBorderWidth,
        ),
        borderRadius: BorderRadius.circular(t.tileBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (humanFirst) ...[humanRow, const VesselGap.xxs(), aiRow]
          else ...[aiRow, const VesselGap.xxs(), humanRow],
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
        const VesselGap.hs(),
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
    final t = VesselThemes.of(context);
    return VesselCard(
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
                return VesselNote(text: l10n.language_progressionEmpty);
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
                          bottom: i < entries.length - 1 ? VesselLayout.listItemGapSmall : 0),
                      child: Row(
                        children: [
                          if (countryCode != null) ...[
                            CountryFlag.fromCountryCode(
                              countryCode,
                              theme: const ImageTheme(
                                width: VesselLayout.langProgressionFlagWidth,
                                height: VesselLayout.langProgressionFlagHeight,
                                shape: RoundedRectangle(2),
                              ),
                            ),
                            const VesselGap.hs(),
                          ],
                          SizedBox(
                            width: VesselLayout.langProgressLabelWidth,
                            child: Text(
                              label,
                              style: VesselFonts.textBodyAccent.copyWith(
                                color: t.textSecondary,
                              ),
                            ),
                          ),
                          const VesselGap.hs(),
                          Expanded(
                            child: VesselProgressBar(
                              value: e.value,
                              mode: VesselProgressBarMode.detailed,
                            ),
                          ),
                          const VesselGap.hs(),
                          SizedBox(
                            width: VesselLayout.langProgressPercentWidth,
                            child: Text(
                              '$pct%',
                              textAlign: TextAlign.end,
                              style: VesselFonts.textCaption.copyWith(
                                color: t.textPrimary,
                              ),
                            ),
                          ),
                          const VesselGap.hs(),
                          VesselButton(
                            icon: PhosphorIconsRegular.trash,
                            size: VesselButtonSize.small,
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
            // ignore: unnecessary_underscores
            error: (_, __) => const SizedBox.shrink(),
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
    final t = VesselThemes.of(context);

    return VesselCard(
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
                      ? VesselFonts.textListItemAccented
                          .copyWith(color: t.textPrimary)
                      : VesselFonts.textListItem.copyWith(color: t.textPrimary),
                ),
                const VesselGap.xxs(),
                Text(
                  description,
                  style: VesselFonts.textCaption.copyWith(color: t.textSecondary),
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
    final t = VesselThemes.of(context);
    return VesselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(packs.length, (i) {
            final p = packs[i];
            return Padding(
              padding: EdgeInsets.only(
                bottom: i < packs.length - 1 ? VesselLayout.listItemGapSmall : 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.langLabel(p.labelKey),
                      style: VesselFonts.textCaption.copyWith(color: t.textSecondary),
                    ),
                  ),
                  Text(
                    l10n.language_termsCount(p.translatedCount, p.totalTerms),
                    style: VesselFonts.textCaption.copyWith(color: t.dangerColor),
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
