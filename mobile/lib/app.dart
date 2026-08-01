import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/router.dart';

class PersonalSuperApp extends StatelessWidget {
  const PersonalSuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Personal Super App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
