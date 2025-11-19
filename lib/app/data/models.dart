// Shared data models used across the app.

class User {
  final String? supabaseUserId;
  final String username;
  final String name;
  final int age;
  final String major;
  final String email;
  final String password;

  User({
    this.supabaseUserId,
    required this.username,
    required this.name,
    required this.age,
    required this.major,
    required this.email,
    required this.password,
  });

  User copyWith({
    String? supabaseUserId,
    String? username,
    String? name,
    int? age,
    String? major,
    String? email,
    String? password,
  }) {
    return User(
      supabaseUserId: supabaseUserId ?? this.supabaseUserId,
      username: username ?? this.username,
      name: name ?? this.name,
      age: age ?? this.age,
      major: major ?? this.major,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supabaseUserId': supabaseUserId,
      'username': username,
      'name': name,
      'age': age,
      'major': major,
      'email': email,
      'password': password,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      supabaseUserId: json['supabaseUserId'] as String?,
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: _parseInt(json['age']),
      major: json['major'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class JournalEntry {
  final String username;
  final String mood;
  final int stressLevel;
  final String note;
  final DateTime timestamp;

  JournalEntry({
    required this.username,
    required this.mood,
    required this.stressLevel,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'mood': mood,
      'stressLevel': stressLevel,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      username: json['username'] as String? ?? '',
      mood: json['mood'] as String? ?? '',
      stressLevel: json['stressLevel'] as int? ?? 0,
      note: json['note'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
