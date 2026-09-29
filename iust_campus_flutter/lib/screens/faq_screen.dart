import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _blue     = Color(0xFF0d6efd);
const _lightBg  = Color(0xFFF4F7FE);
const _white    = Colors.white;
const _blueBg   = Color(0xFFEEF4FF);
const _textDark = Color(0xFF0a2540);
const _textMute = Color(0xFF64748B);
const _border   = Color(0xFFE2E8F4);

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    (
      'ما هو نظام الدراسة في الجامعة؟',
      'نظام فصلي يعتمد الساعات المعتمدة.',
    ),
    (
      'ما هي لغات التدريس؟',
      'اللغة الإنجليزية واللغة العربية.',
    ),
    (
      'هل الحضور إلزامي؟',
      'نعم، الحضور إلزامي.',
    ),
    (
      'ماذا يحدث إذا كان المعدل التراكمي أقل من 2.25؟',
      'لا يستطيع الطالب التسجيل إلكترونيًا، ويجب عليه مراجعة مرشده الأكاديمي.',
    ),
    (
      'ما هي الساعة المعتمدة؟',
      'وحدة أكاديمية تعادل حضور 16 محاضرة نظرية، مدة كل محاضرة ساعة واحدة.',
    ),
    (
      'ما هي الخطة الدراسية؟',
      'مجموع الساعات المعتمدة التي أقرّها مجلس التعليم العالي والتي يجب إتمامها للحصول على درجة البكالوريوس.',
    ),
    (
      'ما هو العبء الدراسي؟',
      'عدد الساعات المعتمدة التي يُسمح للطالب بتسجيلها في فصل دراسي واحد.',
    ),
    (
      'هل مدة الانقطاع عن الدراسة تُحتسب؟',
      'نعم، تُحتسب ضمن الحد الأقصى المسموح به لمدة الدراسة.',
    ),
    (
      'كيف أعود بعد الانقطاع لمدة فصل واحد؟',
      'تعبئة استمارة عودة إلى الدوام، دفع 25,000 ليرة سورية، ثم إعادة التسجيل.',
    ),
    (
      'كيف أعود بعد الانقطاع لمدة فصلين؟',
      'تعبئة استمارة إعادة تسجيل، ويُعامل الطالب ماليًا معاملة الطالب المستجد.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, 'الأسئلة العامة'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: _faqs.map((faq) {
            final (question, answer) = faq;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FaqTile(question: question, answer: answer),
            );
          }).toList(),
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

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});
  final String question, answer;
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: _expanded
                ? _blue.withValues(alpha: 0.35)
                : _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _expanded ? _blue : _blueBg,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        _expanded
                            ? Icons.remove_rounded
                            : Icons.add_rounded,
                        color: _expanded ? _white : _blue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.question,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _expanded ? _blue : _textDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: _border),
                  const SizedBox(height: 12),
                  Text(
                    widget.answer,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: _textMute,
                        height: 1.7),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
