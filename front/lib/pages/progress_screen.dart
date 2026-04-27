import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flessel/flessel.dart';

import '../l10n/app_localizations.dart';
import '../app/providers/daily_activity_provider.dart';
import '../features/vocab/widgets/langwij_vocab_daily_activity_card.dart';
import '../shared/ui/langwij_main_nav_bar.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncStats = ref.watch(dailyActivityProvider);

    return FlesselScaffold(
      title: l10n.navProgress,
      uppercaseTitle: true,
      navBarItems: LangwijMainNavBar.items(context),
      navBarCurrentIndex: LangwijMainNavBar.currentIndex(context),
      notchedNavBar: true,
      navBarSize: FlesselSize.s,
      floatingActionButton: LangwijMainNavBar.fab(context),
      child: ListView(
        padding: FlesselLayout.screenPaddingInsets(context).copyWith(
          bottom: FlesselLayout.screenPaddingInsets(context).bottom + FlesselLayout.navbarSpacer(context),
        ),
        children: [
          LangwijVocabDailyActivityCard(
            asyncStats: asyncStats,
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}
