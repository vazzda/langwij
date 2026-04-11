import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_ext.dart';
import '../app/providers/dictionary_provider.dart';
import '../shared/ui/layout/langwij_layout.dart';
import '../entities/language/lang_codes.dart';
import '../entities/language/language_pack.dart';
import 'package:flessel/flessel.dart';

enum LangPickerMode { native, target }

class LangPickerScreen extends ConsumerWidget {
  const LangPickerScreen({super.key, required this.mode});

  final LangPickerMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncAllPacks = ref.watch(allPacksProvider);

    final title = switch (mode) {
      LangPickerMode.native => l10n.language_iSpeak,
      LangPickerMode.target => l10n.language_iLearn,
    };

    return FlesselScaffold(
      title: title,
      uppercaseTitle: true,
      onBackPressed: () => context.pop(),
      child: asyncAllPacks.when(
        loading: () => const Center(child: FlesselSpinner()),
        error: (_, __) => Center(child: Text(l10n.loadError)),
        data: (packs) {
          return ListView.separated(
            padding: const EdgeInsets.all(FlesselLayout.screenPadding),
            itemCount: packs.length,
            separatorBuilder: (_, __) => const FlesselGap.s(),
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
          color: t.cardBackground,
          border: Border.all(
            color: t.tileBorderColor,
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
                        .copyWith(color: t.textPrimary),
                  ),
                  const FlesselGap.xxs(),
                  Row(
                    children: [
                      _qualitySegment(
                        icon: PhosphorIconsBold.smiley,
                        pct: pack.humanVerified,
                        color: t.textSecondary,
                      ),
                      const FlesselGap.s(),
                      _qualitySegment(
                        icon: PhosphorIconsBold.robot,
                        pct: aiPct,
                        color: t.textSecondary,
                      ),
                      if (pack.code == LangCodes.serbian) ...[
                        const FlesselGap.s(),
                        const Text('\u2764\uFE0F'),
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
