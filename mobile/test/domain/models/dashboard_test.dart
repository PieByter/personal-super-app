import 'package:flutter_test/flutter_test.dart';
import 'package:personal_super_app/domain/models/dashboard.dart';

void main() {
  test('DashboardData parses the modules that remain', () {
    final data = DashboardData.fromJson({
      'projects': {'total': 2, 'active': 1},
      'tasks': {'todo': 3},
      'habits': [],
      'jobs': {'interview': 1},
      'bugs': {'open': 4},
      'subscriptions': {'monthlyCost': '50000'},
    });

    expect(data.projects.active, 1);
    expect(data.tasks.todo, 3);
    expect(data.jobs.interview, 1);
    expect(data.bugs.open, 4);
    expect(data.subscriptions.monthlyCost, '50000');
  });
}
