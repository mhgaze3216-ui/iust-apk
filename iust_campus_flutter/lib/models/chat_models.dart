// ─────────────────────────────────────────────────────────────────────────────
// Chat domain models
// Backend-compatible structure — replace local storage with HTTP calls when ready.
// ─────────────────────────────────────────────────────────────────────────────

enum SenderRole { student, doctor, admin, guest, staff }

// ── Student ↔ Doctor ─────────────────────────────────────────────────────────

class Conversation {
  final String conversationId;
  final String studentId;
  final String doctorId;
  final String doctorName;
  final String? courseId;
  final String? courseName;
  final DateTime createdAt;

  const Conversation({
    required this.conversationId,
    required this.studentId,
    required this.doctorId,
    required this.doctorName,
    this.courseId,
    this.courseName,
    required this.createdAt,
  });
}

class ChatMessage {
  final String messageId;
  final String conversationId;
  final String senderUserId;
  final SenderRole senderRole;
  final String receiverUserId;
  final String body;
  final DateTime sentAt;
  DateTime? readAt;

  ChatMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderUserId,
    required this.senderRole,
    required this.receiverUserId,
    required this.body,
    required this.sentAt,
    this.readAt,
  });
}

// ── Guest ↔ Admin ─────────────────────────────────────────────────────────────

enum InquiryStatus { newInquiry, opened, answered, closed }

class GuestInquiry {
  final String inquiryId;
  final String guestName;
  final String? contactInfo; // optional email or phone
  final String? email;
  final String? phone;
  final String? category;
  final String? subject;
  final String? attachmentName;
  final String message;
  final DateTime createdAt;
  InquiryStatus status;

  GuestInquiry({
    required this.inquiryId,
    required this.guestName,
    this.contactInfo,
    this.email,
    this.phone,
    this.category,
    this.subject,
    this.attachmentName,
    required this.message,
    required this.createdAt,
    this.status = InquiryStatus.newInquiry,
  });
}
