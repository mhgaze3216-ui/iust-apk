import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/doctor_demo_data.dart';
import '../../models/doctor_models.dart';
import 'widgets/doctor_page_header.dart';
import 'widgets/doctor_back_button.dart';
import 'doctor_student_questions_screen.dart';
import 'doctor_assignments_screen.dart';
import 'doctor_grades_screen.dart';
import 'doctor_academic_submission_screen.dart';
import 'doctor_exam_center_screen.dart';
import 'doctor_account_screen.dart';
import 'doctor_midterm_schedule_screen.dart';
import 'doctor_transport_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF6F9FC);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);
const _gold = Color(0xFFF5B82E);

class DoctorNotificationsScreen extends StatefulWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  State<DoctorNotificationsScreen> createState() => _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState extends State<DoctorNotificationsScreen> {
  String _activeFilter = 'الكل'; // 'الكل' or 'غير مقروءة'

  void _handleNotificationTap(String notifId, String type) {
    DoctorDemoData.markNotificationAsRead(notifId);
    setState(() {});

    Widget target;
    switch (type) {
      case 'questions':
        target = const DoctorStudentQuestionsScreen();
        break;
      case 'assignments':
        target = const DoctorAssignmentsScreen();
        break;
      case 'grades':
        target = const DoctorGradesScreen();
        break;
      case 'submission':
        target = const DoctorAcademicSubmissionScreen();
        break;
      case 'exam':
        target = const DoctorExamCenterScreen();
        break;
      case 'officeHours':
        target = const DoctorAccountScreen();
        break;
      case 'schedule':
        target = const DoctorMidtermScheduleScreen();
        break;
      case 'transport':
        target = const DoctorTransportScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => target),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _markAllAsRead() {
    DoctorDemoData.markAllNotificationsAsRead();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديد كافة الإشعارات كمقروءة', style: GoogleFonts.cairo()),
        backgroundColor: _navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allNotifications = DoctorDemoData.notifications;
    final unreadCount = DoctorDemoData.unreadNotificationsCount;
    final notifications = _activeFilter == 'غير مقروءة'
        ? allNotifications.where((n) => !n.isRead).toList()
        : allNotifications;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: DoctorPageHeader(
          title: 'مركز الإشعارات',
          subtitle: unreadCount > 0 ? '$unreadCount إشعار جديد' : 'جميع الإشعارات مقروءة',
          showBackButton: true,
          actions: [
            if (unreadCount > 0)
              TextButton(
                onPressed: _markAllAsRead,
                child: Text(
                  'قراءة الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _blue,
                  ),
                ),
              ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Filter chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: _white,
                child: Row(
                  children: [
                    _buildFilterChip('الكل', allNotifications.length),
                    const SizedBox(width: 8),
                    _buildFilterChip('غير مقروءة', unreadCount),
                  ],
                ),
              ),
              const Divider(height: 1, color: _border),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: _white,
                                shape: BoxShape.circle,
                                border: Border.all(color: _border),
                              ),
                              child: const Icon(
                                Icons.notifications_off_outlined,
                                size: 30,
                                color: _textSub,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد إشعارات حالياً',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textMain,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: notifications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          return _buildNotificationCard(item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _activeFilter == label;
    return InkWell(
      onTap: () => setState(() => _activeFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? _navy : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? _white : _textSub,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? _white.withValues(alpha: 0.2) : _border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? _white : _textMain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(DoctorNotificationItem item) {
    Color iconBg;
    Color iconColor;
    IconData icon;

    switch (item.type) {
      case 'questions':
        iconBg = const Color(0xFFFFF4D6);
        iconColor = _gold;
        icon = Icons.question_answer_rounded;
        break;
      case 'assignments':
        iconBg = const Color(0xFFFDF2E9);
        iconColor = const Color(0xFFE67E22);
        icon = Icons.assignment_turned_in_rounded;
        break;
      case 'grades':
        iconBg = const Color(0xFFEDFAF1);
        iconColor = const Color(0xFF2E9B5F);
        icon = Icons.grade_rounded;
        break;
      case 'submission':
        iconBg = const Color(0xFFF4ECF7);
        iconColor = const Color(0xFF8E44AD);
        icon = Icons.drive_folder_upload_rounded;
        break;
      case 'exam':
        iconBg = const Color(0xFFE8F8F5);
        iconColor = const Color(0xFF16A085);
        icon = Icons.quiz_rounded;
        break;
      case 'officeHours':
        iconBg = const Color(0xFFEDFAF1);
        iconColor = const Color(0xFF16A34A);
        icon = Icons.perm_contact_calendar_rounded;
        break;
      case 'schedule':
        iconBg = const Color(0xFFFCEAE8);
        iconColor = const Color(0xFFC0392B);
        icon = Icons.calendar_month_rounded;
        break;
      case 'transport':
        iconBg = const Color(0xFFFFF4D6);
        iconColor = const Color(0xFFB78103);
        icon = Icons.directions_bus_rounded;
        break;
      default:
        iconBg = const Color(0xFFEAF4FB);
        iconColor = _blue;
        icon = Icons.notifications_rounded;
    }

    return Material(
      color: _white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _handleNotificationTap(item.id, item.type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead ? _border : _blue.withValues(alpha: 0.35),
              width: item.isRead ? 1 : 1.5,
            ),
            color: item.isRead ? _white : const Color(0xFFFAFDFF),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w800,
                              color: _textMain,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.message,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: item.isRead ? _textSub : const Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.time,
                      style: GoogleFonts.cairo(fontSize: 10.5, color: _textSub),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: _textSub,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
