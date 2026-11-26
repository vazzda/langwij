import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/nav_bar/ui/langwij_scaffold.dart';
import 'package:langwij/shared/flag/ui/flag.dart';

enum LangPickerMode { native, target }

class LangPickerPage extends ConsumerWidget {
  const LangPickerPage({super.key, required this.mode});

  final LangPickerMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncAllPacks = ref.watch(DictionaryService.allPacks);

    final title = switch (mode) {
      LangPickerMode.native => l10n.language_iSpeak,
      LangPickerMode.target => l10n.language_iLearn,
    };

    return LangwijScaffold(
      title: title,
      onBackPressed: () => context.pop(),
      child: asyncAllPacks.when(
        loading: () => const Center(child: FlesselSpinner()),
        error: (_, _) => Center(child: Text(l10n.loadError)),
        data: (packs) {
          final publicPacksWithoutWarning = packs
              .where((pack) => pack.isPublic && !pack.isAiGenerated)
              .toList();
          final publicAiGeneratedPacks = packs
              .where((pack) => pack.isPublic && pack.isAiGenerated)
              .toList();
          // Languages that are not public are among the packs only while
          // developer mode is on.
          final packsInDevelopment =
              packs.where((pack) => !pack.isPublic).toList();

          return ListView(
            padding: FlesselLayout.screenPaddingInsets(context).copyWith(
              bottom: FlesselLayout.screenPaddingInsets(context).bottom + LangwijScaffold.navbarSpacer(context),
            ),
            children: [
              ..._buildTilesOfLanguages(
                context,
                l10n,
                publicPacksWithoutWarning,
              ),
              ..._buildTitledSection(
                context,
                l10n,
                icon: PhosphorIconsBold.robot,
                title: l10n.language_aiGeneratedTitle,
                note: l10n.language_aiGeneratedNote,
                packs: publicAiGeneratedPacks,
              ),
              ..._buildTitledSection(
                context,
                l10n,
                icon: PhosphorIconsBold.hammer,
                title: l10n.language_inDevelopmentTitle,
                packs: packsInDevelopment,
              ),
            ],
          );
        },
      ),
    );
  }

  /// A section of languages under a heading. Nothing when the section holds
  /// no language.
  List<Widget> _buildTitledSection(
    BuildContext context,
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    String? note,
    required List<LanguagePack> packs,
  }) {
    if (packs.isEmpty) return const [];
    return [
      const FlesselGap.xl(),
      _SectionHeading(icon: icon, title: title, note: note),
      const FlesselGap.s(),
      ..._buildTilesOfLanguages(context, l10n, packs),
    ];
  }

  /// The tiles of the given languages, with a gap between each two.
  List<Widget> _buildTilesOfLanguages(
    BuildContext context,
    AppLocalizations l10n,
    List<LanguagePack> packs,
  ) {
    return [
      for (final (packIndex, pack) in packs.indexed) ...[
        if (packIndex > 0) const FlesselGap.s(),
        _LangPickerTile(
          pack: pack,
          label: l10n.langLabel(pack.labelKey),
          onTap: () => context.pop(pack.code),
        ),
      ],
    ];
  }
}

/// The heading of a titled section of languages: its icon beside its title
/// and, where the section has one, the note that warns what to expect of
/// its languages, in a card of the danger kind.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    this.note,
  });

  final IconData icon;
  final String title;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: FlesselLayout.iconM, color: t.fg),
            const FlesselGap.xs(),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: FlesselFonts.contentTitle.copyWith(color: t.fg),
              ),
            ),
          ],
        ),
        if (note case final noteText?) ...[
          const FlesselGap.xs(),
          FlesselCard(
            surface: FlesselSurface.s21,
            colorVariant: FlesselVariant.danger,
            margin: FlesselSize.none,
            child: Text(
              noteText,
              style: FlesselFonts.contentSAccent.copyWith(
                color: t.surface21.danger.fg,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LangPickerTile extends StatelessWidget {
  const _LangPickerTile({
    required this.pack,
    required this.label,
    required this.onTap,
  });

  final LanguagePack pack;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = FlesselThemes.of(context);
    final countryCode = LangCodes.flagCountryCode(pack.code);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(FlesselLayout.gapM),
        decoration: BoxDecoration(
          color: t.surface01.regular.bg.colorValue,
          border: Border.all(
            color: t.surface02.regular.border,
            width: t.tileBorderWidth,
          ),
          borderRadius: BorderRadius.circular(t.tileBorderRadius),
        ),
        child: Row(
          children: [
            if (countryCode != null)
              LangwijFlag(
                countryCode: countryCode,
                size: LangwijFlagSize.large,
              ),
            const FlesselGap.m(),
            Flexible(
              child: Text(
                label,
                style: FlesselFonts.contentLAccent.copyWith(color: t.fg),
              ),
            ),
            if (pack.code == LangCodes.serbian) ...[
              const FlesselGap.s(),
              const Text('❤️'),
            ],
            if (pack.isAiGenerated) ...[
              const FlesselGap.s(),
              Icon(
                PhosphorIconsBold.robot,
                size: FlesselLayout.iconM,
                color: t.dangerColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
