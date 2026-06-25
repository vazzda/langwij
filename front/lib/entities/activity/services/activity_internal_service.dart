import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../repository/daily_activity_repository.dart';

class ActivityInternalService {
  static final dailyActivityRepository = FutureProvider<DailyActivityRepository>((ref) async {
    final db = await ref.watch(DatabaseService.database.future);
    return DailyActivityRepository(db: db);
  });

  static final revision = StateProvider<int>((_) => 0);
}
