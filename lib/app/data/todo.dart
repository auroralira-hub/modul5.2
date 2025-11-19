import 'package:hive/hive.dart';

class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
  });

  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  Todo copyWith({
    String? id,
    String? title,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TodoAdapter extends TypeAdapter<Todo> {
  static const int kTypeId = 0;

  @override
  int get typeId => kTypeId;

  @override
  Todo read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final isDone = reader.readBool();
    final createdAtMillis = reader.readInt();
    return Todo(
      id: id,
      title: title,
      isDone: isDone,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..writeBool(obj.isDone)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
