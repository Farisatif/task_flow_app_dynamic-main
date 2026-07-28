import 'package:flutter/material.dart';

/// تحويلات مساعدة بين TimeOfDay ودقائق اليوم (المستخدمة في تخزين المهام)
class TimeUtils {
  TimeUtils._();

  static int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  static TimeOfDay fromMinutes(int minutes) => TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  static String formatMinutes(int minutes) {
    final t = fromMinutes(minutes);
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String rangeLabel(int start, int end) => '${formatMinutes(start)} - ${formatMinutes(end)}';
}
