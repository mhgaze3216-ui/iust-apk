import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/feed_models.dart';
import '../../models/task_model.dart';
import '../../models/student_models.dart';
import '../../data/student_repository.dart';
import '../../services/student_session.dart';
import '../../services/mock_feed_service.dart';
import '../../services/mock_tasks_service.dart';
import 'student_tasks_screen.dart';
import 'student_pomodoro_screen.dart';
import 'student_class_feed_screen.dart';
import 'student_courses_screen.dart';
import 'student_study_plan_screen.dart';
import 'student_registration_screen.dart';
import 'student_grades_screen.dart';
import 'student_calendar_screen.dart';
import 'student_advising_screen.dart';
import 'student_library_screen.dart';
import 'student_transport_screen.dart';
import 'student_final_exams_screen.dart';
import '../../data/academic_calendar_data.dart';
import '../../data/transport_data.dart';
import '../../models/notification_model.dart';
import '../../services/mock_notifications_service.dart';
import 'student_notifications_sheet.dart';

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

class StudentHomeScreen extends StatefulWidget {
  final String? studentId;
  const StudentHomeScreen({super.key, this.studentId});
  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String get _studentId => widget.studentId ?? StudentSession.currentStudentId;
  StudentProfile get _profile =>
      StudentRepository.getStudent(_studentId) ?? StudentSession.currentProfile;

