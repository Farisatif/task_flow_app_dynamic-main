import 'package:drift/drift.dart';
import 'database.dart';
import 'tables.dart';

/// يملأ قاعدة البيانات ببيانات تجريبية أول مرة فقط (عند عدم وجود أي مهام).
/// بهذا يفتح التطبيق ولديه محتوى فعلي بدل شاشات فارغة، وكل البيانات
/// المعروضة بعدها حقيقية ومخزّنة في SQLite ويمكن حذفها/تعديلها بشكل طبيعي.
Future<void> seedDatabaseIfEmpty(AppDatabase db) async {
  final existingTasks = await db.select(db.tasks).get();
  if (existingTasks.isNotEmpty) return; // البيانات موجودة بالفعل، لا تكرر البذر

  // --- الملف الشخصي ---
  await db.into(db.profile).insertOnConflictUpdate(
        ProfileCompanion.insert(
          id: const Value(1),
          name: 'أحمد المطوعي',
          email: const Value('ahmed@example.com'),
          levelLabel: const Value('مستوى 10 - خبير الإنتاجية'),
          xp: const Value(3460),
        ),
      );

  // --- التصنيفات ---
  final categoryIds = <String, int>{};
  final categorySeed = [
    ('العمل', 0xFF7B6FF0),
    ('الدراسة', 0xFF5B9DF9),
    ('الصحة', 0xFF4CD787),
    ('القراءة', 0xFFFFB258),
    ('المنزل', 0xFFFF7EB3),
  ];
  for (final c in categorySeed) {
    final id = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: c.$1, color: c.$2),
        );
    categoryIds[c.$1] = id;
  }

  // --- الأهداف ---
  final goalId = await db.into(db.goals).insert(
        GoalsCompanion.insert(title: 'تعلم Flutter وإطلاق تطبيق', progress: const Value(0.6)),
      );
  await db.into(db.subGoals).insert(SubGoalsCompanion.insert(goalId: goalId, title: 'تعلم أساسيات Flutter', progress: const Value(1.0)));
  await db.into(db.subGoals).insert(SubGoalsCompanion.insert(goalId: goalId, title: 'بناء 3 تطبيقات صغيرة', progress: const Value(0.7)));
  await db.into(db.subGoals).insert(SubGoalsCompanion.insert(goalId: goalId, title: 'النشر على المتجر', progress: const Value(0.3)));

  // --- المشاريع ---
  final projectSeed = [
    ('تطوير التطبيق', 0xFF7B6FF0),
    ('مشروع الجامعة', 0xFF5B9DF9),
    ('متجر إلكتروني', 0xFF4CD787),
    ('مشروع شخصي', 0xFFFFB258),
  ];
  final projectIds = <String, int>{};
  for (final p in projectSeed) {
    final id = await db.into(db.projects).insert(
          ProjectsCompanion.insert(name: p.$1, color: p.$2, goalId: p.$1 == 'تطوير التطبيق' ? Value(goalId) : const Value.absent()),
        );
    projectIds[p.$1] = id;
  }

  // --- المهام (لليوم) ---
  final today = DateTime.now();
  final day = DateTime(today.year, today.month, today.day);

  Future<void> addTask({
    required String title,
    required int startH,
    required int startM,
    required int endH,
    required int endM,
    required TaskPriority priority,
    TaskStatus status = TaskStatus.pending,
    String? category,
    String? project,
    String? notes,
    int dayOffset = 0,
  }) async {
    await db.into(db.tasks).insert(
          TasksCompanion.insert(
            title: title,
            date: day.add(Duration(days: dayOffset)),
            startMinutes: startH * 60 + startM,
            endMinutes: endH * 60 + endM,
            priority: priority,
            status: Value(status),
            categoryId: category != null ? Value(categoryIds[category]) : const Value.absent(),
            projectId: project != null ? Value(projectIds[project]) : const Value.absent(),
            notes: notes != null ? Value(notes) : const Value.absent(),
          ),
        );
  }

  await addTask(
    title: 'تصميم واجهة التطبيق',
    startH: 9,
    startM: 0,
    endH: 11,
    endM: 0,
    priority: TaskPriority.high,
    status: TaskStatus.completed,
    category: 'العمل',
    project: 'تطوير التطبيق',
  );
  await addTask(title: 'اجتماع مع الفريق', startH: 11, startM: 30, endH: 12, endM: 30, priority: TaskPriority.medium, category: 'العمل');
  await addTask(title: 'قراءة كتاب', startH: 12, startM: 0, endH: 13, endM: 0, priority: TaskPriority.medium, category: 'القراءة');
  await addTask(
    title: 'تحضير تقرير',
    startH: 16,
    startM: 0,
    endH: 17,
    endM: 0,
    priority: TaskPriority.low,
    category: 'العمل',
    notes: 'يجب تلخيص نتائج التحليل الذكي والمقارنات مع خطة استخدام الشهر الماضي',
  );
  await addTask(title: 'تمرين رياضي', startH: 18, startM: 0, endH: 19, endM: 0, priority: TaskPriority.low, category: 'الصحة');

  // مهام إضافية موزّعة على الأسبوع لعرض المخطط الأسبوعي بشكل واقعي
  await addTask(title: 'مراجعة كود', startH: 10, startM: 0, endH: 11, endM: 30, priority: TaskPriority.medium, category: 'العمل', dayOffset: -2);
  await addTask(title: 'اتصال عميل', startH: 13, startM: 0, endH: 13, endM: 30, priority: TaskPriority.high, category: 'العمل', dayOffset: -1);
  await addTask(title: 'جلسة تركيز', startH: 9, startM: 0, endH: 10, endM: 30, priority: TaskPriority.medium, project: 'مشروع شخصي', dayOffset: -1);
  await addTask(title: 'التخطيط الأسبوعي', startH: 8, startM: 30, endH: 9, endM: 0, priority: TaskPriority.low, category: 'العمل', dayOffset: 1);
  await addTask(title: 'مراجعة تصميم', startH: 14, startM: 0, endH: 15, endM: 30, priority: TaskPriority.medium, project: 'تطوير التطبيق', dayOffset: 1);
  await addTask(title: 'اجتماع أسبوعي', startH: 11, startM: 0, endH: 12, endM: 0, priority: TaskPriority.high, category: 'العمل', dayOffset: 2);
  await addTask(title: 'وقت عائلي', startH: 17, startM: 0, endH: 19, endM: 0, priority: TaskPriority.low, category: 'الصحة', dayOffset: 3);

  // --- العادات ---
  final habitSeed = [
    ('شرب الماء', 0xFF5B9DF9, 'water_drop'),
    ('قراءة 30 دقيقة', 0xFFFFB258, 'menu_book'),
    ('تمرين رياضي', 0xFF4CD787, 'fitness_center'),
    ('تأمل 10 دقائق', 0xFF7B6FF0, 'self_improvement'),
    ('النوم مبكرًا', 0xFFFF7EB3, 'nightlight'),
  ];
  for (final h in habitSeed) {
    final habitId = await db.into(db.habits).insert(HabitsCompanion.insert(title: h.$1, color: h.$2, iconName: h.$3));
    for (int i = 0; i < 7; i++) {
      final d = day.subtract(Duration(days: 6 - i));
      final done = (i + h.$1.length) % 3 != 0; // نمط عشوائي بسيط للعرض
      await db.into(db.habitLogs).insert(HabitLogsCompanion.insert(habitId: habitId, logDate: d, isCompleted: Value(done)));
    }
  }

  // --- الملاحظات ---
  final noteSeed = [
    ('أفكار تطوير التطبيق', 'إضافة ميزة التحليل الذكي وربط جلسات التركيز بالإحصائيات الشهرية', 0xFFFFF3D9),
    ('ملاحظات اجتماع الفريق', 'مناقشة خطة الإصدار الجديد والتحضير لمرحلة الاختبار', 0xFFE3F2E5),
    ('قياسات ملهمة', 'النجاح هو مجموع جهود صغيرة تتكرر يوميًا', 0xFFE8E5FC),
    ('خطة السفر', 'حجز تذاكر الرحلة وتنظيم الأنشطة الأسبوعية', 0xFFFCE5EE),
  ];
  for (final n in noteSeed) {
    await db.into(db.notes).insert(NotesCompanion.insert(title: n.$1, content: n.$2, color: n.$3));
  }

  // --- التذكيرات ---
  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));
  final tomorrow930 = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 30);
  final today14 = DateTime(now.year, now.month, now.day, 14, 0);
  final tomorrow16 = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 0);
  await db.into(db.reminders).insert(RemindersCompanion.insert(title: 'اجتماع مع الفريق', timeLabel: '11:30 - غدًا', scheduledAt: Value(tomorrow930)));
  await db.into(db.reminders).insert(RemindersCompanion.insert(title: 'قراءة كتاب', timeLabel: '14:00 - اليوم', scheduledAt: Value(today14)));
  await db.into(db.reminders).insert(RemindersCompanion.insert(title: 'شرب الماء', timeLabel: 'كل يوم - 09:00'));
  await db.into(db.reminders).insert(RemindersCompanion.insert(title: 'مراجعة التقرير', timeLabel: '16:00 - غدًا', scheduledAt: Value(tomorrow16), isActive: const Value(false)));
}
