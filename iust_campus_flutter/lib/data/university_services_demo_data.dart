import 'package:flutter/material.dart';

import '../services/api_client.dart';

/// Models and centralized demo repository for the IUST University Administrative Services hub
/// (الإدارة الجامعية - خدمات إدارية رقمية للطلاب والدكاترة والموظفين).

class UniversityDepartment {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> services;

  const UniversityDepartment({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.services,
  });
}

class UniversityService {
  final String id;
  final String departmentId;
  final String name;
  final String description;

  const UniversityService({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.description,
  });
}

class UniversityTransaction {
  final String id;
  final String title;
  final String description;
  final String department;
  final List<String> requirements;
  final List<String> documents;
  final String fees;
  final String expectedDuration;
  final List<String> steps;
  final IconData icon;

  const UniversityTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.requirements,
    required this.documents,
    required this.fees,
    required this.expectedDuration,
    required this.steps,
    required this.icon,
  });
}

enum UniversityRequestStatus {
  newRequest,
  inReview,
  completed,
  rejected,
  cancelled,
}

class RequestTimelineEntry {
  final String title;
  final String date;
  final String note;
  final bool isCompleted;

  const RequestTimelineEntry({
    required this.title,
    required this.date,
    required this.note,
    required this.isCompleted,
  });
}

class UniversityRequest {
  final String id;
  final String title;
  final String department;
  final String requestType;
  final String date;
  final UniversityRequestStatus status;
  final String description;
  final List<String> attachments;
  final List<RequestTimelineEntry> timeline;

  UniversityRequest({
    required this.id,
    required this.title,
    required this.department,
    required this.requestType,
    required this.date,
    required this.status,
    required this.description,
    required this.attachments,
    required this.timeline,
  });

  String get statusLabel {
    switch (status) {
      case UniversityRequestStatus.newRequest:
        return 'جديد';
      case UniversityRequestStatus.inReview:
        return 'قيد المراجعة';
      case UniversityRequestStatus.completed:
        return 'مكتمل';
      case UniversityRequestStatus.rejected:
        return 'مرفوض';
      case UniversityRequestStatus.cancelled:
        return 'ملغى';
    }
  }

  Color get statusColor {
    switch (status) {
      case UniversityRequestStatus.newRequest:
        return const Color(0xFF0F6CBD);
      case UniversityRequestStatus.inReview:
        return const Color(0xFFE67E22);
      case UniversityRequestStatus.completed:
        return const Color(0xFF16A34A);
      case UniversityRequestStatus.rejected:
        return const Color(0xFFDC2626);
      case UniversityRequestStatus.cancelled:
        return const Color(0xFF6F7F89);
    }
  }

  Color get statusBgColor {
    switch (status) {
      case UniversityRequestStatus.newRequest:
        return const Color(0xFFEAF4FB);
      case UniversityRequestStatus.inReview:
        return const Color(0xFFFDF2E9);
      case UniversityRequestStatus.completed:
        return const Color(0xFFEDFAF1);
      case UniversityRequestStatus.rejected:
        return const Color(0xFFFEE2E2);
      case UniversityRequestStatus.cancelled:
        return const Color(0xFFF1F5F9);
    }
  }
}

enum AppointmentStatus { confirmed, pending, completed, cancelled }

class UniversityAppointment {
  final String id;
  final String title;
  final String purpose;
  final String department;
  final String date;
  final String time;
  final String office;
  final AppointmentStatus status;

  const UniversityAppointment({
    required this.id,
    required this.title,
    required this.purpose,
    required this.department,
    required this.date,
    required this.time,
    required this.office,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'مؤكد';
      case AppointmentStatus.pending:
        return 'قيد الانتظار';
      case AppointmentStatus.completed:
        return 'مكتمل';
      case AppointmentStatus.cancelled:
        return 'ملغى';
    }
  }

  Color get statusColor {
    switch (status) {
      case AppointmentStatus.confirmed:
        return const Color(0xFF16A34A);
      case AppointmentStatus.pending:
        return const Color(0xFFE67E22);
      case AppointmentStatus.completed:
        return const Color(0xFF0F6CBD);
      case AppointmentStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  Color get statusBgColor {
    switch (status) {
      case AppointmentStatus.confirmed:
        return const Color(0xFFEDFAF1);
      case AppointmentStatus.pending:
        return const Color(0xFFFDF2E9);
      case AppointmentStatus.completed:
        return const Color(0xFFEAF4FB);
      case AppointmentStatus.cancelled:
        return const Color(0xFFFEE2E2);
    }
  }
}

class UniversityNewsItem {
  final String id;
  final String category;
  final String title;
  final String description;
  final String fullContent;
  final String date;
  final IconData icon;

  const UniversityNewsItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.fullContent,
    required this.date,
    required this.icon,
  });
}

