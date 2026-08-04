import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/modules/auth/login_screen.dart';
import '../presentation/modules/dashboard/dashboard_screen.dart';
import '../presentation/modules/finance/finance_screen.dart';
import '../presentation/modules/finance/transaction_form_screen.dart';
import '../presentation/modules/finance/budget_form_screen.dart';
import '../presentation/modules/finance/goal_form_screen.dart';
import '../presentation/modules/finance/investment_form_screen.dart';
import '../presentation/modules/finance/finance_category_form_screen.dart';
import '../presentation/modules/journal/journal_screen.dart';
import '../presentation/modules/journal/journal_entry_form_screen.dart';
import '../presentation/modules/journal/journal_tags_screen.dart';
import '../presentation/modules/bugs/bugs_screen.dart';
import '../presentation/modules/bugs/bug_form_screen.dart';
import '../presentation/modules/jobs/jobs_screen.dart';
import '../presentation/modules/jobs/job_form_screen.dart';
import '../presentation/modules/jobs/job_contacts_screen.dart';
import '../presentation/modules/jobs/job_interviews_screen.dart';
import '../presentation/modules/projects/projects_screen.dart';
import '../presentation/modules/projects/project_form_screen.dart';
import '../presentation/modules/projects/project_tasks_screen.dart';
import '../presentation/modules/projects/project_milestones_screen.dart';
import '../presentation/modules/habits/habits_screen.dart';
import '../presentation/modules/habits/habit_form_screen.dart';
import '../presentation/modules/habits/habit_logs_screen.dart';
import '../presentation/modules/habits/daily_metrics_screen.dart';
import '../presentation/modules/subscriptions/subscriptions_screen.dart';
import '../presentation/modules/subscriptions/subscription_form_screen.dart';
import '../presentation/modules/subscriptions/subscription_payments_screen.dart';
import '../presentation/modules/inventory/inventory_screen.dart';
import '../presentation/modules/inventory/inventory_item_form_screen.dart';
import '../presentation/modules/inventory/inventory_categories_screen.dart';
import '../presentation/modules/bookmarks/bookmarks_screen.dart';
import '../presentation/modules/bookmarks/bookmark_form_screen.dart';
import '../presentation/modules/bookmarks/bookmark_collections_screen.dart';
import '../presentation/modules/settings/settings_screen.dart';
import '../presentation/modules/settings/export_screen.dart';
import '../presentation/modules/settings/profile_screen.dart';
import '../domain/models/transaction.dart';
import '../domain/models/budget.dart';
import '../domain/models/goal.dart';
import '../domain/models/investment.dart';

