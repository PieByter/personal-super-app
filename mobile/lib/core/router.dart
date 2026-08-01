import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/modules/auth/login_screen.dart';
import '../presentation/modules/dashboard/dashboard_screen.dart';
import '../presentation/modules/finance/finance_screen.dart';
import '../presentation/modules/journal/journal_screen.dart';
import '../presentation/modules/bugs/bugs_screen.dart';
import '../presentation/modules/jobs/jobs_screen.dart';
import '../presentation/modules/projects/projects_screen.dart';
import '../presentation/modules/habits/habits_screen.dart';
import '../presentation/modules/subscriptions/subscriptions_screen.dart';
import '../presentation/modules/inventory/inventory_screen.dart';
import '../presentation/modules/bookmarks/bookmarks_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const FinanceScreen(),
      ),
      GoRoute(
        path: '/journal',
        builder: (context, state) => const JournalScreen(),
      ),
      GoRoute(path: '/bugs', builder: (context, state) => const BugsScreen()),
      GoRoute(path: '/jobs', builder: (context, state) => const JobsScreen()),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: '/habits',
        builder: (context, state) => const HabitsScreen(),
      ),
      GoRoute(
        path: '/subscriptions',
        builder: (context, state) => const SubscriptionsScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),
    ],
  );
}
