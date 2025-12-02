import 'dart:math' as math;
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import '../../../data/models.dart';
import '../providers/user_provider.dart';
import 'user_calendar_page.dart';
import 'user_profile_page.dart';
import 'user_education_controller.dart';
import 'user_location_controller.dart';

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
  DateTime selectedDate = DateTime.now();
  int _currentTabIndex = 0;
  
  // Affirmation state
  String _affirmation = 'Loading...';
  bool _isLoadingAffirmation = true;
  Timer? _affirmationTimer;

  late AnimationController _entranceController;
  late final UserProvider _provider;
  
  // Pages untuk setiap tab
  late final List<Widget> _pages;

  final List<Map<String, dynamic>> moods = [
    {'name': 'Lelah', 'emoji': '😩', 'color': const Color(0xFFFFB74D)},
    {'name': 'Marah', 'emoji': '😠', 'color': const Color(0xFFFF7043)},
    {'name': 'Senang', 'emoji': '😊', 'color': const Color(0xFF66BB6A)},
    {'name': 'Sedih', 'emoji': '😢', 'color': const Color(0xFF42A5F5)},
    {'name': 'Cemas', 'emoji': '😰', 'color': const Color(0xFF9575CD)},
    {'name': 'Bersyukur', 'emoji': '🙏', 'color': const Color(0xFFFFA726)},
  ];

  @override
  void initState() {
    super.initState();
    _provider = UserProvider(user: widget.user);
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    
    // Tampilkan cache dulu agar instan, lalu fetch update di background
    _loadCachedAffirmation().then((_) => _fetchAffirmation());
    // Auto refresh affirmation setiap 30 detik
    _affirmationTimer =
      Timer.periodic(const Duration(seconds: 30), (_) => _fetchAffirmation());
    
    // Initialize pages untuk setiap tab
    _pages = [
      _buildHomePage(), // Tab Home
      UserEducationPage(user: widget.user), // Tab Edukasi
      UserLocationPage(user: widget.user), // Tab Lokasi
      UserProfilePage(user: widget.user), // Tab Profil
    ];
  }
  
  Future<void> _fetchAffirmation() async {
    setState(() => _isLoadingAffirmation = true);
    Future<http.Response> _doRequest() {
      return http
          .get(
            Uri.parse('https://www.affirmations.dev/'),
            headers: const {'accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 4));
    }

    try {
      http.Response response;
      try {
        response = await _doRequest();
      } on TimeoutException {
        // one quick retry on timeout
        response = await _doRequest();
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = (data['affirmation'] as String?)?.trim();
        if (text != null && text.isNotEmpty) {
          setState(() {
            _affirmation = text;
            _isLoadingAffirmation = false;
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('affirmation:last_text', _affirmation);
          await prefs.setString(
              'affirmation:last_time', DateTime.now().toIso8601String());
          return;
        }
      }

      // graceful fallback, keep current text if any
      setState(() {
        if (_affirmation.trim().isEmpty || _affirmation == 'Loading...') {
          _affirmation = 'You are capable of great things!';
        }
        _isLoadingAffirmation = false;
      });
    } catch (_) {
      setState(() {
        // keep whatever is currently shown, fallback if empty
        if (_affirmation.trim().isEmpty || _affirmation == 'Loading...') {
          _affirmation = 'Believe in yourself and all that you are!';
        }
        _isLoadingAffirmation = false;
      });
    }
  }

  Future<void> _loadCachedAffirmation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('affirmation:last_text');
      if (cached != null && cached.trim().isNotEmpty) {
        setState(() {
          _affirmation = cached;
          _isLoadingAffirmation = false;
        });
      } else {
        setState(() {
          _affirmation = 'You are amazing!';
          _isLoadingAffirmation = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingAffirmation = false);
    }
  }

  @override
  void dispose() {
    _affirmationTimer?.cancel();
    _entranceController.dispose();
    _journalCtrl.dispose();
    _provider.dispose();
    super.dispose();
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
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: _currentTabIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() => _currentTabIndex = index);
        },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF7C3AED),
            unselectedItemColor: const Color(0xFF9CA3AF),
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF7C3AED),
              onPressed: _saveEntry,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
  
  Widget _buildHomePage() {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, _) {
        final entries = _provider.entries;
        
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAffirmationCard(),
                const SizedBox(height: 16),
                _buildMoodCard(),
                const SizedBox(height: 16),
                _buildJournalCard(),
                const SizedBox(height: 16),
                _buildHistoryList(entries),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAffirmationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF9F7AEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Daily Affirmation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Auto refresh berjalan tiap 30 detik, dan tombol manual tersedia
              IconButton(
                tooltip: 'Refresh',
                onPressed: _isLoadingAffirmation ? null : _fetchAffirmation,
                icon: _isLoadingAffirmation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _affirmation,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mood Hari Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                '${selectedDate.day} Nov ${selectedDate.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: moods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final mood = moods[index];
                final selected = selectedMoodIndex == index;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => selectedMoodIndex = index),
                    borderRadius: BorderRadius.circular(16),
                    splashColor: (mood['color'] as Color).withOpacity(0.3),
                    highlightColor: (mood['color'] as Color).withOpacity(0.2),
                    child: Ink(
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected 
                            ? (mood['color'] as Color).withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? (mood['color'] as Color)
                              : const Color(0xFFE5E7EB),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mood['emoji'] as String,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mood['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? (mood['color'] as Color)
                                  : const Color(0xFF6B7280),
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
        ],
      ),
    );
  }

  Widget _buildJournalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jurnal Harian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _journalCtrl,
            maxLines: 4,
            style: const TextStyle(color: Color(0xFF111827)),
            cursorColor: Color(0xFF7C3AED),
            decoration: InputDecoration(
              hintText: 'Ceritakan tentang hari Anda...',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  _provider.isSaving || selectedMoodIndex == -1 ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _provider.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.send, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Simpan Jurnal',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<JournalEntry> entries) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Mood',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserCalendarPage(provider: _provider),
                    ),
                  );
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada riwayat mood',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: math.min(5, entries.length),
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final reversed = entries.reversed.toList();
                final entry = reversed[index];
                final moodData = moods.firstWhere(
                  (m) => m['name'] == entry.mood,
                  orElse: () => moods[0],
                );
                final now = DateTime.now();
                final diff = now.difference(entry.timestamp);
                String timeAgo;
                if (diff.inHours < 1) {
                  timeAgo = '${diff.inMinutes} menit lalu';
                } else if (diff.inHours < 24) {
                  timeAgo = '${diff.inHours} jam lalu';
                } else {
                  timeAgo = '${diff.inDays} hari lalu';
                }

                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(entry.mood),
                        content: Text(
                          '${entry.note}\n\n${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: (moodData['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            moodData['emoji'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.note.isEmpty
                                  ? entry.mood
                                  : entry.note.length > 30
                                      ? '${entry.note.substring(0, 30)}...'
                                      : entry.note,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${entry.timestamp.day} Nov ${entry.timestamp.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
