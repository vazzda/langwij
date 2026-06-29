import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flessel/flessel.dart';

import 'package:langwij/l10n/app_localizations.dart';
import 'package:langwij/entities/activity/activity.dart';
import 'package:langwij/shared/nav_bar/ui/langwij_scaffold.dart';
import 'package:langwij/widgets/vocab/daily_activity_card/ui/vocab_daily_activity_card.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncStats = ref.watch(ActivityService.todayStats);

    return LangwijScaffold(
      title: l10n.navProgress,
      child: ListView(
        padding: FlesselLayout.screenPaddingInsets(context).copyWith(
          bottom: FlesselLayout.screenPaddingInsets(context).bottom + LangwijScaffold.navbarSpacer(context),
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
