import 'package:langwij/entities/group/group.dart';
import 'package:langwij/entities/progress/progress.dart';

class DrillGroupCardData {
  DrillGroupCardData({
    required this.group,
    required this.name,
    required this.cardCount,
    required this.words,
    this.coverage,
    this.progress,
  });

  final GroupModel group;
  final String name;
  final int cardCount;
  final List<String> words;
  final int? coverage;
  final DeckProgress? progress;
}
