import 'package:flutter/material.dart';

import '../core/navigation/app_route_observer.dart';
import '../services/affirmations_service.dart';

/* ===========================
   🌟 AFFIRMATIONS WIDGET - BARU!
   =========================== */

class AffirmationsWidget extends StatefulWidget {
  const AffirmationsWidget({super.key});

  @override
  State<AffirmationsWidget> createState() => _AffirmationsWidgetState();
}

class _AffirmationsWidgetState extends State<AffirmationsWidget>
    with SingleTickerProviderStateMixin, RouteAware {
  String _affirmation = 'Loading inspiration...';
  bool _isLoading = true;
  late AnimationController _shimmerController;
  PageRoute<dynamic>? _route;

  final List<IconData> _icons = [
    Icons.favorite,
    Icons.star,
    Icons.emoji_emotions,
    Icons.wb_sunny,
    Icons.auto_awesome,
    Icons.celebration,
  ];

  @override
  void initState() {
    super.initState();
    print('🎯 AffirmationsWidget INITIALIZED!');
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _fetchAffirmation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      if (_route != route) {
        if (_route != null) {
          appRouteObserver.unsubscribe(this);
        }
        _route = route;
        appRouteObserver.subscribe(this, route);
      }
    }
  }

  @override
  void dispose() {
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _fetchAffirmation() async {
    print('🔍 Starting to fetch affirmation...');
    setState(() => _isLoading = true);
    await AffirmationsService.fetchAffirmationWithCallback(
      onSuccess: _handleAffirmationLoaded,
      onError: _handleAffirmationError,
    );
  }

  @override
  void didPush() {
    _fetchAffirmation();
  }

  @override
  void didPopNext() {
    _fetchAffirmation();
  }

  @override
  void didPushNext() {
    _fetchAffirmation();
  }

  void _handleAffirmationLoaded(String message) {
    print('📝 Got affirmation: $message');
    if (!mounted) return;
    setState(() {
      _affirmation = message;
      _isLoading = false;
    });
    print('✅ Widget updated with affirmation!');
  }

  void _handleAffirmationError(String message) {
    print('⚠️ Failed to fetch affirmation: $message');
    if (!mounted) return;
    setState(() {
      _affirmation = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Building AffirmationsWidget...');
    final randomIcon = _icons[DateTime.now().millisecond % _icons.length];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [Color(0xFF2A1948), Color(0xFF191C3B), Color(0xFF0B0F1E)]
        : [
            Colors.purple.shade400,
            Colors.deepPurple.shade500,
            Colors.indigo.shade600,
          ];
    final shimmerColors = isDark
        ? [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ]
        : [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ];
    final chipColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.2);
    final affirmationBg = isDark
        ? Colors.black.withOpacity(0.25)
        : Colors.white.withOpacity(0.15);
    final affirmationBorder = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.white.withOpacity(0.3);
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.5)
        : Colors.deepPurple.withOpacity(0.3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(randomIcon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '✨ Daily Affirmation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconButton(
                onPressed: _fetchAffirmation,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Get new affirmation',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: shimmerColors,
                      stops: [
                        _shimmerController.value - 0.3,
                        _shimmerController.value,
                        _shimmerController.value + 0.3,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                );
              },
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Container(
                key: ValueKey(_affirmation),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: affirmationBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: affirmationBorder, width: 1.5),
                ),
                child: Text(
                  _affirmation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white.withOpacity(0.7),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Tap refresh for new inspiration',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
