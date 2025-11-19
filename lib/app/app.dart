import 'package:flutter/material.dart';

import 'core/navigation/app_route_observer.dart';
import 'core/theme/theme_controller.dart';
import 'data/models.dart';
import 'pages/auth/auth_pages.dart';
import 'pages/dosen/dosen_pages.dart';
import 'pages/user/user_pages.dart';
import 'routes/app_pages.dart';

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({
    super.key,
    required this.themeController,
    this.initialUser,
  });

  final ThemeController themeController;
  final User? initialUser;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final Widget homeWidget = _resolveHome();
        return MaterialApp(
          title: 'MoodTracker & Stress Level',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          ),
          themeMode: themeController.themeMode,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [appRouteObserver],
          home: homeWidget,
          onGenerateRoute: AppPages.onGenerateRoute,
        );
      },
    );
  }

  Widget _resolveHome() {
    if (initialUser == null) {
      return const LoginPage();
    }
    if (initialUser!.username == 'Rofika') {
      return DosenHomePage(username: initialUser!.username);
    }
    return UserHomePage(user: initialUser!);
  }
}
