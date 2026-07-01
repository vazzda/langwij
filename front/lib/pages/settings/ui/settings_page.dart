import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flessel/flessel.dart';
import 'package:go_router/go_router.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/l10n/app_localizations_ext.dart';
import 'package:langwij/entities/dictionary/dictionary.dart';
import 'package:langwij/features/dev_tools/dev_tools.dart';
import 'package:langwij/shared/app/config/config.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/shared/nav_bar/ui/langwij_scaffold.dart';
import 'package:langwij/shared/app/validators/validators.dart';
import 'package:langwij/shared/app/theme/theme.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _validating = false;

  void _handleHideDevSection() {
    FlesselDevGate.enabled.value = false;
  }

  Future<void> _handleLoadSeeds(
    BuildContext context,
    WidgetRef ref,
    String seedName,
  ) async {
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    final l10n = AppLocalizations.of(context)!;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: FlesselSpinner()),
      );

      await ref.read(DevDataService.instance).loadSeeds(seedName: seedName);

      if (!context.mounted) return;
      navigator.pop();
      router.go(AppRoutes.home);
    } catch (e) {
      if (!context.mounted) return;
      navigator.pop();
      FlesselSnackBar.show(context, l10n.settings_seedError(e.toString()));
    }
  }

  Future<void> _handleDeleteContent(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context)!;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: FlesselSpinner()),
      );

      await ref.read(DevDataService.instance).deleteContent();

      if (!context.mounted) return;
      navigator.pop();
      FlesselSnackBar.show(context, l10n.settings_contentDeleted);
    } catch (e) {
      if (!context.mounted) return;
      navigator.pop();
      FlesselSnackBar.show(context, l10n.settings_seedError(e.toString()));
    }
  }

  Future<void> _handleValidateConfigs() async {
    if (_validating) return;
    setState(() => _validating = true);
    try {
      await StartupValidationService.validateAll();
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
    final currentTheme = ref.watch(ThemeService.themeId);
    final asyncLangSettings = ref.watch(ConfigService.languageSettings);
    final asyncAllPacks = ref.watch(DictionaryService.allPacks);
    final asyncUiLanguages = ref.watch(DictionaryService.uiLanguages);

    final langSettings = asyncLangSettings.valueOrNull;

    return LangwijScaffold(
      title: l10n.settingsTitle,
      child: ListView(
        padding: FlesselLayout.screenPaddingInsets(context).copyWith(
          bottom: FlesselLayout.screenPaddingInsets(context).bottom + LangwijScaffold.navbarSpacer(context),
        ),
        children: [
          if (langSettings != null)
            asyncAllPacks.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (packs) {
                final packByCode = {for (final p in packs) p.code: p};
                return asyncUiLanguages.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
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
                                : () => ref.read(ConfigService.instance).setUiLang(code),
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
                                .copyWith(color: t.fg),
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
          Padding(
            padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
            child: Text(
              l10n.settingsTheme,
              style:
                  FlesselFonts.contentXxlAccent.copyWith(color: t.fg),
            ),
          ),
          FlesselCard(
            child: Column(
              children: [
                for (final entry in FlesselThemeCatalog.all)
                  FlesselRadioTile<String>(
                    value: entry.id,
                    groupValue: currentTheme,
                    label: entry.displayName,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(ThemeService.instance).setTheme(value);
                      }
                    },
                  ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: FlesselDevGate.enabled,
            builder: (_, show, _) => show
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FlesselGap.xl(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.settingsDeveloper,
                              style: FlesselFonts.contentXxlAccent
                                  .copyWith(color: t.fg),
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
                                    .copyWith(color: t.fg),
                              ),
                            ),
                            if (_validating)
                              FlesselSpinner(
                                size: FlesselSize.xs,
                                color: t.fgSecondary,
                              )
                            else
                              Icon(PhosphorIconsRegular.caretRight, color: t.fg),
                          ],
                        ),
                      ),
                      const FlesselGap.s(),
                      FlesselCard(
                        header: l10n.settings_seeds,
                        child: Wrap(
                          spacing: FlesselLayout.gapS,
                          runSpacing: FlesselLayout.gapS,
                          children: [
                            FlesselButton(
                              label: l10n.settings_seedFull,
                              onPressed: () =>
                                  _handleLoadSeeds(context, ref, 'full'),
                            ),
                            FlesselButton(
                              label: l10n.settings_deleteContent,
                              variant: FlesselVariant.danger,
                              onPressed: () =>
                                  _handleDeleteContent(context, ref),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
