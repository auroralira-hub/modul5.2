import 'package:flutter/material.dart';

import '../data/models.dart';
import '../pages/auth/auth_pages.dart';
import '../pages/dosen/dosen_pages.dart';
import '../pages/user/user_pages.dart';
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
          return _materialRoute(UserHomePage(user: user), settings);
        }
        return _materialRoute(const LoginPage(), settings);
      case AppRoutes.dosenHome:
        final username = settings.arguments;
        if (username is String) {
          return _materialRoute(DosenHomePage(username: username), settings);
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
