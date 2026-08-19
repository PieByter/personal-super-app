import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/router.dart';
import 'data/api_service.dart';
import 'data/theme_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Restore persisted theme preference before the app builds.
  ThemeService().init();

  // When the API returns 401 (expired/invalid token), clear the session
  // and redirect the user to the login screen.
  ApiService().onUnauthorized = () {
    AppRouter.goToLogin();
  };

  runApp(const PersonalSuperApp());
}
