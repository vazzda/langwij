import 'dart:convert';

import 'package:flutter/services.dart';

import '../../entities/group/group_model.dart';

/// Loads groups and cards from bundled JSON.
class VerbsRepository {
  static const String _assetPath = 'assets/data/verbs.json';

  Future<List<GroupModel>> loadGroups() async {
    final json = await rootBundle.loadString(_assetPath);
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
