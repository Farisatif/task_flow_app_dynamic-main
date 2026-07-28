import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'seed_data.dart';

/// يفتح قاعدة البيانات المحلية مرة واحدة عند إقلاع التطبيق، يبذرها ببيانات
/// تجريبية إن كانت فارغة، ثم يوفرها (Provider) لبقية شجرة الواجهات.
/// أثناء التهيئة يعرض شاشة تحميل بسيطة متوافقة مع هوية التطبيق.
class DatabaseBootstrap extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  const DatabaseBootstrap({super.key, required this.builder});

  @override
  State<DatabaseBootstrap> createState() => _DatabaseBootstrapState();
}

class _DatabaseBootstrapState extends State<DatabaseBootstrap> {
  late final AppDatabase _db;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _initFuture = seedDatabaseIfEmpty(_db);
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: Color(0xFF14121F),
                body: Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: Text('تعذّر فتح قاعدة البيانات: ${snapshot.error}')),
              ),
            ),
          );
        }
        return Provider<AppDatabase>.value(
          value: _db,
          child: Builder(builder: widget.builder),
        );
      },
    );
  }
}
