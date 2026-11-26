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
  @override
  void initState() {
    super.initState();
    ConfigService.markLanguagesConfigured();
  }

  /// Every pair of two offered languages can be learned, so a picked pair
  /// is stored at once.
  void _storeLanguagePair(LanguageSettings languagePair) {
    ref.read(ConfigService.instance).setLanguagePair(
      targetLang: languagePair.targetLang,
      nativeLang: languagePair.nativeLang,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncLangSettings = ref.watch(ConfigService.languageSettings);
    final asyncAllPacks = ref.watch(DictionaryService.allPacks);
    final langSettings = asyncLangSettings.valueOrNull;

    if (langSettings == null) {
      return LangwijScaffold(
        title: l10n.navLanguage,
        child: const Center(child: FlesselSpinner()),
      );
    }

    final nativeCode = langSettings.nativeLang;
    final targetCode = langSettings.targetLang;
    final courseNote = ref.watch(DictionaryService.courseNote).valueOrNull;
    final cardTermIds =
        ref.watch(DictionaryService.languageCardTermIds).valueOrNull ??
            const <String>[];

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
                nativeDictionaryWords:
                    _dictionaryWordsOf(nativeCode, packByCode, cardTermIds),
                targetDictionaryWords:
                    _dictionaryWordsOf(targetCode, packByCode, cardTermIds),
                l10n: l10n,
                onNativeSelected: (code) => _storeLanguagePair(
                  langSettings.withNativeLangPicked(code),
                ),
                onTargetSelected: (code) => _storeLanguagePair(
                  langSettings.withTargetLangPicked(code),
                ),
              ),
              ..._buildLanguageNotes(
                packByCode: packByCode,
                nativeCode: nativeCode,
                targetCode: targetCode,
                courseNote: courseNote,
                l10n: l10n,
              ),
            ],
          );
        },
      ),
    );
  }
}

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

/// How many words the card of a chosen language is given. The words listed
/// for the card repeat up to this count, so that its rows are full on the
/// widest screen.
const int _wordCountGivenToCard = 120;

/// The words of the card of a chosen language as one text: the terms listed
/// for the card, each in the language's own word, repeated to fill the rows.
/// A term the language lacks is left out. Empty when the language is not
/// among the listed packs.
String _dictionaryWordsOf(
  String languageCode,
  Map<String, LanguagePack> packByCode,
  List<String> cardTermIds,
) {
  final pack = packByCode[languageCode];
  if (pack == null) return '';

  final listedWords = [
    for (final termId in cardTermIds)
      if (pack.translations[termId] case final langEntry?) langEntry.headword,
  ];
  if (listedWords.isEmpty) return '';

  return Iterable.generate(
    _wordCountGivenToCard,
    (wordIndex) => listedWords[wordIndex % listedWords.length],
  ).join(' ');
}

/// The messages under the pair of chosen languages, in their order: the note
/// for those who speak the language spoken, the note of the course, and the
/// warning that a language of the pair is AI generated. A pair with none of
/// them gets no message.
List<Widget> _buildLanguageNotes({
  required Map<String, LanguagePack> packByCode,
  required String nativeCode,
  required String targetCode,
  required PlanNote? courseNote,
  required AppLocalizations l10n,
}) {
  final nativePack = packByCode[nativeCode];
  final targetPack = packByCode[targetCode];
  final isAnyLanguageAiGenerated = [nativePack, targetPack]
      .any((pack) => pack != null && pack.isAiGenerated);

  final notes = <Widget>[
    if (nativePack?.nativeNote case final nativeNote?)
      _LanguageMessageCard(
        title: nativeNote.title,
        text: nativeNote.text,
        variant: FlesselVariant.regular,
        backgroundIcon: _MessageBackgroundIcon.speakerNote,
      ),
    if (courseNote != null)
      _LanguageMessageCard(
        title: courseNote.title,
        text: courseNote.text,
        variant: FlesselVariant.regular,
        backgroundIcon: _MessageBackgroundIcon.courseNote,
      ),
    if (isAnyLanguageAiGenerated)
      _LanguageMessageCard(
        title: l10n.language_aiWarningTitle,
        text: l10n.language_aiDictionaryWarning,
        variant: FlesselVariant.danger,
        backgroundIcon: _MessageBackgroundIcon.aiWarning,
      ),
  ];

  return [
    for (final note in notes) ...[
      const FlesselGap.l(),
      note,
    ],
  ];
}

