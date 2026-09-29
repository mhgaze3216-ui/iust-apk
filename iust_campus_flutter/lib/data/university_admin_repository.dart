import 'package:flutter/material.dart';

import '../services/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UNIVERSITY ADMINISTRATION V2 REPOSITORY & MODELS
// ─────────────────────────────────────────────────────────────────────────────

enum AdminReqStatus {
  newRequest,
  inReview,
  waitingOnUser,
  completed,
  rejected,
  cancelled,
}

class AdminReqItem {
  final String id;
  final String title;
  final String requesterName;
  final String requesterRole;
  final String requesterId;
  final String department;
  final String date;
  AdminReqStatus status;
  final String priority;
  final String description;
  final List<String> attachments;
  final List<String> historyLog;
  String? adminNote;

  AdminReqItem({
    required this.id,
    required this.title,
    required this.requesterName,
    required this.requesterRole,
    required this.requesterId,
    required this.department,
    required this.date,
    required this.status,
    required this.priority,
    required this.description,
    required this.attachments,
    required this.historyLog,
    this.adminNote,
  });

  String get statusLabel {
    switch (status) {
      case AdminReqStatus.newRequest:
        return 'جديد';
      case AdminReqStatus.inReview:
        return 'قيد المراجعة';
      case AdminReqStatus.waitingOnUser:
        return 'بانتظار المستخدم';
      case AdminReqStatus.completed:
        return 'مكتمل';
      case AdminReqStatus.rejected:
        return 'مرفوض';
      case AdminReqStatus.cancelled:
        return 'ملغى';
    }
  }

  Color get statusColor {
    switch (status) {
      case AdminReqStatus.newRequest:
        return const Color(0xFF0F6CBD);
      case AdminReqStatus.inReview:
        return const Color(0xFFE67E22);
      case AdminReqStatus.waitingOnUser:
        return const Color(0xFFE67E22);
      case AdminReqStatus.completed:
        return const Color(0xFF16A34A);
      case AdminReqStatus.rejected:
        return const Color(0xFFDC2626);
      case AdminReqStatus.cancelled:
        return const Color(0xFF6F7F89);
    }
  }

  Color get statusBgColor {
    switch (status) {
      case AdminReqStatus.newRequest:
        return const Color(0xFFEAF4FB);
      case AdminReqStatus.inReview:
        return const Color(0xFFFDF2E9);
      case AdminReqStatus.waitingOnUser:
        return const Color(0xFFFDF2E9);
      case AdminReqStatus.completed:
        return const Color(0xFFEDFAF1);
      case AdminReqStatus.rejected:
        return const Color(0xFFFEE2E2);
      case AdminReqStatus.cancelled:
        return const Color(0xFFF1F5F9);
    }
  }
}

class AdminAppointmentItem {
  final String id;
  final String title;
  final String userName;
  final String userRole;
  final String reason;
  final String department;
  final String date;
  final String time;
  final String status;
  final String notes;

  AdminAppointmentItem({
    required this.id,
    required this.title,
    required this.userName,
    required this.userRole,
    required this.reason,
    required this.department,
    required this.date,
    required this.time,
    required this.status,
    this.notes = '',
  });

  bool get isUpcoming => status == 'مؤكد' || status == 'قيد الانتظار';
}

class AdminTransactionDef {
  final String id;
  final String title;
  final String department;
  final String description;
  final List<String> requirements;
  final List<String> documents;
  final String fees;
  final String expectedDuration;
  final List<String> steps;
  final IconData icon;

  const AdminTransactionDef({
    required this.id,
    required this.title,
    required this.department,
    required this.description,
    required this.requirements,
    required this.documents,
    required this.fees,
    required this.expectedDuration,
    required this.steps,
    required this.icon,
  });
}

class AdminUserAccount {
  final String id;
  final String name;
  final String userNumber;
  final String role; // 'طالب' | 'دكتور' | 'إداري' | 'موظف'
  final String facultyOrDept;
  final String email;
  bool isActive;
  List<String> permissions;
  final String username;
  final String targetId;
  final String jobTitle;
  final bool isDemo;

  AdminUserAccount({
    required this.id,
    required this.name,
    required this.userNumber,
    required this.role,
    required this.facultyOrDept,
    required this.email,
    required this.isActive,
    required this.permissions,
    this.username = '',
    this.targetId = '',
    this.jobTitle = '',
    this.isDemo = false,
  });
}

enum AnnouncementState { published, draft, scheduled }

