import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/student_models.dart';
import '../../data/student_repository.dart';
import '../../services/student_session.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class StudentCoursesScreen extends StatefulWidget {
  /// Pass 1 to open the "completed" tab directly (e.g. from Home shortcut).
  final int initialTab;
  final String? studentId;
  const StudentCoursesScreen({super.key, this.initialTab = 0, this.studentId});
  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _search = '';

  String get _studentId => widget.studentId ?? StudentSession.currentStudentId;
  StudentProfile get _profile =>
      StudentRepository.getStudent(_studentId) ?? StudentSession.currentProfile;

  List<Grade> get _allGrades => StudentRepository.getGrades(_studentId);
  List<Course> get _enrolledCourses => StudentRepository.getEnrolledCourses(_studentId);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  List<Grade> get _filteredGrades {
    final grades = _allGrades;
    if (_search.trim().isEmpty) return grades;
    final q = _search.trim().toLowerCase();
    return grades.where((g) =>
        g.courseNameAr.toLowerCase().contains(q) ||
        g.courseCode.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    final enrolled = _enrolledCourses;
    final allGrades = _allGrades;
    final progress = p.completedCreditHours / (p.requiredCreditHours > 0 ? p.requiredCreditHours : 1);

    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(children: [
            // ── header ───────────────────────────────────────────────
            Container(
              color: _white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('موادي', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w800, color: _textMain)),
                Text('${p.currentSemesterNameAr} — ${p.academicYear}',
                    style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
                const SizedBox(height: 12),

                // ── progress bar ──────────────────────────────────────
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('التقدم نحو التخرج',
                        style: GoogleFonts.cairo(fontSize: 12, color: _textSub))),
                    Text('${(progress * 100).round()}%',
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: _navy)),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: _border,
                      valueColor: const AlwaysStoppedAnimation<Color>(_navy),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('${p.completedCreditHours} ساعة مجتازة',
                        style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                    Text('${p.remainingCreditHours} ساعة متبقية',
                        style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                    Text('${p.requiredCreditHours} الإجمالي',
                        style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
                  ]),
                ]),
                const SizedBox(height: 10),

                // ── tabs ──────────────────────────────────────────────
                TabBar(
                  controller: _tabs,
                  labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w500, fontSize: 13),
                  labelColor: _navy,
                  unselectedLabelColor: _textSub,
                  indicatorColor: _navy,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(text: 'المواد الحالية (${enrolled.length})'),
                    Tab(text: 'المواد المنجزة (${allGrades.length})'),
                  ],
                ),
              ]),
            ),

            // ── tab bodies ────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _CurrentCoursesTab(courses: enrolled),
                  _CompletedCoursesTab(
                    filteredGrades: _filteredGrades,
                    search: _search,
                    onSearchChanged: (v) => setState(() => _search = v),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 1: Current Courses
// ══════════════════════════════════════════════════════════════════════════════
class _CurrentCoursesTab extends StatelessWidget {
  final List<Course> courses;
  const _CurrentCoursesTab({required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Center(
        child: Text('لا توجد مواد مسجلة حالياً',
            style: GoogleFonts.cairo(color: _textSub)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 120),
      itemCount: courses.length,
      itemBuilder: (_, i) {
        const colors = [Color(0xFF7C3AED), Color(0xFF0F6CBD)];
        return _CourseCard(course: courses[i], color: colors[i % 2]);
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.color});
  final Course course;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 5, color: color),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(course.courseCode,
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
              ),
              const Spacer(),
              _chip(Icons.access_time_rounded, '${course.creditHours} ساعة', _blue, _lightBlue),
              const SizedBox(width: 6),
              _chip(Icons.info_outline_rounded, course.courseType == 'required' ? 'إلزامي' : 'اختياري', _textSub, const Color(0xFFF1F5F9)),
            ]),
            const SizedBox(height: 10),
            Text(course.courseNameAr, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain)),
            const SizedBox(height: 14),
            const Divider(height: 1, color: _border),
            const SizedBox(height: 12),
            Text('جلسات المادة', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: _textSub)),
            const SizedBox(height: 8),
            ...course.sessions.map((s) => _SessionRow(session: s, color: color)),
          ]),
        ),
      ]),
    );
  }

  Widget _chip(IconData icon, String label, Color c, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 3),
          Text(label, style: GoogleFonts.cairo(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.color});
  final ScheduleSession session;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _lightBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: session.activityType == 'theory' ? _lightBlue : const Color(0xFFEDFAF1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(session.activityTypeAr,
                  style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700,
                      color: session.activityType == 'theory' ? _blue : const Color(0xFF2E9B5F))),
            ),
            const SizedBox(width: 8),
            Text(session.dayOfWeekAr, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: _textMain)),
            const Spacer(),
            Text('${session.startTime} – ${session.endTime}',
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: _navy)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.person_rounded, size: 13, color: _textSub),
            const SizedBox(width: 4),
            Flexible(child: Text(session.doctorName, style: GoogleFonts.cairo(fontSize: 12, color: _textSub), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            const Icon(Icons.room_rounded, size: 13, color: _textSub),
            const SizedBox(width: 4),
            Text(session.roomDisplay, style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
            if (session.buildingNameAr != null) ...[
              const SizedBox(width: 4),
              Flexible(child: Text('— ${session.buildingNameAr}', style: GoogleFonts.cairo(fontSize: 11, color: _textSub), overflow: TextOverflow.ellipsis)),
            ],
          ]),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 2: Completed Courses
// ══════════════════════════════════════════════════════════════════════════════
class _CompletedCoursesTab extends StatelessWidget {
  const _CompletedCoursesTab({
    required this.filteredGrades,
    required this.search,
    required this.onSearchChanged,
  });
  final List<Grade> filteredGrades;
  final String search;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: _white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
          child: Row(children: [
            const Icon(Icons.search_rounded, size: 16, color: _textSub),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                textDirection: TextDirection.rtl,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'ابحث باسم المادة أو الرمز...',
                  hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                  border: InputBorder.none, isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ]),
        ),
      ),
      Expanded(
        child: filteredGrades.isEmpty
            ? Center(child: Text('لا توجد نتائج مطابقة', style: GoogleFonts.cairo(color: _textSub)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 120),
                itemCount: filteredGrades.length,
                itemBuilder: (_, i) => _GradeCard(
                  grade: filteredGrades[i],
                  onTap: () => _showDetail(context, filteredGrades[i]),
                ),
              ),
      ),
    ]);
  }

  void _showDetail(BuildContext context, Grade g) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GradeDetailSheet(grade: g),
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.grade, required this.onTap});
  final Grade grade;
  final VoidCallback onTap;

  Color _gc(double v) {
    if (v >= 3.75) return const Color(0xFF2E9B5F);
    if (v >= 3.25) return _blue;
    if (v >= 3.0)  return const Color(0xFFD4900A);
    return const Color(0xFFE53E3E);
  }

  @override
  Widget build(BuildContext context) {
    final gc = _gc(grade.gradeValue);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(grade.courseNameAr, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: _textMain)),
            const SizedBox(height: 3),
            Row(children: [
              Text(grade.courseCode, style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: grade.activityType == 'theory' ? _lightBlue : const Color(0xFFEDFAF1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(grade.activityType == 'theory' ? 'نظري' : 'عملي',
                    style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600,
                        color: grade.activityType == 'theory' ? _blue : const Color(0xFF2E9B5F))),
              ),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (grade.letterGrade != null && grade.letterGrade!.isNotEmpty) ...[
              Text(grade.letterGrade!, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, color: gc)),
              Text(grade.gradeValue.toStringAsFixed(2), style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
            ] else ...[
              Text(grade.gradeValue.toStringAsFixed(2), style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: gc)),
            ],
          ]),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_left_rounded, color: _textSub, size: 18),
        ]),
      ),
    );
  }
}

class _GradeDetailSheet extends StatelessWidget {
  const _GradeDetailSheet({required this.grade});
  final Grade grade;

  Color _gc(double v) {
    if (v >= 3.75) return const Color(0xFF2E9B5F);
    if (v >= 3.25) return _blue;
    if (v >= 3.0)  return const Color(0xFFD4900A);
    return const Color(0xFFE53E3E);
  }

  @override
  Widget build(BuildContext context) {
    final gc = _gc(grade.gradeValue);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(grade.courseNameAr,
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          _row('رمز المادة', grade.courseCode),
          _row('نوع النشاط', grade.activityType == 'theory' ? 'نظري' : 'عملي'),
          _row('العلامة الرقمية', grade.gradeValue.toStringAsFixed(2), valueColor: gc),
          if (grade.letterGrade != null && grade.letterGrade!.isNotEmpty)
            _row('التقدير بالحرف', grade.letterGrade!, valueColor: gc),
          _row('الحالة', 'ناجح', valueColor: const Color(0xFF2E9B5F)),
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 13, color: _textSub)),
          const Spacer(),
          Text(value, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? _textMain)),
        ]),
      );
}
