import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_ext.dart';
import '../app/providers/dev_section_provider.dart';
import '../app/providers/dictionary_provider.dart';
import '../app/providers/language_settings_provider.dart';
import '../app/providers/theme_provider.dart';
import '../app/router/app_router.dart';
import '../app/theme/vessel_themes.dart';
import '../entities/language/language_pack.dart';
import '../shared/ui/buttons/vessel_button_group.dart';
import '../shared/ui/bottom_sheet/vessel_bottom_sheet.dart';
import '../shared/ui/buttons/vessel_buttons.dart';
import '../shared/ui/inputs/vessel_text_input.dart';
import '../shared/ui/screen_layout/vessel_scaffold.dart';
import '../shared/ui/card/vessel_card.dart';
import '../shared/ui/inputs/vessel_radio_tile.dart';
import '../shared/ui/snackbar/vessel_snackbar.dart';
import 'package:srpski_card/shared/lib/constants.dart';
import '../shared/ui/gap/vessel_gap.dart';
import '../app/layout/vessel_layout.dart';
import '../shared/validators/startup_validator.dart';
import '../shared/validators/config_validator.dart';

/// Settings screen for app configuration.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _settingsTapCount = 0;
  bool _validating = false;

  void _handleTitleTap() {
    _settingsTapCount++;
    if (_settingsTapCount >= AppConstants.devAccessTapCount) {
      _settingsTapCount = 0;
      _showDevPasswordSheet();
    }
  }

  void _showDevPasswordSheet() {
    final passwordController = TextEditingController();
    showVesselBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (sheetContext) {
        final t = VesselThemes.of(sheetContext);
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
                  style: VesselFonts.textSheetTitle
                      .copyWith(color: t.textPrimary),
                ),
                const VesselGap.l(),
                VesselTextInput(
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
                const VesselGap.s(),
                Opacity(
                  opacity: error != null ? 1.0 : 0.0,
                  child: Text(
                    error ?? ' ',
                    style: VesselFonts.textFormError
                        .copyWith(color: t.dangerColor),
                  ),
                ),
                const VesselGap.xxs(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VesselTextButton(
                      label: l10n.cancel,
                      onPressed: () => Navigator.of(stateContext).pop(),
                    ),
                    const VesselGap.hs(),
                    VesselAccentButton(
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
        VesselSnackBar.show(context, l10n.settings_validateSuccess);
      }
    } on ConfigValidationError catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        VesselSnackBar.show(context, l10n.settings_validateError(e.message));
      }
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = VesselThemes.of(context);
    final currentTheme = ref.watch(themeProvider);
    final showDevSection = ref.watch(devSectionEnabledProvider);
    final langSettings = ref.watch(languageSettingsProvider);
    final asyncAllPacks = ref.watch(allPacksProvider);
    final asyncUiLanguages = ref.watch(uiLanguagesProvider);

    return VesselScaffold(
      title: l10n.settingsTitle,
      showBottomNav: true,
      onSettingsDisabledTap: _handleTitleTap,
      child: ListView(
        padding: const EdgeInsets.all(VesselLayout.screenPadding),
        children: [
          // App language section
          Padding(
            padding: const EdgeInsets.only(bottom: VesselLayout.listItemGapSmall),
            child: Text(
              l10n.language_appLanguage,
              style:
                  VesselFonts.textSectionHeader.copyWith(color: t.textPrimary),
            ),
          ),
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
                data: (uiCodes) => ProjectButtonGroup(
                  expanded: true,
                  size: VesselButtonSize.small,
                  items: uiCodes.map((code) {
                    final pack = packByCode[code] as LanguagePack;
                    final isSelected = code == langSettings.uiLang;
                    return VesselButtonGroupItem(
                      label: l10n.langLabel(pack.labelKey),
                      isSelected: isSelected,
                      onPressed: isSelected
                          ? null
                          : () => ref
                              .read(languageSettingsProvider.notifier)
                              .setUiLang(code),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const VesselGap.xl(),
          // Theme section
          Padding(
            padding: const EdgeInsets.only(bottom: VesselLayout.listItemGap),
            child: Text(
              l10n.settingsTheme,
              style:
                  VesselFonts.textSectionHeader.copyWith(color: t.textPrimary),
            ),
          ),
          VesselCard(
            child: Column(
              children: [
                for (final theme in AppTheme.values)
                  VesselRadioTile<AppTheme>(
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
            const VesselGap.xl(),
            Padding(
              padding: const EdgeInsets.only(bottom: VesselLayout.listItemGap),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.settingsDeveloper,
                    style: VesselFonts.textSectionHeader
                        .copyWith(color: t.textPrimary),
                  ),
                  VesselButton(
                    label: l10n.settingsHide,
                    onPressed: _handleHideDevSection,
                  ),
                ],
              ),
            ),
            VesselCard(
              onTap: () => context.push(AppRoutes.devControls),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.settingsControlsList,
                      style: VesselFonts.textListItem
                          .copyWith(color: t.textPrimary),
                    ),
                  ),
                  Icon(PhosphorIconsRegular.caretRight, color: t.textPrimary),
                ],
              ),
            ),
            const VesselGap.s(),
            VesselCard(
              onTap: _validating ? null : _handleValidateConfigs,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.settings_validateConfigs,
                      style: VesselFonts.textListItem
                          .copyWith(color: t.textPrimary),
                    ),
                  ),
                  if (_validating)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: t.textSecondary,
                      ),
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

