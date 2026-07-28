import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'focus_sessions_dao.g.dart';

@DriftAccessor(tables: [FocusSessions])
class FocusSessionsDao extends DatabaseAccessor<AppDatabase> with _$FocusSessionsDaoMixin {
  FocusSessionsDao(super.db);

  Stream<List<FocusSession>> watchToday() {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final next = day.add(const Duration(days: 1));
    return (select(focusSessions)
          ..where((f) => f.startTime.isBiggerOrEqualValue(day) & f.startTime.isSmallerThanValue(next))
          ..orderBy([(f) => OrderingTerm.asc(f.startTime)]))
        .watch();
  }

  Future<int> startSession(FocusSessionsCompanion entry) => into(focusSessions).insert(entry);

  Future<int> completeSession(int id, int durationSeconds) => (update(focusSessions)..where((f) => f.id.equals(id)))
      .write(FocusSessionsCompanion(endTime: Value(DateTime.now()), durationSeconds: Value(durationSeconds), isCompleted: const Value(true)));

  /// إجمالي دقائق التركيز المكتملة اليوم
  Future<int> totalMinutesToday() async {
    final sessions = await watchToday().first;
    final totalSeconds = sessions.where((s) => s.isCompleted).fold<int>(0, (sum, s) => sum + s.durationSeconds);
    return totalSeconds ~/ 60;
  }
}
