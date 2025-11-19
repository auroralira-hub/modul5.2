import '../../../data/in_memory_service.dart';
import '../../../data/models.dart';

class HomeController {
  /// Mengembalikan daftar entri untuk username (selalu non-null, paling tidak empty list)
  List<JournalEntry> entriesFor(String username) =>
      InMemoryService.entriesFor(username);

  /// Simpan entri (delegasi ke AuthService in-memory)
  void saveEntry(JournalEntry entry) => InMemoryService.saveEntry(entry);

  /// Ambil semua user (untuk view dosen)
  List<User> getAllUsers() => InMemoryService.getAllUsers();
}
