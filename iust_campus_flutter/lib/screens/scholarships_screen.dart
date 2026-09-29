import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _blue     = Color(0xFF0d6efd);
const _lightBg  = Color(0xFFF4F7FE);
const _white    = Colors.white;
const _gold     = Color(0xFFc9a84c);
const _blueBg   = Color(0xFFEEF4FF);
const _textDark = Color(0xFF0a2540);
const _textMute = Color(0xFF64748B);
const _border   = Color(0xFFE2E8F4);

class ScholarshipsScreen extends StatelessWidget {
  const ScholarshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, 'المنح والخصومات'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── Secondary scholarship ─────────────────────────────────
            _SectionTitle('منح الشهادة الثانوية'),
            _BulletCard(items: const [
              'منحة كاملة للطلاب الخمسة الأوائل في الشهادة الثانوية العامة السورية أو ما يعادلها.',
              'خمس منح تغطي 50% من الرسوم الدراسية للطلاب الحاصلين على معدل 90% أو أكثر.',
              'تستمر المنحة إذا حافظ الطالب على معدل تراكمي لا يقل عن 3.0 (B).',
            ]),

            // ── Ministry scholarships ─────────────────────────────────
            _SectionTitle('منح وزارة التعليم العالي'),
            _BulletCard(items: const [
              'منح دراسية كاملة وفقًا لمرسوم إحداث الجامعة.',
              'يجب أن يحقق معدل الطالب الحد الأدنى المطلوب للقبول.',
            ]),

            // ── Academic excellence ───────────────────────────────────
            _SectionTitle('مكافآت التفوق الأكاديمي'),
            _InfoCard(
              icon: Icons.info_outline_rounded,
              iconBg: _blueBg,
              iconColor: _blue,
              title: 'الشروط',
              body:
                  'إتمام ما لا يقل عن 30 ساعة معتمدة، وتسجيل ما لا يقل عن '
                  '15 ساعة معتمدة، باستثناء فصل التخرج.',
            ),
            const SizedBox(height: 12),
            // grade badges
            ..._excellenceGrades.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GradeBadgeCard(
                    percent: g.$1,
                    gpa: g.$2,
                    grade: g.$3,
                  ),
                )),

            // ── Sibling discount ──────────────────────────────────────
            _SectionTitle('منحة الإخوة'),
            _BulletCard(items: const [
              'حسم 15% من رسوم الساعات المعتمدة.',
              'يستمر الحسم حتى إذا تخرج أحد الإخوة.',
              'يُشترط وجود فصل دراسي واحد على الأقل يتزامن فيه تسجيل الإخوة في الجامعة.',
            ]),

            // ── Combining discounts ───────────────────────────────────
            _SectionTitle('الجمع بين الحسومات'),
            _BulletCard(items: const [
              'لا يمكن الجمع بين حسم الإخوة وحسم النقابة.',
              'يُطبَّق الحسم الأعلى منهما.',
              'الاستثناء: إذا وُجد ثلاثة إخوة مسجلين في الجامعة وكانوا أبناء عضو في إحدى النقابات المشمولة، فيُطبق حسم 20%.',
            ]),
          ],
        ),
      ),
    );
  }

  static const _excellenceGrades = [
    ('100%', '4.0 (A+)', 'المرتبة الأولى في التخصص'),
    ('25%',  '3.75 (A)',  ''),
    ('20%',  '3.5 (A-)',  ''),
    ('15%',  '3.25 (B+)', ''),
    ('10%',  '3.0 (B)',   ''),
  ];
}

// ── shared widgets ────────────────────────────────────────────────────────

PreferredSizeWidget _appBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: _white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded,
          color: _textDark, size: 20),
      onPressed: () => Navigator.of(context).pop(),
    ),
    centerTitle: true,
    title: Text(title,
        style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textDark)),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: _border),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4, height: 20,
            decoration: BoxDecoration(
                color: _blue, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(text,
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textDark)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.body,
  });
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(title,
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                          height: 1.3)),
                if (title.isNotEmpty && body.isNotEmpty)
                  const SizedBox(height: 4),
                if (body.isNotEmpty)
                  Text(body,
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: _textMute, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({required this.items});
  final List<String> items;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 7),
                        child: Icon(Icons.circle, size: 7, color: _blue),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(e,
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: _textMute,
                                  height: 1.6))),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// Card that shows a discount percentage badge prominently
class _GradeBadgeCard extends StatelessWidget {
  const _GradeBadgeCard({
    required this.percent,
    required this.gpa,
    required this.grade,
  });
  final String percent, gpa, grade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // percent badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: percent == '100%' ? _gold : _blueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              percent,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: percent == '100%' ?  const Color(0xFF073B4C) : _blue,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('معدل تراكمي $gpa',
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textDark)),
                if (grade.isNotEmpty)
                  Text(grade,
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: _textMute)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
