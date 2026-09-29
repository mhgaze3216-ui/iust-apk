import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'student_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock Notifications Service
// Multi-student notifications keyed by studentId.
// Ready for backend integration when API endpoints are connected.
// ─────────────────────────────────────────────────────────────────────────────

class MockNotificationsService {
  static String _resolveStudentId([String? studentId]) =>
      studentId ?? StudentSession.currentStudentId;

  // Master notifications seed (personal keyed by studentId, global when studentId == null)
  static final List<StudentNotification> _seedNotifications = [
    // ── Global notifications for BOTH students (studentId = null) ───────────
    StudentNotification(
      id: 'notif-global-final-exam',
      studentId: null,
      title: 'تنبيه فاينل',
      message: 'راجع جدول الامتحانات النهائية ومواعيدك المؤكدة.',
      type: NotificationType.exam,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    StudentNotification(
      id: 'notif-global-calendar',
      studentId: null,
      title: 'التقويم الأكاديمي',
      message: 'راجع أقرب موعد أكاديمي في التقويم الجامعي.',
      type: NotificationType.calendar,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
    ),
    StudentNotification(
      id: 'notif-global-transport',
      studentId: null,
      title: 'النقل الجامعي',
      message: 'يمكنك مراجعة أقرب رحلة ومواعيد النقل الجامعي.',
      type: NotificationType.transport,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: false,
    ),

    // ── Personal notification for Hamza ─────────────────────────────────────
    StudentNotification(
      id: 'notif-hamza-academic-reminder',
      studentId: 'student-dentistry-001',
      title: 'تذكير أكاديمي',
      message: 'راجع موادك الحالية وجدولك الدراسي.',
      type: NotificationType.academic,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),

    // ── Personal notification for Mustafa ───────────────────────────────────
    StudentNotification(
      id: 'notif-mustafa-final-exam',
      studentId: 'student-informatics-002',
      title: 'تنبيه فاينل',
      message: 'امتحان مهارات اللغة الإنكليزية (2) بتاريخ 2026-09-06 من 09:00 إلى 10:15.',
      type: NotificationType.exam,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
  ];

  static final Map<String, ValueNotifier<List<StudentNotification>>> _notifiersByStudent = {};

  /// Get the ValueNotifier for a student's notifications.
  /// Includes personal notifications for that studentId and global notifications (where studentId == null).
  static ValueNotifier<List<StudentNotification>> getNotifier([String? studentId]) {
    final sid = _resolveStudentId(studentId);
    return _notifiersByStudent.putIfAbsent(sid, () {
      final initial = _seedNotifications
          .where((n) => n.studentId == null || n.studentId == sid)
          .map((n) => n.copyWith())
          .toList();
      return ValueNotifier<List<StudentNotification>>(initial);
    });
  }

  /// Default notifier for the currently active student session.
  static ValueNotifier<List<StudentNotification>> get notificationsNotifier =>
      getNotifier();

  /// Current unread notifications count for a student.
  static int getUnreadCount([String? studentId]) {
    final list = getNotifier(studentId).value;
    return list.where((n) => !n.isRead).length;
  }

  static int get unreadCount => getUnreadCount();

  /// Mark a notification as read.
  static void markAsRead(String id, [String? studentId]) {
    final notifier = getNotifier(studentId);
    final list = notifier.value;
    var modified = false;
    for (final n in list) {
      if (n.id == id && !n.isRead) {
        n.isRead = true;
        modified = true;
      }
    }
    if (modified) {
      notifier.value = List.from(list);
    }
  }

  /// Mark all notifications as read for a student.
  static void markAllAsRead([String? studentId]) {
    final notifier = getNotifier(studentId);
    final list = notifier.value;
    for (final n in list) {
      n.isRead = true;
    }
    notifier.value = List.from(list);
  }

  /// Reset in-memory notifiers (for unit testing purposes).
  static void resetForTesting() {
    _notifiersByStudent.clear();
  }
}
