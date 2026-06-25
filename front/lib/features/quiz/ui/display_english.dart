import 'package:langwij/entities/group/group.dart';
import 'package:langwij/l10n/app_localizations.dart';

String _verbPart(String text) {
  final t = text.trim();
  if (t.length >= 4 && t.substring(0, 4).toLowerCase() == 'you ') {
    return t.substring(4).trim();
  }
  return t;
}

String displayNativeForCard(CardModel card, AppLocalizations l10n) {
  if (card is! EndingCard) return card.nativeText;
  final p = card.pronoun.toLowerCase();
  if (p == 'ti') return '${l10n.pronounYouInformal} ${_verbPart(card.nativeText)}';
  if (p == 'vi') return '${l10n.pronounYouFormal} ${_verbPart(card.nativeText)}';
  return card.nativeText;
}
