import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';
import 'supabase_services.dart';

class OfflineQueueService {
  OfflineQueueService(this._entriesService);

  final SupabaseEntriesService _entriesService;
  static const String _prefsKey = 'offline_pending_entries';

  Future<void> enqueue(JournalEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_prefsKey) ?? <String>[];
    final updated = List<String>.from(existing)
      ..add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_prefsKey, updated);
  }

  Future<void> flush({required String username, required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_prefsKey) ?? <String>[];
    final remaining = <String>[];
    for (final raw in existing) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        if ((map['username'] as String?) != username) {
          remaining.add(raw);
          continue;
        }
        final entry = JournalEntry.fromJson(map);
        await _entriesService.saveEntry(userId: userId, entry: entry);
      } catch (_) {
        remaining.add(raw);
      }
    }
    await prefs.setStringList(_prefsKey, remaining);
  }

  Future<List<JournalEntry>> pendingEntries(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_prefsKey) ?? <String>[];
    final entries = <JournalEntry>[];
    for (final raw in existing) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        if ((map['username'] as String?) == username) {
          entries.add(JournalEntry.fromJson(map));
        }
      } catch (_) {
        continue;
      }
    }
    return entries;
  }
}
