import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/app_preferences.dart';
import '../core/services/notification_prefs.dart';
import '../core/services/notification_service.dart';
import '../core/database/database.dart';
import '../core/theme/app_colors.dart';
import '../widgets/app_scaffold.dart';

/// شاشة موحّدة لإعدادات الإشعارات، الأصوات، والإعدادات الافتراضية للمهام
/// والمخطط الأسبوعي — كل تعديل يُحفظ فورًا في قاعدة البيانات.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appPrefs = context.watch<AppPreferences>();
    final n = appPrefs.notifications;
    final t = appPrefs.taskDefaults;

    return AppScaffold(
      title: 'الإشعارات، الأصوات، والمهام',
      showNav: false,
      body: !appPrefs.loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _group(context, 'التذكيرات', [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text('تفعيل تذكيرات المهام'),
                    subtitle: const Text('تنبيه محلي فعلي قبل بداية كل مهمة لها تذكير'),
                    value: n.remindersEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (v) async {
                      if (v) await NotificationService.instance.requestPermissions();
                      appPrefs.updateNotifications((c) => c.copyWith(remindersEnabled: v));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('المدة الافتراضية قبل المهمة'),
                    subtitle: Text('${n.defaultLeadMinutes} دقيقة'),
                    trailing: DropdownButton<int>(
                      value: n.defaultLeadMinutes,
                      underline: const SizedBox(),
                      items: const [5, 10, 15, 30, 60]
                          .map((m) => DropdownMenuItem(value: m, child: Text('$m د')))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) appPrefs.updateNotifications((c) => c.copyWith(defaultLeadMinutes: v));
                      },
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration),
                    title: const Text('الاهتزاز مع التنبيه'),
                    value: n.vibrate,
                    activeColor: AppColors.primary,
                    onChanged: (v) => appPrefs.updateNotifications((c) => c.copyWith(vibrate: v)),
                  ),
                ]),
                _group(context, 'الصوت', [
                  ...AppNotificationSound.values.map((s) => RadioListTile<AppNotificationSound>(
                        value: s,
                        // ignore: deprecated_member_use
                        groupValue: n.defaultSound,
                        activeColor: AppColors.primary,
                        title: Text(s.label),
                        secondary: Icon(s == AppNotificationSound.silent ? Icons.volume_off_outlined : Icons.music_note_outlined),
                        onChanged: (v) {
                          if (v != null) appPrefs.updateNotifications((c) => c.copyWith(defaultSound: v));
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: const Text('تجربة الصوت الآن'),
                      onPressed: () => NotificationService.instance.showTestNotification(n.defaultSound, vibrate: n.vibrate),
                    ),
                  ),
                ]),
                _group(context, 'الساعات الهادئة', [
                  SwitchListTile(
                    secondary: const Icon(Icons.bedtime_outlined),
                    title: const Text('تفعيل الساعات الهادئة'),
                    subtitle: const Text('كتم صوت التذكيرات خلال نطاق زمني محدد يوميًا'),
                    value: n.quietHoursEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (v) => appPrefs.updateNotifications((c) => c.copyWith(quietHoursEnabled: v)),
                  ),
                  if (n.quietHoursEnabled) ...[
                    ListTile(
                      leading: const Icon(Icons.nightlight_outlined),
                      title: const Text('من الساعة'),
                      trailing: _HourDropdown(
                        value: n.quietStartHour,
                        onChanged: (v) => appPrefs.updateNotifications((c) => c.copyWith(quietStartHour: v)),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.wb_sunny_outlined),
                      title: const Text('إلى الساعة'),
                      trailing: _HourDropdown(
                        value: n.quietEndHour,
                        onChanged: (v) => appPrefs.updateNotifications((c) => c.copyWith(quietEndHour: v)),
                      ),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.priority_high),
                      title: const Text('استثناء المهام عالية الأولوية'),
                      subtitle: const Text('تُنبّه بصوت حتى خلال الساعات الهادئة'),
                      value: n.highPrioritySoundOverride,
                      activeColor: AppColors.primary,
                      onChanged: (v) => appPrefs.updateNotifications((c) => c.copyWith(highPrioritySoundOverride: v)),
                    ),
                  ],
                ]),
                _group(context, 'الملخص اليومي', [
                  SwitchListTile(
                    secondary: const Icon(Icons.summarize_outlined),
                    title: const Text('إشعار الملخص اليومي'),
                    subtitle: const Text('تذكير يومي متكرر بمراجعة مهام اليوم'),
                    value: n.dailySummaryEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (v) async {
                      if (v) await NotificationService.instance.requestPermissions();
                      appPrefs.updateNotifications((c) => c.copyWith(dailySummaryEnabled: v));
                    },
                  ),
                  if (n.dailySummaryEnabled)
                    ListTile(
                      leading: const Icon(Icons.schedule_outlined),
                      title: const Text('التوقيت'),
                      trailing: TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: n.dailySummaryHour, minute: n.dailySummaryMinute),
                          );
                          if (picked != null) {
                            appPrefs.updateNotifications((c) => c.copyWith(
                                  dailySummaryHour: picked.hour,
                                  dailySummaryMinute: picked.minute,
                                ));
                          }
                        },
                        child: Text(
                          TimeOfDay(hour: n.dailySummaryHour, minute: n.dailySummaryMinute).format(context),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ]),
                _group(context, 'إعدادات المهام الافتراضية', [
                  ListTile(
                    leading: const Icon(Icons.hourglass_bottom_outlined),
                    title: const Text('المدة الافتراضية للمهمة الجديدة'),
                    trailing: DropdownButton<int>(
                      value: t.defaultDurationMinutes,
                      underline: const SizedBox(),
                      items: const [15, 30, 45, 60, 90, 120]
                          .map((m) => DropdownMenuItem(value: m, child: Text(m < 60 ? '$m د' : '${m ~/ 60} س')))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) appPrefs.updateTaskDefaults((c) => c.copyWith(defaultDurationMinutes: v));
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag_outlined),
                    title: const Text('الأولوية الافتراضية'),
                    trailing: DropdownButton<TaskPriority>(
                      value: t.defaultPriority,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: TaskPriority.low, child: Text('منخفضة')),
                        DropdownMenuItem(value: TaskPriority.medium, child: Text('متوسطة')),
                        DropdownMenuItem(value: TaskPriority.high, child: Text('عالية')),
                      ],
                      onChanged: (v) {
                        if (v != null) appPrefs.updateTaskDefaults((c) => c.copyWith(defaultPriority: v));
                      },
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.alarm_add_outlined),
                    title: const Text('إضافة تذكير تلقائيًا للمهام الجديدة'),
                    value: t.autoReminderForNewTasks,
                    activeColor: AppColors.primary,
                    onChanged: (v) => appPrefs.updateTaskDefaults((c) => c.copyWith(autoReminderForNewTasks: v)),
                  ),
                ]),
                _group(context, 'المخطط الأسبوعي وساعات العمل', [
                  ListTile(
                    leading: const Icon(Icons.wb_twilight_outlined),
                    title: const Text('بداية يوم العمل'),
                    trailing: _HourDropdown(
                      value: t.workDayStartHour,
                      onChanged: (v) => appPrefs.updateTaskDefaults((c) => c.copyWith(workDayStartHour: v)),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.nights_stay_outlined),
                    title: const Text('نهاية يوم العمل'),
                    trailing: _HourDropdown(
                      value: t.workDayEndHour,
                      onChanged: (v) => appPrefs.updateTaskDefaults((c) => c.copyWith(workDayEndHour: v)),
                    ),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.calendar_view_week_outlined),
                    title: const Text('الأسبوع يبدأ بالسبت'),
                    subtitle: const Text('إيقاف التبديل يجعله يبدأ بالأحد'),
                    value: t.weekStartsSaturday,
                    activeColor: AppColors.primary,
                    onChanged: (v) => appPrefs.updateTaskDefaults((c) => c.copyWith(weekStartsSaturday: v)),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.weekend_outlined),
                    title: const Text('إظهار عطلة نهاية الأسبوع في المخطط'),
                    value: t.showWeekendsInPlanner,
                    activeColor: AppColors.primary,
                    onChanged: (v) => appPrefs.updateTaskDefaults((c) => c.copyWith(showWeekendsInPlanner: v)),
                  ),
                ]),
              ],
            ),
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(child: Column(children: children)),
        ],
      ),
    );
  }
}

class _HourDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _HourDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: value,
      underline: const SizedBox(),
      items: List.generate(24, (h) => h)
          .map((h) => DropdownMenuItem(value: h, child: Text('${h.toString().padLeft(2, '0')}:00')))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
