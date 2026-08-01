class DashboardData {
  final FinanceSummary finance;
  final ProjectStats projects;
  final TaskStats tasks;
  final List<HabitStat> habits;
  final JobStats jobs;
  final BugStats bugs;
  final SubscriptionSummary subscriptions;

  DashboardData({
    required this.finance,
    required this.projects,
    required this.tasks,
    required this.habits,
    required this.jobs,
    required this.bugs,
    required this.subscriptions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      finance: FinanceSummary.fromJson(json['finance']),
      projects: ProjectStats.fromJson(json['projects']),
      tasks: TaskStats.fromJson(json['tasks']),
      habits:
          (json['habits'] as List?)
              ?.map((e) => HabitStat.fromJson(e))
              .toList() ??
          [],
      jobs: JobStats.fromJson(json['jobs']),
      bugs: BugStats.fromJson(json['bugs']),
      subscriptions: SubscriptionSummary.fromJson(json['subscriptions']),
    );
  }
}

class FinanceSummary {
  final String monthIncome;
  final String monthExpense;

  FinanceSummary({required this.monthIncome, required this.monthExpense});

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      monthIncome: json['monthIncome'] ?? '0',
      monthExpense: json['monthExpense'] ?? '0',
    );
  }
}

class ProjectStats {
  final int total;
  final int active;

  ProjectStats({required this.total, required this.active});

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    return ProjectStats(total: json['total'] ?? 0, active: json['active'] ?? 0);
  }
}

class TaskStats {
  final int total;
  final int todo;
  final int inProgress;
  final int done;

  TaskStats({
    required this.total,
    required this.todo,
    required this.inProgress,
    required this.done,
  });

  factory TaskStats.fromJson(Map<String, dynamic> json) {
    return TaskStats(
      total: json['total'] ?? 0,
      todo: json['todo'] ?? 0,
      inProgress: json['inProgress'] ?? 0,
      done: json['done'] ?? 0,
    );
  }
}

class HabitStat {
  final String habitId;
  final String habitName;
  final int completedDays;

  HabitStat({
    required this.habitId,
    required this.habitName,
    required this.completedDays,
  });

  factory HabitStat.fromJson(Map<String, dynamic> json) {
    return HabitStat(
      habitId: json['habitId'],
      habitName: json['habitName'],
      completedDays: json['completedDays'] ?? 0,
    );
  }
}

class JobStats {
  final int total;
  final int interview;
  final int offer;
  final int rejected;

  JobStats({
    required this.total,
    required this.interview,
    required this.offer,
    required this.rejected,
  });

  factory JobStats.fromJson(Map<String, dynamic> json) {
    return JobStats(
      total: json['total'] ?? 0,
      interview: json['interview'] ?? 0,
      offer: json['offer'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }
}

class BugStats {
  final int total;
  final int open;
  final int solved;

  BugStats({required this.total, required this.open, required this.solved});

  factory BugStats.fromJson(Map<String, dynamic> json) {
    return BugStats(
      total: json['total'] ?? 0,
      open: json['open'] ?? 0,
      solved: json['solved'] ?? 0,
    );
  }
}

class SubscriptionSummary {
  final String monthlyCost;

  SubscriptionSummary({required this.monthlyCost});

  factory SubscriptionSummary.fromJson(Map<String, dynamic> json) {
    return SubscriptionSummary(monthlyCost: json['monthlyCost'] ?? '0');
  }
}
