import 'package:flutter/material.dart';

class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api',
  );
  static const String authUrl = '$baseUrl/auth';
  static const String dashboardUrl = '$baseUrl/dashboard';
  static const String transactionsUrl = '$baseUrl/finance/transactions';
  static const String categoriesUrl = '$baseUrl/finance/categories';
  static const String budgetsUrl = '$baseUrl/finance/budgets';
  static const String goalsUrl = '$baseUrl/finance/goals';
  static const String investmentsUrl = '$baseUrl/finance/investments';
  static const String journalUrl = '$baseUrl/journal';
  static const String bugsUrl = '$baseUrl/bugs';
  static const String jobsUrl = '$baseUrl/jobs';
  static const String projectsUrl = '$baseUrl/projects';
  static const String habitsUrl = '$baseUrl/habits';
  static const String subscriptionsUrl = '$baseUrl/subscriptions';
  static const String inventoryUrl = '$baseUrl/inventory';
  static const String bookmarksUrl = '$baseUrl/bookmarks';
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String user = 'user_data';
  static const String theme = 'app_theme';
}

class AppColors {
  static const Color finance = Color(0xFF10B981);
  static const Color journal = Color(0xFF6366F1);
  static const Color bugs = Color(0xFFEF4444);
  static const Color jobs = Color(0xFF3B82F6);
  static const Color projects = Color(0xFF8B5CF6);
  static const Color habits = Color(0xFFF59E0B);
  static const Color subscriptions = Color(0xFFEC4899);
  static const Color inventory = Color(0xFF14B8A6);
  static const Color bookmarks = Color(0xFFF97316);
  static const Color dashboard = Color(0xFF64748B);
}
