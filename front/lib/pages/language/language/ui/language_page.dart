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
import 'package:langwij/shared/flag/ui/flag.dart';
import '../../picker/ui/lang_picker_page.dart';

class LanguagePage extends ConsumerStatefulWidget {
  const LanguagePage({super.key});

  @override
  ConsumerState<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  /// The pair the page shows. It may differ from the stored pair: a pair
  /// without a course is shown, with its warning, but never stored.
  LanguageSettings? _displayedLanguagePair;

  @override
  void initState() {
    super.initState();
    ConfigService.markLanguagesConfigured();
  }

  void _showLanguagePairAndPersistIfValid(
    LanguageSettings languagePair,
    Set<String> availableCourseIds,
  ) {
    setState(() => _displayedLanguagePair = languagePair);
    _persistIfValidPair(
      targetCode: languagePair.targetLang,
      nativeCode: languagePair.nativeLang,
      availableCourseIds: availableCourseIds,
    );
  }

  void _persistIfValidPair({
    required String targetCode,
    required String nativeCode,
    required Set<String> availableCourseIds,
  }) {
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

    final displayedLanguagePair = _displayedLanguagePair ??= langSettings;
    final nativeCode = displayedLanguagePair.nativeLang;
    final targetCode = displayedLanguagePair.targetLang;
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
                nativeCode: nativeCode,
                targetCode: targetCode,
                nativeName: _languageNameOf(nativeCode, packByCode, l10n),
                targetName: _languageNameOf(targetCode, packByCode, l10n),
                l10n: l10n,
                onNativeSelected: (code) => _showLanguagePairAndPersistIfValid(
                  displayedLanguagePair.withNativeLangPicked(code),
                  availableCourseIds,
                ),
                onTargetSelected: (code) => _showLanguagePairAndPersistIfValid(
                  displayedLanguagePair.withTargetLangPicked(code),
                  availableCourseIds,
                ),
              ),
              ..._buildLanguageWarnings(
                packByCode: packByCode,
                nativeCode: nativeCode,
                targetCode: targetCode,
                availableCourseIds: availableCourseIds,
                l10n: l10n,
              ),
              const FlesselGap.l(),
              _LanguageQualityCard(
                languageName: _languageNameOf(nativeCode, packByCode, l10n),
                humanVerifiedPercent:
                    _humanVerifiedPercentOf(nativeCode, packByCode),
              ),
              _LanguageQualityCard(
                languageName: _languageNameOf(targetCode, packByCode, l10n),
                humanVerifiedPercent:
                    _humanVerifiedPercentOf(targetCode, packByCode),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A language that is not among the listed packs counts as made without
/// human checking.
const int _humanVerifiedPercentOfUnlistedLanguage = 0;

/// The name of a language in the interface language, or its code when the
/// language is not among the listed packs.
String _languageNameOf(
  String languageCode,
  Map<String, LanguagePack> packByCode,
  AppLocalizations l10n,
) {
  final pack = packByCode[languageCode];
  return pack != null ? l10n.langLabel(pack.labelKey) : languageCode;
}

int _humanVerifiedPercentOf(
  String languageCode,
  Map<String, LanguagePack> packByCode,
) {
  return packByCode[languageCode]?.humanVerified ??
      _humanVerifiedPercentOfUnlistedLanguage;
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

/// The pair of chosen languages: the language spoken above, the language
/// being learned below, each under its centred title, with the arrow from
/// the one to the other between them.
class _LangPairSelector extends StatelessWidget {
  const _LangPairSelector({
    required this.nativeCode,
    required this.targetCode,
    required this.nativeName,
    required this.targetName,
    required this.l10n,
    required this.onNativeSelected,
    required this.onTargetSelected,
  });

  final String nativeCode;
  final String targetCode;
  final String nativeName;
  final String targetName;
  final AppLocalizations l10n;
  final ValueChanged<String> onNativeSelected;
  final ValueChanged<String> onTargetSelected;

  /// The heart stands in for the arrow where Serbian is the language spoken,
  /// and where a Russian speaker learns Serbian.
  bool get _showsHeartInPlaceOfArrow =>
      nativeCode == LangCodes.serbian ||
      (nativeCode == LangCodes.russian && targetCode == LangCodes.serbian);

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCentredTitle(l10n.language_iSpeak, t),
        const FlesselGap.xs(),
        _ChosenLanguageRow(
          languageCode: nativeCode,
          languageName: nativeName,
          onTap: () => _openPickerAndReportPick(
            context,
            LangPickerMode.native,
            onNativeSelected,
          ),
        ),
        const FlesselGap.s(),
        Center(
          child: Icon(
            _showsHeartInPlaceOfArrow
                ? PhosphorIconsFill.heart
                : PhosphorIconsBold.arrowDown,
            color: t.fg,
            size: FlesselLayout.iconL,
          ),
        ),
        const FlesselGap.s(),
        _buildCentredTitle(l10n.language_iLearn, t),
        const FlesselGap.xs(),
        _ChosenLanguageRow(
          languageCode: targetCode,
          languageName: targetName,
          onTap: () => _openPickerAndReportPick(
            context,
            LangPickerMode.target,
            onTargetSelected,
          ),
        ),
      ],
    );
  }

