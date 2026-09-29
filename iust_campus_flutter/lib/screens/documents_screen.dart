import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _blue     = Color(0xFF0d6efd);
const _lightBg  = Color(0xFFF4F7FE);
const _white    = Colors.white;
const _gold     = Color(0xFFc9a84c);
const _blueBg   = Color(0xFFEEF4FF);
const _goldBg   = Color(0xFFFFF8E1);
const _textDark = Color(0xFF0a2540);
const _textMute = Color(0xFF64748B);
const _border   = Color(0xFFE2E8F4);

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, 'المستندات المطلوبة'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── Sibling discount documents ────────────────────────────
            _SectionTitle('منحة الإخوة'),
            _ChecklistCard(items: const [
              'الهويات الشخصية للإخوة، أو',
              'صورة عن دفتر العائلة تتضمن:\n  • صفحة الأب\n  • صفحة الأم\n  • صفحات الإخوة المسجلين في الجامعة',
            ]),

            // ── Union discount documents ──────────────────────────────
            _SectionTitle('الحسم المرتبط بالنقابة'),
            _ChecklistCard(items: const [
              'وثيقة رسمية تثبت انتساب الأب أو الأم إلى النقابة.',
              'بطاقة النقابة وحدها غير كافية.',
            ]),

            // ── Via mother ────────────────────────────────────────────
            _SectionTitle('عند التقدم للحصول على الحسم عن طريق الأم'),
            _ChecklistCard(items: const [
              'وثيقة رسمية من النقابة.',
              'دفتر العائلة.',
            ]),

            // ── Note ──────────────────────────────────────────────────
            const SizedBox(height: 20),
            _NoteCard(
              text:
                  'تُقدَّم الوثيقة مرة واحدة، وتبقى صالحة حتى تخرج الطالب.',
            ),
          ],
        ),
      ),
    );
  }
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
          Expanded(
            child: Text(text,
                style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textDark)),
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.items});
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
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _blueBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 13, color: _blue),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(e,
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: _textMute,
                                height: 1.65)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _goldBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: _gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _gold,
                    height: 1.6)),
          ),
        ],
      ),
    );
  }
}
