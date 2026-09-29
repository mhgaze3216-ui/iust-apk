import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/student_repository.dart';
import '../../services/student_session.dart';

const _lightBg  = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _blue     = Color(0xFF0F6CBD);
const _white    = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub  = Color(0xFF6F7F89);
const _border   = Color(0xFFDCE8EE);

class StudentAdvisingScreen extends StatelessWidget {
  final String? studentId;
  const StudentAdvisingScreen({super.key, this.studentId});

  @override
  Widget build(BuildContext context) {
    final sid = studentId ?? StudentSession.currentStudentId;
    final p = StudentRepository.getStudent(sid) ?? StudentSession.currentProfile;
    final advisor = p.academicAdvisorName;
    final role    = p.academicAdvisorRole ?? p.academicAdvisorOffice;
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, 'الإرشاد الأكاديمي'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: advisor != null
            ? _AdvisorInfo(name: advisor, role: role, facultyName: p.facultyNameAr)
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 80, height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.support_agent_rounded, size: 40, color: _blue),
                    ),
                    const SizedBox(height: 20),
                    Text('الإرشاد الأكاديمي',
                        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
                    const SizedBox(height: 8),
                    Text('لا يوجد مرشد أكاديمي مسجل حالياً',
                        style: GoogleFonts.cairo(fontSize: 14, color: _textSub),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text('تواصل مع كلية ${p.facultyNameAr} لتحديد مرشدك الأكاديمي.',
                        style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                        textAlign: TextAlign.center),
                  ]),
                ),
              ),
      ),
    );
  }
}

class _AdvisorInfo extends StatelessWidget {
  const _AdvisorInfo({required this.name, this.role, required this.facultyName});
  final String name;
  final String? role;
  final String facultyName;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF073B4C), Color(0xFF0F6CBD)], begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [
        Container(width: 56, height: 56, alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(role ?? 'المرشد الأكاديمي', style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(name, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
      ]),
    ),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0F6CBD).withValues(alpha: 0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded, color: Color(0xFF0F6CBD), size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(
          'للتواصل مع مرشدك الأكاديمي يُرجى مراجعة عمادة كلية $facultyName أو التواصل عبر البريد الجامعي.',
          style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF0F6CBD), height: 1.6),
        )),
      ]),
    ),
  ]);
}

PreferredSizeWidget _appBar(BuildContext ctx, String title) => AppBar(
      backgroundColor: _white, elevation: 0, surfaceTintColor: Colors.transparent,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textMain), onPressed: () => Navigator.of(ctx).pop()),
      centerTitle: true,
      title: Text(title, style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: _textMain)),
      bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: _border)),
    );
