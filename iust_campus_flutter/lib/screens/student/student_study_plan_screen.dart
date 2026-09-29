import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/student_repository.dart';
import '../../data/informatics_study_plan_data.dart';
import '../../services/student_session.dart';
import '../../models/student_models.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _gold      = Color(0xFFF5B82E);
const _goldLight = Color(0xFFFFF4D6);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class StudentStudyPlanScreen extends StatefulWidget {
  final String? studentId;
  const StudentStudyPlanScreen({super.key, this.studentId});
  @override
  State<StudentStudyPlanScreen> createState() => _StudentStudyPlanScreenState();
}

class _StudentStudyPlanScreenState extends State<StudentStudyPlanScreen> {
  int _expandedYear = 3; // default open on current year for year-based plans
  final Set<String> _collapsedCategories = <String>{};

  String get _studentId => widget.studentId ?? StudentSession.currentStudentId;

  @override
  Widget build(BuildContext context) {
    final sid = _studentId;
    final planCourses = StudentRepository.getStudyPlanCourses(sid);
    final studyPlan = StudentRepository.getStudyPlan(sid);
    final profile = StudentRepository.getStudent(sid) ?? StudentSession.currentProfile;

    final hasCategories = planCourses.any((c) => c.category != null);

    final totalCredits = studyPlan?.requiredCreditHours ??
        planCourses.fold<int>(0, (s, c) => s + c.credits);
    final completed = studyPlan?.completedCreditHours ??
        planCourses
            .where((c) => StudentRepository.hasPassedCourse(sid, c))
            .fold<int>(0, (s, c) => s + c.credits);
    final remaining = studyPlan?.remainingCreditHours ??
        (totalCredits > completed ? totalCredits - completed : 0);

    final isMustafa = sid == 'student-informatics-002';
    final completedCoursesCount = isMustafa ? 59 : null;

    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, 'الخطة الدراسية — ${profile.facultyNameAr}'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(children: [
          // ── progress header ──────────────────────────────────────────
          Container(
            color: _white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: Text(
                    'التقدم نحو التخرج',
                    style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                  ),
                ),
                Text(
                  '$completed / $totalCredits ساعة',
                  style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: _navy),
                ),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalCredits > 0 ? completed / totalCredits : 0,
                  backgroundColor: _border,
                  valueColor: const AlwaysStoppedAnimation<Color>(_navy),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 10),

              // ── Stats Summary ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _SummaryStat(label: 'المطلوبة', value: '$totalCredits س', color: _navy)),
                  Expanded(child: _SummaryStat(label: 'المجتازة', value: '$completed س', color: const Color(0xFF2E9B5F))),
                  Expanded(child: _SummaryStat(label: 'المتبقية', value: '$remaining س', color: const Color(0xFFE53E3E))),
                  if (completedCoursesCount != null)
                    Expanded(child: _SummaryStat(label: 'المواد المنجزة', value: '$completedCoursesCount مادة', color: _blue)),
                ],
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _StatusPill('مكتمل', const Color(0xFF2E9B5F), const Color(0xFFEDFAF1)),
                _StatusPill('مسجل حالياً', _gold, _goldLight),
                _StatusPill('متبقي', _textSub, _border),
              ]),
            ]),
          ),
          const Divider(height: 1, color: _border),

          // ── courses list: categories vs years ─────────────────────────
          if (planCourses.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_rounded,
                          size: 48, color: _textSub.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text('الخطة الدراسية التفصيلية غير متوفرة حالياً',
                          style: GoogleFonts.cairo(fontSize: 14, color: _textSub)),
                    ],
                  ),
                ),
              ),
            )
          else if (hasCategories)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                children: kInformaticsCategories.map((category) {
                  final catCourses = planCourses.where((c) => c.category == category).toList();
                  if (catCourses.isEmpty) return const SizedBox.shrink();
                  final isCollapsed = _collapsedCategories.contains(category);
                  return _CategorySection(
                    studentId: sid,
                    category: category,
                    courses: catCourses,
                    isCollapsed: isCollapsed,
                    onToggle: () {
                      setState(() {
                        if (isCollapsed) {
                          _collapsedCategories.remove(category);
                        } else {
                          _collapsedCategories.add(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            )
          else
            Expanded(
              child: _buildYearBasedList(sid, planCourses),
            ),
        ]),
      ),
    );
  }

  Widget _buildYearBasedList(String sid, List<StudyPlanCourse> planCourses) {
    final byYear = <int, Map<int, List<StudyPlanCourse>>>{};
    for (final c in planCourses) {
      byYear.putIfAbsent(c.yearNumber, () => {});
      byYear[c.yearNumber]!.putIfAbsent(c.semesterNumber, () => []);
      byYear[c.yearNumber]![c.semesterNumber]!.add(c);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      children: List.generate(5, (yi) {
        final year = yi + 1;
        final semesters = byYear[year] ?? {};
        final isOpen = _expandedYear == year;
        return _YearSection(
          studentId: sid,
          year: year,
          semesters: semesters,
          isOpen: isOpen,
          onToggle: () => setState(() => _expandedYear = isOpen ? 0 : year),
        );
      }),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: GoogleFonts.cairo(fontSize: 10, color: _textSub)),
      ]);
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.label, this.color, this.bg);
  final String label;
  final Color color, bg;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Section (Informatics style)