  List<Task>     _tasks    = [];
  List<FeedPost> _feedPrev = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await MockTasksService.getTodayTasks(_studentId);
    final feed  = await MockFeedService.getRecentPosts(limit: 2);
    if (mounted) setState(() { _tasks = tasks; _feedPrev = feed; });
  }

  // ── next-lecture calculation ────────────────────────────────────────────
  /// Returns the next upcoming session relative to now, or null if none today.
  ScheduleSession? _nextSession() {
    final now     = TimeOfDay.now();
    final today   = _dayName(DateTime.now().weekday);
    final sessions = StudentRepository.getScheduleSessions(_studentId);
    final todaySessions = sessions
        .where((s) => s.dayOfWeek == today)
        .toList()
      ..sort((a, b) => _compareTime(a.startTime, b.startTime));

    for (final s in todaySessions) {
      final t = s.startTimeOfDay;
      if (t.hour > now.hour ||
          (t.hour == now.hour && t.minute > now.minute)) {
        return s;
      }
    }
    return null; // no remaining sessions today
  }

  /// Returns today's all sessions sorted by start time.
  List<ScheduleSession> _todaySessions() {
    final today = _dayName(DateTime.now().weekday);
    final sessions = StudentRepository.getScheduleSessions(_studentId);
    return sessions
        .where((s) => s.dayOfWeek == today)
        .toList()
      ..sort((a, b) => _compareTime(a.startTime, b.startTime));
  }

  static String _dayName(int weekday) {
    const map = {
      1: 'Monday', 2: 'Tuesday', 3: 'Wednesday',
      4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday',
    };
    return map[weekday] ?? 'Monday';
  }

  static int _compareTime(String a, String b) {
    int toMins(String t) {
      final p = t.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }
    return toMins(a).compareTo(toMins(b));
  }

  // ── course name lookup ──────────────────────────────────────────────────
  String _courseName(String courseId) =>
      StudentRepository.getCourseName(_studentId, courseId);

  @override
  Widget build(BuildContext context) {
    final p           = _profile;
    final completed   = MockTasksService.getTodayCompletedCount(_studentId);
    final total       = MockTasksService.getTodayTotalCount(_studentId);
    final nextSession = _nextSession();
    final todaySched  = _todaySessions();

    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(p)),
            SliverToBoxAdapter(child: _buildHeroCard(p)),
            SliverToBoxAdapter(child: _buildStatusCard(p, nextSession)),
            SliverToBoxAdapter(child: _buildTasksSummary(completed, total)),
            SliverToBoxAdapter(child: _buildStudyTools()),
            SliverToBoxAdapter(child: _buildCompletedShortcut()),
            SliverToBoxAdapter(child: _buildQuickServices()),
            if (todaySched.isNotEmpty)
              SliverToBoxAdapter(child: _buildTodaySchedule(todaySched)),
            SliverToBoxAdapter(child: _buildFeedPreview()),
            SliverToBoxAdapter(child: _buildCalendarEvent()),
            SliverToBoxAdapter(child: _buildNearestTrip()),
            SliverToBoxAdapter(child: _buildAcademicSummary(p)),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  // ── A. Header ─────────────────────────────────────────────────────────
  Widget _buildHeader(StudentProfile p) {
    return Container(
      color: _white,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Center: University Logo ─────────────────────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/img/logo iust.webp',
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (_, e, s) =>
                      const Icon(Icons.account_balance_rounded, color: _navy, size: 28),
                ),
                const SizedBox(width: 8),
                Text(
                  'IUST',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Right Side: Notification Bell with Live Unread Badge ────
          Positioned(
            right: 0,
            child: ValueListenableBuilder<List<StudentNotification>>(
              valueListenable: MockNotificationsService.getNotifier(_studentId),
              builder: (context, notifs, _) {
                final unread = notifs.where((n) => !n.isRead).length;
                return _NotificationBellBtn(
                  unreadCount: unread,
                  onTap: () => StudentNotificationsSheet.show(context, studentId: _studentId),
                );
              },
            ),
          ),

          // ── Left Side: Language Button ───────────────────────────────
          Positioned(
            left: 0,
            child: _LangBtn(),
          ),
        ],
      ),
    );
  }

  // ── B. Hero card ───────────────────────────────────────────────────────
  Widget _buildHeroCard(StudentProfile p) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF073B4C), Color(0xFF0F6CBD)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('أهلاً، ${p.firstName} 👋',
                style: GoogleFonts.cairo(
                    fontSize: 13, color: _white.withValues(alpha: 0.75))),
            const SizedBox(height: 4),
            Text('جاهز ليومك؟',
                style: GoogleFonts.cairo(
                    fontSize: 22, fontWeight: FontWeight.w800, color: _white)),
            const SizedBox(height: 14),
            // search bar
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: _white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _white.withValues(alpha: 0.25)),
              ),
              child: Row(children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.search_rounded, color: Colors.white70, size: 18),
                ),
                Expanded(
                  child: Text('ابحث عن قاعة، دكتور، مقرر أو خدمة...',
                      style: GoogleFonts.cairo(
                          fontSize: 13, color: _white.withValues(alpha: 0.60))),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/img/iust.jpeg',
                height: 110, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, e, s) => Container(
                  height: 110,
                  decoration: BoxDecoration(
                      color: _white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.image_rounded,
                      color: Colors.white38, size: 40),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── C. Status card (next lecture, dynamic) ─────────────────────────────
  Widget _buildStatusCard(StudentProfile p, ScheduleSession? next) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecor(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.schedule_rounded, color: _blue, size: 18),
              const SizedBox(width: 8),
              Text('المحاضرة القادمة',
                  style: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
            ]),
            const Divider(height: 16, color: _border),
            if (next == null)
              Text('لا توجد محاضرات متبقية اليوم',
                  style: GoogleFonts.cairo(fontSize: 13, color: _textSub))
            else
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_courseName(next.courseId),
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _textMain)),
                    const SizedBox(height: 2),
                    Text('${next.startTime} – ${next.endTime}  ·  ${next.activityTypeAr}',
                        style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
                    Text('قاعة ${next.roomDisplay}${next.buildingNameAr != null ? "  ·  ${next.buildingNameAr}" : ""}',
                        style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
                  ],
                )),
                const SizedBox(width: 12),
                // navigation button — disabled when no map node available
                ElevatedButton.icon(
                  onPressed: () {
                    if (next.mapNodeId != null) {
                      // TODO: open map to mapNodeId when coordinates are added
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('موقع القاعة غير متوفر حالياً',
                              style: GoogleFonts.cairo()),
                          backgroundColor: _navy,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.directions_rounded, size: 15),
                  label: Text('اعرض الطريق',
                      style: GoogleFonts.cairo(
                          fontSize: 11, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: next.mapNodeId != null ? _navy : _border,
                    foregroundColor: next.mapNodeId != null ? _white : _textSub,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ]),
          ]),
        ),
      ),
    );
  }

  // ── D. Tasks summary ───────────────────────────────────────────────────
  Widget _buildTasksSummary(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;
    final pending  = _tasks.where((t) => !t.isCompleted).take(3).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _goldLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _gold.withValues(alpha: 0.35)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.task_alt_rounded, color: _gold, size: 18),
              const SizedBox(width: 8),
              Text('إنجاز اليوم',
                  style: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
              const Spacer(),
              Text(
                total == 0
                    ? 'لا توجد مهام اليوم'
                    : '$completed من $total مهام مكتملة',
                style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
              ),
            ]),
            if (total > 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: _gold.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                  minHeight: 8,
                ),
              ),
            ],
            if (pending.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...pending.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.6),
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(t.title,
                              style: GoogleFonts.cairo(
                                  fontSize: 12, color: _textMain),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      if (t.courseName != null)
                        Text(t.courseName!,
                            style: GoogleFonts.cairo(
                                fontSize: 11, color: _textSub)),
                    ]),
                  )),
            ],
            if (total == 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('اضغط + لإضافة مهمة جديدة',
                    style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
              ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => StudentTasksScreen(studentId: _studentId))),
              child: Row(children: [
                Text('عرض كل المهام',
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _gold)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_left_rounded,
                    color: _gold, size: 16),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── E. Study tools ─────────────────────────────────────────────────────
  Widget _buildStudyTools() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionTitle('أدوات الدراسة'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _ToolCard(
                icon: Icons.task_alt_rounded,
                label: 'مهامي',
                sub: 'أضف وتابع مهامك',
                bgColor: _lightBlue, iconColor: _blue,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => StudentTasksScreen(studentId: _studentId))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ToolCard(
                icon: Icons.timer_rounded,
                label: 'Pomodoro',
                sub: 'ابدأ جلسة تركيز',
                bgColor: _goldLight, iconColor: _gold,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => StudentPomodoroScreen(studentId: _studentId))),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  // ── E2. Completed courses shortcut ────────────────────────────────────
  Widget _buildCompletedShortcut() {
    final p = _profile;
    final progress = p.completedCreditHours / p.requiredCreditHours;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                  builder: (_) => StudentCoursesScreen(initialTab: 1, studentId: _studentId))),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.check_circle_rounded, color: _blue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('المواد المنجزة',
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
                const SizedBox(height: 4),
                Row(children: [
                  Text('${p.completedCreditHours} ساعة مجتازة',
                      style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: _border,
                        valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('${(progress * 100).round()}%',
                      style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: _blue)),
                ]),
              ])),
              const Icon(Icons.chevron_left_rounded, color: _textSub, size: 20),
            ]),
          ),
        ),
      ),
    );
  }

  // ── F. Quick services ──────────────────────────────────────────────────
  Widget _buildQuickServices() {
    final items = [
      const _QItem(icon: Icons.menu_book_rounded,        color: Color(0xFF0F6CBD), label: 'الخطة الدراسية', bgColor: Color(0xFFEAF4FB), route: '/student/study-plan'),
      const _QItem(icon: Icons.app_registration_rounded, color: Color(0xFF7C3AED), label: 'التسجيل',         bgColor: Color(0xFFF5F0FF), route: '/student/registration'),
      const _QItem(icon: Icons.bar_chart_rounded,        color: Color(0xFFE53E3E), label: 'النتائج',          bgColor: Color(0xFFFFF0F0), route: '/student/grades'),
      const _QItem(icon: Icons.calendar_month_rounded,   color: Color(0xFFD4900A), label: 'التقويم',          bgColor: Color(0xFFFFF8E1), route: '/student/calendar'),
      const _QItem(icon: Icons.support_agent_rounded,    color: Color(0xFF2E9B5F), label: 'الإرشاد',          bgColor: Color(0xFFEDFAF1), route: '/student/advising'),
      const _QItem(icon: Icons.local_library_rounded,    color: Color(0xFF0F6CBD), label: 'المكتبة',          bgColor: Color(0xFFEAF4FB), route: '/student/library'),
      const _QItem(icon: Icons.directions_bus_rounded,    color: Color(0xFF073B4C), label: 'النقل الجامعي',    bgColor: Color(0xFFEEF4FF), route: '/student/transport'),
      if (_studentId == 'student-informatics-002')
        const _QItem(icon: Icons.event_note_rounded,       color: Color(0xFFE53E3E), label: 'جدول الفاينل', subtitle: 'الامتحانات النهائية', bgColor: Color(0xFFFFF0F0), route: '/student/final-exams'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionTitle('الخدمات السريعة'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => _QuickCard(item: items[i], studentId: _studentId),
          ),
        ]),
      ),
    );
  }

  // ── G. Today's schedule (real data) ────────────────────────────────────
  Widget _buildTodaySchedule(List<ScheduleSession> sessions) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionTitle('جدول اليوم'),
          const SizedBox(height: 10),
          ...sessions.map((s) => _SessionCard(session: s, studentId: _studentId)),
        ]),
      ),
    );
  }

  // ── H. Recent feed preview ─────────────────────────────────────────────
  Widget _buildFeedPreview() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: _SectionTitle('Class Feed')),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => StudentClassFeedScreen(studentId: _studentId))),
              child: Text('عرض Class Feed',
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _blue)),
            ),
          ]),
          const SizedBox(height: 10),
          if (_feedPrev.isEmpty)
            Text('جارٍ التحميل...',
                style: GoogleFonts.cairo(fontSize: 13, color: _textSub))
          else
            ..._feedPrev.map((p) => _FeedPreviewCard(post: p)),
        ]),
      ),
    );
  }

  // ── K. Nearest transport trip ─────────────────────────────────────────
  Widget _buildNearestTrip() {
    final trip = getNearestTrip();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const StudentTransportScreen())),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 38, height: 38, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: trip.hasTripsLeft ? _lightBlue : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.directions_bus_rounded,
                    color: trip.hasTripsLeft ? _blue : _textSub,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أقرب رحلة',
                        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
                    if (trip.hasTripsLeft)
                      Text(trip.waveName,
                          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: _blue)),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _goldLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('مواعيد مقترحة',
                      style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600, color: _gold)),
                ),
              ]),
              const SizedBox(height: 10),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 10),

              if (trip.hasTripsLeft) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _lightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 15, color: _blue),
                          const SizedBox(width: 5),
                          Text(
                            'الوقت: ${trip.departureTime}',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.tripType,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _textMain,
                            ),
                          ),
                          if (trip.stopsCount > 0)
                            Text(
                              '${trip.stopsCount} مساراً / منطقة متاحة',
                              style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: _textSub),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'لا توجد رحلات متبقية اليوم',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _textMain,
                            ),
                          ),
                          Text(
                            'انتهت جميع رحلات النقل الجامعي لهذا اليوم',
                            style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('عرض جميع المواعيد',
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: _blue)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_left_rounded, size: 14, color: _blue),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  // ── J. Nearest calendar event ─────────────────────────────────────────
  Widget _buildCalendarEvent() {
    final next = kNextAcademicEvent;
    if (next == null) return const SizedBox.shrink();

    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(next.startDate.year, next.startDate.month, next.startDate.day);
    final end   = next.endDate != null
        ? DateTime(next.endDate!.year, next.endDate!.month, next.endDate!.day)
        : start;
    final isActive = !today.isBefore(start) && !today.isAfter(end);
    final daysLeft  = start.difference(today).inDays;

    String dateLabel;
    if (isActive) {
      dateLabel = 'جارٍ الآن';
    } else if (daysLeft == 0) {
      dateLabel = 'اليوم';
    } else if (daysLeft == 1) {
      dateLabel = 'غداً';
    } else {
      dateLabel = 'خلال $daysLeft يوم';
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StudentCalendarScreen())),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFFF4D6) : _lightBlue,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: isActive
                      ? const Color(0xFFF5B82E).withValues(alpha: 0.45)
                      : _blue.withValues(alpha: 0.25)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 38, height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFF5B82E).withValues(alpha: 0.2) : _lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.event_rounded,
                    color: isActive ? const Color(0xFFF5B82E) : _blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('التقويم الأكاديمي',
                      style: GoogleFonts.cairo(fontSize: 11,
                          color: isActive ? const Color(0xFFD4900A) : _blue)),
                  const SizedBox(height: 2),
                  Text(next.titleAr,
                      style: GoogleFonts.cairo(
                          fontSize: 13, fontWeight: FontWeight.w700, color: _textMain),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(dateLabel,
                      style: GoogleFonts.cairo(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: isActive ? const Color(0xFFD4900A) : _blue)),
                ]),
              ),
              const Icon(Icons.chevron_left_rounded, color: _textSub, size: 18),
            ]),
          ),
        ),
      ),
    );
  }

  // ── I. Academic summary ────────────────────────────────────────────────
  Widget _buildAcademicSummary(StudentProfile p) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecor(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ملخص أكاديمي',
                style: GoogleFonts.cairo(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
            const SizedBox(height: 12),
            Row(children: [
              _AcadTile(label: 'المعدل التراكمي', value: p.cumulativeGpa.toStringAsFixed(2), color: _navy),
              _AcadTile(label: 'المعدل الفصلي',   value: p.semesterGpa.toStringAsFixed(2),   color: _blue),
              _AcadTile(label: 'الساعات المجتازة', value: '${p.completedCreditHours}/${p.requiredCreditHours}', color: _gold),
            ]),
            const SizedBox(height: 10),
            // credit progress bar
            Row(children: [
              Text('التقدم نحو التخرج',
                  style: GoogleFonts.cairo(fontSize: 12, color: _textSub)),
              const Spacer(),
              Text(
                '${(p.completedCreditHours / p.requiredCreditHours * 100).round()}%',
                style: GoogleFonts.cairo(
                    fontSize: 12, fontWeight: FontWeight.w700, color: _navy),
              ),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: p.completedCreditHours / p.requiredCreditHours,
                backgroundColor: _border,
                valueColor: const AlwaysStoppedAnimation<Color>(_navy),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: p.academicStatus == 'regular'
                      ? const Color(0xFFEDFAF1)
                      : _goldLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(p.academicStatusAr,
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: p.academicStatus == 'regular'
                            ? const Color(0xFF2E9B5F)
                            : _gold)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ── small widgets ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.cairo(
          fontSize: 16, fontWeight: FontWeight.w800, color: _textMain));
}

class _NotificationBellBtn extends StatelessWidget {
  const _NotificationBellBtn({required this.unreadCount, required this.onTap});
  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _lightBg,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _border),
            ),
            child: const Icon(Icons.notifications_outlined, color: _navy, size: 20),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -3,
              left: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: GoogleFonts.cairo(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: _lightBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border)),
        alignment: Alignment.center,
        child: Text('EN',
            style: GoogleFonts.cairo(
                fontSize: 12, fontWeight: FontWeight.w700, color: _textMain)),
      );
}

