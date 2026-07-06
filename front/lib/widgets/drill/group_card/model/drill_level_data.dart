import 'drill_group_card_data.dart';

class DrillLevelData {
  DrillLevelData({
    required this.id,
    required this.name,
    required this.groups,
  });

  final String id;
  final String name;
  final List<DrillGroupCardData> groups;
}
