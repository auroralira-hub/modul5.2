import 'package:flutter/foundation.dart';

import '../../../data/models.dart';
import '../controllers/user_controller.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({required this.user, UserController? controller})
    : _controller = controller ?? UserController() {
    refreshEntries();
    _syncFromCloud();
  }

  final User user;
  final UserController _controller;

  List<JournalEntry> _entries = const [];
  bool _saving = false;
  bool _syncing = false;

  List<JournalEntry> get entries => List.unmodifiable(_entries);
  bool get isSaving => _saving;
  bool get isSyncing => _syncing;

  void refreshEntries() {
    _entries = _controller.fetchEntries(user.username);
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
    _saving = true;
    notifyListeners();
    try {
      await _controller.saveEntry(user: user, entry: entry);
    } finally {
      _entries = _controller.fetchEntries(user.username);
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> addDraft(JournalEntry entry) async {
    await _controller.saveEntry(user: user, entry: entry, syncRemote: false);
    _entries = _controller.fetchEntries(user.username);
    notifyListeners();
  }

  Future<void> refreshFromCloud() => _syncFromCloud();

  Future<void> _syncFromCloud() async {
    _syncing = true;
    notifyListeners();
    try {
      await _controller.syncWithCloud(user);
      _entries = _controller.fetchEntries(user.username);
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }
}
