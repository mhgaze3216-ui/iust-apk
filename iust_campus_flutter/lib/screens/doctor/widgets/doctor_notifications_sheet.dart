import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/doctor_demo_data.dart';
import '../doctor_student_questions_screen.dart';
import '../doctor_assignments_screen.dart';
import '../doctor_grades_screen.dart';
import '../doctor_academic_submission_screen.dart';
import '../doctor_exam_center_screen.dart';
import '../doctor_account_screen.dart';
import '../doctor_midterm_schedule_screen.dart';
import '../doctor_transport_screen.dart';

const _blue = Color(0xFF0F6CBD);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);
const _gold = Color(0xFFF5B82E);

class DoctorNotificationsSheet extends StatefulWidget {
  const DoctorNotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DoctorNotificationsSheet(),
    );
  }

  @override
  State<DoctorNotificationsSheet> createState() =>
      _DoctorNotificationsSheetState();
}

class _DoctorNotificationsSheetState extends State<DoctorNotificationsSheet> {
  void _handleNotificationTap(BuildContext context, String notifId, String type) {
    DoctorDemoData.markNotificationAsRead(notifId);
    setState(() {});
    Navigator.of(context).pop(); // close sheet

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
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = DoctorDemoData.notifications;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFFB78103),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'تنبيهات التدريسي',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: _textMain,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (DoctorDemoData.unreadNotificationsCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE53E3E),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${DoctorDemoData.unreadNotificationsCount}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              'الإشعارات والمهام العاجلة',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
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
                TextButton(
                  onPressed: () {
                    setState(() {
                      DoctorDemoData.markAllNotificationsAsRead();
                    });
                  },
                  child: Text(
                    'تحديد الكل كمقروء',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: _border),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: _border),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return InkWell(
                    onTap: () => _handleNotificationTap(context, notif.id, notif.type),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: notif.isRead ? Colors.transparent : _blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      notif.title,
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.5,
                                        fontWeight: notif.isRead
                                            ? FontWeight.w600
                                            : FontWeight.w800,
                                        color: _textMain,
                                      ),
                                    ),
                                    Text(
                                      notif.time,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: _textSub,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.message,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: notif.isRead
                                        ? _textSub
                                        : const Color(0xFF2C3E50),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: _textSub,
                          ),
                        ],
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
  }
}
