import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../app/theme/app_themes.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';

/// Placeholder screen for tabs not yet implemented.
class UnderDevelopmentScreen extends StatelessWidget {
  const UnderDevelopmentScreen({super.key, required this.titleKey});

  /// l10n key used for the app bar title.
  final String titleKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = AppThemes.of(context);
    final title = titleKey == 'language' ? l10n.navLanguage : l10n.navTools;

    return ScreenLayoutWidget(
      title: title,
      showBottomNav: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.underDevelopmentTitle,
              style: AppFontStyles.textSubtitle.copyWith(color: t.textPrimary),
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
