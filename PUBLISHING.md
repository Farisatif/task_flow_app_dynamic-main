# دليل التجهيز للنشر — Task Flow

هذا المشروع حاليًا كود Dart/Flutter (مجلد `lib/` + `pubspec.yaml`) بدون مجلدات المنصات
(android/ios/web) لأنها تُنشأ عادة بأمر Flutter نفسه. اتبع الخطوات بالترتيب.

## 1) إنشاء مجلدات المنصات
داخل مجلد المشروع (بجانب `lib/` و `pubspec.yaml`):
```bash
flutter create . --project-name task_flow_app --org com.yourcompany
```
هذا الأمر آمن على مشروع موجود: يضيف `android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/`
دون أن يلمس `lib/` أو `pubspec.yaml` الحاليين. غيّر `com.yourcompany` لاسم نطاقك الفعلي —
هذا يصبح جزءًا من applicationId/bundle id ولا يمكن تغييره بسهولة بعد النشر لأول مرة.

## 2) توليد أكواد قاعدة البيانات
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## 3) اسم التطبيق والحزمة
- **اسم العرض على الجهاز**:
  - أندرويد: `android/app/src/main/AndroidManifest.xml` → خاصية `android:label`
  - iOS: `ios/Runner/Info.plist` → مفتاح `CFBundleDisplayName`
- **معرّف الحزمة (applicationId / bundle id)**: يُفضَّل ضبطه من البداية عبر `--org` أعلاه.
  لتغييره لاحقًا، أسهل طريقة هي حزمة `rename` أو `change_app_package_name`:
  ```bash
  dart pub global activate rename
  rename setBundleId --value "com.yourcompany.taskflow"
  rename setAppName --value "Task Flow"
  ```

## 4) أيقونة التطبيق
ضع أيقونة مربعة 1024×1024 بصيغة PNG في `assets/icon/icon.png`، ثم أضف الحزمة:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
```
ثم:
```bash
dart run flutter_launcher_icons
```

## 5) الإصدار (Version)
في `pubspec.yaml`:
```yaml
version: 1.0.0+1   # الصيغة: <اسم-الإصدار>+<رقم-البناء>
```
ارفع رقم البناء (`+1` → `+2` ...) في كل رفعة جديدة على المتجر، ولو لم يتغيّر `1.0.0`.

## 6) التوقيع للنشر (أندرويد)
Google Play يتطلب توقيع الحزمة (App Bundle) بمفتاح release:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
أنشئ `android/key.properties`:
```
storePassword=<كلمة المرور>
keyPassword=<كلمة المرور>
keyAlias=upload
storeFile=/المسار/الكامل/إلى/upload-keystore.jks
```
واربطه في `android/app/build.gradle` ضمن `signingConfigs` (راجع توثيق Flutter الرسمي
لـ "Build and release an Android app" فالخطوات تتغيّر قليلًا بين إصدارات Gradle).

## 7) أوامر البناء النهائية
```bash
# أندرويد - لرفع على Google Play (الصيغة المفضّلة)
flutter build appbundle --release

# أندرويد - ملف APK قابل للتوزيع المباشر
flutter build apk --release --split-per-abi

# iOS (يتطلب macOS + Xcode + حساب Apple Developer)
flutter build ios --release
# ثم افتح ios/Runner.xcworkspace في Xcode لعمل Archive والرفع إلى App Store Connect
```

## 8) نقاط تدقيق قبل الرفع
- [ ] `flutter analyze` بدون أخطاء
- [ ] اختبار كامل لتدفق المهام: إضافة → تعديل → إتمام → حذف، على جهاز/محاكي حقيقي
- [ ] التحقق من عمل الوضع الليلي/النهاري وRTL في كل الشاشات
- [ ] حذف أي بيانات اختبار حساسة، والتأكد أن `seedDatabaseIfEmpty` مناسبة للنشر
      (يمكن تعطيلها كليًا بحذف استدعائها في `database_provider.dart` إن كنت تريد تطبيقًا
      يبدأ فارغًا تمامًا لكل مستخدم جديد)
- [ ] سياسة الخصوصية: التطبيق حاليًا **محلي بالكامل** (SQLite على الجهاز، لا اتصال إنترنت
      ولا جمع بيانات)، وهذا يبسّط متطلبات سياسة الخصوصية في المتاجر — إن أضفت مزامنة سحابية
      أو تحليلات لاحقًا فحدّث السياسة والإفصاحات في نموذج بيانات المتجر (Google Play Data
      Safety / App Store Privacy Nutrition Label) وفقًا لذلك
- [ ] لقطات شاشة (screenshots) للمتجر بالمقاسات المطلوبة من كل من الوضعين النهاري والليلي

## 9) اختياري: تفعيل الحذف الفعلي بدل الحذف الناعم
كل الجداول تستخدم حاليًا "حذف ناعم" (`is_deleted = true` بدل حذف السطر) للحفاظ على تاريخ
البيانات. إن كنت تفضل حذفًا فعليًا من القاعدة، بدّل استدعاءات `softDelete` في كل DAO
بعبارة `delete(table)..where(...)` بدل `update(...).write(...)`.
