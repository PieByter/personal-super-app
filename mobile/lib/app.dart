import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'data/theme_service.dart';

class PersonalSuperApp extends StatelessWidget {
  const PersonalSuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().mode,
      builder: (context, mode, _) {
        return MaterialApp.router(
          title: 'Personal Super App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
