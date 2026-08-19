import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'data/theme_service.dart';
import 'data/app_localizations.dart';

class PersonalSuperApp extends StatelessWidget {
  const PersonalSuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().mode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: ThemeService().accentColor,
          builder: (context, accent, _) {
            return ValueListenableBuilder<Locale>(
              valueListenable: LocaleService().locale,
              builder: (context, locale, _) {
                return MaterialApp.router(
                  title: 'Personal Super App',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme(accent),
                  darkTheme: AppTheme.darkTheme(accent),
                  themeMode: mode,
                  locale: locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    _AppLocalizationsDelegate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routerConfig: AppRouter.router,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.contains(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