class _ToolCard extends StatelessWidget {
  const _ToolCard(
      {required this.icon,
      required this.label,
      required this.sub,
      required this.bgColor,
      required this.iconColor,
      required this.onTap});
  final IconData icon;
  final String label, sub;
  final Color bgColor, iconColor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40, height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.cairo(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _textMain)),
            const SizedBox(height: 2),
            Text(sub,
                style: GoogleFonts.cairo(fontSize: 11, color: _textSub)),
          ]),
        ),
      );
}

class _QItem {
  final IconData icon;
  final Color color, bgColor;
  final String label;
  final String? subtitle;
  final String? route;
  const _QItem(
      {required this.icon,
      required this.color,
      required this.bgColor,
      required this.label,
      this.subtitle,
      this.route});
}

class _QuickCard extends StatefulWidget {
  const _QuickCard({required this.item, this.studentId});
  final _QItem item;
  final String? studentId;
  @override
  State<_QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<_QuickCard> {
  bool _down = false;

  void _handleTap(BuildContext context) {
    final sid = widget.studentId;
    switch (widget.item.route) {
      case '/student/study-plan':
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => StudentStudyPlanScreen(studentId: sid)));
      case '/student/registration':
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => StudentRegistrationScreen(studentId: sid)));
      case '/student/grades':
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => StudentGradesScreen(studentId: sid)));
      case '/student/calendar':
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => StudentCalendarScreen(studentId: sid)));
      case '/student/advising':
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => StudentAdvisingScreen(studentId: sid)));
      case '/student/library':
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => StudentLibraryScreen(studentId: sid)));
      case '/student/transport':
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => const StudentTransportScreen()));
      case '/student/final-exams':
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => StudentFinalExamsScreen(studentId: sid)));
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('هذه الخدمة ستتوفر قريباً', style: GoogleFonts.cairo()),
            backgroundColor: const Color(0xFF073B4C),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) {
          setState(() => _down = false);
          _handleTap(context);
        },
        onTapCancel: () => setState(() => _down = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _down ? -4 : 0, 0),
          child: Container(
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 42, height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: widget.item.bgColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(widget.item.icon, color: widget.item.color, size: 22),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(widget.item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _textMain,
                        height: 1.2)),
              ),
              if (widget.item.subtitle != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(widget.item.subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: _textSub,
                          height: 1.1)),
                ),
            ]),
          ),
        ),
      );
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, this.studentId});
  final ScheduleSession session;
  final String? studentId;

  @override
  Widget build(BuildContext context) {
    final sid = studentId ?? StudentSession.currentStudentId;
    final courseName = StudentRepository.getCourseName(sid, session.courseId);
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(children: [
              Container(
                width: 4, height: 52,
                decoration: BoxDecoration(
                  color: session.activityType == 'theory'
                      ? _blue
                      : const Color(0xFF2E9B5F),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseName.isNotEmpty ? courseName : session.courseId,
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _textMain),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${session.doctorName}  ·  ${session.activityTypeAr}  ·  قاعة ${session.roomDisplay}',
                        style: GoogleFonts.cairo(
                            fontSize: 12, color: _textSub),
                      ),
                    ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(session.startTime,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _navy)),
                Text(session.endTime,
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: _textSub)),
              ]),
            ]),
          ),
        ),
      );
  }
}

class _FeedPreviewCard extends StatelessWidget {
  const _FeedPreviewCard({required this.post});
  final FeedPost post;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 32, height: 32,
                alignment: Alignment.center,
                decoration:
                    const BoxDecoration(color: _navy, shape: BoxShape.circle),
                child: Text(
                  post.studentName.isNotEmpty ? post.studentName[0] : '؟',
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(post.studentName,
                      style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textMain))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(post.courseName,
                    style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: _blue,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            if (post.title != null)
              Text(post.title!,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textMain)),
            Text(post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                    fontSize: 12, color: _textSub, height: 1.5)),
          ]),
        ),
      );
}

class _AcadTile extends StatelessWidget {
  const _AcadTile(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value,
              style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 10, color: _textSub),
              textAlign: TextAlign.center),
        ]),
      );
}

BoxDecoration _cardDecor(
        {Color bgColor = _white, Color borderColor = _border}) =>
    BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3))
      ],
    );
