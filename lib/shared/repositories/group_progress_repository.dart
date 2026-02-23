import 'package:sqflite/sqflite.dart';

import 'models/group_progress.dart';
import 'models/session_record.dart';
import '../../features/quiz/quiz_mode.dart';

/// Persists and reads group progress via SQLite.
class GroupProgressRepository {
  GroupProgressRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns progress for a group, or empty progress if none exists.
  Future<GroupProgress> getProgress(String groupId) async {
    final rows = await _db.query(
      'group_progress',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    final sessions = await _getRecentSessions(groupId);

    if (rows.isEmpty) return GroupProgress(groupId: groupId);

    final row = rows.first;
    return GroupProgress(
      groupId: groupId,
      serbianCardsProgress: (row['serbian_cards_progress'] as num).toDouble(),
      englishCardsProgress: (row['english_cards_progress'] as num).toDouble(),
      writeProgress: (row['write_progress'] as num).toDouble(),
      peakRetention: (row['peak_retention'] as num).toDouble(),
      recentSessions: sessions,
      lastSessionDate: row['last_session_date'] != null
          ? DateTime.parse(row['last_session_date'] as String)
          : null,
    );
  }

  /// Returns all progress as a map of groupId → GroupProgress.
  Future<Map<String, GroupProgress>> getAllProgress() async {
    final rows = await _db.query('group_progress');
    final results = <String, GroupProgress>{};

    for (final row in rows) {
      final groupId = row['group_id'] as String;
      final sessions = await _getRecentSessions(groupId);
      results[groupId] = GroupProgress(
        groupId: groupId,
        serbianCardsProgress:
            (row['serbian_cards_progress'] as num).toDouble(),
        englishCardsProgress:
            (row['english_cards_progress'] as num).toDouble(),
        writeProgress: (row['write_progress'] as num).toDouble(),
        peakRetention: (row['peak_retention'] as num).toDouble(),
        recentSessions: sessions,
        lastSessionDate: row['last_session_date'] != null
            ? DateTime.parse(row['last_session_date'] as String)
            : null,
      );
    }
    return results;
  }

  /// Records a session result and updates progress for a group.
  Future<GroupProgress> recordSession({
    required String groupId,
    required double score,
    required QuizMode mode,
  }) async {
    final current = await getProgress(groupId);
    final now = DateTime.now();

    // Insert session record
    await _db.insert('session_records', {
      'group_id': groupId,
      'date': now.toIso8601String(),
      'score': score,
      'mode': mode.name,
    });

    // Trim to last 3 session records per group
    await _db.rawDelete('''
      DELETE FROM session_records
      WHERE group_id = ? AND id NOT IN (
        SELECT id FROM session_records
        WHERE group_id = ?
        ORDER BY date DESC
        LIMIT 3
      )
    ''', [groupId, groupId]);

    // Calculate progress contribution
    const sessionContribution = 10.0;
    double newSerbianProgress = current.serbianCardsProgress;
    double newEnglishProgress = current.englishCardsProgress;
    double newWriteProgress = current.writeProgress;

    final contribution = (score / 100.0) * sessionContribution;

    switch (mode) {
      case QuizMode.serbianShown:
        newSerbianProgress =
            (current.serbianCardsProgress + contribution).clamp(0.0, 100.0);
        break;
      case QuizMode.englishShown:
        newEnglishProgress =
            (current.englishCardsProgress + contribution).clamp(0.0, 100.0);
        break;
      case QuizMode.write:
        newWriteProgress =
            (current.writeProgress + contribution).clamp(0.0, 100.0);
        break;
    }

    // Upsert group_progress
    await _db.insert(
      'group_progress',
      {
        'group_id': groupId,
        'serbian_cards_progress': newSerbianProgress,
        'english_cards_progress': newEnglishProgress,
        'write_progress': newWriteProgress,
        'peak_retention': current.peakRetention,
        'last_session_date': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return getProgress(groupId);
  }

  /// Updates peak retention for a group (call after calculating current retention).
  Future<void> updatePeakRetention(
      String groupId, double currentRetention) async {
    final current = await getProgress(groupId);
    if (currentRetention > current.peakRetention) {
      await _db.update(
        'group_progress',
        {'peak_retention': currentRetention},
        where: 'group_id = ?',
        whereArgs: [groupId],
      );
    }
  }

  /// Returns the last 3 session records for a group, newest first.
  Future<List<SessionRecord>> _getRecentSessions(String groupId) async {
    final rows = await _db.query(
      'session_records',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'date DESC',
      limit: 3,
    );
    return rows.map((row) => SessionRecord(
      date: DateTime.parse(row['date'] as String),
      score: (row['score'] as num).toDouble(),
      mode: QuizMode.values.firstWhere(
        (m) => m.name == row['mode'],
        orElse: () => QuizMode.write,
      ),
    )).toList();
  }
}
