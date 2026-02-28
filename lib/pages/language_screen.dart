import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_ext.dart';
import '../app/providers/all_languages_progress_provider.dart';
import '../app/providers/dev_section_provider.dart';
import '../app/providers/dictionary_provider.dart';
import '../app/providers/language_settings_provider.dart';
import '../app/theme/app_themes.dart';
import '../entities/language/language_pack.dart';
import '../shared/ui/buttons/project_button_group.dart';
import '../shared/ui/buttons/project_buttons.dart' show ButtonSize;
import '../shared/ui/card/project_card.dart';
import '../shared/ui/note/project_note.dart';
import '../shared/ui/progress_bar/project_progress_bar.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = AppThemes.of(context);
    final langSettings = ref.watch(languageSettingsProvider);
    final asyncAllPacks = ref.watch(allPacksProvider);
    final asyncAllLangProgress = ref.watch(allLanguagesProgressProvider);
    final showDevSection = ref.watch(devSectionEnabledProvider);

    return ScreenLayoutWidget(
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
            padding: const EdgeInsets.all(16),
            children: [
              // Target language selector
              _SectionHeader(label: l10n.language_learning),
              const SizedBox(height: 8),
              _LangButtonGroup(
                codes: allCodes,
                selectedCode: langSettings.targetLang,
                packByCode: packByCode,
                l10n: l10n,
                onSelected: (code) {
                  ref
                      .read(languageSettingsProvider.notifier)
                      .setTargetLang(code);
                },
              ),
              const SizedBox(height: 20),

              // Native language selector
              _SectionHeader(label: l10n.language_native),
              const SizedBox(height: 8),
              _LangButtonGroup(
                codes: allCodes,
                selectedCode: langSettings.nativeLang,
                packByCode: packByCode,
                l10n: l10n,
                onSelected: (code) {
                  ref
                      .read(languageSettingsProvider.notifier)
                      .setNativeLang(code);
                },
              ),
              if (langSettings.targetLang == langSettings.nativeLang) ...[
                const SizedBox(height: 8),
                ProjectNote(text: l10n.language_sameAsLearning),
              ],
              const SizedBox(height: 20),

              // Progression card
              _ProgressionCard(
                asyncProgress: asyncAllLangProgress,
                packByCode: packByCode,
                l10n: l10n,
              ),
              const SizedBox(height: 12),

              // Incomplete dictionaries (dev mode only)
              if (showDevSection) ...packs
                  .where((p) => !p.isPublic)
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ProjectCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.langLabel(p.labelKey),
                                  style: AppFontStyles.textListItem
                                      .copyWith(color: t.textPrimary),
                                ),
                              ),
                              Text(
                                l10n.language_conceptsCount(
                                    p.translatedCount, p.totalConcepts),
                                style: AppFontStyles.textCaption
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    return Text(
      label,
      style: AppFontStyles.textSectionHeader.copyWith(color: t.textPrimary),
    );
  }
}

class _LangButtonGroup extends StatelessWidget {
  const _LangButtonGroup({
    required this.codes,
    required this.selectedCode,
    required this.packByCode,
    required this.l10n,
    required this.onSelected,
  });

  final List<String> codes;
  final String selectedCode;
  final Map<String, LanguagePack> packByCode;
  final AppLocalizations l10n;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ProjectButtonGroup(
      expanded: true,
      size: ButtonSize.small,
      items: codes.map((code) {
        final pack = packByCode[code]!;
        final isSelected = code == selectedCode;
        return ProjectButtonGroupItem(
          label: l10n.langLabel(pack.labelKey),
          isSelected: isSelected,
          onPressed: isSelected ? null : () => onSelected(code),
        );
      }).toList(),
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
    final t = AppThemes.of(context);
    return ProjectCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.language_progression,
            style: AppFontStyles.textListItem.copyWith(color: t.textPrimary),
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
                  const SizedBox(height: 12),
                  ...List.generate(entries.length, (i) {
                    final e = entries[i];
                    final pack = packByCode[e.key]!;
                    final label = l10n.langLabel(pack.labelKey);
                    final pct = (e.value * 100).round();
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: i < entries.length - 1 ? 8 : 0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 72,
                            child: Text(
                              label,
                              style: AppFontStyles.textCaption.copyWith(
                                color: t.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ProjectProgressBar(
                              value: e.value,
                              mode: ProgressBarMode.detailed,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '$pct%',
                              textAlign: TextAlign.end,
                              style: AppFontStyles.textCaption.copyWith(
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
