import 'package:flutter/material.dart';
import '../database/database.dart';
import 'time_utils.dart';

extension TaskUiExtensions on Task {
  Color priorityColor() {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFFF6B81);
      case TaskPriority.medium:
        return const Color(0xFFFFB258);
      case TaskPriority.low:
        return const Color(0xFF4CD787);
    }
  }

  String priorityLabel() {
    switch (priority) {
      case TaskPriority.high:
        return 'عالية';
      case TaskPriority.medium:
        return 'متوسطة';
      case TaskPriority.low:
        return 'منخفضة';
    }
  }

  String get timeRange => TimeUtils.rangeLabel(startMinutes, endMinutes);
}
