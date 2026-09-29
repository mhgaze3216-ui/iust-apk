import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/doctor_demo_data.dart';
import '../../data/doctor_repository.dart';
import '../../data/transport_data.dart';
import 'doctor_academic_submission_screen.dart';
import 'doctor_assignments_screen.dart';
import 'doctor_attendance_screen.dart';
import 'doctor_course_details_screen.dart';
import 'doctor_courses_screen.dart';
import 'doctor_exam_center_screen.dart';
import 'doctor_grades_screen.dart';
import 'doctor_quick_actions_screen.dart';
import 'doctor_student_questions_screen.dart';
import 'doctor_transport_screen.dart';
import 'widgets/doctor_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _gold = Color(0xFFF5B82E);
const _goldLight = Color(0xFFFFF4D6);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorHomeScreen extends StatelessWidget {
  final void Function(int tabIndex)? onSelectTab;

  const DoctorHomeScreen({super.key, this.onSelectTab});

  void _navigateToCourses(BuildContext context) {
    if (onSelectTab != null) {
      onSelectTab!(1);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const DoctorCoursesScreen(showBack: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            const DoctorHeader(),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // 2. Compact Doctor Profile/Hero
                          _buildCompactHeroBanner(),
                          const SizedBox(height: 12),

                          // 3. اليوم (المحاضرة القادمة + أقرب رحلة + جدول اليوم المدمج)
                          _buildTodaySection(context),
                          const SizedBox(height: 14),

                          // 4. تنبيه مهم
                          _buildImportantAlert(context),
                          const SizedBox(height: 14),

                          // 5. نظرة عامة
                          _buildOverviewSection(context),
                          const SizedBox(height: 14),

                          // 6. إجراءات سريعة
                          _buildQuickActionsSection(context),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Compact Doctor Profile/Hero ─────────────────────────────────────────
  Widget _buildCompactHeroBanner() {
    final profile = DoctorDemoData.profile;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'IUST SMART GUIDE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: _gold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'بيانات تجريبية',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            profile.fullName,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${profile.faculty} · ${profile.department}',
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. اليوم (Two Compact Cards + Compact Schedule Card) ───────────────────
  Widget _buildTodaySection(BuildContext context) {
    final firstCourse = DoctorRepository.courses.isNotEmpty
        ? DoctorRepository.courses.first
        : null;
    final nearest = getNearestTrip();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.today_rounded, size: 16, color: _navy),
            const SizedBox(width: 6),
            Text(
              'اليوم',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Row of 2 compact cards: CARD 1: المحاضرة القادمة, CARD 2: أقرب رحلة
        Row(
          children: [
            // Card 1: المحاضرة القادمة
            Expanded(
              child: Material(
                color: _white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    if (firstCourse != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              DoctorCourseDetailsScreen(course: firstCourse),
                        ),
                      );
                    } else {
                      _navigateToCourses(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 114),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
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
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _lightBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: _blue,
                                size: 15,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _lightBlue,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                firstCourse?.startTime ?? '08:00',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: _blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'المحاضرة القادمة',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _textSub,
                              ),
                            ),
                            Text(
                              firstCourse?.courseName ?? 'معالج دقيق',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _textMain,
                              ),
                            ),
                            Text(
                              'القاعة ${firstCourse?.room ?? "4212"}',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: _textSub,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Card 2: أقرب رحلة
            Expanded(
              child: Material(
                color: _white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DoctorTransportScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 114),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
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
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _goldLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.directions_bus_rounded,
                                color: Color(0xFFB78103),
                                size: 15,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: nearest.hasTripsLeft
                                    ? _goldLight
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                nearest.hasTripsLeft
                                    ? nearest.departureTime
                                    : 'انتهت',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: nearest.hasTripsLeft
                                      ? const Color(0xFFB78103)
                                      : _textSub,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'أقرب رحلة نقل',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _textSub,
                              ),
                            ),
                            Text(
                              nearest.hasTripsLeft
                                  ? nearest.waveName
                                  : 'لا توجد رحلات متبقية',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _textMain,
                              ),
                            ),
                            Text(
                              nearest.hasTripsLeft
                                  ? '${nearest.stopsCount} محطات'
                                  : 'عرض جدول النقل',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: _blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Compact "جدول اليوم" Card with simple rows & "عرض الجدول الكامل"
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 15, color: _blue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'جدول اليوم',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _textMain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDFAF1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'السبت (دوام فعلي)',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E9B5F),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 6),

              // Simple Row 1
              _buildScheduleCompactRow(
                time: '08:00 - 11:00',
                title: 'معالج دقيق',
                room: '4212',
                isOfficeHour: false,
              ),
              const Divider(height: 10, color: Color(0xFFF1F5F9)),

              // Simple Row 2
              _buildScheduleCompactRow(
                time: '11:00 - 13:00',
                title: 'الاحتمالات والإشارات العشوائية',
                room: '4212',
                isOfficeHour: false,
              ),
              const Divider(height: 10, color: Color(0xFFF1F5F9)),

              // Simple Row 3: Office Hours
              _buildScheduleCompactRow(
                time: '13:00 - 14:00',
                title: 'الساعات المكتبية والاستشارات',
                room: '4202',
                isOfficeHour: true,
              ),

              const SizedBox(height: 8),
              // Button: عرض الجدول الكامل
              InkWell(
                onTap: () => _navigateToCourses(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'عرض الجدول الكامل',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: _blue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCompactRow({
    required String time,
    required String title,
    required String room,
    required bool isOfficeHour,
  }) {
    return Row(
      children: [
        Container(
          width: 82,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: isOfficeHour
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            time,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isOfficeHour ? const Color(0xFF166534) : _navy,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isOfficeHour ? const Color(0xFF166534) : _textMain,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _border),
          ),
          child: Text(
            room,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _textSub,
            ),
          ),
        ),
      ],
    );
  }

  // ── 4. تنبيه مهم ────────────────────────────────────────────────────────────
  Widget _buildImportantAlert(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const DoctorAcademicSubmissionScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFD54F)),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECB3),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.alarm_on_rounded,
                  color: Color(0xFFB78103),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'تنبيه إداري عاجل',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF8D6E63),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53E3E).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'مهم',
                            style: GoogleFonts.cairo(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE53E3E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'آخر موعد لرفع علامات الامتحان النهائي إلى الإدارة: 10-09-2026',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Color(0xFFB78103),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 5. نظرة عامة (Exact 4 Cards in 2x2 Grid) ────────────────────────────────
  Widget _buildOverviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.dashboard_rounded, size: 16, color: _navy),
            const SizedBox(width: 6),
            Text(
              'نظرة عامة',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Row 1: [المقررات الحالية] [الشعب المسندة]
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                title: 'المقررات الحالية',
                value: '2',
                subtitle: 'معالج دقيق، احتمالات',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF2E9B5F),
                bgColor: const Color(0xFFEDFAF1),
                onTap: () => _navigateToCourses(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildOverviewCard(
                title: 'الشعب المسندة',
                value: '2',
                subtitle: 'شعبة 1، شعبة 2',
                icon: Icons.layers_rounded,
                color: _blue,
                bgColor: _lightBlue,
                onTap: () => _navigateToCourses(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: [أسئلة الطلاب] [تسليمات للمراجعة]
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                title: 'أسئلة الطلاب',
                value: '7',
                subtitle: '3 بحاجة لرد',
                icon: Icons.help_outline_rounded,
                color: _gold,
                bgColor: _goldLight,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DoctorStudentQuestionsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildOverviewCard(
                title: 'تسليمات للمراجعة',
                value: '12',
                subtitle: 'تكليفات طلاب معلقة',
                icon: Icons.assignment_turned_in_rounded,
                color: const Color(0xFFE67E22),
                bgColor: const Color(0xFFFDF2E9),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DoctorAssignmentsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
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
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
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
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
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

  // ── 6. إجراءات سريعة (4 Primary Actions + Full Screen Button) ────────────────
  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flash_on_rounded, size: 16, color: _gold),
            const SizedBox(width: 6),
            Text(
              'إجراءات سريعة',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Row 1: [سجل العلامات] [تسجيل الحضور]
        Row(
          children: [
            Expanded(
              child: _buildHomeActionCard(
                title: 'سجل العلامات',
                subtitle: 'إدخال ومراجعة الدرجات',
                icon: Icons.grade_rounded,
                iconColor: _blue,
                iconBg: _lightBlue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DoctorGradesScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildHomeActionCard(
                title: 'تسجيل الحضور',
                subtitle: 'رصد الحضور والغياب',
                icon: Icons.how_to_reg_rounded,
                iconColor: const Color(0xFF2E9B5F),
                iconBg: const Color(0xFFEDFAF1),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const DoctorAttendanceScreen(showBack: true),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: [رفع النتائج للإدارة] [مركز الامتحانات]
        Row(
          children: [
            Expanded(
              child: _buildHomeActionCard(
                title: 'رفع النتائج للإدارة',
                subtitle: 'اعتماد رقمي بدون أوراق',
                icon: Icons.drive_folder_upload_rounded,
                iconColor: const Color(0xFF8E44AD),
                iconBg: const Color(0xFFF4ECF7),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DoctorAcademicSubmissionScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildHomeActionCard(
                title: 'مركز الامتحانات',
                subtitle: 'نماذج وبرامج الامتحانات',
                icon: Icons.description_rounded,
                iconColor: const Color(0xFF16A085),
                iconBg: const Color(0xFFE8F8F5),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DoctorExamCenterScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Button: عرض جميع العمليات
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DoctorQuickActionsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.grid_view_rounded, size: 16, color: _navy),
            label: Text(
              'عرض جميع العمليات (8)',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: const BorderSide(color: _border),
              backgroundColor: _white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
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
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 16),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
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
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
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
