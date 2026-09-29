import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'guest/widgets/guest_header.dart';

// ── palette (mirrors WelcomeScreen _C) ────────────────────────────────────
const _blue     = Color(0xFF0d6efd);
const _lightBg  = Color(0xFFF4F7FE);
const _white    = Colors.white;
const _gold     = Color(0xFFc9a84c);
const _blueBg   = Color(0xFFEEF4FF);
const _goldBg   = Color(0xFFFFF8E1);
const _textDark = Color(0xFF0a2540);
const _textMute = Color(0xFF64748B);
const _border   = Color(0xFFE2E8F4);

class UniversityInfoScreen extends StatelessWidget {
  final bool isRootTab;
  const UniversityInfoScreen({super.key, this.isRootTab = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: isRootTab
          ? const GuestHeader()
          : _buildAppBar(context, 'عن الجامعة', isRootTab: false),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, isRootTab ? 110 : 32),
          children: [
            // ── intro ─────────────────────────────────────────────────
            _InfoCard(
              icon: Icons.account_balance_rounded,
              iconBg: _blueBg,
              iconColor: _blue,
              title: 'الجامعة الدولية الخاصة للعلوم والتكنولوجيا',
              body:
                  'جامعة سورية خاصة، تهدف إلى تقديم المعرفة برؤية واسعة وطموحة، '
                  'وأن تصبح مركزًا عالميًا متميزًا للإبداع والبحث العلمي.',
            ),

            // ── philosophy ────────────────────────────────────────────
            _SectionTitle('فلسفة الجامعة'),
            _BulletCard(items: const [
              'التعليم.',
              'البحث العلمي.',
              'خدمة المجتمع.',
            ]),

            // ── academic system ───────────────────────────────────────
            _SectionTitle('النظام الأكاديمي'),
            _InfoCard(
              icon: Icons.school_rounded,
              iconBg: _blueBg,
              iconColor: _blue,
              title: 'نظام الدراسة',
              body:
                  'نظام فصلي يعتمد الساعات المعتمدة. '
                  'لغات التدريس: الإنجليزية والعربية. '
                  'الحضور إلزامي. '
                  'الطالب الذي يقل معدله التراكمي عن 2.25 لا يستطيع التسجيل '
                  'إلكترونيًا، ويجب عليه مراجعة مرشده الأكاديمي. '
                  'تُحتسب مدة الانقطاع ضمن الحد الأقصى المسموح به.',
            ),

            // ── definitions ───────────────────────────────────────────
            _SectionTitle('التعريفات'),
            _DefinitionCard(
              term: 'الساعة المعتمدة',
              definition:
                  'وحدة أكاديمية تعادل حضور 16 محاضرة نظرية، مدة كل محاضرة ساعة واحدة.',
              iconBg: _blueBg,
              iconColor: _blue,
            ),
            const SizedBox(height: 10),
            _DefinitionCard(
              term: 'الخطة الدراسية',
              definition:
                  'مجموع الساعات المعتمدة التي أقرّها مجلس التعليم العالي، '
                  'والتي يجب على الطالب إتمامها للحصول على درجة البكالوريوس.',
              iconBg: _goldBg,
              iconColor: _gold,
            ),
            const SizedBox(height: 10),
            _DefinitionCard(
              term: 'العبء الدراسي',
              definition:
                  'عدد الساعات المعتمدة التي يُسمح للطالب بتسجيلها في فصل دراسي واحد.',
              iconBg: const Color(0xFFEDFAF1),
              iconColor: const Color(0xFF2E9B5F),
            ),

            // ── services ──────────────────────────────────────────────
            _SectionTitle('ما توفره الجامعة'),
            _BulletCard(items: const [
              'مختبرات وورشات عمل حديثة.',
              'أنظمة للتعلّم الإلكتروني.',
              'مكتبات إلكترونية وشبكات معلومات.',
              'اتصال سريع بالإنترنت.',
              'برامج للتطوير الأكاديمي لأعضاء الهيئة التدريسية.',
              'اتفاقيات تعاون دولية مع جامعات حول العالم.',
              'حاضنات تكنولوجية ومبادرات بحثية.',
            ]),

            // ── faculties (text only) ─────────────────────────────────
            _SectionTitle('كليات الجامعة'),
            _InfoCard(
              icon: Icons.account_balance_rounded,
              iconBg: _blueBg,
              iconColor: _blue,
              title: 'ست كليات',
              body:
                  'تضم الجامعة ست كليات: إدارة الأعمال والتمويل، الهندسة المعمارية، '
                  'الهندسة والتكنولوجيا، طب الأسنان، الصيدلة، والآداب والعلوم.',
            ),

            // ── engineering vision ────────────────────────────────────
            _SectionTitle('رؤية التعليم الهندسي'),
            _InfoCard(
              icon: Icons.engineering_rounded,
              iconBg: _blueBg,
              iconColor: _blue,
              title: 'الريادة في التعليم الهندسي',
              body:
                  'تسعى الجامعة إلى تحقيق الريادة في التعليم الهندسي من خلال '
                  'تقديم برامج هندسية متميزة ومتوافقة مع احتياجات سوق العمل، '
                  'والمساهمة في تنمية المجتمع. '
                  'كما تهدف إلى توفير بيئة أكاديمية يتفاعل فيها الطلاب وأعضاء '
                  'الهيئة التدريسية لتحقيق التنافسية والريادة على المستويين '
                  'المحلي والإقليمي.',
            ),

            // ── mission ───────────────────────────────────────────────
            _SectionTitle('رسالة الجامعة'),
            _InfoCard(
              icon: Icons.flag_rounded,
              iconBg: _goldBg,
              iconColor: _gold,
              title: 'إعداد خريجين قادرين على',
              body: '',
            ),
            _BulletCard(items: const [
              'الابتكار والعمل الجماعي.',
              'التعلّم مدى الحياة.',
              'تبادل المعرفة.',
              'إجراء البحوث العلمية والتكنولوجية.',
              'خدمة المجتمع.',
            ]),

            // ── academic guidance ─────────────────────────────────────
            _SectionTitle('رؤية الإرشاد الأكاديمي'),
            _InfoCard(
              icon: Icons.support_agent_rounded,
              iconBg: const Color(0xFFF5F0FF),
              iconColor: const Color(0xFF7C3AED),
              title: 'الإرشاد الأكاديمي',
              body:
                  'عملية منظمة تهدف إلى تحديد المشكلات التي تعيق التحصيل '
                  'الأكاديمي للطلاب وتكيّفهم مع الحياة الجامعية.',
            ),
          ],
        ),
      ),
    );
  }
}

// ── shared widgets ────────────────────────────────────────────────────────

PreferredSizeWidget _buildAppBar(BuildContext context, String title, {bool isRootTab = false}) {
  return AppBar(
    backgroundColor: _white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    automaticallyImplyLeading: false,
    leading: isRootTab
        ? null
        : IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
    centerTitle: true,
    title: Text(
      title,
      style: GoogleFonts.cairo(
          fontSize: 17, fontWeight: FontWeight.w800, color: _textDark),
    ),
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
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(2),
            ),
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
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
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
                          fontSize: 13,
                          color: _textMute,
                          height: 1.6)),
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
            offset: const Offset(0, 2),
          ),
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
                        child: Icon(Icons.circle,
                            size: 7, color: _blue),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(e,
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: _textMute,
                                height: 1.6)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _DefinitionCard extends StatelessWidget {
  const _DefinitionCard({
    required this.term,
    required this.definition,
    required this.iconBg,
    required this.iconColor,
  });
  final String term, definition;
  final Color iconBg, iconColor;

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(term,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: iconColor)),
          ),
          const SizedBox(height: 8),
          Text(definition,
              style: GoogleFonts.cairo(
                  fontSize: 13, color: _textMute, height: 1.6)),
        ],
      ),
    );
  }
}

