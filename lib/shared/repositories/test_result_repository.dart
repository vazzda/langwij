import 'package:sqflite/sqflite.dart';

/// Result of a test session for a group.
class TestResult {
  const TestResult({
    required this.percentage,
    required this.date,
  });

  /// Percentage of correct answers (0-100).
  final int percentage;

  /// Date when the test was taken.
  final DateTime date;
}

/// Persists and reads test results per group.
class TestResultRepository {
  TestResultRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns the last test result for a group, or null if never tested.
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

  /// Returns all test results as a map of groupId → TestResult.
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

  /// Saves a test result for a group.
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