/// The pair of chosen languages: the language spoken above, the language
/// being learned below, each in its card.
class _LangPairSelector extends StatelessWidget {
  const _LangPairSelector({
    required this.nativeCode,
    required this.targetCode,
    required this.nativeName,
    required this.targetName,
    required this.nativeDictionaryWords,
    required this.targetDictionaryWords,
    required this.l10n,
    required this.onNativeSelected,
    required this.onTargetSelected,
  });

  final String nativeCode;
  final String targetCode;
  final String nativeName;
  final String targetName;

  /// The dictionary words in the card of the language spoken.
  final String nativeDictionaryWords;

  /// The dictionary words in the card of the language being learned.
  final String targetDictionaryWords;
  final AppLocalizations l10n;
  final ValueChanged<String> onNativeSelected;
  final ValueChanged<String> onTargetSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChosenLanguageCard(
          title: l10n.language_iSpeakLanguage(nativeName),
          languageCode: nativeCode,
          dictionaryWords: nativeDictionaryWords,
          onTap: () => _openPickerAndReportPick(
            context,
            LangPickerMode.native,
            onNativeSelected,
          ),
        ),
        const FlesselGap.l(),
        _ChosenLanguageCard(
          title: l10n.language_iLearnLanguage(targetName),
          languageCode: targetCode,
          dictionaryWords: targetDictionaryWords,
          onTap: () => _openPickerAndReportPick(
            context,
            LangPickerMode.target,
            onTargetSelected,
          ),
        ),
      ],
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

/// A chosen language of the pair, in a card across the page: on the first
/// row its title, and under it three columns, the flag, rows of the
/// language's dictionary words, and the button that changes the language.
/// The count of those rows is fixed. A tap on the card or on the button
/// opens the picker.
class _ChosenLanguageCard extends StatelessWidget {
  const _ChosenLanguageCard({
    required this.title,
    required this.languageCode,
    required this.dictionaryWords,
    required this.onTap,
  });

  /// What the language is to the learner, with its name: "I speak English".
  final String title;
  final String languageCode;

  /// The dictionary words of the language as one text. The card shows as
  /// many of them as its rows hold.
  final String dictionaryWords;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final countryCode = LangCodes.flagCountryCode(languageCode);
    const flagSize = LangwijFlagSize.large;

    final flag = SizedBox(
      width: flagSize.width,
      height: flagSize.height,
      child: countryCode != null
          ? LangwijFlag(countryCode: countryCode, size: flagSize)
          : null,
    );
    final words = Expanded(
      child: ExcludeSemantics(
        child: Text(
          dictionaryWords,
          style: FlesselFonts.contentXs.copyWith(color: t.fgSecondary),
          textAlign: TextAlign.justify,
          maxLines: LangwijLayout.langChosenCardWordRowCount,
          overflow: TextOverflow.clip,
        ),
      ),
    );

