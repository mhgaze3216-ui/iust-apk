import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/doctor_repository.dart';
import '../../models/doctor_models.dart';
import 'doctor_academic_submission_screen.dart';
import 'doctor_announcements_screen.dart';
import 'doctor_assignments_screen.dart';
import 'doctor_attendance_screen.dart';
import 'doctor_final_exam_template_screen.dart';
import 'doctor_grades_screen.dart';
import 'doctor_midterm_schedule_screen.dart';
import 'doctor_midterm_template_screen.dart';
import 'doctor_student_questions_screen.dart';
import 'widgets/doctor_page_header.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);
const _gold = Color(0xFFF5B82E);

class DoctorCourseDetailsScreen extends StatefulWidget {
  final DoctorCourse course;

  const DoctorCourseDetailsScreen({super.key, required this.course});

  @override
  State<DoctorCourseDetailsScreen> createState() =>
      _DoctorCourseDetailsScreenState();
}

class _DoctorCourseDetailsScreenState extends State<DoctorCourseDetailsScreen> {
  void _openStudentsModal(BuildContext context) {
    final roster = DoctorRepository.roster;
    final searchCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final query = searchCtrl.text.trim();
          final filtered = query.isEmpty
              ? roster
              : roster
                  .where((s) =>
                      s.name.contains(query) || s.id.contains(query))
                  .toList();

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.78,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.groups_rounded,
                                color: _blue,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'قائمة الطلاب المسجلين',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _textMain,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${widget.course.courseName} — الشعبة ${widget.course.section}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: _textSub,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDFAF1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${roster.length} طالباً',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E9B5F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchCtrl,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'بحث باسم الطالب أو المعرف...',
                      hintStyle: GoogleFonts.cairo(
                        fontSize: 13,
                        color: _textSub,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _textSub,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: _lightBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد نتائج مطابقة',
                              style: GoogleFonts.cairo(
                                  color: _textSub, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1, color: _border),
                            itemBuilder: (ctx, i) {
                              final st = filtered[i];
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                leading: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: const Color(0xFFEDFAF1),
                                  child: Text(
                                    '${i + 1}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2E9B5F),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  st.name,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: _textMain,
                                  ),
                                ),
                                subtitle: Text(
                                  st.id,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: _textSub,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).then((_) => searchCtrl.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: DoctorPageHeader(
          title: c.courseName,
          subtitle: 'الشعبة ${c.section} · ${c.semester}',
          showBackButton: true,
          badgeText: 'بيانات تجريبية',
          badgeColor: const Color(0xFF16A34A),
          badgeBgColor: const Color(0xFFEDFAF1),
        ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // ── Course Hero Card ──
            _buildHeroCard(c),
            const SizedBox(height: 16),

            // ── Teaching Note / Academic Insight ──
            if (c.teachingNote != null && c.teachingNote!.isNotEmpty) ...[
              _buildTeachingNoteCard(c.teachingNote!),
              const SizedBox(height: 16),
            ],

            // ── 10 Functional Operations ──
            Text(
              'العمليات الأكاديمية للمقرر (10 عمليات نشطة)',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionsList(context, c),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildHeroCard(DoctorCourse c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: _blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.courseName,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textMain,
                      ),
                    ),
                    Text(
                      'الشعبة ${c.section} · ${c.activityType} · رمز المقرر: ${c.courseCode}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: _textSub,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 16),
          // Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today_rounded,
                  'اليوم والوقت',
                  '${c.day} ${c.startTime} - ${c.endTime}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.meeting_room_rounded,
                  'القاعة',
                  c.room != null && c.room!.isNotEmpty
                      ? 'القاعة ${c.room}'
                      : 'غير متوفر',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.groups_rounded,
                  'عدد الطلاب',
                  '${c.studentCount} طالباً',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.analytics_outlined,
                  'نسبة الإنجاز',
                  '${(c.progress * 100).round()}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _lightBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _blue),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
                  color: _textSub,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeachingNoteCard(String note) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE082)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFB78103),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ملاحظات تدريسية وتوجيه أكاديمي',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7A5200),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFECB3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.announcement_outlined,
                  size: 18,
                  color: Color(0xFFB78103),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C2500),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ملاحظة خاصة للمقرر لمراعاة الصعوبات الشائعة في الخطة التدريسية.',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: const Color(0xFF8D6E63),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsList(BuildContext context, DoctorCourse c) {
    final actions = [
      (
        'قائمة الطلاب',
        'عرض وتفقد الطلاب المسجلين (40 طالباً)',
        Icons.groups_rounded,
        const Color(0xFF8E44AD),
        const Color(0xFFF4ECF7),
        () => _openStudentsModal(context),
      ),
      (
        'تسجيل الحضور',
        'رصد الحضور والغياب والتأخر للشعبة',
        Icons.how_to_reg_rounded,
        _blue,
        const Color(0xFFEAF4FB),
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  DoctorAttendanceScreen(initialCourseId: c.courseId),
            ),
          );
        },
      ),
      (
        'سجل العلامات',
        'مفردات الدرجة (نصفي، عملي، نهائي) والاعتماد',
        Icons.grade_rounded,
        const Color(0xFF2E9B5F),
        const Color(0xFFEDFAF1),
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  DoctorGradesScreen(initialCourseId: c.courseId),
            ),
          );
        },
      ),
      (
        'التكليفات والواجبات',
        'متابعة تسليمات ونشاطات الطلاب',
        Icons.assignment_turned_in_rounded,
        const Color(0xFFE67E22),
        const Color(0xFFFDF2E9),
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  DoctorAssignmentsScreen(initialCourseId: c.courseId),
            ),
          );
        },
      ),
      (
        'أسئلة واستفسارات الطلاب',
        'الإجابة عن نقاشات وأسئلة الشعبة',
        Icons.help_outline_rounded,
        _gold,
        const Color(0xFFFFF4D6),
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  DoctorStudentQuestionsScreen(initialCourseId: c.courseId),
            ),
          );
        },
      ),
      (
        'إعلانات المقرر',
        'نشر تنبيه أو تعليمات أكاديمية للطلاب',
        Icons.campaign_rounded,
        _navy,
        const Color(0xFFE8F0F2),
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DoctorAnnouncementsScreen(),
            ),
          );
        },
      ),
      (
        'نموذج الامتحان النصفي',
        'معاينة واعتماد أسئلة الامتحان النصفي (30 درجة)',
        Icons.quiz_rounded,
        const Color(0xFF0F6CBD),
        const Color(0xFFEAF4FB),
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DoctorMidtermTemplateScreen(),
            ),
          );
        },
      ),
      (
        'نموذج الامتحان النهائي',
        'معاينة أسئلة الامتحان النهائي وتعليمات التصحيح (100 درجة)',
        Icons.assignment_rounded,
        const Color(0xFF16A085),
        const Color(0xFFE8F8F5),
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DoctorFinalExamTemplateScreen(),
            ),
          );
        },
      ),
      (
        'برنامج الامتحانات',
        'مواعيد وقاعات الامتحانات النصفية والنهائية',
        Icons.calendar_month_rounded,
        const Color(0xFFC0392B),
        const Color(0xFFFCEAE8),
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DoctorMidtermScheduleScreen(),
            ),
          );
        },
      ),
      (
        'رفع النتائج للإدارة',
        'معاملة تسليم النتائج والمحاضر الموقعة إلكترونياً',
        Icons.drive_folder_upload_rounded,
        const Color(0xFF6B21A8),
        const Color(0xFFF3E8FF),
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DoctorAcademicSubmissionScreen(),
            ),
          );
        },
      ),
    ];

    return Column(
      children: actions.map((act) {
        final (title, sub, icon, iconColor, iconBg, onTap) = act;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textMain,
                            ),
                          ),
                          Text(
                            sub,
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: _textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: _textSub,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
