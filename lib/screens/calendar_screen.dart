import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/database/database.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/task_tile.dart';
import '../core/theme/app_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();

    return AppScaffold(
      title: 'التقويم',
      navIndex: -1,
      showNav: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/task-form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Task>>(
        stream: db.tasksDao.watchAll(),
        builder: (context, snapshot) {
          final allTasks = snapshot.data ?? [];
          final selectedTasks = allTasks.where((t) => isSameDay(t.date, _selectedDay)).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: TableCalendar(
                  locale: 'ar',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.4), shape: BoxShape.circle),
                    selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    markerDecoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  eventLoader: (day) => allTasks.where((t) => isSameDay(t.date, day)).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text('مهام اليوم المحدد', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (selectedTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('لا توجد مهام في هذا اليوم', style: Theme.of(context).textTheme.bodyMedium)),
                )
              else
                ...selectedTasks.map((t) => TaskTile(
                      task: t,
                      onTap: () => context.push('/task-details/${t.id}'),
                      onCheck: (v) => db.tasksDao.setStatus(t.id, v == true ? TaskStatus.completed : TaskStatus.pending),
                    )),
            ],
          );
        },
      ),
    );
  }
}
