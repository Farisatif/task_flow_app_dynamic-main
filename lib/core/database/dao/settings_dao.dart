import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'settings_dao.g.dart';

/// وصول عام لجدول الإعدادات (مفتاح/قيمة) — يُستخدم لتخزين تفضيلات الإشعارات،
/// الأصوات، الإعدادات الافتراضية للمهام، وإعدادات المخطط الأسبوعي كنصوص JSON.
@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(appSettings)..where((s) => s.settingKey.equals(key))).getSingleOrNull();
    return row?.settingValue;
  }

  Stream<String?> watchValue(String key) {
    return (select(appSettings)..where((s) => s.settingKey.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.settingValue);
  }

  Future<void> setValue(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(settingKey: key, settingValue: value),
    );
  }
}
