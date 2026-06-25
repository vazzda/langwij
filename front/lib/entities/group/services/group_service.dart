import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/group_model.dart';
import '../model/test_result.dart';
import 'group_internal_service.dart';

class GroupService {
  GroupService(this._ref);
  final Ref _ref;

  static final instance = Provider((ref) => GroupService(ref));

  static final groups = FutureProvider<List<GroupModel>>((ref) async {
    final repo = ref.watch(GroupInternalService.groupRepository);
    return repo.loadGroups();
  });

  static final testResults = FutureProvider<Map<String, TestResult>>((ref) async {
    ref.watch(GroupInternalService.revision);
    final repo = await ref.watch(GroupInternalService.testResultRepository.future);
    return repo.getAllResults();
  });

  Future<void> saveTestResult(String groupId, int percentage) async {
    final repo = await _ref.read(GroupInternalService.testResultRepository.future);
    await repo.saveResult(groupId, percentage);
    _ref.read(GroupInternalService.revision.notifier).state++;
  }

  static List<GroupModel> nounGroups(List<GroupModel> all) =>
      all.where((g) => g.category == GroupCategory.noun).toList();

  static List<GroupModel> adjectiveGroups(List<GroupModel> all) =>
      all.where((g) => g.category == GroupCategory.adjective).toList();

  static String groupPreviewText(GroupModel group) {
    const maxPreview = 5;
    if (group.type == GroupType.words) {
      final n = group.cards.length.clamp(0, maxPreview);
      if (n == 0) return '';
      final words = group.cards
          .take(n)
          .map((c) => c.targetText)
          .toList();
      final joined = words.join(', ');
      return group.cards.length > maxPreview ? '$joined …' : joined;
    } else {
      final verbCount = wordCount(group);
      final n = verbCount.clamp(0, maxPreview);
      if (n == 0) return '';
      final words = <String>[];
      for (var i = 0; i < n; i++) {
        final idx = i * 6;
        if (idx < group.cards.length) {
          words.add(group.cards[idx].targetText);
        }
      }
      final joined = words.join(', ');
      return verbCount > maxPreview ? '$joined …' : joined;
    }
  }
}
