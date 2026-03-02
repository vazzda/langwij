import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_ext.dart';
import '../app/providers/all_languages_progress_provider.dart';
import '../app/providers/dev_section_provider.dart';
import '../app/providers/dictionary_provider.dart';
import '../app/providers/language_settings_provider.dart';
import '../app/theme/vessel_themes.dart';
import '../entities/language/lang_codes.dart';
import '../entities/language/language_pack.dart';
import '../shared/ui/bottom_sheet/vessel_bottom_sheet.dart';
import '../shared/ui/lang_button/vessel_lang_button.dart';
import '../shared/ui/card/vessel_card.dart';
import '../shared/ui/note/vessel_note.dart';
import '../shared/ui/progress_bar/vessel_progress_bar.dart';
import '../shared/ui/screen_layout/vessel_scaffold.dart';
import '../shared/ui/gap/vessel_gap.dart';
import '../app/layout/vessel_layout.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = VesselThemes.of(context);
    final langSettings = ref.watch(languageSettingsProvider);
    final asyncAllPacks = ref.watch(allPacksProvider);
    final asyncAllLangProgress = ref.watch(allLanguagesProgressProvider);
    final showDevSection = ref.watch(devSectionEnabledProvider);

    return VesselScaffold(
      title: l10n.navLanguage,
      showBottomNav: true,
      child: asyncAllPacks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // ignore: unnecessary_underscores
        error: (_, __) => Center(child: Text(l10n.loadError)),
        data: (packs) {
          final allCodes = packs.map((p) => p.code).toList();
          final packByCode = {for (final p in packs) p.code: p};

          return ListView(
            padding: const EdgeInsets.all(VesselLayout.screenPadding),
            children: [
              _LangPairSelector(
                codes: allCodes,
                packByCode: packByCode,
                nativeCode: langSettings.nativeLang,
                targetCode: langSettings.targetLang,
                l10n: l10n,
                onNativeSelected: (code) =>
                    ref.read(languageSettingsProvider.notifier).setNativeLang(code),
                onTargetSelected: (code) =>
                    ref.read(languageSettingsProvider.notifier).setTargetLang(code),
              ),
              if (langSettings.nativeLang == LangCodes.serbian) ...[
                const VesselGap.l(),
                VesselNote(text: l10n.language_serbianNativeNote, accented: true),
              ],
              if (langSettings.targetLang == langSettings.nativeLang) ...[
                const VesselGap.s(),
                VesselNote(text: l10n.language_sameAsLearning),
              ],
              const VesselGap.l(),

              // Progression card
              _ProgressionCard(
                asyncProgress: asyncAllLangProgress,
                packByCode: packByCode,
                l10n: l10n,
              ),
              const VesselGap.m(),

              // Incomplete dictionaries (dev mode only)
              if (showDevSection) ...packs
                  .where((p) => !p.isPublic)
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: VesselLayout.listItemGapSmall),
                        child: VesselCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.langLabel(p.labelKey),
                                  style: VesselFonts.textListItem
                                      .copyWith(color: t.textPrimary),
                                ),
                              ),
                              Text(
                                l10n.language_conceptsCount(
                                    p.translatedCount, p.totalConcepts),
                                style: VesselFonts.textCaption
                                    .copyWith(color: t.dangerColor),
                              ),
                            ],
                          ),
                        ),
                      )),
            ],
          );
        },
      ),
    );
  }
}

Future<String?> _showLangPicker(
  BuildContext context,
  List<String> codes,
  Map<String, LanguagePack> packByCode,
  AppLocalizations l10n,
) {
  return showVesselBottomSheet<String>(
    context: context,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...codes.map((code) {
            final pack = packByCode[code]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: VesselLayout.listItemGapSmall),
              child: VesselLangButton(
                langCode: code,
                label: l10n.langLabel(pack.labelKey),
                onPressed: () => Navigator.of(sheetContext).pop(code),
              ),
            );
          }),
        ],
      );
    },
  );
}

class _LangPairSelector extends StatelessWidget {
  const _LangPairSelector({
    required this.codes,
    required this.packByCode,
    required this.nativeCode,
    required this.targetCode,
    required this.l10n,
    required this.onNativeSelected,
    required this.onTargetSelected,
  });

  final List<String> codes;
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
                  final picked = await _showLangPicker(context, codes, packByCode, l10n);
                  if (picked != null) onNativeSelected(picked);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VesselLayout.gapS),
              child: Icon(PhosphorIconsRegular.arrowRight, color: t.textSecondary, size: 20),
            ),
            Expanded(
              child: _LangBox(
                selectedLabel: packByCode[targetCode] != null
                    ? l10n.langLabel(packByCode[targetCode]!.labelKey)
                    : targetCode,
                langCode: targetCode,
                onTap: () async {
                  final picked = await _showLangPicker(context, codes, packByCode, l10n);
                  if (picked != null) onTargetSelected(picked);
                },
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

class _ProgressionCard extends StatelessWidget {
  const _ProgressionCard({
    required this.asyncProgress,
    required this.packByCode,
    required this.l10n,
  });

  final AsyncValue<Map<String, double>> asyncProgress;
  final Map<String, LanguagePack> packByCode;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    return VesselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.language_progression,
            style: VesselFonts.textListItem.copyWith(color: t.textPrimary),
          ),
          asyncProgress.when(
            data: (langProgress) {
              final entries = langProgress.entries
                  .where((e) => e.value > 0 && packByCode.containsKey(e.key))
                  .toList();
              if (entries.isEmpty) return const SizedBox.shrink();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VesselGap.m(),
                  ...List.generate(entries.length, (i) {
                    final e = entries[i];
                    final pack = packByCode[e.key]!;
                    final label = l10n.langLabel(pack.labelKey);
                    final pct = (e.value * 100).round();
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: i < entries.length - 1 ? VesselLayout.listItemGapSmall : 0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: VesselLayout.langProgressLabelWidth,
                            child: Text(
                              label,
                              style: VesselFonts.textCaption.copyWith(
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
