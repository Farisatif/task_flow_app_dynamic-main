import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'projects_dao.g.dart';

/// نتيجة مشروع مع إحصائيات مهامه (للاستخدام المباشر في الواجهة)
class ProjectWithStats {
  final Project project;
  final int totalTasks;
  final int completedTasks;
  ProjectWithStats({required this.project, required this.totalTasks, required this.completedTasks});

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;
  int get progressPercent => (progress * 100).round();
}

@DriftAccessor(tables: [Projects, Tasks])
class ProjectsDao extends DatabaseAccessor<AppDatabase> with _$ProjectsDaoMixin {
  ProjectsDao(super.db);

  Stream<List<Project>> watchAll() {
    return (select(projects)
          ..where((p) => p.isDeleted.equals(false) & p.isArchived.equals(false)))
        .watch();
  }

  /// يبث قائمة المشاريع مع عدد مهامها المنجزة/الكلي، محسوبة مباشرة من جدول tasks
  Stream<List<ProjectWithStats>> watchAllWithStats() {
    final query = select(projects)..where((p) => p.isDeleted.equals(false) & p.isArchived.equals(false));
    return query.watch().asyncMap((projectRows) async {
      final result = <ProjectWithStats>[];
      for (final proj in projectRows) {
        final allTasks = await (select(tasks)
              ..where((t) => t.projectId.equals(proj.id) & t.isDeleted.equals(false)))
            .get();
        final completed = allTasks.where((t) => t.status == TaskStatus.completed).length;
        result.add(ProjectWithStats(project: proj, totalTasks: allTasks.length, completedTasks: completed));
      }
      return result;
    });
  }

  Future<int> insertProject(ProjectsCompanion entry) => into(projects).insert(entry);

  Future<bool> updateProject(Project entry) => update(projects).replace(entry);

  Future<int> softDelete(int id) => (update(projects)..where((p) => p.id.equals(id)))
      .write(const ProjectsCompanion(isDeleted: Value(true)));
}
