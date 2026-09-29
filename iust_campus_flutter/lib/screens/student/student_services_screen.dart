import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── palette ────────────────────────────────────────────────────────────────
const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class StudentServicesScreen extends StatelessWidget {
  const StudentServicesScreen({super.key});

  // ── service sections ──────────────────────────────────────────────────
  static const _sections = <_ServiceSection>[
    _ServiceSection(title: 'الخدمات الأكاديمية', items: [
      _Svc(icon: Icons.menu_book_rounded,         bg: Color(0xFFEAF4FB), ic: _blue,              label: 'الخطة الدراسية',       desc: 'خطتك الدراسية الكاملة',         route: null),
      _Svc(icon: Icons.app_registration_rounded,  bg: Color(0xFFF5F0FF), ic: Color(0xFF7C3AED),  label: 'تسجيل المقررات',       desc: 'إضافة وحذف المقررات',           route: null),
      _Svc(icon: Icons.library_books_rounded,     bg: Color(0xFFEDFAF1), ic: Color(0xFF2E9B5F),  label: 'دليل المقررات والمدرسين',desc: 'البحث عن مقرر أو دكتور',       route: null),
      _Svc(icon: Icons.bar_chart_rounded,         bg: Color(0xFFFFF0F0), ic: Color(0xFFE53E3E),  label: 'النتائج والحضور',       desc: 'معدلاتك ونسبة الحضور',         route: null),
      _Svc(icon: Icons.trending_up_rounded,       bg: Color(0xFFEAF4FB), ic: _blue,              label: 'موادي وتقدمي',          desc: 'تقدمك في كل مقرر',             route: null),
      _Svc(icon: Icons.assignment_rounded,        bg: Color(0xFFFFF8E1), ic: Color(0xFFD4900A),  label: 'مهامي الدراسية',       desc: 'تسليمات ومهام المقررات',        route: null),
      _Svc(icon: Icons.timer_rounded,             bg: Color(0xFFF5F0FF), ic: Color(0xFF7C3AED),  label: 'مؤقت التركيز',          desc: 'تقنية بومودورو للدراسة',        route: null),
      _Svc(icon: Icons.forum_rounded,             bg: Color(0xFFEDFAF1), ic: Color(0xFF2E9B5F),  label: 'مجتمع المقررات',        desc: 'نقاش مع زملائك',               route: null),
      _Svc(icon: Icons.support_agent_rounded,     bg: Color(0xFFEAF4FB), ic: _blue,              label: 'الإرشاد الأكاديمي',    desc: 'تواصل مع مرشدك',               route: null),
    ]),
    _ServiceSection(title: 'خدمات الحرم الجامعي', items: [
      _Svc(icon: Icons.place_rounded,             bg: Color(0xFFEAF4FB), ic: _blue,              label: 'دليل المرافق',          desc: 'أماكن الخدمات في الحرم',        route: null),
      _Svc(icon: Icons.directions_bus_rounded,    bg: Color(0xFFFFF8E1), ic: Color(0xFFD4900A),  label: 'النقل الجامعي',         desc: 'مواعيد الحافلات والخطوط',       route: null),
      _Svc(icon: Icons.local_library_rounded,     bg: Color(0xFFEDFAF1), ic: Color(0xFF2E9B5F),  label: 'المكتبة',              desc: 'الكتب والموارد الإلكترونية',    route: null),
      _Svc(icon: Icons.search_rounded,            bg: Color(0xFFF5F0FF), ic: Color(0xFF7C3AED),  label: 'المفقودات',             desc: 'أبلغ عن مفقود أو استرجعه',    route: null),
      _Svc(icon: Icons.emergency_rounded,         bg: Color(0xFFFFF0F0), ic: Color(0xFFE53E3E),  label: 'السلامة والطوارئ',      desc: 'أرقام الطوارئ والإسعاف',        route: null),
    ]),
    _ServiceSection(title: 'خدمات الطالب', items: [
      _Svc(icon: Icons.feedback_rounded,          bg: Color(0xFFEAF4FB), ic: _blue,              label: 'طلب أو شكوى',          desc: 'تقديم طلب أو شكوى',             route: null),
      _Svc(icon: Icons.campaign_rounded,          bg: Color(0xFFFFF8E1), ic: Color(0xFFD4900A),  label: 'الإعلانات والفعاليات', desc: 'آخر أخبار الجامعة',             route: null),
      _Svc(icon: Icons.sports_soccer_rounded,     bg: Color(0xFFEDFAF1), ic: Color(0xFF2E9B5F),  label: 'المرافق الرياضية',      desc: 'صالات الرياضة والملاعب',        route: null),
      _Svc(icon: Icons.local_hospital_rounded,    bg: Color(0xFFFFF0F0), ic: Color(0xFFE53E3E),  label: 'الصحة والمصليات',       desc: 'العيادة ومواقع المصليات',       route: null),
    ]),
    _ServiceSection(title: 'معلومات الجامعة', items: [
      _Svc(icon: Icons.account_balance_rounded,   bg: Color(0xFFEAF4FB), ic: _blue,              label: 'عن الجامعة',            desc: 'الرؤية والكليات والفلسفة',      route: '/info/university'),
      _Svc(icon: Icons.card_membership_rounded,   bg: Color(0xFFFFF8E1), ic: Color(0xFFD4900A),  label: 'المنح والخصومات',       desc: 'الشروط والنسب',                 route: '/info/scholarships'),
      _Svc(icon: Icons.file_copy_outlined,        bg: Color(0xFFEDFAF1), ic: Color(0xFF2E9B5F),  label: 'المستندات المطلوبة',   desc: 'وثائق التسجيل والتحويل',        route: '/info/documents'),
      _Svc(icon: Icons.receipt_long_rounded,      bg: Color(0xFFFFF0F0), ic: Color(0xFFE53E3E),  label: 'الرسوم المالية',        desc: 'التأجيل والانسحاب والرسوم',    route: '/info/financial'),
      _Svc(icon: Icons.chat_bubble_outline_rounded,bg: Color(0xFFF5F0FF),ic: Color(0xFF7C3AED),  label: 'الأسئلة العامة',        desc: 'إجابات عن الدراسة والتسجيل',   route: '/info/faq'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            slivers: [
              // header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الخدمات الجامعية',
                          style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _textMain)),
                      const SizedBox(height: 4),
                      Text('كل خدمات الطالب الأكاديمية واليومية في مكان واحد.',
                          style: GoogleFonts.cairo(
                              fontSize: 13, color: _textSub, height: 1.5)),
                    ],
                  ),
                ),
              ),

              // sections
              for (final section in _sections) ...[
                SliverToBoxAdapter(child: _SectionHeader(title: section.title)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _ServiceCard(svc: section.items[i]),
                      childCount: section.items.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.55,
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── data models ────────────────────────────────────────────────────────────
class _Svc {
  final IconData icon;
  final Color bg, ic;
  final String label, desc;
  final String? route;
  const _Svc({
    required this.icon, required this.bg, required this.ic,
    required this.label, required this.desc, required this.route,
  });
}

class _ServiceSection {
  final String title;
  final List<_Svc> items;
  const _ServiceSection({required this.title, required this.items});
}

// ── widgets ────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Row(children: [
          Container(
            width: 4, height: 20,
            decoration: BoxDecoration(
                color: _navy, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain)),
        ]),
      );
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({required this.svc});
  final _Svc svc;
  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _down = false;

  void _handleTap() {
    if (widget.svc.route != null) {
      Navigator.of(context).pushNamed(widget.svc.route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) { setState(() => _down = false); _handleTap(); },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _down ? -4 : 0, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36, height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.svc.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.svc.icon,
                      color: widget.svc.ic, size: 20),
                ),
                Icon(Icons.chevron_left_rounded,
                    color: _textSub, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.svc.label,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                    height: 1.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(widget.svc.desc,
                style: GoogleFonts.cairo(
                    fontSize: 11, color: _textSub, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
