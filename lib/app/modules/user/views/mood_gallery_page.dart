import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../widgets/affirmations_widget.dart';
import '../../../widgets/theme_toggle_action.dart';

class MoodGalleryPage extends StatefulWidget {
  const MoodGalleryPage({
    super.key,
    required this.moods,
    this.initialIndex = 0,
  });

  final List<Map<String, dynamic>> moods;
  final int initialIndex;

  @override
  State<MoodGalleryPage> createState() => _MoodGalleryPageState();
}

class _MoodGalleryPageState extends State<MoodGalleryPage>
    with TickerProviderStateMixin {
  late int selected;
  late AnimationController _floatController;
  late AnimationController _stagger;

  @override
  void initState() {
    super.initState();
    selected = widget.initialIndex;
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _stagger = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _stagger.dispose();
    super.dispose();
  }

  void _select(int idx) => Navigator.pop(context, idx);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cross = width < 600
        ? 2
        : width < 900
        ? 3
        : 4;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundGradient = isDark
        ? const [Color(0xFF070A13), Color(0xFF131A2C)]
        : const [Color(0xFFF3F8FF), Color(0xFFFFF8F4)];
    final inactiveSurface = isDark ? const Color(0xFF161C2B) : Colors.white;
    final inactiveSurface2 = isDark ? const Color(0xFF0F1422) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.white.withOpacity(0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Mood'),
        backgroundColor: Colors.indigo,
        actions: const [ThemeToggleAction(), CloseButton()],
      ),
      body: AnimatedBuilder(
        animation: _floatController,
        builder: (context, _) {
          final lift = math.sin(_floatController.value * 2 * math.pi) * 6;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: backgroundGradient),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const AffirmationsWidget(),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: GridView.builder(
                      itemCount: widget.moods.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemBuilder: (c, i) {
                        final m = widget.moods[i];
                        final active = selected == i;
                        final anim = CurvedAnimation(
                          parent: _stagger,
                          curve: Interval(
                            (i / widget.moods.length).clamp(0.0, 1.0),
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        );
                        final color = m['color'] as Color;
                        final gradientColors = active
                            ? (isDark
                                  ? [
                                      color.withOpacity(0.95),
                                      color.withOpacity(0.55),
                                    ]
                                  : [color, color.withOpacity(0.9)])
                            : (isDark
                                  ? [inactiveSurface, inactiveSurface2]
                                  : [color.withOpacity(0.1), Colors.white]);
                        final textColor = active
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87);
                        final iconColor = active
                            ? Colors.white
                            : (isDark ? color.withOpacity(0.9) : color);
                        final shadowColor = isDark
                            ? Colors.black.withOpacity(active ? 0.45 : 0.25)
                            : color.withOpacity(active ? 0.2 : 0.06);
                        return FadeTransition(
                          opacity: anim,
                          child: Transform.translate(
                            offset: Offset(0, active ? lift : 0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selected = i);
                                Future.delayed(
                                  const Duration(milliseconds: 140),
                                  () => _select(i),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    active ? 18 : 12,
                                  ),
                                  gradient: LinearGradient(
                                    colors: gradientColors,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: shadowColor,
                                      blurRadius: active ? 16 : 8,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      m['icon'] as IconData,
                                      size: active ? 34 : 28,
                                      color: iconColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      m['name'] as String,
                                      style: TextStyle(
                                        fontSize: active ? 16 : 14,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
