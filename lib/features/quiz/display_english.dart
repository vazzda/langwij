import '../../entities/card/card_model.dart';
import '../../l10n/app_localizations.dart';

/// Returns the verb part of [english] by stripping a leading "you " (case insensitive).
String _verbPart(String english) {
  final t = english.trim();
  if (t.length >= 4 && t.substring(0, 4).toLowerCase() == 'you ') {
    return t.substring(4).trim();
  }
  return t;
}

/// Display string for the English side of a card. Ti → "you (informal, singular) …", Vi → "you (formal, plural) …".
String displayEnglishForCard(CardModel card, AppLocalizations l10n) {
  if (card is! EndingCard) return card.english;
  final p = card.pronoun.toLowerCase();
  if (p == 'ti') return '${l10n.pronounYouInformal} ${_verbPart(card.english)}';
  if (p == 'vi') return '${l10n.pronounYouFormal} ${_verbPart(card.english)}';
  return card.english;
}
