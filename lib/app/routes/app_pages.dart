import 'package:flutter/material.dart';

import '../data/models.dart';
import '../modules/auth/auth_pages.dart';
import '../modules/psikolog/psikolog_pages.dart';
import '../modules/user/user_pages.dart';
import 'app_routes.dart';

class AppPages {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return _materialRoute(const LoginPage(), settings);
      case AppRoutes.register:
        return _materialRoute(const RegisterPage(), settings);
      case AppRoutes.home:
        final user = settings.arguments;
        if (user is User) {
          if (UserRole.isPsychologist(user.role)) {
            return _materialRoute(
              psikologHomePage(username: user.username),
              settings,
            );
          }
          return _materialRoute(UserHomePage(user: user), settings);
        }
        return _materialRoute(const LoginPage(), settings);
      case AppRoutes.psikologHome:
        final username = settings.arguments;
        if (username is String) {
          return _materialRoute(psikologHomePage(username: username), settings);
        }
        return _materialRoute(const LoginPage(), settings);
      default:
        return _materialRoute(const LoginPage(), settings);
    }
  }

  static Route<dynamic> _materialRoute(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
