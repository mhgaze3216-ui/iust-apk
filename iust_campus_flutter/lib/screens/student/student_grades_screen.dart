import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/student_repository.dart';
import '../../services/student_session.dart';
import '../../models/student_models.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class StudentGradesScreen extends StatefulWidget {
  final String? studentId;
  const StudentGradesScreen({super.key, this.studentId});
  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  String _search = '';

  String get _studentId => widget.studentId ?? StudentSession.currentStudentId;
  StudentProfile get _profile =>
      StudentRepository.getStudent(_studentId) ?? StudentSession.currentProfile;

  List<Grade> get _filtered {
    final grades = StudentRepository.getGrades(_studentId);
    if (_search.trim().isEmpty) return grades;
    final q = _search.trim().toLowerCase();
    return grades
        .where((g) =>
            g.courseNameAr.toLowerCase().contains(q) ||
            g.courseCode.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, 'النتائج والحضور'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(children: [
          // ── academic summary ─────────────────────────────────────────
          Container(
            color: _white,
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              _GpaBox(label: 'المعدل التراكمي', value: p.cumulativeGpa.toStringAsFixed(2), color: _navy),
              const SizedBox(width: 10),
              _GpaBox(label: 'المعدل الفصلي', value: p.semesterGpa.toStringAsFixed(2), color: _blue),
              const SizedBox(width: 10),
              _GpaBox(label: 'الساعات المجتازة', value: '${p.completedCreditHours}', color: const Color(0xFF2E9B5F)),
            ]),
          ),
          const Divider(height: 1, color: _border),

          // ── search ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: Row(children: [
                const Icon(Icons.search_rounded, size: 16, color: _textSub),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    textDirection: TextDirection.rtl,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم المادة أو الرمز...',
                      hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // ── list ─────────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('لا توجد نتائج مطابقة',
                    style: GoogleFonts.cairo(color: _textSub)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _GradeRow(grade: _filtered[i]),
                  ),
          ),
        ]),
      ),
    );
  }
}

class _GpaBox extends StatelessWidget {
  const _GpaBox({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(children: [
            Text(value, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.cairo(fontSize: 10, color: _textSub), textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({required this.grade});
  final Grade grade;

  Color _gradeColor(double v) {
    if (v >= 3.75) return const Color(0xFF2E9B5F);
    if (v >= 3.25) return _blue;
    if (v >= 3.0)  return const Color(0xFFD4900A);
    return const Color(0xFFE53E3E);
  }

  @override
  Widget build(BuildContext context) {
    final gc = _gradeColor(grade.gradeValue);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(grade.courseNameAr,
              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: _textMain)),
          const SizedBox(height: 3),
          Row(children: [
            Text(grade.courseCode,
                style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: grade.activityType == 'theory' ? _lightBlue : const Color(0xFFEDFAF1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(grade.activityType == 'theory' ? 'نظري' : 'عملي',
                  style: GoogleFonts.cairo(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: grade.activityType == 'theory' ? _blue : const Color(0xFF2E9B5F))),
            ),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (grade.letterGrade != null && grade.letterGrade!.isNotEmpty) ...[
            Text(grade.letterGrade!,
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: gc)),
            Text(grade.gradeValue.toStringAsFixed(2),
                style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
          ] else ...[
            Text(grade.gradeValue.toStringAsFixed(2),
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: gc)),
          ],
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: grade.resultStatus == 'passed' ? const Color(0xFFEDFAF1) : const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(grade.resultStatus == 'passed' ? 'ناجح' : 'راسب',
                style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: grade.resultStatus == 'passed' ? const Color(0xFF2E9B5F) : const Color(0xFFE53E3E))),
          ),
        ]),
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
          style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: _textMain)),
      bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border)),
    );