class FaqItem {
  final String id;
  final String category;
  final String question;
  final String answer;

  const FaqItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });
}

class UniversityServicesRepository {
  // ── 1. Departments List (10 University Administrative Departments) ─────────
  static List<UniversityDepartment> departments = [];
  static List<String> inquiryTypes = [];
  static List<UniversityTransaction> transactions = [];
  static List<UniversityNewsItem> news = [];
  static List<FaqItem> faqs = [];
  static List<UniversityRequest> requests = [];
  static List<UniversityAppointment> appointments = [];
  static List<({String id, String message, String time, bool isUnread})>
  notifications = [];

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
    for (final department in departments) {
      if (department.id == id) return department.name;
    }
    return _apiText(id);
  }

  static UniversityDepartment? _departmentByName(String name) {
    for (final department in departments) {
      if (department.name == name) return department;
    }
    return null;
  }

  static Future<void> initializeFromApi() async {
    departments = [];
    inquiryTypes = [];
    transactions = [];
    news = [];
    faqs = [];
    requests.clear();
    appointments.clear();
    notifications.clear();

    final responses = await Future.wait([
      ApiClient.instance.get('/public/departments'),
      ApiClient.instance.get('/public/services'),
      ApiClient.instance.get('/public/transactions'),
      ApiClient.instance.get('/public/news'),
      ApiClient.instance.get('/public/faqs'),
      ApiClient.instance.get('/requests'),
      ApiClient.instance.get('/appointments'),
      ApiClient.instance.get('/notifications'),
    ]);
    final departmentsFromApi = _apiRows(responses[0], 'department');
    final servicesFromApi = _apiRows(responses[1], 'service');
    final servicesByDepartment = <String, List<Map<String, dynamic>>>{};
    for (final service in servicesFromApi) {
      servicesByDepartment
          .putIfAbsent(_apiText(service['departmentId']), () => [])
          .add(service);
    }
    departments = departmentsFromApi
        .map((item) {
          final id = _apiText(item['id']);
          return UniversityDepartment(
            id: id,
            name: _apiText(item['nameAr']),
            description: _apiText(item['description']),
            icon: Icons.account_balance_rounded,
            services: (servicesByDepartment[id] ?? const [])
                .map((service) => _apiText(service['name']))
                .toList(growable: false),
          );
        })
        .toList(growable: false);
    inquiryTypes = servicesFromApi
        .map((item) => _apiText(item['name']))
        .toSet()
        .toList(growable: false);
    transactions = _apiRows(responses[2], 'transaction')
        .map(
          (item) => UniversityTransaction(
            id: _apiText(item['id']),
            title: _apiText(item['title']),
            description: _apiText(item['description']),
            department: _departmentName(item['departmentId']),
            requirements: _apiStrings(item['requirements']),
            documents: _apiStrings(item['documents']),
            fees: _apiText(item['fees']),
            expectedDuration: _apiText(item['expectedDuration']),
            steps: _apiStrings(item['steps']),
            icon: Icons.description_rounded,
          ),
        )
        .toList(growable: false);
    news = _apiRows(responses[3], 'news item')
        .map(
          (item) => UniversityNewsItem(
            id: _apiText(item['id']),
            category: _apiText(item['category']),
            title: _apiText(item['title']),
            description: _apiText(item['summary']),
            fullContent: _apiText(item['content']),
            date: _apiDate(item['publishedAt']),
            icon: Icons.campaign_rounded,
          ),
        )
        .toList(growable: false);
    faqs = _apiRows(responses[4], 'FAQ')
        .map(
          (item) => FaqItem(
            id: _apiText(item['id']),
            category: _apiText(item['category']),
            question: _apiText(item['question']),
            answer: _apiText(item['answer']),
          ),
        )
        .toList(growable: false);
    _replaceRequests(_apiRows(responses[5], 'request'));
    _replaceAppointments(_apiRows(responses[6], 'appointment'));
    notifications
      ..clear()
      ..addAll(
        _apiRows(responses[7], 'notification').map(
          (item) => (
            id: _apiText(item['id']),
            message: _apiText(item['message']),
            time: _apiDate(item['createdAt']),
            isUnread: item['readAt'] == null,
          ),
        ),
      );
  }

  static void _replaceRequests(List<Map<String, dynamic>> rows) {
    requests
      ..clear()
      ..addAll(
        rows.map((item) {
          final statusText = _apiText(item['status']);
          final status = switch (statusText) {
            'in_review' ||
            'waiting_on_user' => UniversityRequestStatus.inReview,
            'completed' => UniversityRequestStatus.completed,
            'rejected' => UniversityRequestStatus.rejected,
            'cancelled' => UniversityRequestStatus.cancelled,
            _ => UniversityRequestStatus.newRequest,
          };
          return UniversityRequest(
            id: _apiText(item['id']),
            title: _apiText(item['title']),
            department: _departmentName(item['departmentId']),
            requestType: _apiText(item['category']),
            date: _apiDate(item['createdAt']),
            status: status,
            description: _apiText(item['description']),
            attachments: const [],
            timeline: [
              RequestTimelineEntry(
                title: statusText,
                date: _apiDate(item['createdAt']),
                note: _apiText(item['reference']),
                isCompleted: true,
              ),
            ],
          );
        }),
      );
  }

  static void _replaceAppointments(List<Map<String, dynamic>> rows) {
    appointments
      ..clear()
      ..addAll(
        rows.map((item) {
          final startsAt = DateTime.tryParse(_apiText(item['startsAt']));
          final status = switch (_apiText(item['status'])) {
            'confirmed' => AppointmentStatus.confirmed,
            'completed' => AppointmentStatus.completed,
            'cancelled' => AppointmentStatus.cancelled,
            _ => AppointmentStatus.pending,
          };
          return UniversityAppointment(
            id: _apiText(item['id']),
            title: _apiText(item['purpose']),
            purpose: _apiText(item['purpose']),
            department: _apiText(
              item['departmentName'],
              _apiText(item['departmentId']),
            ),
            date: _apiDate(item['startsAt']),
            time: startsAt == null
                ? ''
                : '${startsAt.hour.toString().padLeft(2, '0')}:${startsAt.minute.toString().padLeft(2, '0')}',
            office: '',
            status: status,
          );
        }),
      );
  }

  static int get unreadNotificationsCount =>
      notifications.where((n) => n.isUnread).length;

  // ── 9. Mutator helper methods ─────────────────────────────────────────────
  static Future<void> addInquiryRequest({
    required String type,
    required String subject,
    required String content,
    String? attachmentName,
  }) async {
    if (attachmentName != null) {
      throw UnsupportedError(
        'The API does not support uploading request attachments.',
      );
    }
    final department = _departmentByName(type);
    final response = await ApiClient.instance.post(
      '/requests',
      body: {
        if (department != null) 'departmentId': department.id,
        'category': type,
        'title': subject,
        'description': content,
      },
    );
    final item = _apiObject(response['data'] ?? response, 'request');
    _replaceRequests(
      _apiRows(await ApiClient.instance.get('/requests'), 'request'),
    );
    if (requests.every((request) => request.id != _apiText(item['id']))) {
      throw StateError('The request was created but could not be reloaded.');
    }
  }

  static Future<void> addAppointment({
    required String department,
    required String service,
    required String date,
    required String time,
  }) async {
    final selectedDepartment = _departmentByName(department);
    if (selectedDepartment == null) {
      throw StateError(
        'The selected department is not available from the API.',
      );
    }
    final selectedDate = DateTime.tryParse(date);
    if (selectedDate == null) {
      throw FormatException('The selected appointment date is invalid.');
    }
    final dateQuery =
        '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final slots = _apiRows(
      await ApiClient.instance.get(
        '/appointments/availability',
        query: {'departmentId': selectedDepartment.id, 'date': dateQuery},
      ),
      'appointment slot',
    );
    final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(time);
    if (timeMatch == null) {
      throw FormatException('The selected appointment time is invalid.');
    }
    var hour = int.parse(timeMatch.group(1)!);
    final minute = int.parse(timeMatch.group(2)!);
    if (time.contains('مساء') && hour < 12) hour += 12;
    if (time.contains('صباح') && hour == 12) hour = 0;
    Map<String, dynamic>? selectedSlot;
    for (final slot in slots) {
      final startsAt = DateTime.tryParse(_apiText(slot['startsAt']))?.toLocal();
      if (startsAt != null &&
          startsAt.hour == hour &&
          startsAt.minute == minute) {
        selectedSlot = slot;
        break;
      }
    }
    if (selectedSlot == null) {
      throw StateError(
        'No appointment slot is available at the selected time.',
      );
    }
    final startsAt = DateTime.parse(_apiText(selectedSlot['startsAt']));
    final endsAt = DateTime.parse(_apiText(selectedSlot['endsAt']));
    await ApiClient.instance.post(
      '/appointments',
      body: {
        'departmentId': selectedDepartment.id,
        'purpose': service,
        'startsAt': startsAt.toUtc().toIso8601String(),
        'endsAt': endsAt.toUtc().toIso8601String(),
      },
    );
    _replaceAppointments(
      _apiRows(await ApiClient.instance.get('/appointments'), 'appointment'),
    );
  }
}
