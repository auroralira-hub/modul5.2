import 'package:flutter/material.dart';

import '../core/theme/theme_controller.dart';

class ThemeToggleAction extends StatelessWidget {
  final Color? iconColor;
  const ThemeToggleAction({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final isDark = themeController.isDarkMode;
        return IconButton(
          tooltip: isDark ? 'Ubah ke mode terang' : 'Ubah ke mode gelap',
          icon: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: iconColor,
          ),
          onPressed: themeController.toggleTheme,
        );
      },
    );
  }
}
