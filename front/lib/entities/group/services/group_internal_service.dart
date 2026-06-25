import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/shared/app/database/database.dart';
import '../repository/group_repository.dart';
import '../repository/test_result_repository.dart';

class GroupInternalService {
  static final groupRepository = Provider<GroupRepository>((ref) {
    return GroupRepository();
  });

  static final testResultRepository = FutureProvider<TestResultRepository>((ref) async {
    final db = await ref.watch(DatabaseService.database.future);
    return TestResultRepository(db: db);
  });

  static final revision = StateProvider<int>((_) => 0);
}
