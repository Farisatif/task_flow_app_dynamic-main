import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'habits_dao.g.dart';

/// عادة مع سجل آخر 7 أيام (true = أنجزت في ذلك اليوم)
class HabitWithWeek {
  final Habit habit;
  final List<bool> last7Days;
  HabitWithWeek({required this.habit, required this.last7Days});

  int get doneCount => last7Days.where((d) => d).length;
}

@DriftAccessor(tables: [Habits, HabitLogs])
class HabitsDao extends DatabaseAccessor<AppDatabase> with _$HabitsDaoMixin {
  HabitsDao(super.db);

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Stream<List<Habit>> watchAll() {
    return (select(habits)..where((h) => h.isDeleted.equals(false) & h.isArchived.equals(false))).watch();
  }

  /// يبث كل عادة مع حالة آخر 7 أيام محسوبة من habit_logs
  Stream<List<HabitWithWeek>> watchAllWithWeek() {
    return watchAll().asyncMap((habitRows) async {
      final today = _dateOnly(DateTime.now());
      final result = <HabitWithWeek>[];
      for (final h in habitRows) {
        final week = <bool>[];
        for (int i = 6; i >= 0; i--) {
          final day = today.subtract(Duration(days: i));
          final log = await (select(habitLogs)
                ..where((l) => l.habitId.equals(h.id) & l.logDate.equals(day)))
              .getSingleOrNull();
          week.add(log?.isCompleted ?? false);
        }
        result.add(HabitWithWeek(habit: h, last7Days: week));
      }
      return result;
    });
  }

  Future<int> insertHabit(HabitsCompanion entry) => into(habits).insert(entry);

  /// يبدّل حالة إنجاز عادة في يوم معيّن (يُنشئ السجل إن لم يكن موجودًا)
  Future<void> toggleDay(int habitId, DateTime date, bool completed) async {
    final day = _dateOnly(date);
    final existing = await (select(habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.logDate.equals(day)))
        .getSingleOrNull();
    if (existing == null) {
      await into(habitLogs).insert(HabitLogsCompanion.insert(habitId: habitId, logDate: day, isCompleted: Value(completed)));
    } else {
      await (update(habitLogs)..where((l) => l.id.equals(existing.id)))
          .write(HabitLogsCompanion(isCompleted: Value(completed)));
    }
  }

  Future<int> softDelete(int id) =>
      (update(habits)..where((h) => h.id.equals(id))).write(const HabitsCompanion(isDeleted: Value(true)));
}
