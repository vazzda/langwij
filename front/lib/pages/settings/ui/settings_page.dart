import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flessel/flessel.dart';
import 'package:go_router/go_router.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/features/dev_tools/dev_tools.dart';
import 'package:langwij/shared/app/routing/routing.dart';
import 'package:langwij/shared/nav_bar/ui/langwij_scaffold.dart';
import 'package:langwij/shared/app/validators/validators.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const String _fullSeedName = 'full';

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

    return LangwijScaffold(
      title: l10n.settingsTitle,
      child: ListView(
        padding: FlesselLayout.screenPaddingInsets(context).copyWith(
          bottom: FlesselLayout.screenPaddingInsets(context).bottom + LangwijScaffold.navbarSpacer(context),
        ),
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: FlesselDevGate.enabled,
            builder: (_, isDeveloperSectionShown, _) => isDeveloperSectionShown
                ? _buildDeveloperToolsSection(context)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperToolsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FlesselGap.xl(),
        _buildDeveloperSectionHeader(context),
        _buildValidateConfigsCard(context),
        const FlesselGap.s(),
        _buildSeedsCard(context),
      ],
    );
  }

  Widget _buildDeveloperSectionHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = FlesselThemes.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: FlesselLayout.listItemGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.settingsDeveloper,
            style: FlesselFonts.contentXxlAccent.copyWith(color: t.fg),
          ),
          FlesselButton(
            label: l10n.settingsHide,
            onPressed: _handleHideDevSection,
          ),
        ],
      ),
    );
  }

  Widget _buildValidateConfigsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = FlesselThemes.of(context);

    return FlesselCard(
      onTap: _validating ? null : _handleValidateConfigs,
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.settings_validateConfigs,
              style: FlesselFonts.contentM.copyWith(color: t.fg),
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
    );
  }

  Widget _buildSeedsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FlesselCard(
      header: l10n.settings_seeds,
      child: Wrap(
        spacing: FlesselLayout.gapS,
        runSpacing: FlesselLayout.gapS,
        children: [
          FlesselButton(
            label: l10n.settings_seedFull,
            onPressed: () => _handleLoadSeeds(context, ref, _fullSeedName),
          ),
          FlesselButton(
            label: l10n.settings_deleteContent,
            variant: FlesselVariant.danger,
            onPressed: () => _handleDeleteContent(context, ref),
          ),
        ],
      ),
    );
  }
}
