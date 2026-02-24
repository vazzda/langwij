import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../app/providers/daily_activity_provider.dart';
import '../app/providers/dictionary_provider.dart';
import '../app/providers/group_progress_provider.dart';
import '../app/providers/language_settings_provider.dart';
import '../app/theme/app_themes.dart';
import '../shared/repositories/daily_activity_repository.dart';
import '../shared/repositories/dictionary_repository.dart';
import '../shared/ui/buttons/project_button_group.dart';
import '../shared/ui/buttons/project_buttons.dart' show ButtonSize;
import '../shared/ui/card/project_card.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';

/// Resolves a language ARB label key to its localized string.
String _langLabel(AppLocalizations l10n, String labelKey) {
  switch (labelKey) {
    case 'lang_english':
      return l10n.lang_english;
    case 'lang_serbian':
      return l10n.lang_serbian;
    case 'lang_russian':
      return l10n.lang_russian;
    default:
      return labelKey;
  }
}

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = AppThemes.of(context);
    final langSettings = ref.watch(languageSettingsProvider);
    final asyncAllPacks = ref.watch(allPacksProvider);
    final asyncStats = ref.watch(dailyActivityProvider);
    final allProgress = ref.watch(groupProgressProvider);
    final asyncDictionary = ref.watch(dictionaryProvider);

    return ScreenLayoutWidget(
      title: l10n.navLanguage,
      showBottomNav: true,
      child: asyncAllPacks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // ignore: unnecessary_underscores
        error: (_, __) => Center(child: Text(l10n.loadError)),
        data: (packs) {
          // All language codes from packs
          final allCodes = packs.map((p) => p.code).toList();
          // Available UI languages
          final uiCodes = availableUiLanguages;
          // Find packs map for label lookup
          final packByCode = {for (final p in packs) p.code: p};

          // Progress stats
          final totalGroups = asyncDictionary.valueOrNull?.groups.length ?? 0;
          final groupsWithProgress = allProgress.values
              .where((p) => p.recentSessions.isNotEmpty)
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Target language selector
              _SectionHeader(label: l10n.language_learning),
              const SizedBox(height: 8),
              _LangButtonGroup(
                codes: allCodes,
                selectedCode: langSettings.targetLang,
                disabledCode: langSettings.nativeLang,
                packByCode: packByCode,
                l10n: l10n,
                onSelected: (code) {
                  ref.read(languageSettingsProvider.notifier).setTargetLang(code);
                },
              ),
              const SizedBox(height: 20),

              // Native language selector
              _SectionHeader(label: l10n.language_native),
              const SizedBox(height: 8),
              _LangButtonGroup(
                codes: allCodes,
                selectedCode: langSettings.nativeLang,
                disabledCode: langSettings.targetLang,
                packByCode: packByCode,
                l10n: l10n,
                onSelected: (code) {
                  ref.read(languageSettingsProvider.notifier).setNativeLang(code);
                },
              ),
              const SizedBox(height: 20),

              // UI language selector
              _SectionHeader(label: l10n.language_appLanguage),
              const SizedBox(height: 8),
              _LangButtonGroup(
                codes: uiCodes,
                selectedCode: langSettings.uiLang,
                packByCode: packByCode,
                l10n: l10n,
                onSelected: (code) {
                  ref.read(languageSettingsProvider.notifier).setUiLang(code);
                },
              ),
              const SizedBox(height: 24),

              // Daily activity
              _DailyActivityCard(asyncStats: asyncStats, l10n: l10n),
              const SizedBox(height: 12),

              // Progress overview
              ProjectCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.language_myProgress,
                      style: AppFontStyles.textListItem.copyWith(color: t.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.language_groupsProgress(groupsWithProgress, totalGroups),
                      style: AppFontStyles.textCaption.copyWith(color: t.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Incomplete dictionaries
              ...packs
                  .where((p) => !p.isComplete)
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ProjectCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _langLabel(l10n, p.labelKey),
                                  style: AppFontStyles.textListItem.copyWith(color: t.textPrimary),
                                ),
                              ),
                              Text(
                                l10n.language_conceptsCount(p.translatedCount, p.totalConcepts),
                                style: AppFontStyles.textCaption.copyWith(color: t.dangerColor),
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
    this.disabledCode,
    required this.packByCode,
    required this.l10n,
    required this.onSelected,
  });

  final List<String> codes;
  final String selectedCode;
  final String? disabledCode;
  final Map<String, dynamic> packByCode;
  final AppLocalizations l10n;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ProjectButtonGroup(
      expanded: true,
      size: ButtonSize.small,
      items: codes.map((code) {
        final pack = packByCode[code];
        final labelKey = pack?.labelKey ?? 'lang_$code';
        final isSelected = code == selectedCode;
        final isDisabled = code == disabledCode;
        return ProjectButtonGroupItem(
          label: _langLabel(l10n, labelKey as String),
          isSelected: isSelected,
          onPressed: isDisabled || isSelected ? null : () => onSelected(code),
        );
      }).toList(),
    );
  }
}

class _DailyActivityCard extends StatelessWidget {
  const _DailyActivityCard({
    required this.asyncStats,
    required this.l10n,
  });

  final AsyncValue<DailyActivityStats> asyncStats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    return ProjectCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dailyActivityTitle,
              style: AppFontStyles.textListItem.copyWith(color: t.textPrimary),
            ),
            const SizedBox(height: 4),
            asyncStats.when(
              data: (stats) {
                final isEmpty = stats.correct == 0 &&
                    stats.wrong == 0 &&
                    stats.wordsTouched == 0;
                return Text(
                  isEmpty
                      ? l10n.dailyActivityEmpty
                      : '${l10n.correctCount(stats.correct)} · ${l10n.wrongCount(stats.wrong)} · ${l10n.wordsCount(stats.wordsTouched)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFontStyles.textCaption.copyWith(color: t.textSecondary),
                );
              },
              loading: () => Text(
                l10n.dailyActivityEmpty,
                style: AppFontStyles.textCaption.copyWith(color: t.textSecondary),
              ),
              // ignore: unnecessary_underscores
              error: (_, __) => Text(
                l10n.dailyActivityEmpty,
                style: AppFontStyles.textCaption.copyWith(color: t.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
