import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/notification_model.dart';
import '../../services/mock_notifications_service.dart';
import '../../services/student_session.dart';
import 'student_calendar_screen.dart';
import 'student_courses_screen.dart';
import 'student_final_exams_screen.dart';
import 'student_transport_screen.dart';

const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _lightBlue = Color(0xFFEAF4FB);
const _gold      = Color(0xFFF5B82E);
const _goldLight = Color(0xFFFFF4D6);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

/// Modal bottom sheet presenting the student's notifications.
class StudentNotificationsSheet extends StatelessWidget {
  final String? studentId;
  const StudentNotificationsSheet({super.key, this.studentId});

  static Future<void> show(BuildContext context, {String? studentId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentNotificationsSheet(studentId: studentId),
    );
  }

  void _handleNotificationTap(BuildContext context, StudentNotification notification, String sid) {
    // 1. Mark as read
    MockNotificationsService.markAsRead(notification.id, sid);

    // 2. Dismiss sheet
    Navigator.of(context).pop();

    // 3. Navigate to respective screen
    switch (notification.type) {
      case NotificationType.exam:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => StudentFinalExamsScreen(studentId: sid),
        ));
      case NotificationType.calendar:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => StudentCalendarScreen(studentId: sid),
        ));
      case NotificationType.transport:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const StudentTransportScreen(),
        ));
      case NotificationType.academic:
      case NotificationType.schedule:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => StudentCoursesScreen(studentId: sid),
        ));
    }
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m <= 1 ? 'الآن' : 'منذ $m دقيقة';
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return h == 1 ? 'منذ ساعة' : 'منذ $h ساعات';
    } else {
      final d = diff.inDays;
      return d == 1 ? 'أمس' : 'منذ $d أيام';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sid = studentId ?? StudentSession.currentStudentId;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── drag handle ───────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // ── header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications_rounded, color: _blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإشعارات',
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _textMain,
                          ),
                        ),
                        ValueListenableBuilder<List<StudentNotification>>(
                          valueListenable: MockNotificationsService.getNotifier(sid),
                          builder: (context, notifs, child) {
                            final unread = notifs.where((n) => !n.isRead).length;
                            return Text(
                              unread == 0
                                  ? 'لا توجد إشعارات غير مقروءة'
                                  : '$unread إشعار غير مقروء',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: _textSub,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => MockNotificationsService.markAllAsRead(sid),
                    icon: const Icon(Icons.done_all_rounded, size: 16, color: _blue),
                    label: Text(
                      'تحديد الكل كمقروء',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16, color: _border),

            // ── notification list ─────────────────────────────────────
            Flexible(
              child: ValueListenableBuilder<List<StudentNotification>>(
                valueListenable: MockNotificationsService.getNotifier(sid),
                builder: (context, notifs, _) {
                  if (notifs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none_rounded, size: 48, color: _textSub.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد إشعارات حالياً',
                            style: GoogleFonts.cairo(fontSize: 14, color: _textSub),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: notifs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = notifs[i];
                      return _NotificationTile(
                        notification: item,
                        timeStr: _formatRelativeTime(item.createdAt),
                        onTap: () => _handleNotificationTap(context, item, sid),
                      );
                    },
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.timeStr,
    required this.onTap,
  });

  final StudentNotification notification;
  final String timeStr;
  final VoidCallback onTap;

  (IconData icon, Color iconColor, Color bg) get _visuals {
    switch (notification.type) {
      case NotificationType.exam:
        return (Icons.event_note_rounded, _gold, _goldLight);
      case NotificationType.calendar:
        return (Icons.calendar_month_rounded, _blue, _lightBlue);
      case NotificationType.transport:
        return (Icons.directions_bus_rounded, const Color(0xFF2E9B5F), const Color(0xFFEDFAF1));
      case NotificationType.schedule:
        return (Icons.schedule_rounded, _blue, _lightBlue);
      case NotificationType.academic:
        return (Icons.school_rounded, _blue, _lightBlue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, bg) = _visuals;
    final isUnread = !notification.isRead;

    return Material(
      color: isUnread ? _lightBg : _white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnread ? _blue.withValues(alpha: 0.25) : _border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
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
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                              color: _textMain,
                            ),
                          ),
                        ),
                        Text(
                          timeStr,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: _textSub,
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53E3E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.message,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isUnread ? _textMain.withValues(alpha: 0.85) : _textSub,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