class AdminAnnouncementItem {
  final String id;
  String title;
  String category;
  String content;
  final String targetAudience;
  final String publishDate;
  AnnouncementState state;

  AdminAnnouncementItem({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.targetAudience,
    required this.publishDate,
    required this.state,
  });
}

class AdminFaqModel {
  final String id;
  final String category;
  String question;
  String answer;
  bool isVisible;

  AdminFaqModel({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    this.isVisible = true,
  });
}

class InquiryMessage {
  final String sender;
  final String text;
  final String time;
  final bool isAdmin;

  const InquiryMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isAdmin,
  });
}

class AdminInquiryItem {
  final String id;
  final String userName;
  final String department;
  final String question;
  final String time;
  String status; // 'جديد' | 'تم الرد' | 'مغلق'
  final List<InquiryMessage> messages;

  AdminInquiryItem({
    required this.id,
    required this.userName,
    required this.department,
    required this.question,
    required this.time,
    required this.status,
    required this.messages,
  });
}

class AdminNotificationModel {
  final String id;
  final String text;
  final String time;
  bool isUnread;

  AdminNotificationModel({
    required this.id,
    required this.text,
    required this.time,
    this.isUnread = true,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CENTRALIZED REPOSITORY CLASS
// ─────────────────────────────────────────────────────────────────────────────

class UniversityAdminRepository {
  // ── 1. Requests ───────────────────────────────────────────────────────────
  static List<AdminReqItem> requests = [];

  // ── 2. Appointments ───────────────────────────────────────────────────────
  static List<AdminAppointmentItem> appointments = [];

  // ── 3. Transactions Guide (12 transactions) ───────────────────────────────
  static List<AdminTransactionDef> transactions = [];

  // ── 4. Accounts Management ────────────────────────────────────────────────
  static List<AdminUserAccount> accounts = [];

  // ── 5. News & Announcements ───────────────────────────────────────────────
  static List<AdminAnnouncementItem> announcements = [];

  // ── 6. FAQs Management ────────────────────────────────────────────────────
  static List<AdminFaqModel> faqs = [];

  // ── 7. Inquiries ──────────────────────────────────────────────────────────
  static List<AdminInquiryItem> inquiries = [];

  // ── 8. Notifications ──────────────────────────────────────────────────────
  static List<AdminNotificationModel> notifications = [];

  static Map<String, String> _departmentIdsByName = const {};
  static List<String> _departmentNames = const [];
  static List<String> get departmentNames =>
      List.unmodifiable(_departmentNames);

  static Map<String, dynamic> _apiObject(Object? value, String field) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('The API returned an invalid $field object.');
  }

  static List<Map<String, dynamic>> _apiRows(Object? response, String field) {
    final value = response is Map<String, dynamic>
        ? response['data'] ?? response
        : response;
    if (value is! List) {
      throw FormatException('The API returned an invalid $field list.');
    }
    return value.map((item) => _apiObject(item, field)).toList(growable: false);
  }

  static String _apiText(Object? value, [String fallback = '']) =>
      value?.toString() ?? fallback;

  static List<String> _apiStrings(Object? value) => value is List
      ? value.map((item) => item.toString()).toList(growable: false)
      : const [];

  static String _apiDate(Object? value) {
    final date = DateTime.tryParse(_apiText(value));
    return date == null
        ? _apiText(value)
        : '${date.day}/${date.month}/${date.year}';
  }

  static String _departmentName(Object? id) {
    for (final entry in _departmentIdsByName.entries) {
      if (entry.value == id) return entry.key;
    }
    return _apiText(id);
  }

  static Future<void> initializeFromApi() async {
    requests.clear();
    appointments.clear();
    transactions = [];
    accounts.clear();
    announcements.clear();
    faqs.clear();
    inquiries.clear();
    notifications.clear();
    _departmentIdsByName = const {};
    _departmentNames = const [];

    final responses = await Future.wait([
      ApiClient.instance.get('/admin/requests'),
      ApiClient.instance.get('/appointments'),
      ApiClient.instance.get('/public/transactions'),
      ApiClient.instance.get('/admin/users'),
      ApiClient.instance.get('/admin/announcements'),
      ApiClient.instance.get('/admin/faqs'),
      ApiClient.instance.get('/admin/inquiries'),
      ApiClient.instance.get('/notifications'),
      ApiClient.instance.get('/public/departments'),
    ]);
    final departments = _apiRows(responses[8], 'department');
    _departmentIdsByName = {
      for (final item in departments)
        _apiText(item['nameAr']): _apiText(item['id']),
    };
    _departmentNames = departments
        .map((item) => _apiText(item['nameAr']))
        .toList(growable: false);

    requests.addAll(
      _apiRows(responses[0], 'request').map((item) {
        final status = switch (_apiText(item['status'])) {
          'in_review' => AdminReqStatus.inReview,
          'waiting_on_user' => AdminReqStatus.waitingOnUser,
          'completed' => AdminReqStatus.completed,
          'rejected' => AdminReqStatus.rejected,
          'cancelled' => AdminReqStatus.cancelled,
          _ => AdminReqStatus.newRequest,
        };
        final priority = switch (_apiText(item['priority'])) {
          'urgent' || 'high' => 'عالي',
          'low' => 'منخفض',
          _ => 'عادي',
        };
        return AdminReqItem(
          id: _apiText(item['id']),
          title: _apiText(item['title']),
          requesterName: _apiText(item['requesterUserId']),
          requesterRole: 'مستخدم',
          requesterId: _apiText(item['requesterUserId']),
          department: _departmentName(item['departmentId']),
          date: _apiDate(item['createdAt']),
          status: status,
          priority: priority,
          description: _apiText(item['description']),
          attachments: const [],
          historyLog: [_apiText(item['reference'])],
        );
      }),
    );
    appointments.addAll(
      _apiRows(responses[1], 'appointment').map((item) {
        final start = DateTime.tryParse(_apiText(item['startsAt']));
        final end = DateTime.tryParse(_apiText(item['endsAt']));
        final status = switch (_apiText(item['status'])) {
          'confirmed' => 'مؤكد',
          'completed' => 'مكتمل',
          'cancelled' => 'ملغى',
          _ => 'قيد الانتظار',
        };
        return AdminAppointmentItem(
          id: _apiText(item['id']),
          title: _apiText(item['purpose']),
          userName: _apiText(item['requesterUserId']),
          userRole: 'مستخدم',
          reason: _apiText(item['purpose']),
          department: _apiText(
            item['departmentName'],
            _departmentName(item['departmentId']),
          ),
          date: _apiDate(item['startsAt']),
          time: start == null
              ? ''
              : '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end == null ? '' : '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}'}',
          status: status,
          notes: _apiText(item['notes']),
        );
      }),
    );
    transactions = _apiRows(responses[2], 'transaction')
        .map(
          (item) => AdminTransactionDef(
            id: _apiText(item['id']),
            title: _apiText(item['title']),
            department: _departmentName(item['departmentId']),
            description: _apiText(item['description']),
            requirements: _apiStrings(item['requirements']),
            documents: _apiStrings(item['documents']),
            fees: _apiText(item['fees']),
            expectedDuration: _apiText(item['expectedDuration']),
            steps: _apiStrings(item['steps']),
            icon: Icons.description_rounded,
          ),
        )
        .toList(growable: false);
    accounts.addAll(
      _apiRows(responses[3], 'user').map((item) {
        final role = switch (_apiText(item['role'])) {
          'student' => 'طالب',
          'doctor' => 'دكتور',
          'staff' => 'موظف',
          'admin' => 'إداري',
          final value => value,
        };
        return AdminUserAccount(
          id: _apiText(item['id']),
          targetId: _apiText(item['id']),
          name: _apiText(item['fullName']),
          userNumber: _apiText(item['username']),
          username: _apiText(item['username']),
          role: role,
          facultyOrDept: '',
          email: _apiText(item['email']),
          isActive: _apiText(item['status']) == 'active',
          permissions: const [],
          jobTitle: '',
          isDemo: false,
        );
      }),
    );
    announcements.addAll(
      _apiRows(responses[4], 'announcement').map((item) {
        final state = switch (_apiText(item['status'])) {
          'published' => AnnouncementState.published,
          'scheduled' => AnnouncementState.scheduled,
          _ => AnnouncementState.draft,
        };
        return AdminAnnouncementItem(
          id: _apiText(item['id']),
          title: _apiText(item['title']),
          category: _apiText(item['category']),
          content: _apiText(item['content']),
          targetAudience: _apiStrings(item['audience']).join(', '),
          publishDate: _apiDate(item['publishAt'] ?? item['publishedAt']),
          state: state,
        );
      }),
    );
    faqs.addAll(
      _apiRows(responses[5], 'FAQ').map(
        (item) => AdminFaqModel(
          id: _apiText(item['id']),
          category: _apiText(item['category']),
          question: _apiText(item['question']),
          answer: _apiText(item['answer']),
          isVisible: item['isPublished'] == true,
        ),
      ),
    );
    inquiries.addAll(
      _apiRows(responses[6], 'inquiry').map((item) {
        final message = _apiText(item['message']);
        return AdminInquiryItem(
          id: _apiText(item['id']),
          userName: _apiText(item['guestName']),
          department: _apiText(item['category']),
          question: _apiText(item['subject']),
          time: _apiDate(item['createdAt']),
          status: switch (_apiText(item['status'])) {
            'new' => 'جديد',
            'in_review' => 'تم الرد',
            'completed' || 'rejected' || 'cancelled' => 'مغلق',
            _ => 'قيد الانتظار',
          },
          messages: [
            InquiryMessage(
              sender: _apiText(item['guestName']),
              text: message,
              time: _apiDate(item['createdAt']),
              isAdmin: false,
            ),
          ],
        );
      }),
    );
    notifications.addAll(
      _apiRows(responses[7], 'notification').map(
        (item) => AdminNotificationModel(
          id: _apiText(item['id']),
          text: _apiText(item['message']),
          time: _apiDate(item['createdAt']),
          isUnread: item['readAt'] == null,
        ),
      ),
    );
  }

  static int get unreadNotificationsCount =>
      notifications.where((n) => n.isUnread).length;

  static Future<void> markNotificationRead(String id) async {
    await ApiClient.instance.patch('/notifications/$id/read');
    final item = notifications.where((notification) => notification.id == id);
    if (item.isNotEmpty) item.first.isUnread = false;
  }

  static Future<void> markAllNotificationsRead() async {
    await ApiClient.instance.post('/notifications/read-all');
    for (final notification in notifications) {
      notification.isUnread = false;
    }
  }

  // ── 9. Mutator Helpers ────────────────────────────────────────────────────
  static Future<void> updateRequestStatus(
    String reqId,
    AdminReqStatus newStatus, {
    String? note,
  }) async {
    final req = requests.firstWhere((r) => r.id == reqId);
    final status = switch (newStatus) {
      AdminReqStatus.newRequest => 'new',
      AdminReqStatus.inReview => 'in_review',
      AdminReqStatus.waitingOnUser => 'waiting_on_user',
      AdminReqStatus.completed => 'completed',
      AdminReqStatus.rejected => 'rejected',
      AdminReqStatus.cancelled => 'cancelled',
    };
    final requestBody = <String, dynamic>{'status': status};
    if (note != null) {
      requestBody['note'] = note;
    }
    await ApiClient.instance.patch(
      '/admin/requests/$reqId/status',
      body: requestBody,
    );
    req.status = newStatus;
    if (note != null && note.isNotEmpty) {
      req.adminNote = note;
    }
    req.historyLog.insert(
      0,
      'تم تحديث الحالة إلى "${req.statusLabel}" بواسطة الإدارة',
    );
  }

  static Future<void> addAppointment({
    required String title,
    required String userName,
    required String userRole,
    required String reason,
    required String department,
    required String date,
    required String time,
    String notes = '',
  }) async {
    throw UnsupportedError(
      'The API only supports self-service appointment booking; administrator booking on behalf of another user is not implemented.',
    );
  }

  static Future<void> addAnnouncement({
    required String title,
    required String category,
    required String content,
    required String targetAudience,
    required String publishDate,
    String? attachmentName,
  }) async {
    if (attachmentName != null) {
      throw UnsupportedError(
        'The API does not implement announcement attachment uploads.',
      );
    }
    final dateParts = publishDate.split('/');
    if (dateParts.length == 3) {
      final selectedDate = DateTime.tryParse(
        '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}',
      );
      if (selectedDate == null) {
        throw FormatException('The publication date is invalid.');
      }
      if (selectedDate.isAfter(DateTime.now())) {
        throw UnsupportedError(
          'Scheduled publishing is not configured by the API.',
        );
      }
    }
    final audiences = <String>[];
    final normalized = targetAudience.toLowerCase();
    if (normalized.contains('student') || targetAudience.contains('طالب')) {
      audiences.add('student');
    }

    if (normalized.contains('doctor') || targetAudience.contains('دكتور')) {
      audiences.add('doctor');
    }
    if (normalized.contains('staff') || targetAudience.contains('موظف')) {
      audiences.add('staff');
    }
    if (normalized.contains('admin') || targetAudience.contains('إداري')) {
      audiences.add('admin');
    }
    await ApiClient.instance.post(
      '/admin/announcements',
      body: {
        'title': title,
        'category': category,
        'content': content,
        'audience': audiences.isEmpty
            ? ['student', 'doctor', 'staff']
            : audiences,
        'status': 'published',
      },
    );
    final rows = _apiRows(
      await ApiClient.instance.get('/admin/announcements'),
      'announcement',
    );
    announcements
      ..clear()
      ..addAll(
        rows.map(
          (item) => AdminAnnouncementItem(
            id: _apiText(item['id']),
            title: _apiText(item['title']),
            category: _apiText(item['category']),
            content: _apiText(item['content']),
            targetAudience: _apiStrings(item['audience']).join(', '),
            publishDate: _apiDate(item['publishAt'] ?? item['publishedAt']),
            state: _apiText(item['status']) == 'published'
                ? AnnouncementState.published
                : AnnouncementState.draft,
          ),
        ),
      );
  }

  static Future<void> updateAnnouncementStatus(
    String id,
    AnnouncementState state,
  ) async {
    final status = switch (state) {
      AnnouncementState.published => 'published',
      AnnouncementState.draft => 'draft',
      AnnouncementState.scheduled => throw UnsupportedError(
        'Scheduled publishing is not configured by the API.',
      ),
    };
    await ApiClient.instance.patch(
      '/admin/announcements/$id',
      body: {'status': status},
    );
    final item = announcements.where((announcement) => announcement.id == id);
    if (item.isNotEmpty) item.first.state = state;
  }

  static Future<void> updateAnnouncement({
    required String id,
    String? title,
    String? category,
    String? content,
  }) async {
    final requestBody = <String, dynamic>{};
    if (title != null) requestBody['title'] = title;
    if (category != null) requestBody['category'] = category;
    if (content != null) requestBody['content'] = content;
    await ApiClient.instance.patch(
      '/admin/announcements/$id',
      body: requestBody,
    );
    final item = announcements.where((announcement) => announcement.id == id);
    if (item.isNotEmpty) {
      if (title != null) item.first.title = title;
      if (category != null) item.first.category = category;
      if (content != null) item.first.content = content;
    }
  }

  static Future<void> updateFaq({
    required String id,
    String? category,
    String? question,
    String? answer,
    bool? isVisible,
  }) async {
    final requestBody = <String, dynamic>{};
    if (category != null) requestBody['category'] = category;
    if (question != null) requestBody['question'] = question;
    if (answer != null) requestBody['answer'] = answer;
    if (isVisible != null) requestBody['isPublished'] = isVisible;
    await ApiClient.instance.patch(
      '/admin/faqs/$id',
      body: requestBody,
    );
    final rows = _apiRows(await ApiClient.instance.get('/admin/faqs'), 'FAQ');
    faqs
      ..clear()
      ..addAll(
        rows.map(
          (item) => AdminFaqModel(
            id: _apiText(item['id']),
            category: _apiText(item['category']),
            question: _apiText(item['question']),
            answer: _apiText(item['answer']),
            isVisible: item['isPublished'] == true,
          ),
        ),
      );
  }

  static Future<void> addFaq({
    required String category,
    required String question,
    required String answer,
  }) async {
    await ApiClient.instance.post(
      '/admin/faqs',
      body: {'category': category, 'question': question, 'answer': answer},
    );
    final rows = _apiRows(await ApiClient.instance.get('/admin/faqs'), 'FAQ');
    faqs
      ..clear()
      ..addAll(
        rows.map(
          (item) => AdminFaqModel(
            id: _apiText(item['id']),
            category: _apiText(item['category']),
            question: _apiText(item['question']),
            answer: _apiText(item['answer']),
            isVisible: item['isPublished'] == true,
          ),
        ),
      );
  }

  static Future<void> deleteFaq(String id) async {
    await ApiClient.instance.delete('/admin/faqs/$id');
    faqs.removeWhere((f) => f.id == id);
  }

  static Future<void> replyToInquiry(String inqId, String replyText) async {
    final inq = inquiries.firstWhere((i) => i.id == inqId);
    final response = await ApiClient.instance.post(
      '/admin/inquiries/$inqId/messages',
      body: {'body': replyText},
    );
    final item = _apiObject(response['data'] ?? response, 'inquiry message');
    inq.messages.add(
      InquiryMessage(
        sender: _apiText(item['senderLabel'], 'إدارة الجامعة'),
        text: _apiText(item['body'], replyText),
        time: _apiDate(item['createdAt']),
        isAdmin: true,
      ),
    );
    inq.status = 'تم الرد';
  }
}
