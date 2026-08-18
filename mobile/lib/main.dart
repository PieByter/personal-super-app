import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/router.dart';
import 'data/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // When the API returns 401 (expired/invalid token), clear the session
  // and redirect the user to the login screen.
  ApiService().onUnauthorized = () {
    AppRouter.goToLogin();
  };

  runApp(const PersonalSuperApp());
}
