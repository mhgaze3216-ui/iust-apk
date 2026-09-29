// ─────────────────────────────────────────────────────────────────────────────
// Notification domain models
// Backend-compatible structure for student notifications.
// ─────────────────────────────────────────────────────────────────────────────

enum NotificationType {
  exam,      // تنبيه امتحانات
  schedule,  // تذكير جدول ومحاضرات
  academic,  // تنبيه أكاديمي
  calendar,  // التقويم الأكاديمي
  transport, // النقل الجامعي
}

class StudentNotification {
  final String id;
  final String? studentId; // null = global notification
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  bool isRead;

  StudentNotification({
    required this.id,
    this.studentId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  StudentNotification copyWith({
    String? id,
    String? studentId,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return StudentNotification(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
