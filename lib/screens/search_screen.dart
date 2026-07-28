import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/database/database.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/task_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return AppScaffold(
      title: 'البحث والفلترة',
      showNav: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'ابحث في المهام...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardTheme.color,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: Wrap(
                    spacing: 8,
                    children: ['الكل', 'الأولوية', 'التصنيف', 'المشروع', 'الحالة']
                        .map((f) => FilterChip(label: Text(f), selected: f == 'الكل', onSelected: (_) {}))
                        .toList(),
                  ).children,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: db.tasksDao.watchAll(),
              builder: (context, snapshot) {
                final all = snapshot.data ?? [];
                final results = _query.isEmpty ? all : all.where((t) => t.title.contains(_query)).toList();
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(child: Text('لا توجد نتائج', style: Theme.of(context).textTheme.bodyMedium)),
                      )
                    else
                      ...results.map((t) => TaskTile(task: t, onTap: () => context.push('/task-details/${t.id}'))),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
