import 'dart:convert';

/// الأصوات المتاحة للتذكيرات (تُعرض للمستخدم، وتُستخدم كقناة إشعار مختلفة على أندرويد)
enum AppNotificationSound { defaultSound, chime, gentle, alert, silent }

extension AppNotificationSoundLabel on AppNotificationSound {
  String get label => switch (this) {
        AppNotificationSound.defaultSound => 'الافتراضي',
        AppNotificationSound.chime => 'جرس هادئ',
        AppNotificationSound.gentle => 'نغمة لطيفة',
        AppNotificationSound.alert => 'تنبيه واضح',
        AppNotificationSound.silent => 'صامت (اهتزاز فقط)',
      };

  String get channelId => 'reminders_${name}_v1';
}

/// تفضيلات الإشعارات والأصوات الخاصة بالتطبيق بالكامل، مخزّنة كـ JSON واحد
/// في جدول الإعدادات (مفتاح: notification_prefs)
class NotificationPrefs {
  final bool remindersEnabled;
  final AppNotificationSound defaultSound;
  final int defaultLeadMinutes;
  final bool vibrate;
  final bool dailySummaryEnabled;
  final int dailySummaryHour;
  final int dailySummaryMinute;
  final bool quietHoursEnabled;
  final int quietStartHour;
  final int quietEndHour;
  final bool highPrioritySoundOverride; // المهام العالية الأولوية تتجاوز الساعات الهادئة

  const NotificationPrefs({
    this.remindersEnabled = true,
    this.defaultSound = AppNotificationSound.defaultSound,
    this.defaultLeadMinutes = 10,
    this.vibrate = true,
    this.dailySummaryEnabled = false,
    this.dailySummaryHour = 8,
    this.dailySummaryMinute = 0,
    this.quietHoursEnabled = false,
    this.quietStartHour = 22,
    this.quietEndHour = 7,
    this.highPrioritySoundOverride = true,
  });

  NotificationPrefs copyWith({
    bool? remindersEnabled,
    AppNotificationSound? defaultSound,
    int? defaultLeadMinutes,
    bool? vibrate,
    bool? dailySummaryEnabled,
    int? dailySummaryHour,
    int? dailySummaryMinute,
    bool? quietHoursEnabled,
    int? quietStartHour,
    int? quietEndHour,
    bool? highPrioritySoundOverride,
  }) {
    return NotificationPrefs(
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      defaultSound: defaultSound ?? this.defaultSound,
      defaultLeadMinutes: defaultLeadMinutes ?? this.defaultLeadMinutes,
      vibrate: vibrate ?? this.vibrate,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      dailySummaryHour: dailySummaryHour ?? this.dailySummaryHour,
      dailySummaryMinute: dailySummaryMinute ?? this.dailySummaryMinute,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
      highPrioritySoundOverride: highPrioritySoundOverride ?? this.highPrioritySoundOverride,
    );
  }

  Map<String, dynamic> toMap() => {
        'remindersEnabled': remindersEnabled,
        'defaultSound': defaultSound.index,
        'defaultLeadMinutes': defaultLeadMinutes,
        'vibrate': vibrate,
        'dailySummaryEnabled': dailySummaryEnabled,
        'dailySummaryHour': dailySummaryHour,
        'dailySummaryMinute': dailySummaryMinute,
        'quietHoursEnabled': quietHoursEnabled,
        'quietStartHour': quietStartHour,
        'quietEndHour': quietEndHour,
        'highPrioritySoundOverride': highPrioritySoundOverride,
      };

  String toJson() => jsonEncode(toMap());

  factory NotificationPrefs.fromJson(String? source) {
    if (source == null || source.isEmpty) return const NotificationPrefs();
    try {
      final map = jsonDecode(source) as Map<String, dynamic>;
      return NotificationPrefs(
        remindersEnabled: map['remindersEnabled'] as bool? ?? true,
        defaultSound: AppNotificationSound.values[(map['defaultSound'] as int?) ?? 0],
        defaultLeadMinutes: map['defaultLeadMinutes'] as int? ?? 10,
        vibrate: map['vibrate'] as bool? ?? true,
        dailySummaryEnabled: map['dailySummaryEnabled'] as bool? ?? false,
        dailySummaryHour: map['dailySummaryHour'] as int? ?? 8,
        dailySummaryMinute: map['dailySummaryMinute'] as int? ?? 0,
        quietHoursEnabled: map['quietHoursEnabled'] as bool? ?? false,
        quietStartHour: map['quietStartHour'] as int? ?? 22,
        quietEndHour: map['quietEndHour'] as int? ?? 7,
        highPrioritySoundOverride: map['highPrioritySoundOverride'] as bool? ?? true,
      );
    } catch (_) {
      return const NotificationPrefs();
    }
  }

  /// هل هذه اللحظة (ساعة) تقع ضمن الساعات الهادئة؟ يدعم النطاق العابر لمنتصف الليل
  bool isWithinQuietHours(int hour) {
    if (!quietHoursEnabled) return false;
    if (quietStartHour == quietEndHour) return false;
    if (quietStartHour < quietEndHour) {
      return hour >= quietStartHour && hour < quietEndHour;
    }
    // نطاق عابر لمنتصف الليل، مثل 22 -> 7
    return hour >= quietStartHour || hour < quietEndHour;
  }
}
