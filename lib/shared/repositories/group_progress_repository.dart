import 'package:sqflite/sqflite.dart';

import 'db_schema.dart';
import 'models/group_progress.dart';
import 'models/session_record.dart';
import '../../features/quiz/quiz_mode.dart';

/// Persists and reads group progress via SQLite, scoped by target language.
class GroupProgressRepository {
  GroupProgressRepository({required Database db}) : _db = db;

  final Database _db;

  /// Returns progress for a group in a target language, or empty progress if none exists.
  Future<GroupProgress> getProgress(String targetLang, String groupId) async {
    final rows = await _db.query(
      DbSchema.tableGroupProgress,
      where: '${DbSchema.colTargetLang} = ? AND ${DbSchema.colGroupId} = ?',
      whereArgs: [targetLang, groupId],
    );
    final sessions = await _getRecentSessions(targetLang, groupId);

    if (rows.isEmpty) return GroupProgress(groupId: groupId);

    final row = rows.first;
    return GroupProgress(
      groupId: groupId,
      targetShownProgress:
          (row[DbSchema.colTargetShownProgress] as num).toDouble(),
      nativeShownProgress:
          (row[DbSchema.colNativeShownProgress] as num).toDouble(),
      writeProgress: (row[DbSchema.colWriteProgress] as num).toDouble(),
      peakRetention: (row[DbSchema.colPeakRetention] as num).toDouble(),
      recentSessions: sessions,
      lastSessionDate: row[DbSchema.colLastSessionDate] != null
          ? DateTime.parse(row[DbSchema.colLastSessionDate] as String)
          : null,
    );
  }

  /// Returns all progress for a target language as a map of groupId → GroupProgress.
  Future<Map<String, GroupProgress>> getAllProgress(String targetLang) async {
    final rows = await _db.query(
      DbSchema.tableGroupProgress,
      where: '${DbSchema.colTargetLang} = ?',
      whereArgs: [targetLang],
    );
    final results = <String, GroupProgress>{};

    for (final row in rows) {
      final groupId = row[DbSchema.colGroupId] as String;
      final sessions = await _getRecentSessions(targetLang, groupId);
      results[groupId] = GroupProgress(
        groupId: groupId,
        targetShownProgress:
            (row[DbSchema.colTargetShownProgress] as num).toDouble(),
        nativeShownProgress:
            (row[DbSchema.colNativeShownProgress] as num).toDouble(),
        writeProgress: (row[DbSchema.colWriteProgress] as num).toDouble(),
        peakRetention: (row[DbSchema.colPeakRetention] as num).toDouble(),
        recentSessions: sessions,
        lastSessionDate: row[DbSchema.colLastSessionDate] != null
            ? DateTime.parse(row[DbSchema.colLastSessionDate] as String)
            : null,
      );
    }
    return results;
  }

  /// Records a session result and updates progress for a group.
  Future<GroupProgress> recordSession({
    required String targetLang,
    required String groupId,
    required double score,
    required QuizMode mode,
  }) async {
    final current = await getProgress(targetLang, groupId);
    final now = DateTime.now();

    // Insert session record
    await _db.insert(DbSchema.tableSessionRecords, {
      DbSchema.colTargetLang: targetLang,
      DbSchema.colGroupId: groupId,
      DbSchema.colDate: now.toIso8601String(),
      DbSchema.colScore: score,
      DbSchema.colMode: mode.name,
    });

    // Trim to last 3 session records per (target_lang, group)
    await _db.rawDelete('''
      DELETE FROM ${DbSchema.tableSessionRecords}
      WHERE ${DbSchema.colTargetLang} = ? AND ${DbSchema.colGroupId} = ? AND id NOT IN (
        SELECT id FROM ${DbSchema.tableSessionRecords}
        WHERE ${DbSchema.colTargetLang} = ? AND ${DbSchema.colGroupId} = ?
        ORDER BY ${DbSchema.colDate} DESC
        LIMIT 3
      )
    ''', [targetLang, groupId, targetLang, groupId]);

    // Calculate progress contribution
    const sessionContribution = 10.0;
    double newTargetShown = current.targetShownProgress;
    double newNativeShown = current.nativeShownProgress;
    double newWrite = current.writeProgress;

    final contribution = (score / 100.0) * sessionContribution;

    switch (mode) {
      case QuizMode.targetShown:
        newTargetShown =
            (current.targetShownProgress + contribution).clamp(0.0, 100.0);
        break;
      case QuizMode.nativeShown:
        newNativeShown =
            (current.nativeShownProgress + contribution).clamp(0.0, 100.0);
        break;
      case QuizMode.write:
        newWrite = (current.writeProgress + contribution).clamp(0.0, 100.0);
        break;
    }

    // Upsert group_progress
    await _db.insert(
      DbSchema.tableGroupProgress,
      {
        DbSchema.colTargetLang: targetLang,
        DbSchema.colGroupId: groupId,
        DbSchema.colTargetShownProgress: newTargetShown,
        DbSchema.colNativeShownProgress: newNativeShown,
        DbSchema.colWriteProgress: newWrite,
        DbSchema.colPeakRetention: current.peakRetention,
        DbSchema.colLastSessionDate: now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return getProgress(targetLang, groupId);
  }

  /// Updates peak retention for a group (call after calculating current retention).
  Future<void> updatePeakRetention(
      String targetLang, String groupId, double currentRetention) async {
    final current = await getProgress(targetLang, groupId);
    if (currentRetention > current.peakRetention) {
      await _db.update(
        DbSchema.tableGroupProgress,
        {DbSchema.colPeakRetention: currentRetention},
        where:
            '${DbSchema.colTargetLang} = ? AND ${DbSchema.colGroupId} = ?',
        whereArgs: [targetLang, groupId],
      );
    }
  }

  /// Returns summed totalProgress per target language across all groups.
  /// Only includes languages that have at least one group_progress row.
  Future<Map<String, double>> getSumProgressAllLanguages() async {
    final rows = await _db.query(DbSchema.tableGroupProgress);
    final Map<String, double> sumByLang = {};
    for (final row in rows) {
      final lang = row[DbSchema.colTargetLang] as String;
      final gp = GroupProgress(
        groupId: row[DbSchema.colGroupId] as String,
        targetShownProgress:
            (row[DbSchema.colTargetShownProgress] as num).toDouble(),
        nativeShownProgress:
            (row[DbSchema.colNativeShownProgress] as num).toDouble(),
        writeProgress: (row[DbSchema.colWriteProgress] as num).toDouble(),
      );
      sumByLang[lang] = (sumByLang[lang] ?? 0.0) + gp.totalProgress;
    }
    return sumByLang;
  }

  /// Returns the last 3 session records for a (target_lang, group), newest first.
  Future<List<SessionRecord>> _getRecentSessions(
      String targetLang, String groupId) async {
    final rows = await _db.query(
      DbSchema.tableSessionRecords,
      where:
          '${DbSchema.colTargetLang} = ? AND ${DbSchema.colGroupId} = ?',
      whereArgs: [targetLang, groupId],
      orderBy: '${DbSchema.colDate} DESC',
      limit: 3,
    );
    return rows
        .map((row) => SessionRecord(
              date: DateTime.parse(row[DbSchema.colDate] as String),
              score: (row[DbSchema.colScore] as num).toDouble(),
              mode: QuizMode.values.firstWhere(
                (m) => m.name == row[DbSchema.colMode],
                orElse: () => QuizMode.write,
              ),
            ))
        .toList();
  }
}
