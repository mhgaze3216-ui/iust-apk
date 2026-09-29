import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/doctor_demo_data.dart';
import '../../models/doctor_models.dart';
import 'widgets/doctor_page_header.dart';
import 'widgets/doctor_back_button.dart';

typedef DoctorQuestionsScreen = DoctorStudentQuestionsScreen;

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);
const _gold = Color(0xFFF5B82E);

class DoctorStudentQuestionsScreen extends StatefulWidget {
  final String? initialCourseId;
  const DoctorStudentQuestionsScreen({super.key, this.initialCourseId});

  @override
  State<DoctorStudentQuestionsScreen> createState() =>
      _DoctorStudentQuestionsScreenState();
}

class _DoctorStudentQuestionsScreenState
    extends State<DoctorStudentQuestionsScreen> {
  void _openReplyDialog(DoctorStudentQuestion q) {
    final replyCtrl = TextEditingController(text: q.answer ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'الإجابة على سؤال الطالب',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                'السؤال من: ${q.studentName} (${q.courseName})',
                style: GoogleFonts.cairo(
                    fontSize: 12, fontWeight: FontWeight.w700, color: _blue),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _lightBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  q.question,
                  style: GoogleFonts.cairo(
                      fontSize: 12.5, color: _textMain, height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: replyCtrl,
                maxLines: 4,
                style: GoogleFonts.cairo(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'نص إجابة الدكتور...',
                  labelStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء',
                  style: GoogleFonts.cairo(color: _textSub)),
            ),
            ElevatedButton(
              onPressed: () {
                if (replyCtrl.text.trim().isEmpty) return;
                DoctorDemoData.replyToQuestion(q.id, replyCtrl.text.trim());
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حفظ الإجابة وإرسالها للطالب بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: const Color(0xFF2E9B5F),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: _white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('إرسال الإجابة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    ).then((_) => replyCtrl.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final questions = DoctorDemoData.questions;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: const DoctorPageHeader(
          title: 'أسئلة واستفسارات الطلاب',
          subtitle: 'الإجابة المباشرة على استفسارات ونقاشات المحاضرات',
          showBackButton: true,
        ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.question_answer_rounded,
                        color: Color(0xFFB78103), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استفسارات الطلاب الأكاديمية',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _textMain,
                          ),
                        ),
                        Text(
                          'إجابة مباشرة وتوضيحات على استفسارات المحاضرات',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            color: _textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...questions.map((q) {
              final isAnswered = q.status == 'تمت الإجابة';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            q.studentName,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isAnswered
                                ? const Color(0xFFEDFAF1)
                                : const Color(0xFFFDF2E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            q.status,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isAnswered
                                  ? const Color(0xFF2E9B5F)
                                  : const Color(0xFFE67E22),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${q.courseName} · ${q.createdAt}',
                      style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      q.question,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textMain,
                        height: 1.4,
                      ),
                    ),
                    if (q.answer != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDFAF1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD5F5E3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 16, color: Color(0xFF2E9B5F)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'رد الدكتور: ${q.answer}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: const Color(0xFF1E6B37),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _openReplyDialog(q),
                          icon: Icon(
                            isAnswered
                                ? Icons.edit_note_rounded
                                : Icons.reply_rounded,
                            size: 16,
                          ),
                          label: Text(
                            isAnswered ? 'تعديل الإجابة' : 'إجابة الآن',
                            style: GoogleFonts.cairo(
                                fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isAnswered ? const Color(0xFF2E9B5F) : _navy,
                            foregroundColor: _white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );
  }
}
