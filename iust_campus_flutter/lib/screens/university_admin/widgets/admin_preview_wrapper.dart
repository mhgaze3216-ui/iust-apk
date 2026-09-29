import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/admin_preview_session.dart';

/// A wrapper widget that embeds any existing shell (`StudentShell`, `DoctorShell`, etc.)
/// with a compact, persistent top banner indicating administrative preview mode.
///
/// Provides a one-tap action to safely return to the master Administration control center.
class AdminPreviewWrapper extends StatelessWidget {
  final String roleLabel;
  final String userName;
  final String userId;
  final Widget child;

  const AdminPreviewWrapper({
    super.key,
    required this.roleLabel,
    required this.userName,
    required this.userId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF073B4C);
    const gold = Color(0xFFF5B82E);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          AdminPreviewSession.exitPreview(context);
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F9FC),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Compact Master Admin Preview Banner ────────────────────────
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: navy,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Badge: معاينة بواسطة الإدارة
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: gold.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.visibility_rounded, color: gold, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'معاينة بواسطة الأدمن',
                              style: GoogleFonts.cairo(
                                color: gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // User name & ID tag
                      Expanded(
                        child: Text(
                          '$userName ($userId)',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Exit action: العودة إلى الأدمن
                      InkWell(
                        onTap: () => AdminPreviewSession.exitPreview(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'العودة إلى الأدمن',
                                style: GoogleFonts.cairo(
                                  color: navy,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.exit_to_app_rounded, color: navy, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── The Real Screen / Shell ──────────────────────────────────
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