// ─────────────────────────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final String studentId;
  final String category;
  final List<StudyPlanCourse> courses;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const _CategorySection({
    required this.studentId,
    required this.category,
    required this.courses,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final totalCredits = courses.fold<int>(0, (s, c) => s + c.credits);
    final confirmedCount = courses.where((c) => StudentRepository.hasPassedCourse(studentId, c)).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _white,
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
      child: Column(children: [
        // Category Header
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.folder_outlined, color: _blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    category,
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: _textMain),
                  ),
                  Text(
                    '${courses.length} مقرر  ·  $totalCredits ساعة معتمدة'
                    '${confirmedCount > 0 ? "  ·  $confirmedCount مكتمل" : ""}',
                    style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                  ),
                ]),
              ),
              Icon(isCollapsed ? Icons.expand_more_rounded : Icons.expand_less_rounded, color: _textSub),
            ]),
          ),
        ),

        // Course list
        if (!isCollapsed) ...[
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              children: courses.map((c) => _CourseDetailCard(studentId: studentId, course: c)).toList(),
            ),
          ),
        ],
      ]),
    );
  }
}

class _CourseDetailCard extends StatelessWidget {
  final String studentId;
  final StudyPlanCourse course;

  const _CourseDetailCard({required this.studentId, required this.course});

  @override
  Widget build(BuildContext context) {
    final passed = StudentRepository.hasPassedCourse(studentId, course);
    final enrolledCourses = StudentRepository.getEnrolledCourses(studentId);
    final enrolledCodes = enrolledCourses
        .map((c) => c.courseCode)
        .toSet();

    final current = !passed &&
        ((course.courseCode != null && enrolledCodes.contains(course.courseCode)) ||
         (course.secondaryCourseCode != null && enrolledCodes.contains(course.secondaryCourseCode)));

    Color statusColor;
    Color statusBg;
    String statusLabel;
    if (passed) {
      statusColor = const Color(0xFF2E9B5F);
      statusBg = const Color(0xFFEDFAF1);
      statusLabel = 'مكتمل';
    } else if (current) {
      statusColor = _gold;
      statusBg = _goldLight;
      statusLabel = 'مسجل حالياً';
    } else {
      statusColor = _textSub;
      statusBg = _border;
      statusLabel = 'متبقي';
    }

    final prereqText = course.prerequisites.isNotEmpty
        ? course.prerequisites.join(' ، ')
        : (course.prerequisiteText ?? 'لا يوجد');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: passed ? const Color(0xFFF9FFF9) : _lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: passed ? const Color(0xFFC8E6C9) : _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (passed)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.check_circle_rounded, color: Color(0xFF2E9B5F), size: 16),
            )
          else if (current)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.radio_button_checked_rounded, color: _gold, size: 16),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.radio_button_unchecked_rounded, color: _textSub, size: 16),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                course.courseNameAr,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 2),
              Row(children: [
                if (course.courseCode != null) ...[
                  Text(
                    'الرمز: ${course.courseCode}',
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: _textSub),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  '${course.credits} س.م',
                  style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                ),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
            child: Text(
              statusLabel,
              style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _border.withValues(alpha: 0.7)),
          ),
          child: Row(children: [
            const Icon(Icons.link_rounded, size: 13, color: _textSub),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'المتطلب السابق: $prereqText',
                style: GoogleFonts.cairo(fontSize: 10, color: _textSub),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Year Section (Dentistry style)
// ─────────────────────────────────────────────────────────────────────────────

class _YearSection extends StatelessWidget {
  const _YearSection({
    required this.studentId,
    required this.year,
    required this.semesters,
    required this.isOpen,
    required this.onToggle,
  });
  final String studentId;
  final int year;
  final Map<int, List<StudyPlanCourse>> semesters;
  final bool isOpen;
  final VoidCallback onToggle;

  static const _arabic = ['', 'الأولى', 'الثانية', 'الثالثة', 'الرابعة', 'الخامسة'];

  @override
  Widget build(BuildContext context) {
    final allRows = semesters.values.expand((v) => v).toList();
    final done = allRows.where((c) => StudentRepository.hasPassedCourse(studentId, c)).length;
    final total = allRows.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        // header
        InkWell(
          onTap: onToggle,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(10)),
                child: Text('$year', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _blue)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('السنة ${_arabic[year]}',
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: _textMain)),
                Text('$done / $total مادة مكتملة',
                    style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
              ])),
              Icon(isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: _textSub),
            ]),
          ),
        ),
        if (isOpen) ...[
          const Divider(height: 1, color: _border),
          ...(semesters.entries.toList()
                ..sort((a, b) => a.key.compareTo(b.key)))
              .map((e) => _SemesterBlock(studentId: studentId, semNum: e.key, courses: e.value)),
        ],
      ]),
    );
  }
}

