import '../../entities/group/group_model.dart';
import '../../l10n/app_localizations.dart';

/// Returns the localized display label for a group by its labelKey.
String groupLabel(AppLocalizations l10n, String labelKey) {
  switch (labelKey) {
    case 'groupWords':
      return l10n.groupWords;
    case 'groupBasicVerbs01':
      return l10n.groupBasicVerbs01;
    case 'groupBasicVerbs02':
      return l10n.groupBasicVerbs02;
    case 'groupBasicVerbs03':
      return l10n.groupBasicVerbs03;
    case 'groupBasicVerbs04':
      return l10n.groupBasicVerbs04;
    case 'groupBasicVerbs05':
      return l10n.groupBasicVerbs05;
    case 'groupBasicVerbs06':
      return l10n.groupBasicVerbs06;
    case 'groupBasicVerbs07':
      return l10n.groupBasicVerbs07;
    case 'groupBasicVerbs08':
      return l10n.groupBasicVerbs08;
    case 'groupBasicVerbs09':
      return l10n.groupBasicVerbs09;
    case 'groupBasicVerbs10':
      return l10n.groupBasicVerbs10;
    case 'groupBasicVerbs11':
      return l10n.groupBasicVerbs11;
    case 'groupAdverbsOfTime':
      return l10n.groupAdverbsOfTime;
    case 'groupPrepositions':
      return l10n.groupPrepositions;
    case 'groupDemonstrativePronouns':
      return l10n.groupDemonstrativePronouns;
    case 'groupRelativeDirection':
      return l10n.groupRelativeDirection;
    case 'groupDegreeAndQuantity':
      return l10n.groupDegreeAndQuantity;
    case 'groupPeople':
      return l10n.groupPeople;
    case 'groupPlaces':
      return l10n.groupPlaces;
    case 'groupDailyItemsAndObjects':
      return l10n.groupDailyItemsAndObjects;
    case 'groupTimeAndNature':
      return l10n.groupTimeAndNature;
    case 'groupAbstractConcepts':
      return l10n.groupAbstractConcepts;
    case 'groupGeneralQualities':
      return l10n.groupGeneralQualities;
    case 'groupPeopleAndEmotions':
      return l10n.groupPeopleAndEmotions;
    case 'groupSensesAndFeelings':
      return l10n.groupSensesAndFeelings;
    case 'groupColors':
      return l10n.groupColors;
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
        .map((c) => (c as dynamic).serbian as String)
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
        words.add(group.cards[idx].serbian);
      }
    }
    final joined = words.join(', ');
    return verbCount > maxPreview ? '$joined …' : joined;
  }
}