    return FlesselCard(
      padding: FlesselSize.xs,
      margin: FlesselSize.none,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: FlesselFonts.displayL.copyWith(color: t.fg),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const FlesselGap.s(),
          Row(
            children: [
              flag,
              const FlesselGap.m(),
              words,
              const FlesselGap.m(),
              FlesselButton(
                surface: FlesselSurface.s21,
                icon: PhosphorIconsRegular.arrowsDownUp,
                onPressed: onTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The icon a message of the Language page carries as its background, with
/// all that sets its look: its size, how much of its colour is seen over the
/// card, and how far it lies past the card's corner. Each value is set by
/// hand and nothing scales it.
enum _MessageBackgroundIcon {
  /// Behind the warning that a language of the pair is AI generated.
  aiWarning(
    iconData: PhosphorIconsRegular.robot,
    size: 120.0,
    opacity: 0.25,
    shiftPastCornerHorizontal: 10.0,
    shiftPastCornerVertical: 28.0,
  ),

  /// Behind the note for those who speak the language spoken.
  speakerNote(
    iconData: PhosphorIconsFill.heart,
    size: 120.0,
    opacity: 0.65,
    shiftPastCornerHorizontal: 10.0,
    shiftPastCornerVertical: 34.0,
  ),

  /// Behind the note of the course.
  courseNote(
    iconData: PhosphorIconsRegular.tractor,
    size: 120.0,
    opacity: 0.4,
    shiftPastCornerHorizontal: 0.0,
    shiftPastCornerVertical: -6.0,
  );

  const _MessageBackgroundIcon({
    required this.iconData,
    required this.size,
    required this.opacity,
    required this.shiftPastCornerHorizontal,
    required this.shiftPastCornerVertical,
  });

  final IconData iconData;

  /// The size of the icon in pixels, whatever the size of its card.
  final double size;
  final double opacity;

  /// How far the icon lies past the corner of its card to the end side.
  final double shiftPastCornerHorizontal;

  /// How far the icon lies past the corner of its card to the bottom.
  final double shiftPastCornerVertical;
}

/// A message under the pair of chosen languages: a title over its text, in
/// a card whose [variant] tells its weight: regular for a note, danger for
/// a warning. The message may carry an icon as its background; the title
/// and the text keep clear of it by a wider padding at their end side.
class _LanguageMessageCard extends StatelessWidget {
  const _LanguageMessageCard({
    required this.title,
    required this.text,
    required this.variant,
    this.backgroundIcon,
  });

  final String title;
  final String text;
  final FlesselVariant variant;

  /// The icon drawn behind the text, at its own size and cut by the card's
  /// edges, in the corner where the text ends. It takes the colour the
  /// card's background begins with, seen through by its own opacity. None
  /// when the message has no icon.
  final _MessageBackgroundIcon? backgroundIcon;

  /// The share of an icon's box that the icon set leaves empty on each side.
  /// The background icon is moved out by it, so that its drawing reaches the
  /// corner of the card before the shift past that corner is added.
  static const double _emptyMarginShareOfIconBox = 0.125;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final surfaceColors = t.surface21.resolve(variant);
    final cardPadding = FlesselLayout.cardPadding(FlesselSize.m);

    return FlesselCard(
      surface: FlesselSurface.s21,
      colorVariant: variant,
      padding: FlesselSize.none,
      margin: FlesselSize.none,
      child: Stack(
        children: [
          if (backgroundIcon case final backgroundIcon?)
            PositionedDirectional(
              end: -(backgroundIcon.size * _emptyMarginShareOfIconBox +
                  backgroundIcon.shiftPastCornerHorizontal),
              bottom: -(backgroundIcon.size * _emptyMarginShareOfIconBox +
                  backgroundIcon.shiftPastCornerVertical),
              child: Opacity(
                opacity: backgroundIcon.opacity,
                child: Icon(
                  backgroundIcon.iconData,
                  size: backgroundIcon.size,
                  color: surfaceColors.bg.colorValue,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: cardPadding,
              top: cardPadding,
              bottom: cardPadding,
              end: cardPadding + FlesselLayout.gapL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FlesselFonts.displayL.copyWith(
                    color: surfaceColors.fg,
                  ),
                ),
                const FlesselGap.s(),
                Text(
                  text,
                  style: FlesselFonts.contentBodyAccent.copyWith(
                    color: surfaceColors.fg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
