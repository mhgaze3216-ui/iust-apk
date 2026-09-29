import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/doctor_page_header.dart';
import 'widgets/doctor_back_button.dart';
import 'doctor_grades_screen.dart';
import 'doctor_attendance_screen.dart';
import 'doctor_assignments_screen.dart';
import 'doctor_announcements_screen.dart';
import 'doctor_student_questions_screen.dart';
import 'doctor_academic_submission_screen.dart';
import 'doctor_exam_center_screen.dart';
import 'doctor_midterm_schedule_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);
const _gold = Color(0xFFF5B82E);

class DoctorQuickActionsScreen extends StatelessWidget {
  const DoctorQuickActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        'سجل العلامات',
        'إدخال ومراجعة الدرجات والسلالم',
        Icons.grade_rounded,
        _blue,
        const Color(0xFFEAF4FB),
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DoctorGradesScreen()),
        ),
      ),
      (
        'تسجيل الحضور',
        'رصد الحضور والغياب اليومي',
        Icons.how_to_reg_rounded,
        const Color(0xFF2E9B5F),
        const Color(0xFFEDFAF1),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DoctorAttendanceScreen(showBack: true),
          ),
        ),
      ),
      (
        'تكليف جديد',
        'إنشاء ونشر مهمة جديدة للشعب',
        Icons.add_task_rounded,
        const Color(0xFFE67E22),
        const Color(0xFFFDF2E9),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const DoctorAssignmentsScreen(openNewAssignmentOnLaunch: true),
          ),
        ),
      ),
      (
        'إعلان المقرر',
        'إرسال تعميم أو تنبيه رسمي',
        Icons.campaign_rounded,
        _navy,
        const Color(0xFFE8F0F2),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const DoctorAnnouncementsScreen(openNewAnnouncementOnLaunch: true),
          ),
        ),
      ),
      (
        'أسئلة الطلاب',
        'متابعة الاستفسارات الأكاديمية والرد',
        Icons.question_answer_rounded,
        _gold,
        const Color(0xFFFFF4D6),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DoctorStudentQuestionsScreen(),
          ),
        ),
      ),
      (
        'رفع النتائج للإدارة',
        'اعتماد وتدقيق الكشوف إلكترونياً',
        Icons.drive_folder_upload_rounded,
        const Color(0xFF8E44AD),
        const Color(0xFFF4ECF7),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DoctorAcademicSubmissionScreen(),
          ),
        ),
      ),
      (
        'برنامج الامتحانات',
        'جدول مواعيد وقاعات النصفي والنهائي',
        Icons.calendar_month_rounded,
        const Color(0xFFC0392B),
        const Color(0xFFFCEAE8),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DoctorMidtermScheduleScreen(),
          ),
        ),
      ),
      (
        'نماذج الامتحانات',
        'نماذج النصفي والنهائي المعتمدة',
        Icons.description_rounded,
        const Color(0xFF16A085),
        const Color(0xFFE8F8F5),
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DoctorExamCenterScreen(),
          ),
        ),
      ),
    ];

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: const DoctorPageHeader(
          title: 'جميع العمليات والإجراءات',
          subtitle: '8 إجراءات وعمليات أكاديمية متكاملة',
          showBackButton: true,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.flash_on_rounded,
                        color: Color(0xFFB78103),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'لوحة العمليات الأكاديمية السريعة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _textMain,
                            ),
                          ),
                          Text(
                            'كافة العمليات اليومية وإدارة الشعب والامتحانات',
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  final crossAxisCount = isWide ? 3 : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: actions.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 114,
                    ),
                    itemBuilder: (context, index) {
                      final (title, subtitle, icon, iconColor, iconBg, onTap) =
                          actions[index];
                      return _ActionGridCard(
                        title: title,
                        subtitle: subtitle,
                        icon: icon,
                        iconColor: iconColor,
                        iconBg: iconBg,
                        onTap: onTap,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _ActionGridCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: _textSub,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: _textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
