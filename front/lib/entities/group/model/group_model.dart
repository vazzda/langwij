import 'card_model.dart';
import 'adjective_card.dart';
import 'ending_card.dart';
import 'noun_card.dart';
import 'word_card.dart';

enum GroupCategory { noun, adjective, verb, other }

class GroupModel {
  const GroupModel({
    required this.id,
    required this.labelKey,
    required this.type,
    required this.cards,
    this.category,
  });

  final String id;
  final String labelKey;
  final GroupType type;
  final List<CardModel> cards;
  final GroupCategory? category;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final type = GroupType.values.byName(json['type'] as String);
    final cardsJson = json['cards'] as List<dynamic>;
    final List<CardModel> cards;
    final categoryStr = json['category'] as String?;
    final category = categoryStr != null
        ? GroupCategory.values.byName(categoryStr)
        : null;
    if (type == GroupType.endings) {
      cards = cardsJson
          .map((e) => EndingCard.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      cards = cardsJson.map((e) {
        final map = e as Map<String, dynamic>;
        if (category == GroupCategory.noun) {
          return NounCard.fromJson(map);
        }
        if (category == GroupCategory.adjective) {
          return AdjectiveCard.fromJson(map);
        }
        return WordCard.fromJson(map);
      }).toList();
    }
    return GroupModel(
      id: json['id'] as String,
      labelKey: json['labelKey'] as String,
      type: type,
      cards: cards,
      category: category,
    );
  }
}

enum GroupType { words, endings }

int wordCount(GroupModel g) {
  return g.type == GroupType.words
      ? g.cards.length
      : g.cards.length ~/ 6;
}
