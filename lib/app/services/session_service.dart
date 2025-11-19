import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../data/models.dart';

class SessionService {
  SessionService._();

  static const String _boxName = 'session_box';
  static const String _key = 'last_logged_in_user';
  static Box<dynamic>? _box;

  static Future<void> init() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
  }

  static Future<void> saveUser(User user) async {
    final box = _box ?? await Hive.openBox<dynamic>(_boxName);
    await box.put(_key, user.toJson());
  }

  static Future<User?> loadUser() async {
    final box = _box ?? await Hive.openBox<dynamic>(_boxName);
    final data = box.get(_key);
    if (data == null) return null;
    try {
      if (data is Map) {
        return User.fromJson(Map<String, dynamic>.from(data as Map));
      }
      if (data is String) {
        return User.fromJson(jsonDecode(data) as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<void> clear() async {
    final box = _box ?? await Hive.openBox<dynamic>(_boxName);
    await box.delete(_key);
  }
}
