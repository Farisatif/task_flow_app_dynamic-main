import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [Goals, SubGoals])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Stream<List<Goal>> watchAll() {
    return (select(goals)..where((g) => g.isDeleted.equals(false))).watch();
  }

  Stream<List<SubGoal>> watchSubGoals(int goalId) {
    return (select(subGoals)..where((s) => s.goalId.equals(goalId))).watch();
  }

  Future<int> insertGoal(GoalsCompanion entry) => into(goals).insert(entry);

  Future<int> insertSubGoal(SubGoalsCompanion entry) => into(subGoals).insert(entry);

  Future<bool> updateGoal(Goal entry) => update(goals).replace(entry);

  Future<bool> updateSubGoal(SubGoal entry) => update(subGoals).replace(entry);

  Future<int> softDelete(int id) =>
      (update(goals)..where((g) => g.id.equals(id))).write(const GoalsCompanion(isDeleted: Value(true)));
}
