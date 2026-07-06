import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/group_model.dart';

class GroupRepository {
  static const String _assetPath = 'assets/data/drills_sr.json';

  Future<List<GroupModel>> loadGroups() async {
    final json = await rootBundle.loadString(_assetPath);
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
