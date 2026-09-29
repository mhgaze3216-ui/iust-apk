import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _navy = Color(0xFF073B4C);
const Color _white = Colors.white;
const Color _border = Color(0xFFE2E8F4);
const Color _lightBg = Color(0xFFF4F7FE);
const Color _textDark = Color(0xFF0A2540);
const Color _textMuted = Color(0xFF64748B);

/// Clean, compact header for Guest / Visitor browsing.
///
/// Layout:
/// - Physical left: Language button ([ EN / AR ]) or compact Back button on subpages.
/// - Center: University logo + IUST text.
/// - No bell, no avatar, no hamburger menu.
class GuestHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  const GuestHeader({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            color: _white,
            border: Border(
              bottom: BorderSide(color: _border, width: 1),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Physical Left: Language or Back button ───────────────────
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
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _border),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: _navy,
                            size: 16,
                          ),
                        ),
                      )
                    : const GuestLanguageButton(),
              ),

              // ── Center: University Logo + IUST text ──────────────────────
              Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/img/logo iust.webp',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.account_balance_rounded,
                            color: _navy,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'IUST',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact interactive language toggle button displaying [ EN / AR ].
class GuestLanguageButton extends StatefulWidget {
  const GuestLanguageButton({super.key});

  @override
  State<GuestLanguageButton> createState() => _GuestLanguageButtonState();
}

class _GuestLanguageButtonState extends State<GuestLanguageButton> {
  // App default is Arabic (AR)
  String _currentLang = 'AR';

  void _toggleLanguage() {
    setState(() {
      _currentLang = (_currentLang == 'AR') ? 'EN' : 'AR';
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(
          _currentLang == 'AR'
              ? 'تم ضبط اللغة: العربية (AR)'
              : 'Language set to English (EN)',
          style: GoogleFonts.cairo(fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = _currentLang == 'AR';
    return Directionality(
      textDirection: TextDirection.ltr,
      child: InkWell(
        onTap: _toggleLanguage,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _lightBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EN',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: isAr ? FontWeight.w500 : FontWeight.w800,
                  color: isAr ? _textMuted : _navy,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  '/',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              Text(
                'AR',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: isAr ? FontWeight.w800 : FontWeight.w500,
                  color: isAr ? _navy : _textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
