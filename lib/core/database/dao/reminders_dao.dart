import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase> with _$RemindersDaoMixin {
  RemindersDao(super.db);

  Stream<List<Reminder>> watchAll() {
    return (select(reminders)..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).watch();
  }

  /// كل التذكيرات النشطة القادمة (مرتبة بأقربها)، لعرضها في الرئيسية/اللوحة
  Stream<List<Reminder>> watchUpcoming() {
    final now = DateTime.now();
    return (select(reminders)
          ..where((r) => r.isActive.equals(true) & r.scheduledAt.isBiggerOrEqualValue(now))
          ..orderBy([(r) => OrderingTerm.asc(r.scheduledAt)]))
        .watch();
  }

  Future<Reminder?> getForTask(int taskId) =>
      (select(reminders)..where((r) => r.taskId.equals(taskId))).getSingleOrNull();

  Future<int> insertReminder(RemindersCompanion entry) => into(reminders).insert(entry);

  /// ينشئ أو يحدّث تذكيرًا مرتبطًا بمهمة (تذكير واحد فعّال لكل مهمة)
  Future<int> upsertForTask({
    required int taskId,
    required String title,
    required String timeLabel,
    required DateTime scheduledAt,
    required int leadMinutes,
    required ReminderSound sound,
  }) async {
    final existing = await getForTask(taskId);
    if (existing != null) {
      await (update(reminders)..where((r) => r.id.equals(existing.id))).write(
        RemindersCompanion(
          title: Value(title),
          timeLabel: Value(timeLabel),
          scheduledAt: Value(scheduledAt),
          leadMinutes: Value(leadMinutes),
          sound: Value(sound),
          isActive: const Value(true),
        ),
      );
      return existing.id;
    }
    return into(reminders).insert(RemindersCompanion.insert(
      taskId: Value(taskId),
      title: title,
      timeLabel: timeLabel,
      scheduledAt: Value(scheduledAt),
      leadMinutes: Value(leadMinutes),
      sound: Value(sound),
    ));
  }

  Future<int> deleteForTask(int taskId) => (delete(reminders)..where((r) => r.taskId.equals(taskId))).go();

  Future<int> setActive(int id, bool active) =>
      (update(reminders)..where((r) => r.id.equals(id))).write(RemindersCompanion(isActive: Value(active)));

  Future<int> deleteReminder(int id) => (delete(reminders)..where((r) => r.id.equals(id))).go();
}
