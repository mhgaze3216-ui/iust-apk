import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/student_repository.dart';
import '../../services/student_session.dart';
import '../../models/student_models.dart';

const _blue     = Color(0xFF0F6CBD);
const _lightBg  = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _white    = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub  = Color(0xFF6F7F89);
const _border   = Color(0xFFDCE8EE);

class StudentRegistrationScreen extends StatelessWidget {
  final String? studentId;
  const StudentRegistrationScreen({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    final sid = studentId ?? StudentSession.currentStudentId;
    final p = StudentRepository.getStudent(sid) ?? StudentSession.currentProfile;
    final enrolledCourses = StudentRepository.getEnrolledCourses(sid);
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, 'تسجيل المقررات'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // semester info
            _InfoCard(
              icon: Icons.event_note_rounded,
              iconBg: _lightBlue, iconColor: _blue,
              title: 'الفصل الحالي',
              body: '${p.currentSemesterNameAr}  ·  ${p.academicYear}',
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.access_time_rounded,
              iconBg: const Color(0xFFFFF8E1), iconColor: const Color(0xFFD4900A),
              title: 'الساعات المسجلة حالياً',
              body: '${p.currentRegisteredCreditHours} ساعات معتمدة',
            ),
            const SizedBox(height: 20),
            Text('المواد المسجلة حالياً',
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain)),
            const SizedBox(height: 10),
            if (enrolledCourses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('لا توجد مواد مسجلة حالياً',
                    style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
              )
            else
              ...enrolledCourses.map((c) => _CurrentCourseCard(course: c)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _blue.withValues(alpha: 0.25)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, color: _blue, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  'إضافة أو حذف المقررات متاح خلال فترة الإضافة والحذف فقط. '
                  'تواصل مع دائرة التسجيل للمزيد.',
                  style: GoogleFonts.cairo(fontSize: 12, color: _blue, height: 1.6),
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentCourseCard extends StatelessWidget {
  const _CurrentCourseCard({required this.course});
  final Course course;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.menu_book_rounded, color: _blue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(course.courseNameAr,
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
          Text('${course.courseCode}  ·  ${course.creditHours} ساعة',
              style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFEDFAF1), borderRadius: BorderRadius.circular(8)),
          child: Text('مسجل', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2E9B5F))),
        ),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.iconBg, required this.iconColor, required this.title, required this.body});
  final IconData icon; final Color iconBg, iconColor; final String title, body;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(width: 40, height: 40, alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
            Text(body, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
          ])),
        ]),
      );
}

PreferredSizeWidget _appBar(BuildContext ctx, String title) => AppBar(
      backgroundColor: _white, elevation: 0, surfaceTintColor: Colors.transparent,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textMain), onPressed: () => Navigator.of(ctx).pop()),
      centerTitle: true,
      title: Text(title, style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: _textMain)),
      bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: _border)),
    );
