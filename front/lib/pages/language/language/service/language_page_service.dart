import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/entities/activity/activity.dart';
import 'package:langwij/entities/progress/progress.dart';
import 'package:langwij/shared/app/config/config.dart';

class LanguagePageService {
  LanguagePageService(this._ref);
  final Ref _ref;

  static final instance = Provider((ref) => LanguagePageService(ref));

  Future<void> resetLanguage(String targetLang) async {
    await _ref.read(ProgressService.instance).deleteForLanguage(targetLang);
    await _ref.read(ActivityService.instance).deleteForLanguage(targetLang);
    _ref.read(ConfigService.instance).bumpRevision();
  }
}
