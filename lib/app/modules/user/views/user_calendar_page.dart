import 'package:flutter/material.dart';

import '../../../data/models.dart';
import '../../../widgets/theme_toggle_action.dart';
import '../providers/user_provider.dart';

class UserCalendarPage extends StatelessWidget {
  const UserCalendarPage({super.key, required this.provider});

  final UserProvider provider;

  List<DateTime> _daysInMonth(DateTime date) {
    final first = DateTime(date.year, date.month, 1);
    final next = DateTime(date.year, date.month + 1, 1);
    return List.generate(
      next.difference(first).inDays,
      (i) => DateTime(date.year, date.month, i + 1),
    );
  }

  Map<String, List<JournalEntry>> _groupEntries(List<JournalEntry> entries) {
    final Map<String, List<JournalEntry>> map = {};
    for (final e in entries) {
      final key =
          '${e.timestamp.year}-${e.timestamp.month.toString().padLeft(2, '0')}-${e.timestamp.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = _daysInMonth(now);
    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) {
        final entries = provider.entries;
        final grouped = _groupEntries(entries);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kalender Riwayat'),
            backgroundColor: Colors.indigo,
            actions: const [ThemeToggleAction()],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  'Bulan: ${now.month}/${now.year}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    itemCount: days.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                    itemBuilder: (c, i) {
                      final d = days[i];
                      final key =
                          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                      final has = grouped.containsKey(key);
                      final dayEntries = grouped[key] ?? [];
                      return GestureDetector(
                        onTap: has
                            ? () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) {
                                    return ListView(
                                      padding: const EdgeInsets.all(12),
                                      children: dayEntries
                                          .map(
                                            (e) => ListTile(
                                              leading: CircleAvatar(
                                                child: Text(
                                                  e.mood.isNotEmpty
                                                      ? e.mood[0]
                                                      : 'M',
                                                ),
                                              ),
                                              title: Text(
                                                '${e.mood} • Stress ${e.stressLevel}/10',
                                              ),
                                              subtitle: Text(
                                                e.note.isEmpty
                                                    ? '(tidak ada catatan)'
                                                    : e.note,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    );
                                  },
                                );
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: has
                                ? Colors.teal.withOpacity(0.9)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${d.day}',
                                  style: TextStyle(
                                    color: has ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (has) const SizedBox(height: 6),
                                if (has)
                                  const Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
