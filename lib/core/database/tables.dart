import 'package:drift/drift.dart';
// ==================== Enums ====================
// تُخزَّن كأعداد صحيحة في القاعدة عبر intEnum، وتُقرأ كأنواع Dart آمنة في الكود

enum TaskPriority { low, medium, high }

enum TaskStatus { pending, inProgress, completed }

enum AttachmentKind { image, pdf, text, doc, chart, presentation }

// ==================== الجداول ====================

@DataClassName('ProfileRow')
class Profile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get levelLabel => text().withDefault(const Constant('مستوى 1'))();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Setting')
class AppSettings extends Table {
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();

  @override
  Set<Column> get primaryKey => {settingKey};
}

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  TextColumn get iconName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('Goal')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get progress => real().withDefault(const Constant(0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('SubGoal')
class SubGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(Goals, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  RealColumn get progress => real().withDefault(const Constant(0))();
}

@DataClassName('Project')
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  TextColumn get iconName => text().nullable()();
  IntColumn get goalId => integer().nullable().references(Goals, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('Task')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get date => dateTime()();
  // نخزن الوقت كدقائق منذ منتصف الليل لتبسيط الفرز والمقارنة
  IntColumn get startMinutes => integer()();
  IntColumn get endMinutes => integer()();
  IntColumn get priority => intEnum<TaskPriority>()();
  IntColumn get status => intEnum<TaskStatus>().withDefault(Constant(TaskStatus.pending.index))();
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  IntColumn get projectId => integer().nullable().references(Projects, #id, onDelete: KeyAction.setNull)();
  IntColumn get goalId => integer().nullable().references(Goals, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

enum ReminderSound { defaultSound, chime, gentle, alert, silent }

@DataClassName('Reminder')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get timeLabel => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  // التوقيت الفعلي المجدولة له الإشعار المحلي (null = تذكير قديم بدون جدولة فعلية)
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  // عدد الدقائق قبل وقت بداية المهمة التي يُطلق عندها التذكير
  IntColumn get leadMinutes => integer().withDefault(const Constant(10))();
  IntColumn get sound => intEnum<ReminderSound>().withDefault(Constant(ReminderSound.defaultSound.index))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Note')
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get color => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('Attachment')
class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get filePath => text().nullable()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  IntColumn get kind => intEnum<AttachmentKind>()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Habit')
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get color => integer()();
  TextColumn get iconName => text()();
  IntColumn get targetDaysPerWeek => integer().withDefault(const Constant(7))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('HabitLog')
class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get logDate => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, logDate},
      ];
}

@DataClassName('FocusSession')
class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}
