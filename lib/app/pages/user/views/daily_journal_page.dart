import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models.dart';
import '../../../services/supabase_services.dart';
import '../../../widgets/theme_toggle_action.dart';
import '../controllers/user_controller.dart';
import '../providers/user_provider.dart';

class DailyJournalPage extends StatefulWidget {
  const DailyJournalPage({
    super.key,
    required this.user,
    required this.provider,
    this.initialText = '',
    this.initialStress = 5,
    this.initialMoodIndex,
  });

  final User user;
  final UserProvider provider;
  final String initialText;
  final int initialStress;
  final int? initialMoodIndex;

  @override
  State<DailyJournalPage> createState() => _DailyJournalPageState();
}

class _DailyJournalPageState extends State<DailyJournalPage>
    with TickerProviderStateMixin {
  late TextEditingController _ctrl;
  late AnimationController _bgController;
  late AnimationController _floatController;
  late AnimationController _saveAnimController;

  int _stress = 5;
  int? _selectedMood;
  Color _paperColor = Colors.white;
  bool _saving = false;
  Timer? _autoSaveTimer;

  final List<Map<String, dynamic>> _moods = [
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
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
    _stress = widget.initialStress;
    _selectedMood = widget.initialMoodIndex;

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _saveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _autoSaveTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (!mounted) return;
      _autoSaveDraft();
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _ctrl.dispose();
    _bgController.dispose();
    _floatController.dispose();
    _saveAnimController.dispose();
    super.dispose();
  }

  Future<void> _autoSaveDraft() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final draftEntry = JournalEntry(
      username: widget.user.username,
      mood: _selectedMood != null
          ? _moods[_selectedMood!]['name'] as String
          : 'Draft',
      stressLevel: _stress,
      note: '$text (draft)',
      timestamp: DateTime.now(),
    );
    try {
      await widget.provider.addDraft(draftEntry);
    } catch (_) {}
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);
    _saveAnimController.forward(from: 0);
    final text = _ctrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Isi jurnal sebelum menyimpan.')),
      );
      setState(() => _saving = false);
      return;
    }

    final entry = JournalEntry(
      username: widget.user.username,
      mood: _selectedMood != null
          ? _moods[_selectedMood!]['name'] as String
          : 'Unspecified',
      stressLevel: _stress,
      note: text,
      timestamp: DateTime.now(),
    );

    try {
      await widget.provider.addEntry(entry);
      messenger.showSnackBar(
        const SnackBar(content: Text('Entri jurnal tersimpan ke Supabase')),
      );
      _ctrl.clear();
      setState(() {
        _stress = 5;
        _selectedMood = null;
        _paperColor = Colors.white;
      });
    } on MissingSupabaseUserIdException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } on SupabaseEntriesServiceException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menyimpan ke Supabase: ${e.message}')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradient = isDark
        ? const [Color(0xFF03060F), Color(0xFF111A2C)]
        : const [Color(0xFFFFFDE7), Color(0xFFFFF3E0)];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal Harian'),
        backgroundColor: Colors.indigo,
        actions: const [ThemeToggleAction()],
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              final t = _bgController.value;
              final alignment = Alignment(
                math.sin(t * 2 * math.pi),
                math.cos(t * 2 * math.pi),
              );
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: alignment,
                    end: -alignment,
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Halo, ${widget.user.name}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _saving ? null : _onSave,
                        icon: const Icon(Icons.cloud_upload),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 64,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(_moods.length, (index) {
                          final mood = _moods[index];
                          final selected = _selectedMood == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(mood['name'] as String),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _selectedMood = index),
                              avatar: Icon(
                                mood['icon'] as IconData,
                                color: selected
                                    ? Colors.white
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.thermostat, color: Colors.deepOrange),
                      Expanded(
                        child: Slider(
                          min: 0,
                          max: 10,
                          divisions: 10,
                          value: _stress.toDouble(),
                          label: '$_stress',
                          onChanged: (value) =>
                              setState(() => _stress = value.toInt()),
                        ),
                      ),
                      Text(
                        '$_stress/10',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, _) {
                      final float =
                          math.sin(_floatController.value * 2 * math.pi) * 8;
                      return Transform.translate(
                        offset: Offset(0, float),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _paperColor,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _ctrl,
                            maxLines: 12,
                            onChanged: (value) {
                              setState(() {
                                final baseColor = value.length % 2 == 0
                                    ? Colors.white
                                    : Colors.amber.shade50;
                                _paperColor = baseColor;
                              });
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  'Tulis jurnal... (ceritakan perasaanmu, tiga hal yang disyukuri, rencana besok)',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _onSave,
                      icon: _saving
                          ? AnimatedBuilder(
                              animation: _saveAnimController,
                              builder: (_, __) => Transform.rotate(
                                angle: _saveAnimController.value * 2 * math.pi,
                                child: const Icon(Icons.sync),
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(_saving ? 'Menyimpan...' : 'Simpan Jurnal'),
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
}
