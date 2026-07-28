import 'package:flutter/material.dart';
import '../database/database.dart';
import 'notification_prefs.dart';
import 'task_defaults.dart';
import 'notification_service.dart';

const _kNotificationPrefsKey = 'notification_prefs';
const _kTaskDefaultsKey = 'task_defaults';

/// يحمّل ويحفظ تفضيلات الإشعارات/الأصوات وإعدادات المهام الافتراضية من
/// قاعدة البيانات، ويُبقيها متاحة لكل التطبيق عبر Provider. أي تعديل من
/// شاشة الإعدادات يمر من هنا فيُحفظ فورًا ويُعاد جدولة ما يلزم من إشعارات.
class AppPreferences extends ChangeNotifier {
  final AppDatabase db;
  AppPreferences(this.db) {
    _load();
  }

  NotificationPrefs _notifications = const NotificationPrefs();
  TaskDefaultsPrefs _taskDefaults = const TaskDefaultsPrefs();
  bool _loaded = false;

  NotificationPrefs get notifications => _notifications;
  TaskDefaultsPrefs get taskDefaults => _taskDefaults;
  bool get loaded => _loaded;

  Future<void> _load() async {
    final notifJson = await db.settingsDao.getValue(_kNotificationPrefsKey);
    final taskJson = await db.settingsDao.getValue(_kTaskDefaultsKey);
    _notifications = NotificationPrefs.fromJson(notifJson);
    _taskDefaults = TaskDefaultsPrefs.fromJson(taskJson);
    _loaded = true;
    notifyListeners();

    if (_notifications.dailySummaryEnabled) {
      await NotificationService.instance.scheduleDailySummary(
        hour: _notifications.dailySummaryHour,
        minute: _notifications.dailySummaryMinute,
        sound: _notifications.defaultSound,
      );
    }
  }

  Future<void> updateNotifications(NotificationPrefs Function(NotificationPrefs current) update) async {
    final next = update(_notifications);
    _notifications = next;
    notifyListeners();
    await db.settingsDao.setValue(_kNotificationPrefsKey, next.toJson());

    if (next.dailySummaryEnabled) {
      await NotificationService.instance.scheduleDailySummary(
        hour: next.dailySummaryHour,
        minute: next.dailySummaryMinute,
        sound: next.defaultSound,
      );
    } else {
      await NotificationService.instance.cancelDailySummary();
    }
  }

  Future<void> updateTaskDefaults(TaskDefaultsPrefs Function(TaskDefaultsPrefs current) update) async {
    final next = update(_taskDefaults);
    _taskDefaults = next;
    notifyListeners();
    await db.settingsDao.setValue(_kTaskDefaultsKey, next.toJson());
  }
}
