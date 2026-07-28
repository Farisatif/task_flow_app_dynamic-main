import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [Profile])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Stream<ProfileRow?> watchProfile() => (select(profile)..where((p) => p.id.equals(1))).watchSingleOrNull();

  Future<void> upsertProfile(ProfileCompanion entry) async {
    await into(profile).insertOnConflictUpdate(entry);
  }
}
