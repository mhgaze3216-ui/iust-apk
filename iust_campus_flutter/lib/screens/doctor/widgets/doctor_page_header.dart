import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_back_button.dart';

const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _gold = Color(0xFFF5B82E);
const _border = Color(0xFFDCE8EE);

/// A unified, reusable AppBar header for all Doctor subpages.
/// Ensures consistent RTL back-button placement, typography, and optional demo badge/actions.
class DoctorPageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeBgColor;

  const DoctorPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.badgeText = 'بيانات تجريبية',
    this.badgeColor = const Color(0xFFB78103),
    this.badgeBgColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(
      (subtitle != null ? 58.0 : 54.0) + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final bgBadge = badgeBgColor ?? (badgeColor != null ? badgeColor!.withValues(alpha: 0.14) : const Color(0xFFFFF4D6));

    return AppBar(
      backgroundColor: _white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? DoctorBackButton(onCustomPop: onBackPressed)
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textSub,
              ),
            ),
        ],
      ),
      actions: [
        ...?actions,
        if (badgeText != null && badgeText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bgBadge,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText!,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? _gold,
                  ),
                ),
              ),
            ),
          ),
      ],
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: bottom!.preferredSize,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1, color: _border),
                  bottom!,
                ],
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: _border, height: 1),
            ),
    );
  }
}
