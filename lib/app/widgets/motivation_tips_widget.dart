import 'package:flutter/material.dart';

import '../services/motivation_service.dart';

class MotivationTipsWidget extends StatefulWidget {
  const MotivationTipsWidget({super.key});

  @override
  State<MotivationTipsWidget> createState() => _MotivationTipsWidgetState();
}

class _MotivationTipsWidgetState extends State<MotivationTipsWidget> {
  String _tip = 'Memuat tips motivasi...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTip();
  }

  Future<void> _loadTip() async {
    setState(() => _isLoading = true);
    final tip = await MotivationService.fetchRandomTip();
    if (!mounted) return;
    setState(() {
      _tip = tip;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.bolt,
                      color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tips Motivasi (REST via http)',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _loadTip,
                  tooltip: 'Muat ulang',
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _tip,
                key: ValueKey(_tip),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
