import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../repository/app_settings_repository.dart';
import '../repository/language_settings_repository.dart';

class ConfigInternalService {
  static final appSettingsRepository = FutureProvider<AppSettingsRepository>((ref) async {
    final db = await ref.watch(DatabaseService.database.future);
    return AppSettingsRepository(db: db);
  });

  static final langSettingsRepository = FutureProvider<LanguageSettingsRepository>((ref) async {
    final db = await ref.watch(DatabaseService.database.future);
    return LanguageSettingsRepository(db: db);
  });

  static final revision = StateProvider<int>((_) => 0);
}
