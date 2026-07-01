import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/shared/app/database/database.dart';
// Barrel bypass: dev-only tool needs to bump internal revision signals.
// ignore: implementation_imports
import 'package:langwij/entities/activity/services/activity_internal_service.dart';
// ignore: implementation_imports
import 'package:langwij/entities/progress/services/progress_internal_service.dart';
import 'seed_loader_service.dart';

class DevDataService {
  DevDataService(this._ref);

  final Ref _ref;

  static final instance = Provider((ref) => DevDataService(ref));

  Future<void> loadSeeds({String seedName = 'full'}) async {
    final db = await _ref.read(DatabaseService.database.future);
    await SeedLoaderService.loadSeeds(db, seedName: seedName);
    _bumpRevisions();
  }

  Future<void> deleteContent() async {
    final db = await _ref.read(DatabaseService.database.future);
    await SeedLoaderService.truncateDataTables(db);
    _bumpRevisions();
  }

  void _bumpRevisions() {
    _ref.read(ProgressInternalService.revision.notifier).state++;
    _ref.read(ActivityInternalService.revision.notifier).state++;
  }
}
