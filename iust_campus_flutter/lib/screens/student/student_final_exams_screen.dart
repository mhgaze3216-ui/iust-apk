import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/student_repository.dart';
import '../../models/student_models.dart';
import '../../services/student_session.dart';

const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);
const _green     = Color(0xFF2E9B5F);
const _greenLight= Color(0xFFEDFAF1);

// ─────────────────────────────────────────────────────────────────────────────
// Student Final Exams Screen
// Displays the official confirmed final exams schedule filtered for the
// active student's currently enrolled courses.
// ─────────────────────────────────────────────────────────────────────────────

class StudentFinalExamsScreen extends StatelessWidget {
  final String? studentId;
  const StudentFinalExamsScreen({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    final sid = studentId ?? StudentSession.currentStudentId;
    final profile = StudentRepository.getStudent(sid) ?? StudentSession.currentProfile;
    final enrolledCourses = StudentRepository.getEnrolledCourses(sid);
    final confirmedExams = StudentRepository.getFinalExams(sid);

    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'جدول الامتحانات النهائية',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain),
          ),
          Text(
            profile.currentSemesterNameAr,
            style: GoogleFonts.cairo(fontSize: 11, color: _textSub, fontWeight: FontWeight.w600),
          ),
        ]),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Info banner ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _blue.withValues(alpha: 0.2)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, color: _blue, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'يتم إدراج مواعيد الامتحانات النهائية المؤكدة فقط وفق الجداول الرسمية المعلنة من الكلية.',
                    style: GoogleFonts.cairo(fontSize: 12, color: _blue, height: 1.5),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Course exam cards ──────────────────────────────────────────
            if (enrolledCourses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'لا توجد مواد مسجلة حالياً',
                    style: GoogleFonts.cairo(color: _textSub),
                  ),
                ),
              )
            else
              ...enrolledCourses.map((course) {
                FinalExam? exam;
                for (final e in confirmedExams) {
                  if (e.courseCode == course.courseCode) {
                    exam = e;
                    break;
                  }
                }
                return _ExamCard(course: course, exam: exam);
              }),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Course course;
  final FinalExam? exam;

  const _ExamCard({required this.course, this.exam});

  @override
  Widget build(BuildContext context) {
    final hasConfirmedExam = exam != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasConfirmedExam ? _blue.withValues(alpha: 0.3) : _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: Course name & status badge
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                course.courseNameAr,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'رمز المقرر: ${course.courseCode}  ·  ${course.creditHours} ساعات معتمدة',
                style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hasConfirmedExam ? _greenLight : const Color(0xFFF1F4F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hasConfirmedExam ? 'موعد مؤكد' : 'غير محدد',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: hasConfirmedExam ? _green : _textSub,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1, color: _border),
        const SizedBox(height: 12),

        // Body: Confirmed details or unconfirmed notice
        if (hasConfirmedExam) ...[
          Row(children: [
            const Icon(Icons.event_available_rounded, size: 16, color: _blue),
            const SizedBox(width: 8),
            Text(
              '${exam!.day}  ·  ${exam!.date}',
              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: _textMain),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.access_time_rounded, size: 16, color: _blue),
            const SizedBox(width: 8),
            Text(
              'التوقيت: ${exam!.startTime} – ${exam!.endTime}',
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: _textSub),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'امتحان ${exam!.examType}',
                style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: _blue),
              ),
            ),
          ]),
        ] else ...[
          Row(children: [
            const Icon(Icons.pending_actions_rounded, size: 16, color: _textSub),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'لا يوجد موعد نهائي مؤكد لهذه المادة حالياً',
                style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}
