import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/nav_bar/ui/main_nav_bar.dart';
import 'package:langwij/shared/app/layout/layout.dart';

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

    return FlesselScaffold(
      title: title,
      uppercaseTitle: true,
      onBackPressed: () => context.pop(),
      navBarItems: LangwijMainNavBar.items(context),
      navBarCurrentIndex: LangwijMainNavBar.currentIndex(context),
      notchedNavBar: true,
      navBarSize: FlesselSize.xs,
      floatingActionButton: LangwijMainNavBar.fab(context),
      child: asyncAllPacks.when(
        loading: () => const Center(child: FlesselSpinner()),
        error: (_, _) => Center(child: Text(l10n.loadError)),
        data: (packs) {
          return ListView.separated(
            padding: FlesselLayout.screenPaddingInsets(context).copyWith(
              bottom: FlesselLayout.screenPaddingInsets(context).bottom + FlesselLayout.navbarSpacer(context),
            ),
            itemCount: packs.length,
            separatorBuilder: (_, _) => const FlesselGap.s(),
            itemBuilder: (_, index) {
              final pack = packs[index];
              return _LangPickerTile(
                pack: pack,
                label: l10n.langLabel(pack.labelKey),
                onTap: () => context.pop(pack.code),
              );
            },
          );
        },
      ),
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
    final aiPct = 100 - pack.humanVerified;

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
              CountryFlag.fromCountryCode(
                countryCode,
                theme: const ImageTheme(
                  width: LangwijLayout.langFlagWidth,
                  height: LangwijLayout.langFlagHeight,
                  shape: RoundedRectangle(4),
                ),
              ),
            const FlesselGap.m(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: FlesselFonts.contentLAccent
                        .copyWith(color: t.fg),
                  ),
                  const FlesselGap.xxs(),
                  Row(
                    children: [
                      _qualitySegment(
                        icon: PhosphorIconsBold.smiley,
                        pct: pack.humanVerified,
                        color: t.fgSecondary,
                      ),
                      const FlesselGap.s(),
                      _qualitySegment(
                        icon: PhosphorIconsBold.robot,
                        pct: aiPct,
                        color: t.fgSecondary,
                      ),
                      if (pack.code == LangCodes.serbian) ...[
                        const FlesselGap.s(),
                        const Text('❤️'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _qualitySegment({
    required IconData icon,
    required int pct,
    required Color color,
  }) {
    return SizedBox(
      width: LangwijLayout.langPickerQualitySegmentWidth,
      child: Row(
        children: [
          Icon(icon, size: FlesselLayout.iconS, color: color),
          const FlesselGap.xs(),
          Text(
            '$pct%',
            style: FlesselFonts.contentSAccent.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
