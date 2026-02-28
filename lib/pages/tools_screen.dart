import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../app/providers/language_settings_provider.dart';
import '../entities/language/lang_codes.dart';
import '../app/router/app_router.dart';
import '../app/theme/app_themes.dart';
import '../shared/ui/card/project_card.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';

/// Tools screen — language-specific practice tools.
/// For Serbian: conjugation endings and gender agreement drills.
class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = AppThemes.of(context);
    final langSettings = ref.watch(languageSettingsProvider);

    // Tools available per target language.
    final tools = _toolsForLanguage(langSettings.targetLang);

    return ScreenLayoutWidget(
      title: l10n.navTools,
      showBottomNav: true,
      child: tools.isEmpty
          ? Center(
              child: Text(
                l10n.tools_emptyState,
                style: AppFontStyles.textBody.copyWith(color: t.textSecondary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: tools.map((tool) {
                final label = _toolLabel(tool, l10n);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProjectCard(
                    onTap: () => _onToolTap(context, tool),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: AppFontStyles.textListItem.copyWith(color: t.textPrimary),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: t.textPrimary,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  void _onToolTap(BuildContext context, _Tool tool) {
    switch (tool) {
      case _Tool.conjugations:
        context.go(AppRoutes.conjugations);
      case _Tool.agreement:
        context.go(AppRoutes.agreement);
    }
  }
}

enum _Tool { conjugations, agreement }

List<_Tool> _toolsForLanguage(String targetLang) {
  switch (targetLang) {
    case LangCodes.serbian:
      return [_Tool.conjugations, _Tool.agreement];
    default:
      return [];
  }
}

String _toolLabel(_Tool tool, AppLocalizations l10n) {
  switch (tool) {
    case _Tool.conjugations:
      return l10n.tools_conjugations;
    case _Tool.agreement:
      return l10n.tools_agreement;
  }
}
