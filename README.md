# Task Flow — تطبيق إدارة المهام والإنتاجية

تطبيق Flutter كامل ومتصل بقاعدة بيانات محلية حقيقية (SQLite عبر Drift). كل المهام،
المشاريع، الأهداف، العادات، الملاحظات، المرفقات، والتذكيرات تُضاف وتُعدَّل وتُحذف
فعليًا وتُخزَّن على الجهاز — لا توجد بيانات وهمية بعد الآن.

## 1) التشغيل للتطوير

```bash
cd task_flow_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # يولّد ملفات Drift (*.g.dart)
flutter run
```

أعد تشغيل أمر build_runner في كل مرة تُعدّل فيها أي جدول داخل `lib/core/database/tables.dart`
أو أي DAO جديد.

## 2) البنية

```
lib/
  core/
    theme/            الألوان والثيمات (نهاري/ليلي) + مزود التبديل بينهما
    database/
      tables.dart       تعريف كل جداول SQLite (13 جدولًا)
      database.dart     AppDatabase الرئيسية (يفتح/يهاجر القاعدة)
      database_provider.dart  يفتح القاعدة عند الإقلاع، يبذرها إن كانت فارغة، ثم يوفرها للواجهات
      seed_data.dart    بيانات تجريبية تُدرج مرة واحدة فقط عند أول تشغيل (قاعدة فارغة)
      dao/              10 DAOs (مهام، مشاريع، أهداف، عادات، ملاحظات، مرفقات، تذكيرات...)
    utils/              تحويلات الوقت، أيقونات، امتدادات المهمة
  widgets/              عناصر مشتركة (بطاقة مهمة، شريط تنقل سفلي، إطار شاشة موحّد)
  screens/              24 شاشة، معظمها متصل مباشرة بقاعدة البيانات عبر StreamBuilder
  router/               GoRouter يربط كل الشاشات
  main.dart             نقطة الدخول: يهيّئ العربية، يفتح القاعدة، يشغّل التطبيق
```

## 3) إدارة المهام (إضافة / تعديل / حذف) — جاهزة بالكامل

- **إضافة**: زر (+) العائم في أي شاشة مهام يفتح `TaskFormScreen` (`/task-form`) — عنوان،
  تاريخ، وقت البداية/النهاية، أولوية، تصنيف، مشروع، ملاحظات.
- **تعديل**: من تفاصيل المهمة اضغط "تعديل" → يفتح نفس النموذج مسبقًا بالبيانات
  (`/task-form/:id`) ويحفظ التعديلات على نفس السجل.
- **حذف**: من تفاصيل المهمة أو من نموذج التعديل، مع نافذة تأكيد. الحذف "منطقي"
  (soft delete عبر `is_deleted`) بحيث يمكن لاحقًا بناء شاشة "سلة المحذوفات" دون فقد البيانات فعليًا.
- **إتمام / إعادة فتح**: زر مباشر في تفاصيل المهمة وفي كل قائمة (Checkbox).
- كل الشاشات (الرئيسية، اليوم، قائمة المهام، التقويم، البحث) تُحدَّث تلقائيًا وفوريًا
  عند أي تغيير لأنها تستمع لتيار (`Stream`) مباشر من قاعدة البيانات — لا حاجة لتحديث يدوي.

نفس النمط مطبّق أيضًا على: الأهداف، العادات، المشاريع، الملاحظات، التذكيرات، والمرفقات
(إضافة/حذف من كل شاشة مباشرة).

## 4) الشاشات التحليلية (لا تزال بيانات عرض توضيحية)

الإحصائيات، تحليل الإنتاجية، تقارير الأداء، الإنجازات، لوحة التركيز، المخطط الأسبوعي،
والملف الشخصي/الإعدادات تعرض حاليًا أرقامًا توضيحية وليست محسوبة من قاعدة البيانات.
لتفعيلها بالكامل لاحقًا: اجمع البيانات عبر `TasksDao`/`FocusSessionsDao`/`HabitsDao`
الموجودة بالفعل بدل الأرقام الثابتة — البنية التحتية (الجداول والـ DAOs) جاهزة لذلك.