class _SemesterBlock extends StatelessWidget {
  const _SemesterBlock({required this.studentId, required this.semNum, required this.courses});
  final String studentId;
  final int semNum;
  final List<StudyPlanCourse> courses;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('الفصل ${semNum == 1 ? "الأول" : "الثاني"}',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: _textSub)),
        const SizedBox(height: 6),
        ...courses.map((c) => _PlanRow(studentId: studentId, course: c)),
        const SizedBox(height: 6),
      ]),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.studentId, required this.course});
  final String studentId;
  final StudyPlanCourse course;

  @override
  Widget build(BuildContext context) {
    final passed = StudentRepository.hasPassedCourse(studentId, course);
    final enrolledCourses = StudentRepository.getEnrolledCourses(studentId);
    final enrolledCodes = enrolledCourses
        .map((c) => c.courseCode)
        .toSet();
    final current = !passed &&
        ((course.courseCode != null && enrolledCodes.contains(course.courseCode)) ||
         (course.secondaryCourseCode != null && enrolledCodes.contains(course.secondaryCourseCode)));

    Color statusColor;
    Color statusBg;
    String statusLabel;
    if (passed) { statusColor = const Color(0xFF2E9B5F); statusBg = const Color(0xFFEDFAF1); statusLabel = 'مكتمل'; }
    else if (current) { statusColor = _gold; statusBg = _goldLight; statusLabel = 'حالي'; }
    else { statusColor = _textSub; statusBg = _border; statusLabel = 'متبقي'; }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: passed ? const Color(0xFFF8FFF8) : _lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        if (passed)
          const Icon(Icons.check_circle_rounded, color: Color(0xFF2E9B5F), size: 16)
        else if (current)
          Icon(Icons.radio_button_checked_rounded, color: _gold, size: 16)
        else
          Icon(Icons.radio_button_unchecked_rounded, color: _textSub, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(course.courseNameAr,
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: passed ? _textSub : _textMain,
                  decoration: passed ? TextDecoration.none : null)),
          Row(children: [
            if (course.courseCode != null)
              Text(course.courseCode!,
                  style: GoogleFonts.cairo(fontSize: 10, color: _textSub)),
            if (course.courseCode != null) const SizedBox(width: 6),
            Text('${course.rawCreditsLabel ?? course.credits} ساعة',
                style: GoogleFonts.cairo(fontSize: 10, color: _textSub)),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
          child: Text(statusLabel,
              style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
        ),
      ]),
    );
  }
}

PreferredSizeWidget _appBar(BuildContext ctx, String title) => AppBar(
      backgroundColor: _white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textMain),
        onPressed: () => Navigator.of(ctx).pop(),
      ),
      centerTitle: true,
      title: Text(title,
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain)),
      bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border)),
    );
