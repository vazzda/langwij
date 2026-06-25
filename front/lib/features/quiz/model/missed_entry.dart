import 'package:langwij/entities/group/group.dart';

class MissedEntry {
  const MissedEntry({required this.card, this.userTypedAnswer});

  final CardModel card;
  final String? userTypedAnswer;
}
