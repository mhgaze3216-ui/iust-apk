import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_services_demo_data.dart';
import '../subpages/university_notifications_screen.dart';

const _navy = Color(0xFF073B4C);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _border = Color(0xFFDCE8EE);
const _lightBg = Color(0xFFF6F9FC);

class UniversityServicesHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showNotificationBell;

  const UniversityServicesHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.showNotificationBell = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(
      title != null ? (subtitle != null && subtitle!.trim().isNotEmpty ? 92 : 72) : 54);

  @override
  Widget build(BuildContext context) {
    final unread = UniversityServicesRepository.unreadNotificationsCount;

    return Container(
      color: _white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top bar: Back, University Logo, Notification Bell
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Center: University Logo & Name (IUST only) ──────────────
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/img/logo iust.webp',
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.account_balance_rounded, color: _navy, size: 28),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'IUST',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textMain,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Right Side: Notification Bell ───────────────────────────
                if (showNotificationBell)
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UniversityNotificationsScreen(),
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _lightBg,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: _border),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: _navy,
                              size: 20,
                            ),
                          ),
                          if (unread > 0)
                            Positioned(
                              top: -3,
                              right: -3,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE74C3C),
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$unread',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // ── Left Side: Back Button or Language Indicator ───────────
                Positioned(
                  left: 0,
                  child: showBackButton
                      ? GestureDetector(
                          onTap: onBack ?? () => Navigator.of(context).maybePop(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _lightBg,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: _border),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: _navy,
                              size: 16,
                            ),
                          ),
                        )
                      : Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _lightBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _border),
                          ),
                          child: Text(
                            'AR',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Title / Subtitle Bar
          if (title != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEDF2F7))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _textMain,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF6F7F89),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
