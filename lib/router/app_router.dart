import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/today_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/task_list_screen.dart';
import '../screens/task_details_screen.dart';
import '../screens/task_form_screen.dart';
import '../screens/focus_timer_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/more_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/habits_screen.dart';
import '../screens/projects_screen.dart';
import '../screens/focus_dashboard_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/attachments_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/weekly_planner_screen.dart';
import '../screens/productivity_analysis_screen.dart';
import '../screens/performance_reports_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/backup_sync_screen.dart';
import '../screens/search_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/quick_add_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/trash_screen.dart';

/// خريطة التنقل الكاملة للتطبيق - تربط كل الشاشات ببعضها
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/today', builder: (context, state) => const TodayScreen()),
    GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
    GoRoute(path: '/tasks', builder: (context, state) => const TaskListScreen()),
    GoRoute(
      path: '/task-details/:id',
      builder: (context, state) => TaskDetailsScreen(taskId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/task-form', builder: (context, state) => const TaskFormScreen()),
    GoRoute(
      path: '/task-form/:id',
      builder: (context, state) => TaskFormScreen(taskId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/focus-timer', builder: (context, state) => const FocusTimerScreen()),
    GoRoute(path: '/statistics', builder: (context, state) => const StatisticsScreen()),
    GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
    GoRoute(path: '/goals', builder: (context, state) => const GoalsScreen()),
    GoRoute(path: '/habits', builder: (context, state) => const HabitsScreen()),
    GoRoute(path: '/projects', builder: (context, state) => const ProjectsScreen()),
    GoRoute(path: '/focus-dashboard', builder: (context, state) => const FocusDashboardScreen()),
    GoRoute(path: '/notes', builder: (context, state) => const NotesScreen()),
    GoRoute(path: '/attachments', builder: (context, state) => const AttachmentsScreen()),
    GoRoute(path: '/reminders', builder: (context, state) => const RemindersScreen()),
    GoRoute(path: '/weekly-planner', builder: (context, state) => const WeeklyPlannerScreen()),
    GoRoute(path: '/productivity-analysis', builder: (context, state) => const ProductivityAnalysisScreen()),
    GoRoute(path: '/performance-reports', builder: (context, state) => const PerformanceReportsScreen()),
    GoRoute(path: '/achievements', builder: (context, state) => const AchievementsScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/backup-sync', builder: (context, state) => const BackupSyncScreen()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/categories', builder: (context, state) => const CategoriesScreen()),
    GoRoute(path: '/quick-add', builder: (context, state) => const QuickAddScreen()),
    GoRoute(path: '/notification-settings', builder: (context, state) => const NotificationSettingsScreen()),
    GoRoute(path: '/trash', builder: (context, state) => const TrashScreen()),
  ],
);
