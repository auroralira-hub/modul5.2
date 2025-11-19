import 'models.dart';

/// Simple in-memory storage for demo purposes.
class InMemoryService {
  static final List<User> _users = [
    User(
      username: 'Rofika',
      name: 'Rofika (Dosen)',
      age: 40,
      major: 'Psikologi',
      email: 'rofika@univ.edu',
      password: 'rofika12',
    ),
    User(
      username: 'lira',
      name: 'Lira Aurora',
      age: 22,
      major: 'Teknik Informatika',
      email: 'lira@example.com',
      password: 'liralira',
    ),
  ];

  static final Map<String, List<JournalEntry>> _entries = {};

  static User? login(String username, String password) {
    try {
      return _users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  static bool register(User user) {
    if (_users.any((x) => x.username == user.username)) return false;
    _users.add(user);
    return true;
  }

  static User? getByUsername(String username) {
    try {
      return _users.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  static List<User> allUsers() => List.unmodifiable(_users);
  static List<User> getAllUsers() => allUsers();

  static List<JournalEntry> entriesFor(String username) =>
      List.unmodifiable(_entries[username] ?? []);

  static void saveEntry(JournalEntry entry) {
    final list = _entries.putIfAbsent(entry.username, () => []);
    list.add(entry);
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  static void replaceEntries(String username, List<JournalEntry> entries) {
    _entries[username] = List<JournalEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}
