import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../data/in_memory_service.dart';
import '../../../data/models.dart';
import '../../../services/network_service.dart';
import '../../../services/offline_queue_service.dart';
import '../../../services/supabase_services.dart';

class MissingSupabaseUserIdException implements Exception {
  const MissingSupabaseUserIdException([
    this.message = 'ID Supabase tidak ditemukan, entri hanya tersimpan lokal.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class UserController {
  UserController({SupabaseEntriesService? entriesService})
    : _entriesService = entriesService ?? const SupabaseEntriesService(),
      _offlineQueue = OfflineQueueService(
        entriesService ?? const SupabaseEntriesService(),
      );

  final SupabaseEntriesService _entriesService;
  final OfflineQueueService _offlineQueue;

  List<JournalEntry> fetchEntries(String username) =>
      InMemoryService.entriesFor(username);

  Future<void> saveEntry({
    required User user,
    required JournalEntry entry,
    bool syncRemote = true,
  }) async {
    InMemoryService.saveEntry(entry);

    if (!syncRemote) return;

    final hasNetwork = await NetworkService.hasConnection();
    final supabaseId = (user.supabaseUserId?.isNotEmpty ?? false)
        ? user.supabaseUserId
        : supa.Supabase.instance.client.auth.currentUser?.id;

    if (!hasNetwork || supabaseId == null || supabaseId.isEmpty) {
      await _offlineQueue.enqueue(entry);
      throw const MissingSupabaseUserIdException(
        'Offline: entri disimpan lokal dan akan disinkronkan saat online.',
      );
    }

    await _entriesService.saveEntry(userId: supabaseId, entry: entry);
    await _offlineQueue.flush(username: user.username, userId: supabaseId);
  }

  Future<void> syncWithCloud(User user) async {
    final hasNetwork = await NetworkService.hasConnection();
    if (!hasNetwork) return;
    final supabaseId = (user.supabaseUserId?.isNotEmpty ?? false)
        ? user.supabaseUserId
        : supa.Supabase.instance.client.auth.currentUser?.id;
    if (supabaseId == null || supabaseId.isEmpty) return;

    await _offlineQueue.flush(username: user.username, userId: supabaseId);
    final remoteEntries = await _entriesService.fetchEntries(user.username);
    InMemoryService.replaceEntries(user.username, remoteEntries);
  }
}