  Widget _buildCentredTitle(String title, FlesselThemeData t) {
    return Text(
      title.toUpperCase(),
      textAlign: TextAlign.center,
      style: FlesselFonts.contentTitle.copyWith(color: t.fg),
    );
  }

  Future<void> _openPickerAndReportPick(
    BuildContext context,
    LangPickerMode pickerMode,
    ValueChanged<String> onLanguagePicked,
  ) async {
    final pickedLanguageCode = await context.push<String>(
      AppRoutes.langPicker,
      extra: pickerMode,
    );
    if (pickedLanguageCode != null) onLanguagePicked(pickedLanguageCode);
  }
}

/// A chosen language of the pair: its flag and its name in one centred row.
/// A tap opens the picker. The row paints no surface of its own.
class _ChosenLanguageRow extends StatelessWidget {
  const _ChosenLanguageRow({
    required this.languageCode,
    required this.languageName,
    required this.onTap,
  });

  final String languageCode;
  final String languageName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final countryCode = LangCodes.flagCountryCode(languageCode);

    return FlesselCard(
      variant: FlesselCardVariant.transparent,
      margin: FlesselSize.none,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (countryCode != null) ...[
            LangwijFlag(
              countryCode: countryCode,
              size: LangwijFlagSize.large,
            ),
            const FlesselGap.s(),
          ],
          Flexible(
            child: Text(
              languageName,
              style: FlesselFonts.contentLAccent.copyWith(color: t.fg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// The shares of a language's dictionary made by humans and by AI, in a card
/// across the page under the language's name.
class _LanguageQualityCard extends StatelessWidget {
  const _LanguageQualityCard({
    required this.languageName,
    required this.humanVerifiedPercent,
  });

  static const int _fullPercent = 100;

  /// From this share of human-made entries on, the human line stands first
  /// and is the accented one; below it the AI line is.
  static const int _humanVerifiedPercentThatLeads = 80;

  final String languageName;
  final int humanVerifiedPercent;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final aiMadePercent = _fullPercent - humanVerifiedPercent;
    final isHumanLineLeading =
        humanVerifiedPercent >= _humanVerifiedPercentThatLeads;

    final humanLine = _qualityRow(
      icon: PhosphorIconsRegular.finnTheHuman,
      label: l10n.language_qualityHuman(humanVerifiedPercent),
      style: isHumanLineLeading
          ? FlesselFonts.contentSAccent
          : FlesselFonts.contentS,
      color: t.fg,
    );
    final aiLine = _qualityRow(
      icon: PhosphorIconsRegular.robot,
      label: l10n.language_qualityAi(aiMadePercent),
      style: isHumanLineLeading
          ? FlesselFonts.contentS
          : FlesselFonts.contentSAccent,
      color: aiMadePercent > 0 ? t.surface01.danger.fg : t.fg,
    );

    return FlesselCard(
      header: languageName,
      headerInside: true,
      margin: FlesselSize.s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: isHumanLineLeading
            ? [humanLine, const FlesselGap.xxs(), aiLine]
            : [aiLine, const FlesselGap.xxs(), humanLine],
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
