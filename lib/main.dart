import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'app/app.dart';
import 'app/core/theme/theme_controller.dart';
import 'app/data/models.dart';
import 'app/services/session_service.dart';
import 'app/services/todo_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw StateError(
      'Supabase credentials are missing. Please set SUPABASE_URL and SUPABASE_ANON_KEY in the .env file.',
    );
  }

  await Hive.initFlutter();
  await TodoService.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  themeController = ThemeController(prefs);
  await SessionService.init();

  await supa.Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  final User? lastUser = await SessionService.loadUser();
  runApp(
    MoodTrackerApp(themeController: themeController, initialUser: lastUser),
  );
}
