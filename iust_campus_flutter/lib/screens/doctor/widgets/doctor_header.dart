import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/doctor_demo_data.dart';
import '../doctor_notifications_screen.dart';
import 'doctor_back_button.dart';

const _navy     = Color(0xFF073B4C);
const _white    = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _border   = Color(0xFFDCE8EE);
const _lightBg  = Color(0xFFF6F9FC);

/// Top app bar header for Doctor screens.
/// Guarantees exact horizontal centering of the IUST logo.
class DoctorHeader extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final bool showBackButton;

  const DoctorHeader({
    super.key,
    this.onNotificationTap,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(54);

  @override
  State<DoctorHeader> createState() => _DoctorHeaderState();
}

class _DoctorHeaderState extends State<DoctorHeader> {
  Future<void> _openNotifications() async {
    if (widget.onNotificationTap != null) {
      widget.onNotificationTap!();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const DoctorNotificationsScreen(),
      ),
    );
    // When screen pops or updates, refresh badge
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _white,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Center: University Logo ─────────────────────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/img/logo iust.webp',
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (_, e, s) =>
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
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: _openNotifications,
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
                  if (DoctorDemoData.unreadNotificationsCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
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
                          '${DoctorDemoData.unreadNotificationsCount}',
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
            child: widget.showBackButton
                ? const DoctorBackButton()
                : Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: _lightBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'EN',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textMain,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
