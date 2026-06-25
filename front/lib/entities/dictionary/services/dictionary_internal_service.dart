import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/dictionary_repository.dart';
import '../repository/plan_repository.dart';
import '../model/language_entry.dart';

class DictionaryInternalService {
  static final dictionaryRepository = Provider<DictionaryRepository>((ref) {
    return DictionaryRepository();
  });

  static final planRepository = Provider<PlanRepository>((ref) {
    return PlanRepository();
  });

  static final planLanguages = FutureProvider<List<LanguageEntry>>((ref) async {
    final repo = ref.watch(planRepository);
    return repo.getLanguages();
  });

  static final publicLanguageCodes = FutureProvider<Set<String>>((ref) async {
    final repo = ref.watch(planRepository);
    return (await repo.getPublicLanguages()).toSet();
  });
}
