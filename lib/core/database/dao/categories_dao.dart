import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchAll() {
    return (select(categories)
          ..where((c) => c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  Future<int> insertCategory(CategoriesCompanion entry) => into(categories).insert(entry);

  Future<bool> updateCategory(Category entry) => update(categories).replace(entry);

  Future<int> softDelete(int id) => (update(categories)..where((c) => c.id.equals(id)))
      .write(const CategoriesCompanion(isDeleted: Value(true)));
}
