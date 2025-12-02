import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../data/models.dart';
import '../../../data/todo.dart';
import '../../../routes/app_routes.dart';
import '../../../services/session_service.dart';
import '../../../services/supabase_services.dart';
import '../../../services/todo_service.dart';
import '../../../widgets/affirmations_widget.dart';
import '../../../widgets/theme_toggle_action.dart';
import '../controllers/user_controller.dart';
import '../providers/user_provider.dart';
import 'mood_gallery_page.dart';
import 'user_calendar_page.dart';
import 'user_education_controller.dart';
import 'user_location_controller.dart';
import 'user_profile_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key, required this.user});

  final User user;

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage>
    with TickerProviderStateMixin {
  int selectedMoodIndex = -1;
  int stressValue = 5;
  final _journalCtrl = TextEditingController();
  final _todoCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int _currentTabIndex = 0;
  bool _isAddingTodo = false;

  late AnimationController _mistController;
  late AnimationController _entranceController;
  late ScrollController _moodScrollController;
  late final UserProvider _provider;

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
      'name': 'Playful',
      'icon': Icons.emoji_emotions,
      'color': Colors.deepPurpleAccent,
    },
    {'name': 'Grateful', 'icon': Icons.favorite, 'color': Colors.redAccent},
    {
      'name': 'Relaxed',
      'icon': Icons.beach_access,
      'color': Colors.lightBlueAccent,
    },
    {'name': 'Motivated', 'icon': Icons.trending_up, 'color': Colors.green},
    {'name': 'Bored', 'icon': Icons.hourglass_empty, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _provider = UserProvider(user: widget.user);
    _mistController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _moodScrollController = ScrollController();
  }

  @override
  void dispose() {
    _mistController.dispose();
    _entranceController.dispose();
    _journalCtrl.dispose();
    _todoCtrl.dispose();
    _moodScrollController.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildHomePage(),
          UserEducationPage(user: widget.user),
          UserLocationPage(user: widget.user),
          UserProfilePage(user: widget.user),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5B4BFF),
        unselectedItemColor: const Color(0xFF9EA4B3),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_rounded),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, _) {
        final entries = _provider.entries;
        final width = MediaQuery.of(context).size.width;
        final isWide = width > 740;

        return Stack(
          children: [
            AnimatedBuilder(
              animation: _mistController,
              builder: (context, _) {
                final move = math.sin(_mistController.value * 2 * math.pi) * 40;
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                final gradientColors = isDark
                    ? const [Color(0xFF05060C), Color(0xFF0A0F1F)]
                    : const [Color(0xFFF7FAFF), Color(0xFFFFFBF6)];
                final blobA = isDark
                    ? const Color(0xFF7C4DFF).withOpacity(0.24)
                    : const Color(0xFFFFB6C1).withOpacity(0.25);
                final blobB = isDark
                    ? const Color(0xFF03DAC5).withOpacity(0.18)
                    : const Color(0xFF81D4FA).withOpacity(0.2);
                final blobC = isDark
                    ? const Color(0xFFFFAB91).withOpacity(0.2)
                    : const Color(0xFFA5D6A7).withOpacity(0.35);

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -120 + move,
                        left: -80,
                        child: _blob(260, blobA),
                      ),
                      Positioned(
                        bottom: -100 - move,
                        right: -60,
                        child: _blob(220, blobB),
                      ),
                      Positioned(
                        bottom: 120 + move,
                        left: 40,
                        child: _blob(140, blobC),
                      ),
                    ],
                  ),
                );
              },
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 12),
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _entranceController,
                        curve: Curves.easeOutBack,
                      ),
                      child: const AffirmationsWidget(),
                    ),
                    const SizedBox(height: 16),
                    _buildTodoSection(),
                    const SizedBox(height: 16),
                    _buildMoodJournalCard(isWide),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: isWide ? 2 : 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isWide ? 1.2 : 1.0,
                      children: [
                        _buildActionCard(
                          icon: Icons.calendar_today,
                          title: 'Kalender Mood',
                          description: 'Lihat riwayat mood bulanan',
                          color: Colors.orangeAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserCalendarPage(provider: _provider),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCard(entries),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home - ${widget.user.name}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selamat datang kembali, ${widget.user.username}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sinkronisasi Supabase',
            onPressed: _provider.isSyncing
                ? null
                : () {
                    _provider.refreshFromCloud();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sinkronisasi dimulai...')),
                    );
                  },
            icon: _provider.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_sync_rounded),
          ),
          ThemeToggleAction(iconColor: theme.colorScheme.primary),
          IconButton(
            tooltip: 'Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfilePage(user: widget.user),
                ),
              );
            },
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            tooltip: 'Keluar',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoSection() {
    final theme = Theme.of(context);
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.task_alt_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Daftar To-Do (Hive)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoCtrl,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTodo(),
                    decoration: InputDecoration(
                      hintText: 'Tambah to-do baru',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isAddingTodo ? null : _addTodo,
                  child: _isAddingTodo
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ValueListenableBuilder<Box<Todo>>(
              valueListenable: TodoService.listenable(),
              builder: (context, box, _) {
                final todos = box.values.toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                if (todos.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Belum ada to-do. Tambahkan tugas kecilmu di atas dan rasakan persistent storage Hive ketika aplikasi ditutup dan dibuka kembali.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todos.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 12,
                    color: Colors.grey.shade300,
                  ),
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: todo.isDone,
                        onChanged: (_) => _toggleTodo(todo),
                      ),
                      title: Text(
                        todo.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: todo.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: todo.isDone
                              ? theme.colorScheme.primary.withOpacity(0.7)
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        'Dibuat ${_formatTodoDate(todo.createdAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: IconButton(
                        tooltip: 'Hapus',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteTodo(todo),
                      ),
                      onTap: () => _toggleTodo(todo),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodJournalCard(bool isWide) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catat Mood Hari Ini',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tanggal ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Pilih tanggal',
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: Scrollbar(
                  controller: _moodScrollController,
                  thumbVisibility: true,
                  interactive: true,
                  child: ListView.separated(
                    controller: _moodScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: moods.length,
                    padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final mood = moods[index];
                      final selected = selectedMoodIndex == index;
                      final Color color = mood['color'] as Color;
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedMoodIndex = index);
                          _animateMoodTo(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 120,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: selected
                                  ? [color, color.withOpacity(0.72)]
                                  : [
                                      Colors.grey.shade200,
                                      Colors.grey.shade100,
                                    ],
                            ),
                            boxShadow: [
                              if (selected)
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                mood['icon'] as IconData,
                                color: selected ? Colors.white : Colors.grey.shade700,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mood['name'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Level Stress',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Slider(
                          min: 0,
                          max: 10,
                          divisions: 10,
                          value: stressValue.toDouble(),
                          label: '$stressValue',
                          onChanged: (v) => setState(() => stressValue = v.toInt()),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.indigo.shade50,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Nilai',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$stressValue/10',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _journalCtrl,
                maxLines: isWide ? 3 : 4,
                decoration: const InputDecoration(
                  hintText: 'Tulis catatan harian singkat...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _provider.isSaving ? null : _saveEntry,
                      icon: const Icon(Icons.save),
                      label: _provider.isSaving
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan Entri'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _openMoodGallery(initialIndex: selectedMoodIndex),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.grid_view),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(description, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<JournalEntry> entries) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Terbaru',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Text(
                  'Kosong - belum ada entri',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              )
            else ...[
              Text(
                '${entries.last.mood} • Stress ${entries.last.stressLevel}/10',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                entries.last.note.isEmpty ? '(tidak ada catatan)' : entries.last.note,
              ),
              const SizedBox(height: 8),
              const Divider(),
              const Text(
                'Riwayat singkat (terakhir 5 entri):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: math.min(5, entries.length),
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (c, i) {
                    final reversed = entries.reversed.toList();
                    final e = reversed[i];
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
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(e.mood),
                          content: Text('${e.note}\n\n${e.timestamp}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tutup'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _addTodo() async {
    final title = _todoCtrl.text.trim();
    if (title.isEmpty || _isAddingTodo) return;
    setState(() => _isAddingTodo = true);
    try {
      await TodoService.addTodo(title);
      _todoCtrl.clear();
    } finally {
      if (mounted) {
        setState(() => _isAddingTodo = false);
      } else {
        _isAddingTodo = false;
      }
    }
  }

  Future<void> _toggleTodo(Todo todo) => TodoService.toggleTodo(todo.id);

  Future<void> _deleteTodo(Todo todo) => TodoService.deleteTodo(todo.id);

  String _formatTodoDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  Future<void> _openMoodGallery({int initialIndex = 0}) async {
    final idx = await Navigator.push<int>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, sec) => FadeTransition(
          opacity: anim,
          child: MoodGalleryPage(moods: moods, initialIndex: initialIndex),
        ),
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
    if (idx != null) {
      setState(() => selectedMoodIndex = idx);
      _animateMoodTo(idx);
    }
  }

  void _animateMoodTo(int index) {
    const double itemExtent = 132;
    final target = math.max(0.0, itemExtent * index - 12);
    _moodScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  Future<void> _saveEntry() async {
    if (_provider.isSaving) return;
    final mood = selectedMoodIndex >= 0
        ? moods[selectedMoodIndex]['name'] as String
        : 'Unspecified';
    final entry = JournalEntry(
      username: widget.user.username,
      mood: mood,
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
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _provider.addEntry(entry);
      messenger.showSnackBar(
        const SnackBar(content: Text('Entri tersimpan ke Supabase')),
      );
    } on MissingSupabaseUserIdException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } on SupabaseEntriesServiceException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menyimpan ke Supabase: ${e.message}')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _logout() async {
    await SessionService.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  static Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );
}
