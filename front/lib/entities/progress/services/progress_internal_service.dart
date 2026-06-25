import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../repository/deck_progress_repository.dart';
import '../repository/language_stats_repository.dart';

class ProgressInternalService {
  static final deckProgressRepository = FutureProvider<DeckProgressRepository>((ref) async {
    final db = await ref.watch(DatabaseService.database.future);
    return DeckProgressRepository(db: db);
  });

  static final languageStatsRepository = FutureProvider<LanguageStatsRepository>((ref) async {
    final db = await ref.watch(DatabaseService.database.future);
    return LanguageStatsRepository(db: db);
  });

  static final revision = StateProvider<int>((_) => 0);
}
