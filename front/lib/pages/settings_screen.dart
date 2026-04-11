import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_ext.dart';
import '../app/providers/dev_section_provider.dart';
import '../app/providers/dictionary_provider.dart';
import '../app/providers/language_settings_provider.dart';
import '../app/providers/theme_provider.dart';
import '../entities/language/language_pack.dart';
import 'package:flessel/flessel.dart';
import '../shared/ui/langwij_main_nav_bar.dart';
import 'package:langwij/shared/lib/constants.dart';
import '../shared/validators/startup_validator.dart';
import '../shared/validators/config_validator.dart';

/// Settings screen for app configuration.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _validating = false;

  void _showDevPasswordSheet() {
    final passwordController = TextEditingController();
    showFlesselBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (sheetContext) {
        final t = FlesselThemes.of(sheetContext);
        final l10n = AppLocalizations.of(sheetContext)!;
        String? error;
        var listenerAdded = false;
        return StatefulBuilder(
          builder: (stateContext, setSheetState) {
            if (!listenerAdded) {
              listenerAdded = true;
              passwordController.addListener(() => setSheetState(() {}));
            }
            final hasText = passwordController.text.isNotEmpty;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.dev_enterPassword,
                  style: FlesselFonts.contentXxlAccent
                      .copyWith(color: t.textPrimary),
                ),
                const FlesselGap.l(),
                FlesselTextInput(
                  controller: passwordController,
                  autofocus: true,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  onSubmitted: hasText
                      ? (_) {
                          if (passwordController.text ==
                              AppConstants.devAccessPassword) {
                            Navigator.of(stateContext).pop();
                            ref.read(devSectionEnabledProvider.notifier).state =
                                true;
                            saveDevSectionEnabled(true);
                          } else {
                            setSheetState(
                                () => error = l10n.dev_wrongPassword);
                          }
                        }
                      : null,
                ),
                const FlesselGap.s(),
                Opacity(
                  opacity: error != null ? 1.0 : 0.0,
                  child: Text(
                    error ?? ' ',
                    style: FlesselFonts.contentS
                        .copyWith(color: t.dangerColor),
                  ),
                ),
                const FlesselGap.xxs(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlesselTextButton(
                      label: l10n.cancel,
                      onPressed: () => Navigator.of(stateContext).pop(),
                    ),
                    const FlesselGap.s(),
                    FlesselAccentButton(
                      label: l10n.dev_unlock,
                      onPressed: hasText
                          ? () {
                              if (passwordController.text ==
                                  AppConstants.devAccessPassword) {
                                Navigator.of(stateContext).pop();
                                ref
                                    .read(devSectionEnabledProvider.notifier)
                                    .state = true;
                                saveDevSectionEnabled(true);
                              } else {
                                setSheetState(
                                    () => error = l10n.dev_wrongPassword);
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleHideDevSection() {
    ref.read(devSectionEnabledProvider.notifier).state = false;
    saveDevSectionEnabled(false);
  }

  Future<void> _handleValidateConfigs() async {
    if (_validating) return;
    setState(() => _validating = true);
    try {
      await StartupValidator.validateAll();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        FlesselSnackBar.show(context, l10n.settings_validateSuccess);
      }
    } on ConfigValidationError catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        FlesselSnackBar.show(context, l10n.settings_validateError(e.message));
      }
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = FlesselThemes.of(context);
    final currentTheme = ref.watch(themeProvider);
    final showDevSection = ref.watch(devSectionEnabledProvider);
    final langSettings = ref.watch(languageSettingsProvider);
    final asyncAllPacks = ref.watch(allPacksProvider);
    final asyncUiLanguages = ref.watch(uiLanguagesProvider);

    return FlesselScaffold(
      title: l10n.settingsTitle,
      uppercaseTitle: true,
      bottomNavBar: LangwijMainNavBar(
        onDevAccessTapsReached: _showDevPasswordSheet,
      ),
      child: ListView(
        padding: const EdgeInsets.all(FlesselLayout.screenPadding),
        children: [
          // App language section
          asyncAllPacks.when(
            loading: () => const SizedBox.shrink(),
            // ignore: unnecessary_underscores
            error: (_, __) => const SizedBox.shrink(),
            data: (packs) {
              final packByCode = {for (final p in packs) p.code: p};
              return asyncUiLanguages.when(
                loading: () => const SizedBox.shrink(),
                // ignore: unnecessary_underscores
                error: (_, __) => const SizedBox.shrink(),
                data: (uiCodes) {
                  final uiCodesList = uiCodes.toList();
                  if (uiCodesList.isEmpty) return const SizedBox.shrink();

                  final Widget picker;
                  if (uiCodesList.length == 1) {
                    final pack =
                        packByCode[uiCodesList.first] as LanguagePack;
                    picker = FlesselButton(
                      label: l10n.langLabel(pack.labelKey),
                      size: FlesselSize.s,
                      onPressed: null,
                    );
                  } else {
                    final selectedIndex =
                        uiCodesList.indexOf(langSettings.uiLang);
                    picker = FlesselButtonGroup(
                      expanded: true,
                      size: FlesselSize.s,
                      selectedIndices:
                          selectedIndex >= 0 ? {selectedIndex} : const {},
                      items: uiCodesList.map((code) {
                        final pack = packByCode[code] as LanguagePack;
                        final isSelected = code == langSettings.uiLang;
                        return FlesselButtonGroupItem(
                          label: l10n.langLabel(pack.labelKey),
                          onPressed: isSelected
                              ? null
                              : () => ref
                                  .read(languageSettingsProvider.notifier)
                                  .setUiLang(code),
                        );
                      }).toList(),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: FlesselLayout.listItemGapSmall),
                        child: Text(
                          l10n.language_appLanguage,
                          style: FlesselFonts.contentXxlAccent
                              .copyWith(color: t.textPrimary),
                        ),
                      ),
                      picker,
                      const FlesselGap.xl(),
                    ],
                  );
                },
              );
            },
          ),
          // Theme section
          Padding(
            padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
            child: Text(
              l10n.settingsTheme,
              style:
                  FlesselFonts.contentXxlAccent.copyWith(color: t.textPrimary),
            ),
          ),
          FlesselCard(
            child: Column(
              children: [
                for (final theme in AppTheme.values)
                  FlesselRadioTile<AppTheme>(
                    value: theme,
                    groupValue: currentTheme,
                    label: theme.getDisplayName(l10n),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(themeProvider.notifier).state = value;
                        saveAppTheme(value);
                      }
                    },
                  ),
              ],
            ),
          ),
          // Developer section (hidden until unlocked)
          if (showDevSection) ...[
            const FlesselGap.xl(),
            Padding(
              padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.settingsDeveloper,
                    style: FlesselFonts.contentXxlAccent
                        .copyWith(color: t.textPrimary),
                  ),
                  FlesselButton(
                    label: l10n.settingsHide,
                    onPressed: _handleHideDevSection,
                  ),
                ],
              ),
            ),
            FlesselCard(
              onTap: _validating ? null : _handleValidateConfigs,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.settings_validateConfigs,
                      style: FlesselFonts.contentM
                          .copyWith(color: t.textPrimary),
                    ),
                  ),
                  if (_validating)
                    FlesselSpinner(
                      size: FlesselSize.xs,
                      color: t.textSecondary,
                    )
                  else
                    Icon(PhosphorIconsRegular.caretRight, color: t.textPrimary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

