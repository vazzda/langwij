import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/shared/nav_bar/ui/langwij_scaffold.dart';
import 'package:langwij/shared/app/layout/layout.dart';
import '../../picker/ui/lang_picker_page.dart';

class LanguagePage extends ConsumerStatefulWidget {
  const LanguagePage({super.key});

  @override
  ConsumerState<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  String? _displayedNativeCode;
  String? _displayedTargetCode;

  @override
  void initState() {
    super.initState();
    ConfigService.markLanguagesConfigured();
  }

  void _onNativeSelected(String code, Set<String> availableCourseIds) {
    final targetCode = _displayedTargetCode!;
    setState(() => _displayedNativeCode = code);
    _persistIfValidPair(targetCode: targetCode, nativeCode: code, availableCourseIds: availableCourseIds);
  }

  void _onTargetSelected(String code, Set<String> availableCourseIds) {
    final nativeCode = _displayedNativeCode!;
    setState(() => _displayedTargetCode = code);
    _persistIfValidPair(targetCode: code, nativeCode: nativeCode, availableCourseIds: availableCourseIds);
  }

  void _persistIfValidPair({
    required String targetCode,
    required String nativeCode,
    required Set<String> availableCourseIds,
  }) {
    if (targetCode == nativeCode) return;
    final courseId = '$targetCode→$nativeCode';
    if (!availableCourseIds.contains(courseId)) return;
    ref.read(ConfigService.instance).setLanguagePair(
      targetLang: targetCode,
      nativeLang: nativeCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncLangSettings = ref.watch(ConfigService.languageSettings);
    final asyncAllPacks = ref.watch(DictionaryService.allPacks);
    final asyncCourseIds = ref.watch(DictionaryService.availableCourseIds);
    final langSettings = asyncLangSettings.valueOrNull;

    if (langSettings == null) {
      return LangwijScaffold(
        title: l10n.navLanguage,
        child: const Center(child: FlesselSpinner()),
      );
    }

    _displayedNativeCode ??= langSettings.nativeLang;
    _displayedTargetCode ??= langSettings.targetLang;
    final nativeCode = _displayedNativeCode!;
    final targetCode = _displayedTargetCode!;
    final availableCourseIds = asyncCourseIds.valueOrNull ?? const {};

    return LangwijScaffold(
      title: l10n.navLanguage,
      child: asyncAllPacks.when(
        loading: () => const Center(child: FlesselSpinner()),
        error: (_, _) => Center(child: Text(l10n.loadError)),
        data: (packs) {
          final packByCode = {for (final p in packs) p.code: p};

          return ListView(
            padding: FlesselLayout.screenPaddingInsets(context).copyWith(
              bottom: FlesselLayout.screenPaddingInsets(context).bottom + LangwijScaffold.navbarSpacer(context),
            ),
            children: [
              _LangPairSelector(
                packByCode: packByCode,
                nativeCode: nativeCode,
                targetCode: targetCode,
                l10n: l10n,
                onNativeSelected: (code) =>
                    _onNativeSelected(code, availableCourseIds),
                onTargetSelected: (code) =>
                    _onTargetSelected(code, availableCourseIds),
              ),
              ..._buildLanguageWarnings(
                packByCode: packByCode,
                nativeCode: nativeCode,
                targetCode: targetCode,
                availableCourseIds: availableCourseIds,
                l10n: l10n,
              ),
            ],
          );
        },
      ),
    );
  }
}

List<Widget> _buildLanguageWarnings({
  required Map<String, LanguagePack> packByCode,
  required String nativeCode,
  required String targetCode,
  required Set<String> availableCourseIds,
  required AppLocalizations l10n,
}) {
  final warnings = <Widget>[];

  final courseId = '$targetCode→$nativeCode';
  if (!availableCourseIds.contains(courseId)) {
    warnings.add(const FlesselGap.l());
    warnings.add(_LanguageWarningCard(text: l10n.language_pairUnavailable));
    return warnings;
  }

  final nativeHuman = packByCode[nativeCode]?.humanVerified ?? 0;
  final targetHuman = packByCode[targetCode]?.humanVerified ?? 0;
  if (nativeHuman < 100 || targetHuman < 100) {
    warnings.add(const FlesselGap.l());
    warnings.add(_LanguageWarningCard(text: l10n.language_aiDictionaryWarning));
  }

  return warnings;
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

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.language_iSpeak.toUpperCase(),
          style: FlesselFonts.contentTitle.copyWith(color: t.fg),
        ),
        const FlesselGap.xs(),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const FlesselGap.s(),
              Expanded(
                child: _QualityBlock(
                  humanVerified: packByCode[nativeCode]?.humanVerified ?? 0,
                ),
              ),
            ],
          ),
        ),
        const FlesselGap.xs(),
        Transform.translate(
          offset: const Offset(0, FlesselLayout.gapS),
          child: Center(
            child: Icon(
              nativeCode == LangCodes.serbian ||
                      (nativeCode == LangCodes.russian &&
                          targetCode == LangCodes.serbian)
                  ? PhosphorIconsFill.heart
                  : PhosphorIconsBold.arrowDown,
              color: t.fg,
              size: FlesselLayout.iconL,
            ),
          ),
        ),
        Text(
          l10n.language_iLearn.toUpperCase(),
          style: FlesselFonts.contentTitle.copyWith(color: t.fg),
        ),
        const FlesselGap.xs(),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const FlesselGap.s(),
              Expanded(
                child: _QualityBlock(
                  humanVerified: packByCode[targetCode]?.humanVerified ?? 0,
                ),
              ),
            ],
          ),
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
                      shape: RoundedRectangle(LangwijLayout.langFlagBorderRadius),
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
      icon: PhosphorIconsRegular.finnTheHuman,
      label: l10n.language_qualityHuman(humanVerified),
      style: humanFirst
          ? FlesselFonts.contentSAccent
          : FlesselFonts.contentS,
      color: t.fg,
    );

    final aiColor = aiPct > 0 ? t.surface01.danger.fg : t.fg;
    final aiRow = _qualityRow(
      icon: PhosphorIconsRegular.robot,
      label: l10n.language_qualityAi(aiPct),
      style: humanFirst
          ? FlesselFonts.contentS
          : FlesselFonts.contentSAccent,
      color: aiColor,
    );

    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (humanFirst) ...[humanRow, const FlesselGap.xxs(), aiRow]
          else ...[aiRow, const FlesselGap.xxs(), humanRow],
        ],
      ),
    );
  }

  static Widget _qualityRow({
    required IconData icon,
    required String label,
    required TextStyle style,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: LangwijLayout.langQualityIconSize, color: color),
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

class _LanguageWarningCard extends StatelessWidget {
  const _LanguageWarningCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    return FlesselCard(
      surface: FlesselSurface.s21,
      colorVariant: FlesselVariant.danger,
      margin: FlesselSize.none,
      child: Text(
        text,
        style: FlesselFonts.contentBodyAccent.copyWith(
          color: t.surface21.danger.fg,
        ),
      ),
    );
  }
}
