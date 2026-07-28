import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<Note>> watchAll() {
    return (select(notes)
          ..where((n) => n.isDeleted.equals(false))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
        .watch();
  }

  Future<int> insertNote(NotesCompanion entry) => into(notes).insert(entry);

  Future<bool> updateNote(Note entry) => update(notes).replace(entry);

  Future<int> softDelete(int id) =>
      (update(notes)..where((n) => n.id.equals(id))).write(const NotesCompanion(isDeleted: Value(true)));
}
