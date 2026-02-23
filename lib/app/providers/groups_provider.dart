import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entities/group/group_model.dart';
import '../../shared/repositories/verbs_repository.dart';

final groupsProvider = FutureProvider<List<GroupModel>>((ref) async {
  final repo = VerbsRepository();
  return repo.loadGroups();
});

/// Selected group (set when user taps a group). Used by mode/count and session screens.
final selectedGroupProvider = StateProvider<GroupModel?>((ref) => null);

/// Scroll offset to restore when returning to list screen. Set by result/session exit.
final scrollOffsetToRestoreProvider = StateProvider<double?>((ref) => null);

/// Noun groups (for agreement sessions).
List<GroupModel> nounGroups(List<GroupModel> all) =>
    all.where((g) => g.category == GroupCategory.noun).toList();

/// Adjective groups (for agreement group list).
List<GroupModel> adjectiveGroups(List<GroupModel> all) =>
    all.where((g) => g.category == GroupCategory.adjective).toList();