import '../domain/models/journal.dart';
import '../domain/models/bug.dart';
import '../domain/models/job.dart';
import '../domain/models/project.dart';
import '../domain/models/habit.dart';
import '../domain/models/subscription.dart';
import '../domain/models/inventory.dart';
import '../domain/models/bookmark.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: '/login',
        routes: [
          GoRoute(
              path: '/login', builder: (context, state) => const LoginScreen()),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/finance',
            builder: (context, state) => const FinanceScreen(),
          ),
          GoRoute(
            path: '/finance/transactions/new',
            builder: (context, state) => const TransactionFormScreen(),
          ),
          GoRoute(
            path: '/finance/transactions/edit',
            builder: (context, state) => TransactionFormScreen(
              transaction: state.extra as Transaction?,
            ),
          ),
          GoRoute(
            path: '/finance/budgets/new',
            builder: (context, state) => const BudgetFormScreen(),
          ),
          GoRoute(
            path: '/finance/budgets/edit',
            builder: (context, state) => BudgetFormScreen(
              budget: state.extra as Budget?,
            ),
          ),
          GoRoute(
            path: '/finance/goals/new',
            builder: (context, state) => const GoalFormScreen(),
          ),
          GoRoute(
            path: '/finance/goals/edit',
            builder: (context, state) => GoalFormScreen(
              goal: state.extra as SavingGoal?,
            ),
          ),
          GoRoute(
            path: '/finance/investments/new',
            builder: (context, state) => const InvestmentFormScreen(),
          ),
          GoRoute(
            path: '/finance/investments/edit',
            builder: (context, state) => InvestmentFormScreen(
              investment: state.extra as Investment?,
            ),
          ),
          GoRoute(
            path: '/finance/categories',
            builder: (context, state) => const FinanceCategoryFormScreen(),
          ),
          GoRoute(
            path: '/journal',
            builder: (context, state) => const JournalScreen(),
          ),
          GoRoute(
            path: '/journal/new',
            builder: (context, state) => const JournalEntryFormScreen(),
          ),
          GoRoute(
            path: '/journal/edit',
            builder: (context, state) => JournalEntryFormScreen(
              entry: state.extra as JournalEntry?,
            ),
          ),
          GoRoute(
            path: '/journal/tags',
            builder: (context, state) => const JournalTagsScreen(),
          ),
          GoRoute(
              path: '/bugs', builder: (context, state) => const BugsScreen()),
          GoRoute(
            path: '/bugs/new',
            builder: (context, state) => const BugFormScreen(),
          ),
          GoRoute(
            path: '/bugs/edit',
            builder: (context, state) => BugFormScreen(
              bug: state.extra as BugEntry?,
            ),
          ),
          GoRoute(
              path: '/jobs', builder: (context, state) => const JobsScreen()),
          GoRoute(
            path: '/jobs/new',
            builder: (context, state) => const JobFormScreen(),
          ),
          GoRoute(
            path: '/jobs/edit',
            builder: (context, state) => JobFormScreen(
              job: state.extra as JobApplication?,
            ),
          ),
          GoRoute(
            path: '/jobs/contacts',
            builder: (context, state) => JobContactsScreen(
              job: state.extra as JobApplication,
            ),
          ),
          GoRoute(
            path: '/jobs/interviews',
            builder: (context, state) => JobInterviewsScreen(
              job: state.extra as JobApplication,
            ),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/projects/new',
            builder: (context, state) => const ProjectFormScreen(),
          ),
          GoRoute(
            path: '/projects/edit',
            builder: (context, state) => ProjectFormScreen(
              project: state.extra as Project?,
            ),
          ),
          GoRoute(
            path: '/projects/tasks',
            builder: (context, state) => ProjectTasksScreen(
              project: state.extra as Project,
            ),
          ),
          GoRoute(
            path: '/projects/milestones',
            builder: (context, state) => ProjectMilestonesScreen(
              project: state.extra as Project,
            ),
          ),
          GoRoute(
            path: '/habits',
            builder: (context, state) => const HabitsScreen(),
          ),
          GoRoute(
            path: '/habits/new',
            builder: (context, state) => const HabitFormScreen(),
          ),
          GoRoute(
            path: '/habits/edit',
            builder: (context, state) => HabitFormScreen(
              habit: state.extra as Habit?,
            ),
          ),
          GoRoute(
            path: '/habits/logs',
            builder: (context, state) => HabitLogsScreen(
              habit: state.extra as Habit,
            ),
          ),
          GoRoute(
            path: '/habits/metrics',
            builder: (context, state) => const DailyMetricsScreen(),
          ),
          GoRoute(
            path: '/subscriptions',
            builder: (context, state) => const SubscriptionsScreen(),
          ),
          GoRoute(
            path: '/subscriptions/new',
            builder: (context, state) => const SubscriptionFormScreen(),
          ),
          GoRoute(
            path: '/subscriptions/edit',
            builder: (context, state) => SubscriptionFormScreen(
              subscription: state.extra as Subscription?,
            ),
          ),
          GoRoute(
            path: '/subscriptions/payments',
            builder: (context, state) => SubscriptionPaymentsScreen(
              subscription: state.extra as Subscription,
            ),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/inventory/new',
            builder: (context, state) => const InventoryItemFormScreen(),
          ),
          GoRoute(
            path: '/inventory/edit',
            builder: (context, state) => InventoryItemFormScreen(
              item: state.extra as InventoryItem?,
            ),
          ),
          GoRoute(
            path: '/inventory/categories',
            builder: (context, state) => const InventoryCategoriesScreen(),
          ),
          GoRoute(
            path: '/bookmarks',
            builder: (context, state) => const BookmarksScreen(),
          ),
          GoRoute(
            path: '/bookmarks/new',
            builder: (context, state) => const BookmarkFormScreen(),
          ),
          GoRoute(
            path: '/bookmarks/edit',
            builder: (context, state) => BookmarkFormScreen(
              bookmark: state.extra as Bookmark?,
            ),
          ),
          GoRoute(
            path: '/bookmarks/collections',
            builder: (context, state) => const BookmarkCollectionsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/settings/export',
            builder: (context, state) => const ExportScreen(),
          ),
          GoRoute(
            path: '/settings/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      );
}
