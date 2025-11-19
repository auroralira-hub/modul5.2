import 'dart:math';
import 'package:flutter/material.dart';
import '../../../data/models.dart';
import '../controllers/home_controller.dart';

/// Contains UserHomePage, UserCalendarPage, DailyJournalPage, DosenHomePage, DosenViewUserProfileWithHistory.
/// Uses HomeController to read/save entries.

class UserHomePage extends StatefulWidget {
  final User user;
  final HomeController controller;
  const UserHomePage({super.key, required this.user, required this.controller});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage>
    with TickerProviderStateMixin {
  int selectedMoodIndex = -1;
  int stressValue = 5;
  final _journalCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();

  late AnimationController _floatController;
  late AnimationController _mistController;

  final List<Map<String, dynamic>> moods = [
    {
      'name': 'Happy',
      'icon': Icons.sentiment_very_satisfied,
      'color': Colors.orange,
    },
    {'name': 'Calm', 'icon': Icons.self_improvement, 'color': Colors.teal},
    {'name': 'Focused', 'icon': Icons.psychology, 'color': Colors.indigo},
    {
      'name': 'Sad',
      'icon': Icons.sentiment_dissatisfied,
      'color': Colors.blueGrey,
    },
    {'name': 'Tired', 'icon': Icons.bedtime, 'color': Colors.amber},
    {
      'name': 'Anxious',
      'icon': Icons.sentiment_neutral,
      'color': Colors.pinkAccent,
    },
    {
      'name': 'Excited',
      'icon': Icons.flash_on,
      'color': Colors.deepOrangeAccent,
    },
    {
      'name': 'Lonely',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Colors.purpleAccent,
    },
    {'name': 'Grateful', 'icon': Icons.favorite, 'color': Colors.redAccent},
    {'name': 'Motivated', 'icon': Icons.trending_up, 'color': Colors.green},
    {
      'name': 'Relaxed',
      'icon': Icons.beach_access,
      'color': Colors.lightBlueAccent,
    },
    {'name': 'Bored', 'icon': Icons.hourglass_empty, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _mistController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _mistController.dispose();
    _journalCtrl.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final moodName = (selectedMoodIndex >= 0)
        ? moods[selectedMoodIndex]['name'] as String
        : 'Unspecified';
    final entry = JournalEntry(
      username: widget.user.username,
      mood: moodName,
      stressLevel: stressValue,
      note: _journalCtrl.text.trim(),
      timestamp: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
      ),
    );
    widget.controller.saveEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entri tersimpan ke riwayat kalender')),
    );
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ignore: unused_element
  List<DateTime> _daysInMonth(DateTime date) {
    final first = DateTime(date.year, date.month, 1);
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final days = nextMonth.difference(first).inDays;
    return List.generate(days, (i) => DateTime(date.year, date.month, i + 1));
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final controller = widget.controller;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Home - ${widget.user.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Lihat profil',
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Profil Pengguna')),
                    body: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 46,
                            child: Text(
                              widget.user.name.isNotEmpty
                                  ? widget.user.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _mistController,
            builder: (context, _) {
              final move = sin(_mistController.value * 2 * pi) * 50;
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE0F7FA),
                      Color(0xFFFCE4EC),
                      Color(0xFFE3F2FD),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 120 + move,
                      left: 50 + move,
                      child: _buildMistBlob(200, Colors.tealAccent.shade100),
                    ),
                    Positioned(
                      bottom: 100 - move,
                      right: 40 - move,
                      child: _buildMistBlob(250, Colors.pink.shade100),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 100,
              left: 12,
              right: 12,
              bottom: 12,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columnCount = constraints.maxWidth < 600
                    ? 2
                    : constraints.maxWidth < 900
                    ? 3
                    : 4;
                // ignore: unused_local_variable
                final entries = controller.entriesFor(widget.user.username);

                return Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.emoji_people,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Catat Mood & Stress',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.indigo.shade700,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: _pickDate,
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: isLandscape ? 160 : 200,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: moods.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columnCount,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1,
                                  ),
                              itemBuilder: (context, i) {
                                final m = moods[i];
                                final isActive = selectedMoodIndex == i;
                                return GestureDetector(
                                  onTap: () => setState(
                                    () => selectedMoodIndex = isActive ? -1 : i,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        isActive ? 20 : 12,
                                      ),
                                      gradient: isActive
                                          ? LinearGradient(
                                              colors: [
                                                m['color'] as Color,
                                                (m['color'] as Color).withAlpha(
                                                  180,
                                                ),
                                              ],
                                            )
                                          : LinearGradient(
                                              colors: [
                                                (m['color'] as Color).withAlpha(
                                                  80,
                                                ),
                                                Colors.white,
                                              ],
                                            ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (m['color'] as Color)
                                              .withAlpha(isActive ? 120 : 40),
                                          blurRadius: isActive ? 20 : 6,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            m['icon'] as IconData,
                                            size: isActive ? 36 : 28,
                                            color: isActive
                                                ? Colors.white
                                                : (m['color'] as Color),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            m['name'] as String,
                                            style: TextStyle(
                                              color: isActive
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.w600,
                                              fontSize: isActive ? 14 : 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Stress level: $stressValue',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Slider(
                            value: stressValue.toDouble(),
                            min: 0,
                            max: 10,
                            divisions: 10,
                            label: stressValue.toString(),
                            onChanged: (v) =>
                                setState(() => stressValue = v.round()),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _journalCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Tulis catatan harian singkat...',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _saveEntry,
                                icon: const Icon(Icons.save),
                                label: const Text('Simpan ke Kalender'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DailyJournalPage(
                                        initialText: _journalCtrl.text,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.note),
                                label: const Text('Buka Jurnal'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => UserCalendarPage(
                                        username: widget.user.username,
                                        controller: controller,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Lihat Kalender Riwayat'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Terbaru',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildLatestEntryPreview(),
                            const SizedBox(height: 12),
                            const Text(
                              'Riwayat singkat (terakhir 5 entri):',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Expanded(child: _buildRecentList()),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestEntryPreview() {
    final entries = widget.controller.entriesFor(widget.user.username);
    if (entries.isEmpty) {
      return Text(
        'Belum ada entri. Silakan catat mood dan jurnal harian.',
        style: TextStyle(color: Colors.grey.shade700),
      );
    }
    final last = entries.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${last.mood} • Stress ${last.stressLevel}/10',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(last.note.isEmpty ? '(tidak ada catatan)' : last.note),
        const SizedBox(height: 6),
        Text(
          'Pada: ${last.timestamp.day}/${last.timestamp.month}/${last.timestamp.year} ${last.timestamp.hour}:${last.timestamp.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildRecentList() {
    final entries = widget.controller
        .entriesFor(widget.user.username)
        .reversed
        .toList();
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'Kosong - belum ada entri',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }
    final toShow = entries.take(5).toList();
    return ListView.separated(
      itemCount: toShow.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, i) {
        final e = toShow[i];
        return ListTile(
          leading: CircleAvatar(
            child: Text(e.mood.isNotEmpty ? e.mood[0] : 'M'),
          ),
          title: Text('${e.mood} • Stress ${e.stressLevel}/10'),
          subtitle: Text(
            e.note.isEmpty ? '(tidak ada catatan)' : e.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text('${e.timestamp.day}/${e.timestamp.month}'),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text('${e.mood} • ${e.stressLevel}/10'),
                  content: Text('${e.note}\n\n${e.timestamp}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMistBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withAlpha(100), Colors.transparent],
        ),
      ),
    );
  }
}

class UserCalendarPage extends StatelessWidget {
  final String username;
  final HomeController controller;
  const UserCalendarPage({
    super.key,
    required this.username,
    required this.controller,
  });

  List<DateTime> _daysInMonth(DateTime date) {
    final first = DateTime(date.year, date.month, 1);
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final days = nextMonth.difference(first).inDays;
    return List.generate(days, (i) => DateTime(date.year, date.month, i + 1));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthDays = _daysInMonth(now);
    final Map<String, List<JournalEntry>> entries = {};
    final userList = controller.entriesFor(username);

    for (var e in userList) {
      final key =
          '${e.timestamp.year}-${e.timestamp.month.toString().padLeft(2, '0')}-${e.timestamp.day.toString().padLeft(2, '0')}';
      entries.putIfAbsent(key, () => []).add(e);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Riwayat'),
        backgroundColor: Colors.indigo,
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
                itemCount: monthDays.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, i) {
                  final d = monthDays[i];
                  final key =
                      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                  final has = entries.containsKey(key);
                  final list = entries[key] ?? [];
                  return GestureDetector(
                    onTap: has
                        ? () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return ListView(
                                  padding: const EdgeInsets.all(12),
                                  children: list.map((e) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          e.mood.isNotEmpty ? e.mood[0] : 'M',
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
                                    );
                                  }).toList(),
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
  }
}

class DailyJournalPage extends StatelessWidget {
  final String initialText;
  const DailyJournalPage({super.key, this.initialText = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.shade50,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text("My Daily Journal"),
      ),
      body: Center(
        child: Hero(
          tag: "dailyJournal",
          child: Container(
            width: 320,
            height: 380,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4DD0E1), Color(0xFF26C6DA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  const Text(
                    "✨ Write your thoughts here ✨",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Mulai menulis...',
                      ),
                      controller: TextEditingController(text: initialText),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Selesai'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Dosen Home ----------------

class DosenHomePage extends StatefulWidget {
  final String username;
  final HomeController controller;
  const DosenHomePage({
    super.key,
    required this.username,
    required this.controller,
  });

  @override
  State<DosenHomePage> createState() => _DosenHomePageState();
}

class _DosenHomePageState extends State<DosenHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = widget.controller.getAllUsers();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Dosen - ${widget.username}'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizeTransition(
              sizeFactor: CurvedAnimation(parent: _anim, curve: Curves.easeOut),
              axisAlignment: -1,
              child: Card(
                color: Colors.deepPurple.shade50,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Icon(
                      Icons.monitor_heart,
                      color: Colors.deepPurple,
                    ),
                  ),
                  title: const Text('Monitoring Mahasiswa'),
                  subtitle: Text('Jumlah terdaftar: ${users.length}'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada mahasiswa terdaftar',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, i) {
                        final u = users[i];
                        final count = widget.controller
                            .entriesFor(u.username)
                            .length;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                u.name.isNotEmpty
                                    ? u.name[0].toUpperCase()
                                    : 'U',
                              ),
                            ),
                            title: Text(u.name),
                            subtitle: Text(
                              '${u.major} • ${u.age} tahun • entri: $count',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DosenViewUserProfileWithHistory(
                                          user: u,
                                          controller: widget.controller,
                                        ),
                                  ),
                                );
                              },
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
  }
}

class DosenViewUserProfileWithHistory extends StatelessWidget {
  final User user;
  final HomeController controller;
  const DosenViewUserProfileWithHistory({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final entries = controller.entriesFor(user.username);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 46,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(label: 'Username', value: user.username),
                    InfoRow(label: 'Nama', value: user.name),
                    InfoRow(label: 'Usia', value: '${user.age}'),
                    InfoRow(label: 'Jurusan', value: user.major),
                    InfoRow(label: 'Email', value: user.email),
                    InfoRow(label: 'Jumlah Entri', value: '${entries.length}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Riwayat Entri:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada entri',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final e = entries[i];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(e.mood.isNotEmpty ? e.mood[0] : 'M'),
                          ),
                          title: Text('${e.mood} • Stress ${e.stressLevel}/10'),
                          subtitle: Text(
                            e.note.isEmpty ? '(tidak ada catatan)' : e.note,
                          ),
                          trailing: Text(
                            '${e.timestamp.day}/${e.timestamp.month}/${e.timestamp.year}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// small helper widget reused in several views
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
