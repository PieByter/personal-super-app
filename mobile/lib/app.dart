import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'data/theme_service.dart';
import 'data/app_localizations.dart';
import 'data/connectivity_service.dart';

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
                  builder: (context, child) {
                    return Column(
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: ConnectivityService().isOnline,
                          builder: (context, online, _) {
                            if (online) return const SizedBox.shrink();
                            return Material(
                              color: Colors.orange.shade800,
                              child: SafeArea(
                                bottom: false,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 12,
                                  ),
                                  child: const Text(
                                    'Offline — data may not sync',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Expanded(child: child ?? const SizedBox.shrink()),
                      ],
                    );
                  },
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
