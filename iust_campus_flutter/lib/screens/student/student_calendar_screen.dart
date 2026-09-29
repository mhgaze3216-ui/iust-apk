import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/academic_calendar_data.dart';
import '../../data/student_repository.dart';
import '../../services/student_session.dart';

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

class StudentCalendarScreen extends StatefulWidget {
  final String? studentId;
  const StudentCalendarScreen({super.key, this.studentId});
  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {
  // default to the student's current semester
  late String _selectedSemester;

  @override
  void initState() {
    super.initState();
    final sid = widget.studentId ?? StudentSession.currentStudentId;
    final profile = StudentRepository.getStudent(sid) ?? StudentSession.currentProfile;
    _selectedSemester = profile.currentSemesterId;
  }

  static const _semesters = [
    ('20251', 'الفصل الأول'),
    ('20252', 'الفصل الثاني'),
    ('20253', 'الفصل الصيفي'),
  ];

  List<AcademicEvent> get _events => kAcademicCalendar
      .where((e) => e.semesterId == _selectedSemester)
      .toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: _appBar(context, 'التقويم الأكاديمي'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(children: [
          // ── semester selector ─────────────────────────────────────────
          Container(
            color: _white,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(children: _semesters.map((s) {
              final (id, label) = s;
              final active = _selectedSemester == id;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSemester = id),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? _navy : _lightBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: active ? _navy : _border),
                    ),
                    child: Text(label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? _white : _textSub)),
                  ),
                ),
              );
            }).toList()),
          ),
          const Divider(height: 1, color: _border),

          // ── event list ────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
              itemCount: _events.length,
              itemBuilder: (_, i) => _EventCard(event: _events[i]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});
  final AcademicEvent event;

  bool get _isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = event.endDate ?? event.startDate;
    final start = event.startDate;
    return !end.isBefore(today) && !start.isAfter(today.add(const Duration(days: 14)));
  }

  bool get _isActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
    final end   = event.endDate != null
        ? DateTime(event.endDate!.year, event.endDate!.month, event.endDate!.day)
        : start;
    return !today.isBefore(start) && !today.isAfter(end);
  }

  Color get _typeColor {
    switch (event.type) {
      case CalendarEventType.finalExam:
      case CalendarEventType.midtermExam:  return const Color(0xFFE53E3E);
      case CalendarEventType.studyStart:
      case CalendarEventType.registration: return const Color(0xFF2E9B5F);
      case CalendarEventType.holiday:      return const Color(0xFFD4900A);
      case CalendarEventType.resultsAnnounced: return _blue;
      case CalendarEventType.objection:
      case CalendarEventType.withdrawal:   return const Color(0xFF7C3AED);
      default:                             return _textSub;
    }
  }

  Color get _typeBg {
    switch (event.type) {
      case CalendarEventType.finalExam:
      case CalendarEventType.midtermExam:  return const Color(0xFFFFF0F0);
      case CalendarEventType.studyStart:
      case CalendarEventType.registration: return const Color(0xFFEDFAF1);
      case CalendarEventType.holiday:      return const Color(0xFFFFF8E1);
      case CalendarEventType.resultsAnnounced: return _lightBlue;
      case CalendarEventType.objection:
      case CalendarEventType.withdrawal:   return const Color(0xFFF5F0FF);
      default:                             return _border;
    }
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final active = _isActive;
    final upcoming = _isUpcoming && !active;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? _goldLight : _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? _gold.withValues(alpha: 0.5) : (upcoming ? _blue.withValues(alpha: 0.3) : _border),
          width: active || upcoming ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        // date block
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_fmt(event.startDate),
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: active ? _gold : _navy)),
          if (event.endDate != null && !event.isSingleDay)
            Text('→ ${_fmt(event.endDate!)}',
                style: GoogleFonts.cairo(fontSize: 10, color: _textSub)),
        ]),
        const SizedBox(width: 12),
        const VerticalDivider(width: 1, thickness: 1, color: _border),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.titleAr,
              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700,
                  color: active ? _textMain : _textMain)),
          const SizedBox(height: 4),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: _typeBg, borderRadius: BorderRadius.circular(5)),
              child: Text(event.type.labelAr, style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: _typeColor)),
            ),
            if (active) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: _goldLight, borderRadius: BorderRadius.circular(5), border: Border.all(color: _gold.withValues(alpha: 0.4))),
                child: Text('جارٍ الآن', style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: _gold)),
              ),
            ] else if (upcoming) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(5)),
                child: Text('قريباً', style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600, color: _blue)),
              ),
            ],
          ]),
        ])),
      ]),
    );
  }
}

PreferredSizeWidget _appBar(BuildContext ctx, String title) => AppBar(
      backgroundColor: _white, elevation: 0, surfaceTintColor: Colors.transparent,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textMain), onPressed: () => Navigator.of(ctx).pop()),
      centerTitle: true,
      title: Text(title, style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: _textMain)),
      bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: _border)),
    );
