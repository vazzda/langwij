import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:langwij/shared/app/config/config.dart';
import '../model/pronunciation_config.dart';
import '../model/pronunciation_route.dart';

class PronunciationService {
  PronunciationService(this._ref);

  final Ref _ref;
  final FlutterTts _tts = FlutterTts();

  static final instance = Provider<PronunciationService>(PronunciationService.new);

  Future<bool> pronounce(String text) async {
    try {
      final settings = await _ref.read(ConfigService.languageSettings.future);
      final route = await _resolveRoute(settings.targetLang);
      return await switch (route) {
        PronunciationRoute.deviceVoice => _speak(text, settings.targetLang),
        PronunciationRoute.googleDefine => _openDefine(text, settings.targetLang),
        PronunciationRoute.googleTranslate => _openTranslate(text, settings),
      };
    } catch (e) {
      debugPrint('PronunciationService.pronounce failed: $e');
      return false;
    }
  }

  Future<PronunciationRoute> _resolveRoute(String targetLang) async {
    final locale = PronunciationConfig.speechLocales[targetLang];
    if (locale != null && await _tts.isLanguageAvailable(locale) == true) {
      return PronunciationRoute.deviceVoice;
    }
    if (PronunciationConfig.defineQueries.containsKey(targetLang)) {
      return PronunciationRoute.googleDefine;
    }
    return PronunciationRoute.googleTranslate;
  }

  Future<bool> _speak(String text, String targetLang) async {
    final locale = PronunciationConfig.speechLocales[targetLang]!;
    await _tts.setLanguage(locale);
    final result = await _tts.speak(text);
    return result == 1;
  }

  Future<bool> _openDefine(String text, String targetLang) {
    final query = PronunciationConfig.defineQueries[targetLang]!
        .replaceAll(PronunciationConfig.wordToken, text);
    final uri = Uri.https(
      PronunciationConfig.googleSearchHost,
      PronunciationConfig.googleSearchPath,
      {'q': query, 'hl': targetLang},
    );
    return _openInApp(uri);
  }

  Future<bool> _openTranslate(String text, LanguageSettings settings) {
    final uri = Uri.https(
      PronunciationConfig.translateHost,
      '/',
      {
        'sl': settings.targetLang,
        'tl': settings.nativeLang,
        'text': text,
        'op': 'translate',
      },
    );
    return _openInApp(uri);
  }

  Future<bool> _openInApp(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.inAppBrowserView);
}
