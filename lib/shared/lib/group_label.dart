import '../../entities/group/group_model.dart';
import '../../l10n/app_localizations.dart';

/// Returns the localized display label for a conjugation group by its labelKey.
/// Only valid for Tools (conjugation/agreement) groups — vocab groups use meta system.
String groupLabel(AppLocalizations l10n, String labelKey) {
  switch (labelKey) {
    case 'groupWords':
      return l10n.groupWords;
    case 'groupEndingsImEAti':
      return l10n.groupEndingsImEAti;
    case 'groupEndingsImEEti':
      return l10n.groupEndingsImEEti;
    case 'groupEndingsImEIti':
      return l10n.groupEndingsImEIti;
    case 'groupEndingsAmAju':
      return l10n.groupEndingsAmAju;
    case 'groupEndingsEmUGati':
      return l10n.groupEndingsEmUGati;
    case 'groupEndingsEmUHati':
      return l10n.groupEndingsEmUHati;
    case 'groupEndingsEmUKati':
      return l10n.groupEndingsEmUKati;
    case 'groupEndingsEmUAvati':
      return l10n.groupEndingsEmUAvati;
    case 'groupEndingsEmUIvati':
      return l10n.groupEndingsEmUIvati;
    case 'groupEndingsEmUOvati':
      return l10n.groupEndingsEmUOvati;
    case 'groupEndingsEmUCi':
      return l10n.groupEndingsEmUCi;
    case 'groupEndingsEmEju':
      return l10n.groupEndingsEmEju;
    case 'groupIrregular':
      return l10n.groupIrregular;
    default:
      return labelKey;
  }
}

/// Returns preview string for group tile: first up to 5 words (Serbian), comma-separated, with " …" if more.
String groupPreviewText(GroupModel group) {
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
