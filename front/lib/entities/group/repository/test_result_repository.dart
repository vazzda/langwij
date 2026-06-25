import 'package:sqflite/sqflite.dart';

import '../model/test_result.dart';

class TestResultRepository {
  TestResultRepository({required Database db}) : _db = db;

  final Database _db;

  Future<TestResult?> getResult(String groupId) async {
    final rows = await _db.query(
      'test_results',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return TestResult(
      percentage: (row['percentage'] as int?) ?? 0,
      date: DateTime.parse(row['date'] as String),
    );
  }

  Future<Map<String, TestResult>> getAllResults() async {
    final rows = await _db.query('test_results');
    final results = <String, TestResult>{};
    for (final row in rows) {
      final groupId = row['group_id'] as String;
      results[groupId] = TestResult(
        percentage: (row['percentage'] as int?) ?? 0,
        date: DateTime.parse(row['date'] as String),
      );
    }
    return results;
  }

  Future<void> saveResult(String groupId, int percentage) async {
    await _db.insert(
      'test_results',
      {
        'group_id': groupId,
        'percentage': percentage,
        'date': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
