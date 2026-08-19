import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

/// Simple app localization with Indonesian and English.
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('id')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isIndonesian => locale.languageCode == 'id';

  String get appTitle => _t('appTitle');
  String get settings => _t('settings');
  String get profile => _t('profile');
  String get darkMode => _t('darkMode');
  String get accentColor => _t('accentColor');
  String get biometric => _t('biometric');
  String get pushNotifications => _t('pushNotifications');
  String get exportData => _t('exportData');
  String get signOut => _t('signOut');
  String get dashboard => _t('dashboard');
  String get finance => _t('finance');
  String get journal => _t('journal');
  String get bugTracker => _t('bugTracker');
  String get jobTracker => _t('jobTracker');
  String get projects => _t('projects');
  String get habits => _t('habits');
  String get subscriptions => _t('subscriptions');
  String get inventory => _t('inventory');
  String get bookmarks => _t('bookmarks');

  String _t(String key) {
    final map = isIndonesian ? _id : _en;
    return map[key] ?? key;
  }

  static const _en = {
    'appTitle': 'Personal Super App',
    'settings': 'Settings',
    'profile': 'Profile',
    'darkMode': 'Dark Mode',
    'accentColor': 'Accent Color',
    'biometric': 'Biometric Authentication',
    'pushNotifications': 'Push Notifications',
    'exportData': 'Export Data',
    'signOut': 'Sign Out',
    'dashboard': 'Dashboard',
    'finance': 'Finance',
    'journal': 'Journal',
    'bugTracker': 'Bug Tracker',
    'jobTracker': 'Job Tracker',
    'projects': 'Projects',
    'habits': 'Habits',
    'subscriptions': 'Subscriptions',
    'inventory': 'Inventory',
    'bookmarks': 'Bookmarks',
  };

  static const _id = {
    'appTitle': 'Aplikasi Super Pribadi',
    'settings': 'Pengaturan',
    'profile': 'Profil',
    'darkMode': 'Mode Gelap',
    'accentColor': 'Warna Aksen',
    'biometric': 'Autentikasi Biometrik',
    'pushNotifications': 'Notifikasi Push',
    'exportData': 'Ekspor Data',
    'signOut': 'Keluar',
    'dashboard': 'Dasbor',
    'finance': 'Keuangan',
    'journal': 'Jurnal',
    'bugTracker': 'Pelacak Bug',
    'jobTracker': 'Pelacak Lamaran',
    'projects': 'Proyek',
    'habits': 'Kebiasaan',
    'subscriptions': 'Langganan',
    'inventory': 'Inventaris',
    'bookmarks': 'Penanda',
  };
}

/// Persists the language preference.
class LocaleService {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(StorageKeys.locale);
    locale.value = saved == 'id' ? const Locale('id') : const Locale('en');
  }

  Future<void> setLocale(Locale value) async {
    locale.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.locale, value.languageCode);
  }
}
