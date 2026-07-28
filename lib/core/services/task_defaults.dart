import 'dart:convert';
import '../database/tables.dart';

/// إعدادات افتراضية للمهام الجديدة + إعدادات عرض المخطط الأسبوعي (ساعات
/// العمل، بداية الأسبوع...). مخزّنة كـ JSON في جدول الإعدادات (مفتاح: task_defaults)
class TaskDefaultsPrefs {
  final int defaultDurationMinutes;
  final TaskPriority defaultPriority;
  final int defaultReminderLeadMinutes;
  final bool autoReminderForNewTasks;
  final int workDayStartHour; // بداية نطاق المخطط الأسبوعي/ساعات العمل
  final int workDayEndHour;
  final bool weekStartsSaturday; // ترتيب الأسبوع: يبدأ بالسبت (عربي) أو الأحد
  final bool showWeekendsInPlanner;

  const TaskDefaultsPrefs({
    this.defaultDurationMinutes = 60,
    this.defaultPriority = TaskPriority.medium,
    this.defaultReminderLeadMinutes = 10,
    this.autoReminderForNewTasks = false,
    this.workDayStartHour = 8,
    this.workDayEndHour = 22,
    this.weekStartsSaturday = true,
    this.showWeekendsInPlanner = true,
  });

  TaskDefaultsPrefs copyWith({
    int? defaultDurationMinutes,
    TaskPriority? defaultPriority,
    int? defaultReminderLeadMinutes,
    bool? autoReminderForNewTasks,
    int? workDayStartHour,
    int? workDayEndHour,
    bool? weekStartsSaturday,
    bool? showWeekendsInPlanner,
  }) {
    return TaskDefaultsPrefs(
      defaultDurationMinutes: defaultDurationMinutes ?? this.defaultDurationMinutes,
      defaultPriority: defaultPriority ?? this.defaultPriority,
      defaultReminderLeadMinutes: defaultReminderLeadMinutes ?? this.defaultReminderLeadMinutes,
      autoReminderForNewTasks: autoReminderForNewTasks ?? this.autoReminderForNewTasks,
      workDayStartHour: workDayStartHour ?? this.workDayStartHour,
      workDayEndHour: workDayEndHour ?? this.workDayEndHour,
      weekStartsSaturday: weekStartsSaturday ?? this.weekStartsSaturday,
      showWeekendsInPlanner: showWeekendsInPlanner ?? this.showWeekendsInPlanner,
    );
  }

  Map<String, dynamic> toMap() => {
        'defaultDurationMinutes': defaultDurationMinutes,
        'defaultPriority': defaultPriority.index,
        'defaultReminderLeadMinutes': defaultReminderLeadMinutes,
        'autoReminderForNewTasks': autoReminderForNewTasks,
        'workDayStartHour': workDayStartHour,
        'workDayEndHour': workDayEndHour,
        'weekStartsSaturday': weekStartsSaturday,
        'showWeekendsInPlanner': showWeekendsInPlanner,
      };

  String toJson() => jsonEncode(toMap());

  factory TaskDefaultsPrefs.fromJson(String? source) {
    if (source == null || source.isEmpty) return const TaskDefaultsPrefs();
    try {
      final map = jsonDecode(source) as Map<String, dynamic>;
      return TaskDefaultsPrefs(
        defaultDurationMinutes: map['defaultDurationMinutes'] as int? ?? 60,
        defaultPriority: TaskPriority.values[(map['defaultPriority'] as int?) ?? TaskPriority.medium.index],
        defaultReminderLeadMinutes: map['defaultReminderLeadMinutes'] as int? ?? 10,
        autoReminderForNewTasks: map['autoReminderForNewTasks'] as bool? ?? false,
        workDayStartHour: map['workDayStartHour'] as int? ?? 8,
        workDayEndHour: map['workDayEndHour'] as int? ?? 22,
        weekStartsSaturday: map['weekStartsSaturday'] as bool? ?? true,
        showWeekendsInPlanner: map['showWeekendsInPlanner'] as bool? ?? true,
      );
    } catch (_) {
      return const TaskDefaultsPrefs();
    }
  }
}
