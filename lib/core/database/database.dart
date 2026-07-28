import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
export 'tables.dart';
import 'dao/categories_dao.dart';
import 'dao/goals_dao.dart';
import 'dao/projects_dao.dart';
import 'dao/tasks_dao.dart';
import 'dao/habits_dao.dart';
import 'dao/notes_dao.dart';
import 'dao/attachments_dao.dart';
import 'dao/reminders_dao.dart';
import 'dao/focus_sessions_dao.dart';
import 'dao/profile_dao.dart';
import 'dao/settings_dao.dart';

part 'database.g.dart';

/// قاعدة البيانات الرئيسية للتطبيق (SQLite محلي عبر Drift).
/// شغّل بعد `flutter pub get`:
///   dart run build_runner build --delete-conflicting-outputs
/// لتوليد ملف database.g.dart قبل أول تشغيل.
@DriftDatabase(
  tables: [
    Profile,
    AppSettings,
    Categories,
    Goals,
    SubGoals,
    Projects,
    Tasks,
    Reminders,
    Notes,
    Attachments,
    Habits,
    HabitLogs,
    FocusSessions,
  ],
  daos: [
    CategoriesDao,
    GoalsDao,
    ProjectsDao,
    TasksDao,
    HabitsDao,
    NotesDao,
    AttachmentsDao,
    RemindersDao,
    FocusSessionsDao,
    ProfileDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// مُنشئ إضافي للاختبارات: يسمح بحقن اتصال في الذاكرة
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v1 -> v2: إشعارات فعلية مجدولة على التذكيرات بدل نص توضيحي فقط
          if (from < 2) {
            await m.addColumn(reminders, reminders.scheduledAt);
            await m.addColumn(reminders, reminders.leadMinutes);
            await m.addColumn(reminders, reminders.sound);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'task_flow.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
