import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'notification_prefs.dart';

/// طبقة الإشعارات المحلية الفعلية للتطبيق (بديل التذكيرات الوهمية السابقة).
/// مسؤولة عن: التهيئة، طلب الأذونات، جدولة/إلغاء تذكيرات المهام، الملخص
/// اليومي، وإشعار تجريبي لمعاينة الصوت المختار في الإعدادات.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int dailySummaryNotificationId = 999999;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    // لا نعتمد على تحديد المنطقة الزمنية للجهاز عبر حزمة خارجية إضافية؛
    // نستخدم أوفست الجهاز الحالي عبر DateTime.now() عند الجدولة (انظر _toTz).
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      for (final sound in AppNotificationSound.values) {
        await androidPlugin?.createNotificationChannel(
          AndroidNotificationChannel(
            sound.channelId,
            'تذكيرات — ${sound.label}',
            description: 'قناة إشعارات التذكيرات بصوت "${sound.label}"',
            importance: sound == AppNotificationSound.silent ? Importance.low : Importance.high,
            playSound: sound != AppNotificationSound.silent,
            enableVibration: sound != AppNotificationSound.silent,
          ),
        );
      }
    }
    _initialized = true;
  }

  /// يطلب إذن الإشعارات على أندرويد 13+ وiOS. يُستحسن استدعاؤه من شاشة
  /// إعدادات الإشعارات أو عند أول تفعيل لتذكير، وليس عند الإقلاع مباشرة.
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      // إذن الجدولة الدقيقة على أندرويد 12+ (اختياري — يتراجع تلقائيًا لجدولة غير دقيقة)
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
      return status.isGranted;
    }
    return true;
  }

  Future<bool> hasPermission() async {
    if (Platform.isAndroid) return await Permission.notification.isGranted;
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return result?.isEnabled ?? false;
    }
    return true;
  }

  NotificationDetails _details(AppNotificationSound sound, {bool vibrate = true}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        sound.channelId,
        'تذكيرات — ${sound.label}',
        channelDescription: 'إشعارات تذكير المهام',
        importance: sound == AppNotificationSound.silent ? Importance.low : Importance.high,
        priority: sound == AppNotificationSound.silent ? Priority.low : Priority.high,
        playSound: sound != AppNotificationSound.silent,
        enableVibration: vibrate && sound != AppNotificationSound.silent,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: sound != AppNotificationSound.silent,
        presentAlert: true,
        presentBadge: true,
      ),
    );
  }

  tz.TZDateTime _toTz(DateTime dt) {
    // نبني منطقة زمنية محلية من الأوفست الحالي للجهاز بدل الاعتماد على اسم
    // منطقة النظام (يتجنب الحاجة لقناة أصلية إضافية لجلب اسم المنطقة).
    final offset = dt.timeZoneOffset;
    final location = tz.getLocation('UTC');
    final utcEquivalent = dt.subtract(offset);
    return tz.TZDateTime.from(utcEquivalent, location).add(offset);
  }

  /// يجدول تذكيرًا لمهمة محددة. يُستخدم معرّف المهمة نفسه كمعرّف الإشعار
  /// (بافتراض تذكير واحد فعّال لكل مهمة)، مما يسهّل الإلغاء لاحقًا.
  Future<void> scheduleTaskReminder({
    required int taskId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    AppNotificationSound sound = AppNotificationSound.defaultSound,
    bool vibrate = true,
  }) async {
    await init();
    if (scheduledAt.isBefore(DateTime.now())) return; // لا نجدول لحظة في الماضي
    try {
      await _plugin.zonedSchedule(
        taskId,
        title,
        body,
        _toTz(scheduledAt),
        _details(sound, vibrate: vibrate),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      // يتراجع لجدولة غير دقيقة إن رُفض إذن التنبيه الدقيق على أندرويد
      if (kDebugMode) debugPrint('exact schedule failed, falling back: $e');
      await _plugin.zonedSchedule(
        taskId,
        title,
        body,
        _toTz(scheduledAt),
        _details(sound, vibrate: vibrate),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelTaskReminder(int taskId) async {
    await init();
    await _plugin.cancel(taskId);
  }

  /// إشعار تجريبي فوري لمعاينة الصوت المختار من شاشة الإعدادات
  Future<void> showTestNotification(AppNotificationSound sound, {bool vibrate = true}) async {
    await init();
    await _plugin.show(
      -1,
      'هذا مثال على تذكيراتك 🔔',
      'الصوت المختار: ${sound.label}',
      _details(sound, vibrate: vibrate),
    );
  }

  /// يجدول ملخصًا يوميًا متكررًا (كل يوم في نفس الساعة/الدقيقة)
  Future<void> scheduleDailySummary({
    required int hour,
    required int minute,
    required AppNotificationSound sound,
  }) async {
    await init();
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      dailySummaryNotificationId,
      'ملخصك اليومي 📋',
      'راجع مهامك المجدولة لهذا اليوم وابدأ بأولوياتك',
      _toTz(next),
      _details(sound),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailySummary() async {
    await init();
    await _plugin.cancel(dailySummaryNotificationId);
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}
