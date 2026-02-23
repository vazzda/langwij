import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../app/theme/app_themes.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';

/// Placeholder screen for tabs not yet implemented.
class UnderDevelopmentScreen extends StatelessWidget {
  const UnderDevelopmentScreen({super.key, required this.titleKey});

  /// l10n key name: 'navLanguage' or 'navTools'.
  final String titleKey;

  String _resolveTitle(AppLocalizations l10n) {
    switch (titleKey) {
      case 'navLanguage':
        return l10n.navLanguage;
      case 'navTools':
        return l10n.navTools;
      default:
        return titleKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = AppThemes.of(context);
    final title = _resolveTitle(l10n);

    return ScreenLayoutWidget(
      title: title,
      showBottomNav: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.underDevelopmentTitle,
              style: AppFontStyles.textSectionHeader.copyWith(color: t.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.underDevelopmentBody,
              style: AppFontStyles.textBody.copyWith(color: t.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