## 5) خطوات النشر (Publish) على المتاجر

### أ) توليد مجلدات المنصات (مطلوب مرة واحدة)
هذا المستودع يحتوي فقط على `lib/` و `pubspec.yaml` (بدون `android/` و `ios/`).
شغّل داخل مجلد المشروع:
```bash
flutter create . --org com.yourcompany --project-name task_flow_app
```
هذا يضيف مجلدات `android/` و `ios/` (و`macos/`/`windows/`/`linux/` إن أردت) دون
المساس بـ `lib/` أو `pubspec.yaml` الحاليين.

### ب) الأيقونة
تم توليد أيقونة مبدئية بألوان هوية التطبيق في `assets/icon/app_icon.png`.
استبدلها بشعارك النهائي (مربع 1024×1024 بدون حواف شفافة زائدة) ثم شغّل:
```bash
dart run flutter_launcher_icons
```
لتوليد كل أحجام الأيقونات على أندرويد و iOS تلقائيًا.

### ج) اسم التطبيق ومعرّف الحزمة
- **اسم العرض**: عدّل `android/app/src/main/AndroidManifest.xml` (`android:label`)
  و `ios/Runner/Info.plist` (`CFBundleDisplayName`).
- **معرّف الحزمة (applicationId / bundle id)**: حدّده مباشرة عبر أمر `flutter create`
  أعلاه (`--org`)، أو عدّله لاحقًا في `android/app/build.gradle` (`applicationId`)
  و Xcode (`Runner` target → General → Bundle Identifier).

### د) الإصدار
ارفع رقم الإصدار في `pubspec.yaml` قبل كل نشر:
```yaml
version: 1.0.0+1   # <رقم يظهر للمستخدم>+<رقم بناء داخلي يجب أن يزيد كل مرة>
```

### هـ) بناء أندرويد (Google Play)
```bash
flutter build appbundle --release
```
يحتاج توقيعًا (keystore) قبل الرفع الفعلي:
1. أنشئ keystore: `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. أنشئ `android/key.properties` (غير مضمّن في git):
   ```
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=/absolute/path/to/upload-keystore.jks
   ```
3. اربطه في `android/app/build.gradle` (قسم `signingConfigs`) حسب توثيق Flutter الرسمي
   لـ "Build and release an Android app".
الناتج: `build/app/outputs/bundle/release/app-release.aab` يُرفع مباشرة إلى Google Play Console.

### و) بناء iOS (App Store)
```bash
flutter build ipa --release
```
يتطلب: حساب Apple Developer، فتح `ios/Runner.xcworkspace` في Xcode لضبط Signing &
Capabilities (فريق التوقيع)، ثم الرفع عبر Xcode Organizer أو Transporter.

### ز) قائمة تحقق أخيرة قبل النشر
- [ ] `flutter analyze` بدون أخطاء
- [ ] اختبار التطبيق على جهاز/محاكي حقيقي (إضافة/تعديل/حذف مهمة فعليًا)
- [ ] استبدال الأيقونة المبدئية بشعار نهائي
- [ ] تحديث `version` في `pubspec.yaml`
- [ ] مراجعة صلاحيات المنصة إن أضفت لاحقًا إشعارات فعلية أو مرفقات ملفات حقيقية
- [ ] `flutter build appbundle --release` / `flutter build ipa --release` بدون أخطاء

## 6) ملاحظة بيئية مهمة
لا تتوفر لديّ بيئة Flutter SDK فعلية لتشغيل `flutter analyze` أو `flutter run` أو
`build_runner` والتحقق الآلي الكامل من الكود. راجعت كل الملفات يدويًا (تطابق أسماء
الأعمدة، أنواع البيانات، الحقول المطلوبة عند الإدراج، توازن الأقواس)، لكن يُنصح
بتشغيل `flutter analyze` بعد أول `pub get` + `build_runner build` للتأكد قبل أي نشر فعلي.
