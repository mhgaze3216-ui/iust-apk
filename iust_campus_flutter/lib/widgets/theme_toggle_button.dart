import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

/// Reusable Theme Toggle Button for all main role headers
/// (Student, Doctor, Master Admin, Administrative Staff, Guest).
///
/// Displays:
/// - Moon icon with tooltip "الوضع الداكن" in Light Mode.
/// - Sun icon with tooltip "الوضع الفاتح" in Dark Mode.
class ThemeToggleButton extends StatelessWidget {
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const ThemeToggleButton({
    super.key,
    this.size = 36,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeModeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final tooltip = isDark ? 'الوضع الفاتح' : 'الوضع الداكن';
        final icon = isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded;

        final effectiveIconColor = iconColor ??
            (isDark ? const Color(0xFFF5B82E) : const Color(0xFF073B4C));
        final effectiveBgColor = backgroundColor ??
            (isDark ? const Color(0xFF132738) : const Color(0xFFF6F9FC));
        final effectiveBorderColor = borderColor ??
            (isDark ? const Color(0xFF1E3A52) : const Color(0xFFDCE8EE));

        return Tooltip(
          message: tooltip,
          child: GestureDetector(
            onTap: () => ThemeController.instance.toggleTheme(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: effectiveBgColor,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: effectiveBorderColor),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: size * 0.55,
              ),
            ),
          ),
        );
      },
    );
  }
}
