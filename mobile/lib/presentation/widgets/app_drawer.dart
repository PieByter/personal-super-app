import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../data/api_service.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final modules = [
      _ModuleItem(
        'Dashboard',
        Icons.dashboard_outlined,
        '/dashboard',
        AppColors.dashboard,
      ),
      _ModuleItem(
        'Finance',
        Icons.account_balance_wallet_outlined,
        '/finance',
        AppColors.finance,
      ),
      _ModuleItem(
        'Journal',
        Icons.book_outlined,
        '/journal',
        AppColors.journal,
      ),
      _ModuleItem(
        'Bug Tracker',
        Icons.bug_report_outlined,
        '/bugs',
        AppColors.bugs,
      ),
      _ModuleItem('Job Tracker', Icons.work_outline, '/jobs', AppColors.jobs),
      _ModuleItem(
        'Projects',
        Icons.folder_outlined,
        '/projects',
        AppColors.projects,
      ),
      _ModuleItem(
        'Habits',
        Icons.check_circle_outline,
        '/habits',
        AppColors.habits,
      ),
      _ModuleItem(
        'Subscriptions',
        Icons.subscriptions_outlined,
        '/subscriptions',
        AppColors.subscriptions,
      ),
      _ModuleItem(
        'Inventory',
        Icons.inventory_2_outlined,
        '/inventory',
        AppColors.inventory,
      ),
      _ModuleItem(
        'Bookmarks',
        Icons.bookmark_outline,
        '/bookmarks',
        AppColors.bookmarks,
      ),
    ];

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.apps,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Personal Super App',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your personal operating system',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                final isSelected = currentRoute == module.route;
                return ListTile(
                  leading: Icon(
                    module.icon,
                    color: isSelected ? module.color : null,
                  ),
                  title: Text(
                    module.name,
                    style: TextStyle(
                      color: isSelected ? module.color : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: module.color.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (!isSelected) context.go(module.route);
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              await ApiService().clearToken();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ModuleItem {
  final String name;
  final IconData icon;
  final String route;
  final Color color;

  _ModuleItem(this.name, this.icon, this.route, this.color);
}
