import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import '../core/database/database.dart';
import '../core/services/app_preferences.dart';
import '../core/utils/task_extensions.dart';
import '../core/theme/app_colors.dart';
import '../widgets/app_scaffold.dart';

/// مخطط أسبوعي احترافي حقيقي: محور ساعات رأسي + سبعة أعمدة أيام، تُظهر كل
/// مهمة كمربع ملوّن بحجم وموضع يطابقان وقتها الفعلي، والباقي "وقت فارغ".
class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  int _weekOffset = 0;
  static const double _hourHeight = 64;
  static const double _timeAxisWidth = 42;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _startOfWeek(bool weekStartsSaturday) {
    final now = _dateOnly(DateTime.now());
    final anchor = weekStartsSaturday ? DateTime.saturday : DateTime.sunday;
    final daysSinceAnchor = (now.weekday - anchor + 7) % 7;
    return now.subtract(Duration(days: daysSinceAnchor)).add(Duration(days: 7 * _weekOffset));
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    final appPrefs = context.watch<AppPreferences>();
    final t = appPrefs.taskDefaults;
    final startOfWeek = _startOfWeek(t.weekStartsSaturday);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final today = _dateOnly(DateTime.now());

    final dayLabels = t.weekStartsSaturday
        ? ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة']
        : ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];

    final visibleIndices = List.generate(7, (i) => i)
        .where((i) {
          if (t.showWeekendsInPlanner) return true;
          final d = startOfWeek.add(Duration(days: i));
          return d.weekday != DateTime.friday && d.weekday != DateTime.saturday;
        })
        .toList();

    return AppScaffold(
      title: 'المخطط الأسبوعي',
      showNav: false,
      actions: [
        IconButton(
          tooltip: 'إعدادات ساعات العمل',
          icon: const Icon(Icons.tune_outlined),
          onPressed: () => context.push('/notification-settings'),
        ),
      ],
      body: StreamBuilder<List<Task>>(
        stream: db.tasksDao.watchTasksForRange(startOfWeek, endOfWeek),
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? [];

          // نحسب نطاق الساعات المعروض: ساعات العمل المُعدّة، مُوسّعة تلقائيًا
          // إن وُجدت مهام قبل أو بعد هذا النطاق حتى لا تُقصّ من العرض
          int rangeStart = t.workDayStartHour;
          int rangeEnd = t.workDayEndHour;
          for (final task in tasks) {
            final startHour = task.startMinutes ~/ 60;
            final endHour = (task.endMinutes / 60).ceil();
            if (startHour < rangeStart) rangeStart = startHour;
            if (endHour > rangeEnd) rangeEnd = endHour;
          }
          rangeStart = rangeStart.clamp(0, 23);
          rangeEnd = rangeEnd.clamp(rangeStart + 1, 24);
          final hourCount = rangeEnd - rangeStart;

          // إجمالي الدقائق المشغولة لكل يوم (لملخص "مشغول/فارغ" أعلى كل عمود)
          final busyMinutesByDay = <int, int>{};
          for (final task in tasks) {
            final dayIndex = task.date.difference(startOfWeek).inDays;
            busyMinutesByDay[dayIndex] = (busyMinutesByDay[dayIndex] ?? 0) + (task.endMinutes - task.startMinutes);
          }

          return Column(
            children: [
              _weekNav(context, startOfWeek, endOfWeek),
              const SizedBox(height: 4),
              _legend(context),
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // رأس الأعمدة: اسم اليوم + التاريخ + ملخص مشغول/فارغ
                      Row(
                        children: [
                          const SizedBox(width: _timeAxisWidth),
                          ...visibleIndices.map((i) {
                            final date = startOfWeek.add(Duration(days: i));
                            final isToday = date == today;
                            final totalWorkMinutes = hourCount * 60;
                            final busy = busyMinutesByDay[i] ?? 0;
                            final freeH = ((totalWorkMinutes - busy).clamp(0, totalWorkMinutes)) / 60;
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: isToday ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(dayLabels[i],
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                                            color: isToday ? AppColors.primary : null)),
                                    const SizedBox(height: 2),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isToday ? AppColors.primary : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text('${date.day}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isToday ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color)),
                                    ),
                                    const SizedBox(height: 3),
                                    Text('${freeH.toStringAsFixed(freeH % 1 == 0 ? 0 : 1)}س فاضي',
                                        style: TextStyle(fontSize: 9.5, color: AppColors.accentGreen, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // الشبكة: محور الساعات + أعمدة الأيام
                      SizedBox(
                        height: hourCount * _hourHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _hourAxis(context, rangeStart, hourCount),
                            ...visibleIndices.map((i) {
                              final date = startOfWeek.add(Duration(days: i));
                              final dayTasks = tasks.where((tk) => tk.date.difference(startOfWeek).inDays == i).toList();
                              final isToday = date == today;
                              return Expanded(
                                child: _DayColumn(
                                  date: date,
                                  isToday: isToday,
                                  rangeStartHour: rangeStart,
                                  hourCount: hourCount,
                                  hourHeight: _hourHeight,
                                  tasks: dayTasks,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _weekNav(BuildContext context, DateTime start, DateTime endExclusive) {
    final end = endExclusive.subtract(const Duration(days: 1));
    final sameMonth = start.month == end.month;
    final label = sameMonth
        ? '${start.day} - ${end.day} ${intl.DateFormat('MMMM yyyy', 'ar').format(end)}'
        : '${intl.DateFormat('d MMM', 'ar').format(start)} - ${intl.DateFormat('d MMM yyyy', 'ar').format(end)}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => setState(() => _weekOffset--), icon: const Icon(Icons.chevron_right)),
          Column(
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              if (_weekOffset != 0)
                TextButton(
                  onPressed: () => setState(() => _weekOffset = 0),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(10, 20)),
                  child: const Text('العودة لهذا الأسبوع', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
          IconButton(onPressed: () => setState(() => _weekOffset++), icon: const Icon(Icons.chevron_left)),
        ],
      ),
    );
  }

  Widget _legend(BuildContext context) {
    Widget dot(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.5)),
          ],
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          dot(AppColors.priorityHigh, 'عالية'),
          dot(AppColors.priorityMedium, 'متوسطة'),
          dot(AppColors.priorityLow, 'منخفضة'),
          dot(AppColors.lightBorder, 'وقت فارغ'),
        ],
      ),
    );
  }

  Widget _hourAxis(BuildContext context, int startHour, int hourCount) {
    return SizedBox(
      width: _timeAxisWidth,
      child: Stack(
        children: List.generate(hourCount + 1, (i) {
          final hour = startHour + i;
          return Positioned(
            top: i * _hourHeight - 6,
            right: 0,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9.5),
            ),
          );
        }),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final int rangeStartHour;
  final int hourCount;
  final double hourHeight;
  final List<Task> tasks;

  const _DayColumn({
    required this.date,
    required this.isToday,
    required this.rangeStartHour,
    required this.hourCount,
    required this.hourHeight,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final showNowLine = isToday;
    final nowOffset = ((now.hour * 60 + now.minute) - rangeStartHour * 60) / 60 * hourHeight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primary.withValues(alpha: 0.04)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // خطوط الساعات (شبكة خلفية توضح "وقت فارغ")
          ...List.generate(hourCount, (i) => Positioned(
                top: i * hourHeight,
                left: 0,
                right: 0,
                child: Container(height: 1, color: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withValues(alpha: 0.6)),
              )),
          // خط "الآن" الأحمر
          if (showNowLine && nowOffset >= 0 && nowOffset <= hourCount * hourHeight)
            Positioned(
              top: nowOffset,
              left: 0,
              right: 0,
              child: Row(children: [
                Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.priorityHigh, shape: BoxShape.circle)),
                Expanded(child: Container(height: 1.4, color: AppColors.priorityHigh)),
              ]),
            ),
          // فتح نموذج مهمة جديدة عند الضغط على منطقة فارغة من العمود (تحت كتل المهام)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push('/task-form'),
            ),
          ),
          // كتل المهام (الوقت المشغول) — فوق طبقة الضغط الفارغة فتلتقط لمسها أولًا
          ...tasks.map((task) {
            final top = ((task.startMinutes - rangeStartHour * 60) / 60 * hourHeight).clamp(0.0, hourCount * hourHeight);
            final rawHeight = (task.endMinutes - task.startMinutes) / 60 * hourHeight;
            final height = rawHeight.clamp(16.0, hourCount * hourHeight - top);
            final color = task.priorityColor();
            return Positioned(
              top: top,
              left: 2,
              right: 2,
              height: height,
              child: GestureDetector(
                onTap: () => context.push('/task-details/${task.id}'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: task.status == TaskStatus.completed ? 0.35 : 0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border(right: BorderSide(color: color, width: 3)),
                  ),
                  child: Text(
                    task.title,
                    maxLines: height > 32 ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, height: 1.1),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
