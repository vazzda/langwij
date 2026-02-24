import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../shared/repositories/models/decay_formula.dart';
import '../app/providers/app_settings_provider.dart';
import '../app/providers/dev_section_provider.dart';
import '../app/providers/theme_provider.dart';
import '../app/router/app_router.dart';
import '../app/theme/app_themes.dart';
import '../shared/ui/buttons/project_buttons.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';
import '../shared/ui/card/project_card.dart';
import '../shared/ui/inputs/project_radio_tile.dart';
import 'package:srpski_card/shared/lib/constants.dart';

/// Settings screen for app configuration.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _settingsTapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDevSectionState();
  }

  Future<void> _loadDevSectionState() async {
    final enabled = await loadDevSectionEnabled();
    if (mounted) {
      ref.read(devSectionEnabledProvider.notifier).state = enabled;
    }
  }

  void _handleTitleTap() {
    setState(() {
      _settingsTapCount++;
      if (_settingsTapCount >= AppConstants.devAccessTapCount) {
        ref.read(devSectionEnabledProvider.notifier).state = true;
        saveDevSectionEnabled(true);
        _settingsTapCount = 0;
      }
    });
  }

  void _handleHideDevSection() {
    ref.read(devSectionEnabledProvider.notifier).state = false;
    saveDevSectionEnabled(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = AppThemes.of(context);
    final settings = ref.watch(appSettingsProvider);
    final currentTheme = ref.watch(themeProvider);
    final showDevSection = ref.watch(devSectionEnabledProvider);

    return ScreenLayoutWidget(
      title: l10n.settingsTitle,
      showBottomNav: true,
      onSettingsDisabledTap: _handleTitleTap,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme section
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.settingsTheme,
              style: AppFontStyles.textSectionHeader.copyWith(color: t.textPrimary),
            ),
          ),
          ProjectCard(
            child: Column(
              children: [
                for (final theme in AppTheme.values)
                  ProjectRadioTile<AppTheme>(
                    value: theme,
                    groupValue: currentTheme,
                    label: theme.getDisplayName(),
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
          const SizedBox(height: 24),
          // Decay section
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.settingsDecaySpeed,
              style: AppFontStyles.textSectionHeader.copyWith(color: t.textPrimary),
            ),
          ),
          _DecayOption(
            title: l10n.decayRelaxed,
            description: l10n.decayRelaxedDesc,
            isSelected: settings.decayFormula == DecayFormula.relaxed,
            onTap: () => ref
                .read(appSettingsProvider.notifier)
                .setDecayFormula(DecayFormula.relaxed),
          ),
          const SizedBox(height: 8),
          _DecayOption(
            title: l10n.decayStandard,
            description: l10n.decayStandardDesc,
            isSelected: settings.decayFormula == DecayFormula.standard,
            onTap: () => ref
                .read(appSettingsProvider.notifier)
                .setDecayFormula(DecayFormula.standard),
          ),
          const SizedBox(height: 8),
          _DecayOption(
            title: l10n.decayIntensive,
            description: l10n.decayIntensiveDesc,
            isSelected: settings.decayFormula == DecayFormula.intensive,
            onTap: () => ref
                .read(appSettingsProvider.notifier)
                .setDecayFormula(DecayFormula.intensive),
          ),
          const SizedBox(height: 8),
          _DecayOption(
            title: l10n.decayHardcore,
            description: l10n.decayHardcoreDesc,
            isSelected: settings.decayFormula == DecayFormula.hardcore,
            onTap: () => ref
                .read(appSettingsProvider.notifier)
                .setDecayFormula(DecayFormula.hardcore),
          ),
          // Developer section (hidden until unlocked)
          if (showDevSection) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Developer',
                    style: AppFontStyles.textSectionHeader.copyWith(color: t.textPrimary),
                  ),
                  BaseButton(
                    label: l10n.settingsHide,
                    onPressed: _handleHideDevSection,
                  ),
                ],
              ),
            ),
            ProjectCard(
              onTap: () => context.push(AppRoutes.devControls),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Controls List',
                      style: AppFontStyles.textListItem.copyWith(color: t.textPrimary),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: t.textPrimary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DecayOption extends StatelessWidget {
  const _DecayOption({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);

    return ProjectCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isSelected
                      ? AppFontStyles.textListItemAccented.copyWith(color: t.textPrimary)
                      : AppFontStyles.textListItem.copyWith(color: t.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppFontStyles.textCaption.copyWith(color: t.textSecondary),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: t.accentColor,
            ),
        ],
      ),
    );
  }
}
