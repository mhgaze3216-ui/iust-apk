import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'guest/widgets/guest_header.dart';

// ════════════════════════════════════════════════════════════════════════════
// Palette
// ════════════════════════════════════════════════════════════════════════════
class _C {
  static const navy     = Color(0xFF073B4C);
  static const blue     = Color(0xFF0d6efd);
  static const lightBg  = Color(0xFFF4F7FE);
  static const white    = Colors.white;
  static const gold     = Color(0xFFc9a84c);
  static const goldBg   = Color(0xFFFFF8E1);
  static const blueBg   = Color(0xFFEEF4FF);
  static const textDark = Color(0xFF0a2540);
  static const textMute = Color(0xFF64748B);
  static const border   = Color(0xFFE2E8F4);
}

// ════════════════════════════════════════════════════════════════════════════
// WelcomeScreen
// ════════════════════════════════════════════════════════════════════════════
class WelcomeScreen extends StatefulWidget {
  final bool isRootTab;
  final ValueChanged<int>? onNavigateTab;
  const WelcomeScreen({super.key, this.isRootTab = false, this.onNavigateTab});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.lightBg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ── scrollable content ──────────────────────────────────────
            CustomScrollView(
              slivers: [
                // header
                const SliverToBoxAdapter(child: GuestHeader()),
                // hero
                SliverToBoxAdapter(child: _HeroCard(
                  onLearnMore: () {
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(4);
                    } else {
                      Navigator.of(context).pushNamed('/info/university');
                    }
                  },
                  onLogin: () =>
                      Navigator.of(context).pushNamed('/login'),
                )),
                // info grid
                const SliverToBoxAdapter(child: _InfoSection()),
                // faculties
                const SliverToBoxAdapter(child: _FacultiesSection()),
                // student CTA
                SliverToBoxAdapter(child: _StudentCta(
                  onLogin: () =>
                      Navigator.of(context).pushNamed('/login'),
                )),
                // bottom padding for nav bar
                const SliverToBoxAdapter(
                    child: SizedBox(height: 110)),
              ],
            ),

            // ── floating bottom nav ─────────────────────────────────────
            if (!widget.isRootTab)
              Positioned(
                left: 16, right: 16, bottom: 20,
                child: _FloatingNav(
                  selectedIndex: _navIndex,
                  onTap: (i) {
                    setState(() => _navIndex = i);
                    if (i == 4) {
                      Navigator.of(context).pushNamed('/login');
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 2. HERO CARD
// ════════════════════════════════════════════════════════════════════════════
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onLearnMore, required this.onLogin});
  final VoidCallback onLearnMore, onLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF073B4C), Color(0xFF0A5367)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _C.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _C.gold.withValues(alpha: 0.40), width: 1),
                ),
                child: Text('مرحباً بك في IUST',
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _C.gold)),
              ),
              const SizedBox(height: 16),

              // heading
              Text(
                'اكتشف الجامعة\nقبل أن تبدأ رحلتك.',
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _C.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),

              // subtitle
              Text(
                'تعرّف على الكليات، البرامج، المنح، وثائق القبول، والخدمات المتاحة للزوار.',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  color: _C.white.withValues(alpha: 0.72),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),

              // buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onLearnMore,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _C.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text('تعرّف على الجامعة',
                            style: GoogleFonts.cairo(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: _C.navy)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: onLogin,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _C.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _C.white.withValues(alpha: 0.30)),
                        ),
                        alignment: Alignment.center,
                        child: Text('تسجيل دخول طالب',
                            style: GoogleFonts.cairo(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: _C.white)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // campus image
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/img/iust.jpeg',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 3. INFO SECTION  –  "معلومات تهمك"
// ════════════════════════════════════════════════════════════════════════════
class _InfoSection extends StatelessWidget {
  const _InfoSection();

  static const _items = [
    (_InfoItem(
      icon: Icons.account_balance_rounded,
      bgColor: _C.blueBg,
      iconColor: _C.blue,
      title: 'عن الجامعة',
      desc: 'الرؤية والرسالة والفلسفة والكليات.',
      route: '/info/university',
    )),
    (_InfoItem(
      icon: Icons.card_membership_rounded,
      bgColor: _C.goldBg,
      iconColor: _C.gold,
      title: 'المنح والخصومات',
      desc: 'الشروط والنسب والمستندات المطلوبة.',
      route: '/info/scholarships',
    )),
    (_InfoItem(
      icon: Icons.file_copy_outlined,
      bgColor: Color(0xFFEDFAF1),
      iconColor: Color(0xFF2E9B5F),
      title: 'المستندات المطلوبة',
      desc: 'وثائق التسجيل والتحويل والتسويات.',
      route: '/info/documents',
    )),
    (_InfoItem(
      icon: Icons.chat_bubble_outline_rounded,
      bgColor: Color(0xFFF5F0FF),
      iconColor: Color(0xFF7C3AED),
      title: 'الأسئلة العامة',
      desc: 'إجابات واضحة عن الدراسة والتسجيل.',
      route: '/info/faq',
    )),
    (_InfoItem(
      icon: Icons.receipt_long_rounded,
      bgColor: Color(0xFFE6F7FB),
      iconColor: Color(0xFF0891B2),
      title: 'الرسوم والإجراءات المالية',
      desc: 'الرسوم والتأجيل والانسحاب والإجراءات المالية.',
      route: '/info/financial',
    )),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: 'معلومات تهمك',
              subtitle: 'يمكنك تصفح هذه الخدمات دون حساب.',
            ),
            const SizedBox(height: 16),

            // 2-column grid via manual row pairs
            for (int i = 0; i < _items.length; i += 2) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        child: _TapLift(
                          onTap: () => Navigator.of(context)
                              .pushNamed(_items[i].route),
                          child: _InfoCard(item: _items[i]),
                        )),
                    const SizedBox(width: 12),
                    Expanded(
                      child: i + 1 < _items.length
                          ? _TapLift(
                              onTap: () => Navigator.of(context)
                                  .pushNamed(_items[i + 1].route),
                              child: _InfoCard(item: _items[i + 1]),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final Color bgColor, iconColor;
  final String title, desc, route;
  const _InfoItem({
    required this.icon, required this.bgColor, required this.iconColor,
    required this.title, required this.desc, required this.route,
  });
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});
  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.blue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(item.title,
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.textDark,
                  height: 1.25)),
          const SizedBox(height: 5),
          Text(item.desc,
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: _C.textMute,
                  height: 1.55)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 5. FACULTIES SECTION
