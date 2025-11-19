import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/todo.dart';

class TodoService {
  static const String boxName = 'todosBox';

  static Future<void> ensureInitialized() async {
    if (!Hive.isAdapterRegistered(TodoAdapter.kTypeId)) {
      Hive.registerAdapter(TodoAdapter());
    }
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Todo>(boxName);
    }
  }

  static Box<Todo> get _box => Hive.box<Todo>(boxName);

  static ValueListenable<Box<Todo>> listenable() => _box.listenable();

  static List<Todo> getTodos() => _box.values.toList()
    ..sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

  static Future<void> addTodo(String title) async {
    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      isDone: false,
      createdAt: DateTime.now(),
    );
    await _box.put(todo.id, todo);
  }

  static Future<void> toggleTodo(String id) async {
    final todo = _box.get(id);
    if (todo == null) return;
    await _box.put(id, todo.copyWith(isDone: !todo.isDone));
  }

  static Future<void> deleteTodo(String id) => _box.delete(id);
}
