import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'attachments_dao.g.dart';

@DriftAccessor(tables: [Attachments])
class AttachmentsDao extends DatabaseAccessor<AppDatabase> with _$AttachmentsDaoMixin {
  AttachmentsDao(super.db);

  Stream<List<Attachment>> watchAll() {
    return (select(attachments)..orderBy([(a) => OrderingTerm.desc(a.createdAt)])).watch();
  }

  Future<int> insertAttachment(AttachmentsCompanion entry) => into(attachments).insert(entry);

  Future<int> deleteAttachment(int id) => (delete(attachments)..where((a) => a.id.equals(id))).go();
}
