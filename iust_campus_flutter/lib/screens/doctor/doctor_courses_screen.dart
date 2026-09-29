import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/doctor_repository.dart';
import '../../models/doctor_models.dart';
import '../../theme/app_theme.dart';
import '../campus_map_screen.dart';
import 'doctor_course_details_screen.dart';
import 'widgets/doctor_back_button.dart';
import 'widgets/doctor_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorCoursesScreen extends StatelessWidget {
  final bool showBack;
  const DoctorCoursesScreen({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final courses = DoctorRepository.courses;

    final content = Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Column(
          children: [
            DoctorHeader(showBackButton: showBack),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderBanner(context),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.menu_book_rounded,
                              size: 18, color: _navy),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'المقررات المسندة (${courses.length})',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _textMain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...courses.map((c) => _buildCourseCard(context, c)),
                      const SizedBox(height: 105),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (showBack) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          safeDoctorPop(context);
        },
        child: content,
      );
    }
    return content;
  }

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مقرراتي التدريسية',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'متابعة الشعب والمحاضرات والتقييمات لكل مقرر',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CampusMapScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.map_outlined,
                  size: 20, color: AppTheme.primary),
              label: Text(
                'خريطة القاعات والمباني',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppTheme.primary.withValues(alpha: 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, DoctorCourse c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DoctorCourseDetailsScreen(course: c),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Activity Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        c.courseName,
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _textMain,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        c.activityType,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'الشعبة ${c.section} · ${c.semester}',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    color: _textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 14),
                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 15, color: _blue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${c.day} ${c.startTime} - ${c.endTime}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: _textMain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_rounded,
                            size: 16, color: _navy),
                        const SizedBox(width: 6),
                        Text(
                          c.room != null ? 'القاعة ${c.room}' : 'غير متوفر',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _navy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups_rounded,
                            size: 16, color: Color(0xFF8E44AD)),
                        const SizedBox(width: 6),
                        Text(
                          '${c.studentCount} طالباً',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF8E44AD),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'إدارة المقرر',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _blue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: _blue),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