// ════════════════════════════════════════════════════════════════════════════
class _FacultiesSection extends StatelessWidget {
  const _FacultiesSection();

  static const _faculties = [
    _FacultyItem(
      name: 'كلية إدارة الأعمال والتمويل',
      englishName: 'Faculty of Business Administration & Finance',
      tagline: 'الإدارة والتمويل والمحاسبة والتسويق',
      image: 'assets/img/works.jpeg',
      route: '/faculty/business',
    ),
    _FacultyItem(
      name: 'كلية الهندسة المعمارية',
      englishName: 'Faculty of Architecture',
      tagline: 'التصميم المعماري والتخطيط الحضري والاستدامة',
      image: 'assets/img/architecture.jpeg',
      route: '/faculty/architecture',
    ),
    _FacultyItem(
      name: 'كلية الهندسة والتكنولوجيا',
      englishName: 'Faculty of Engineering & Technology',
      tagline: 'الهندسة المدنية والاتصالات وهندسة الحاسوب',
      image: 'assets/img/information.jpeg',
      route: '/faculty/engineering',
    ),
    _FacultyItem(
      name: 'كلية طب الأسنان',
      englishName: 'Faculty of Dentistry',
      tagline: 'الرعاية الفموية والتدريب السريري والبحث العلمي',
      image: 'assets/img/teeth.jpeg',
      route: '/faculty/dentistry',
    ),
    _FacultyItem(
      name: 'كلية الصيدلة',
      englishName: 'Faculty of Pharmacy',
      tagline: 'العلوم الدوائية والسريرية والبيولوجية',
      image: 'assets/img/pharmaceutics.jpeg',
      route: '/faculty/pharmacy',
    ),
    _FacultyItem(
      name: 'كلية الآداب والعلوم',
      englishName: 'Faculty of Arts & Sciences',
      tagline: 'التصميم الداخلي والغرافيكي واللغة الإنجليزية',
      image: 'assets/img/sciences.jpeg',
      route: '/faculty/arts-sciences',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 24, 14, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SectionHeader(
                  title: 'كليات الجامعة',
                  subtitle: 'كليات مرتبطة باحتياجات المجتمع وسوق العمل.',
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text('فلسفة الجامعة',
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: _C.blue,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ..._faculties.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _TapLift(
                    onTap: () => Navigator.of(context).pushNamed(f.route),
                    child: _FacultyCard(faculty: f),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _FacultyItem {
  final String name, englishName, tagline, image, route;
  const _FacultyItem({
    required this.name,
    required this.englishName,
    required this.tagline,
    required this.image,
    required this.route,
  });
}

class _FacultyCard extends StatelessWidget {
  const _FacultyCard({required this.faculty});
  final _FacultyItem faculty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.asset(
                  faculty.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, s) => Container(
                    decoration: const BoxDecoration(color: _C.lightBg),
                    child: const Icon(Icons.school_rounded,
                        size: 48, color: _C.textMute),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: faculty.route == '/faculty/engineering'
                        ? _C.navy.withValues(alpha: 0.90)
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: faculty.route == '/faculty/engineering'
                          ? _C.gold
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        faculty.route == '/faculty/engineering'
                            ? Icons.map_rounded
                            : Icons.info_outline_rounded,
                        size: 12,
                        color: faculty.route == '/faculty/engineering'
                            ? _C.gold
                            : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        faculty.route == '/faculty/engineering'
                            ? '4 خرائط متاحة'
                            : 'لا توجد خرائط مضافة حالياً',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: faculty.route == '/faculty/engineering'
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // text
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(faculty.name,
                          style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _C.textDark,
                              height: 1.3)),
                      const SizedBox(height: 2),
                      Text(faculty.englishName,
                          style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _C.textMute)),
                      const SizedBox(height: 4),
                      Text(faculty.tagline,
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: _C.blue,
                              height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_left_rounded,
                    color: _C.textMute, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 6. STUDENT LOGIN CTA
// ════════════════════════════════════════════════════════════════════════════
class _StudentCta extends StatelessWidget {
  const _StudentCta({required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _C.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل أنت طالب في الجامعة؟',
                  style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _C.textDark)),
              const SizedBox(height: 8),
              Text(
                'سجّل الدخول للوصول إلى الجدول، النتائج، التسجيل، '
                'الخرائط الداخلية والمساعد الذكي.',
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: _C.textMute,
                    height: 1.6),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.navy,
                    foregroundColor: _C.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('تسجيل الدخول',
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 7. FLOATING BOTTOM NAVIGATION
// ════════════════════════════════════════════════════════════════════════════
class _FloatingNav extends StatelessWidget {
  const _FloatingNav({
    required this.selectedIndex,
    required this.onTap,
  });
  final int selectedIndex;
  final void Function(int) onTap;

  static const _items = [
    (Icons.home_rounded,           'الرئيسية'),
    (Icons.map_rounded,            'الحرم'),
    (Icons.info_outline_rounded,   'المعلومات'),
    (Icons.account_balance_rounded,'الجامعة'),
    (Icons.login_rounded,          'تسجيل الدخول'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: List.generate(_items.length, (i) {
            final (icon, label) = _items[i];
            final active = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // gold indicator dot when active
                    Container(
                      height: 3, width: 20,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: active
                            ? _C.gold
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: active
                            ? _C.blueBg
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            icon,
                            size: 20,
                            color: active
                                ? _C.navy
                                : _C.textMute,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            style: GoogleFonts.cairo(
                              fontSize: 9.5,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: active
                                  ? _C.navy
                                  : _C.textMute,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ════════════════════════════════════════════════════════════════════════════

/// Section title + subtitle block (RTL, used inside a Directionality parent)
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _C.textDark,
                height: 1.2)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: GoogleFonts.cairo(
                fontSize: 13,
                color: _C.textMute,
                height: 1.5)),
      ],
    );
  }
}

/// Lift-on-press touch animation wrapper
class _TapLift extends StatefulWidget {
  const _TapLift({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_TapLift> createState() => _TapLiftState();
}

class _TapLiftState extends State<_TapLift> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
              0.0, _down ? -6.0 : 0.0, 0.0)
          ..scaleByDouble(
              _down ? 1.01 : 1.0, _down ? 1.01 : 1.0, 1.0, 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: _down
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}
