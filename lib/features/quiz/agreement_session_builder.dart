import 'dart:math';

import '../../entities/card/card_model.dart';
import '../../entities/group/group_model.dart';

/// Builds a queue of phrase cards (adjective + noun in agreement) for an agreement session.
/// Picks a random session gender; combines random adjectives from [adjectiveGroup]
/// with random nouns of that gender from [nounGroups].
({List<CardModel> queue, Set<String> wordIds}) buildAgreementQueue({
  required GroupModel adjectiveGroup,
  required List<GroupModel> nounGroups,
  required int count,
  required Random random,
}) {
  final adjectives = adjectiveGroup.cards
      .whereType<AdjectiveCard>()
      .toList();
  final nounsByGender = <String, List<NounCard>>{
    'm': [],
    'f': [],
    'n': [],
  };
  for (final group in nounGroups) {
    for (final card in group.cards) {
      if (card is NounCard) {
        nounsByGender[card.gender]!.add(card);
      }
    }
  }
  final gendersWithNouns = ['m', 'f', 'n']
      .where((g) => nounsByGender[g]!.isNotEmpty)
      .toList();
  if (gendersWithNouns.isEmpty || adjectives.isEmpty) {
    return (queue: <CardModel>[], wordIds: <String>{});
  }
  final sessionGender = gendersWithNouns[random.nextInt(gendersWithNouns.length)];
  final nouns = nounsByGender[sessionGender]!;
  final queue = <CardModel>[];
  final wordIds = <String>{};
  for (var i = 0; i < count; i++) {
    final adj = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];
    final serbian = '${adj.formForGender(sessionGender)} ${noun.serbian}';
    final english = '${adj.english} ${noun.english}';
    queue.add(PhraseCard(serbian: serbian, english: english));
    wordIds.add('agreement:${adjectiveGroup.id}:$i');
  }
  return (queue: queue, wordIds: wordIds);
}
