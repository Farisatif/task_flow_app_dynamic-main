import 'package:flutter/material.dart';

/// يحوّل اسم أيقونة مخزّن في قاعدة البيانات (نص) إلى IconData فعلي.
/// نخزن الاسم كنص لأن IconData نفسه غير قابل للتخزين مباشرة في SQLite.
IconData iconFromName(String name) {
  switch (name) {
    case 'water_drop':
      return Icons.water_drop_outlined;
    case 'menu_book':
      return Icons.menu_book_outlined;
    case 'fitness_center':
      return Icons.fitness_center_outlined;
    case 'self_improvement':
      return Icons.self_improvement_outlined;
    case 'nightlight':
      return Icons.nightlight_outlined;
    case 'work':
      return Icons.work_outline;
    case 'school':
      return Icons.school_outlined;
    case 'favorite':
      return Icons.favorite_border;
    case 'home':
      return Icons.home_outlined;
    case 'smartphone':
      return Icons.smartphone_outlined;
    case 'storefront':
      return Icons.storefront_outlined;
    case 'person':
      return Icons.person_outline;
    default:
      return Icons.circle_outlined;
  }
}

/// خيارات الأيقونات المتاحة للاختيار عند إنشاء عادة/مشروع جديد
const List<(String, IconData)> availableIconChoices = [
  ('water_drop', Icons.water_drop_outlined),
  ('menu_book', Icons.menu_book_outlined),
  ('fitness_center', Icons.fitness_center_outlined),
  ('self_improvement', Icons.self_improvement_outlined),
  ('nightlight', Icons.nightlight_outlined),
  ('work', Icons.work_outline),
  ('school', Icons.school_outlined),
  ('favorite', Icons.favorite_border),
  ('home', Icons.home_outlined),
  ('smartphone', Icons.smartphone_outlined),
  ('storefront', Icons.storefront_outlined),
  ('person', Icons.person_outline),
];

/// لوحة ألوان مبسطة للاختيار عند إنشاء عنصر جديد
const List<int> availableColorChoices = [
  0xFF7B6FF0,
  0xFF5B9DF9,
  0xFF4CD787,
  0xFFFFB258,
  0xFFFF7EB3,
  0xFFFFD166,
];
