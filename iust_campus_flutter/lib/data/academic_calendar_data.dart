// ─────────────────────────────────────────────────────────────────────────────
// Official Academic Calendar 2025/2026
// Source: IUST official schedule
// DO NOT invent additional dates.
// ─────────────────────────────────────────────────────────────────────────────

enum CalendarEventType {
  registration,
  studyStart,
  addDrop,
  lastDay,
  midtermExam,
  makeup,
  withdrawal,
  privationNotice,
  finalExam,
  resultsAnnounced,
  objection,
  adminDeadline,
  holiday,
  semesterBroadcast,
}

extension CalendarEventTypeX on CalendarEventType {
  String get labelAr {
    switch (this) {
      case CalendarEventType.registration:     return 'تسجيل';
      case CalendarEventType.studyStart:       return 'بدء الدراسة';
      case CalendarEventType.addDrop:          return 'سحب وإضافة';
      case CalendarEventType.lastDay:          return 'آخر موعد';
      case CalendarEventType.midtermExam:      return 'امتحان نصفي';
      case CalendarEventType.makeup:           return 'امتحان غير مكتمل';
      case CalendarEventType.withdrawal:       return 'انسحاب';
      case CalendarEventType.privationNotice:  return 'قوائم حرمان';
      case CalendarEventType.finalExam:        return 'امتحان نهائي';
      case CalendarEventType.resultsAnnounced: return 'إعلان نتائج';
      case CalendarEventType.objection:        return 'اعتراض';
      case CalendarEventType.adminDeadline:    return 'موعد إداري';
      case CalendarEventType.holiday:          return 'عطلة';
      case CalendarEventType.semesterBroadcast:return 'إرسال برنامج';
    }
  }
}

class AcademicEvent {
  final String id;
  final String semesterId;   // '20251' | '20252' | '20253'
  final String semesterName;
  final DateTime startDate;
  final DateTime? endDate;   // null = single day
  final String titleAr;
  final CalendarEventType type;

  const AcademicEvent({
    required this.id,
    required this.semesterId,
    required this.semesterName,
    required this.startDate,
    this.endDate,
    required this.titleAr,
    required this.type,
  });

  bool get isSingleDay => endDate == null || endDate!.isAtSameMomentAs(startDate);

  /// Returns true if today falls within this event's date range.
  bool get isCurrentOrUpcoming {
    final now = DateTime.now();
    final end = endDate ?? startDate;
    return !end.isBefore(DateTime(now.year, now.month, now.day));
  }
}

// ── SEMESTER 1 — 20251 ────────────────────────────────────────────────────────
const _s1 = '20251';
const _s1n = 'الفصل الأول 2025/2026';

// ── SEMESTER 2 — 20252 ────────────────────────────────────────────────────────
const _s2 = '20252';
const _s2n = 'الفصل الثاني 2025/2026';

// ── SUMMER SEMESTER — 20253 ───────────────────────────────────────────────────
const _s3 = '20253';
const _s3n = 'الفصل الصيفي 2025/2026';

final kAcademicCalendar = <AcademicEvent>[

  // ════════════════════════════════════════════════════════════════════════════
  // FIRST SEMESTER — 20251
  // ════════════════════════════════════════════════════════════════════════════
  AcademicEvent(id: 'ev-s1-01', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2025, 9, 15), endDate: DateTime(2025, 9, 21),
      titleAr: 'فترة التسجيل للطلبة القدامى',
      type: CalendarEventType.registration),
  AcademicEvent(id: 'ev-s1-02', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2025, 9, 22),
      titleAr: 'بدء الدراسة للفصل الدراسي الأول',
      type: CalendarEventType.studyStart),
  AcademicEvent(id: 'ev-s1-03', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2025, 9, 22), endDate: DateTime(2025, 9, 24),
      titleAr: 'فترة السحب والإضافة',
      type: CalendarEventType.addDrop),
  AcademicEvent(id: 'ev-s1-04', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2025, 9, 27),
      titleAr: 'آخر موعد لإلغاء الشعب وإعلان القوائم النهائية',
      type: CalendarEventType.lastDay),
  AcademicEvent(id: 'ev-s1-05', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2025, 11, 8), endDate: DateTime(2025, 11, 17),
      titleAr: 'فترة الامتحان النصفي',
      type: CalendarEventType.midtermExam),
  AcademicEvent(id: 'ev-s1-06', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2025, 11, 18),
      titleAr: 'موعد تقديم امتحان غير مكتمل للامتحان النصفي',
      type: CalendarEventType.makeup),
  AcademicEvent(id: 'ev-s1-07', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2026, 1, 3),
      titleAr: 'انتهاء فترة الانسحاب المتأخر من مقرر أو من الفصل',
      type: CalendarEventType.withdrawal),
  AcademicEvent(id: 'ev-s1-08', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2026, 1, 7),
      titleAr: 'آخر موعد لإرسال قوائم الحرمان من الامتحانات النهائية',
      type: CalendarEventType.privationNotice),
  AcademicEvent(id: 'ev-s1-09', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2026, 1, 10), endDate: DateTime(2026, 1, 19),
      titleAr: 'فترة الامتحانات النهائية',
      type: CalendarEventType.finalExam),
  AcademicEvent(id: 'ev-s1-10', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2026, 1, 20),
      titleAr: 'موعد تقديم امتحان غير مكتمل للامتحان النهائي',
      type: CalendarEventType.makeup),
  AcademicEvent(id: 'ev-s1-11', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2026, 1, 24),
      titleAr: 'آخر موعد لتسليم العلامات إلى دائرة التسجيل',
      type: CalendarEventType.adminDeadline),
  AcademicEvent(id: 'ev-s1-12', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2026, 1, 25),
      titleAr: 'إعلان نتائج مواد الفصل الدراسي الأول',
      type: CalendarEventType.resultsAnnounced),
  AcademicEvent(id: 'ev-s1-13', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2026, 1, 26), endDate: DateTime(2026, 1, 28),
      titleAr: 'فترة الاعتراض على نتيجة الامتحانات النهائية',
      type: CalendarEventType.objection),
  AcademicEvent(id: 'ev-s1-14', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2026, 1, 31),
      titleAr: 'آخر موعد لتسليم نتائج الاعتراضات',
      type: CalendarEventType.adminDeadline),
  AcademicEvent(id: 'ev-s1-15', semesterId: _s1, semesterName: _s1n,
      startDate: DateTime(2026, 2, 1),
      titleAr: 'آخر موعد لإرسال برنامج الفصل الثاني 20252',
      type: CalendarEventType.semesterBroadcast),

  // ════════════════════════════════════════════════════════════════════════════
  // SECOND SEMESTER — 20252
  // ════════════════════════════════════════════════════════════════════════════
  AcademicEvent(id: 'ev-s2-01', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 2, 7), endDate: DateTime(2026, 2, 14),
      titleAr: 'فترة التسجيل لمواد الفصل الدراسي الثاني',
      type: CalendarEventType.registration),
  AcademicEvent(id: 'ev-s2-02', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 2, 15),
      titleAr: 'بدء الدراسة للفصل الدراسي الثاني',
      type: CalendarEventType.studyStart),
  AcademicEvent(id: 'ev-s2-03', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 2, 15), endDate: DateTime(2026, 2, 17),
      titleAr: 'فترة السحب والإضافة',
      type: CalendarEventType.addDrop),
  AcademicEvent(id: 'ev-s2-04', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 2, 21),
      titleAr: 'آخر موعد لإلغاء الشعب وإعلان القوائم النهائية',
      type: CalendarEventType.lastDay),
  AcademicEvent(id: 'ev-s2-05', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 3, 20), endDate: DateTime(2026, 3, 22),
      titleAr: 'عطلة عيد الفطر (تقديري)',
      type: CalendarEventType.holiday),
  AcademicEvent(id: 'ev-s2-06', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 4, 5),
      titleAr: 'عيد الفصح الغربي',
      type: CalendarEventType.holiday),
  AcademicEvent(id: 'ev-s2-07', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 4, 12),
      titleAr: 'عيد الفصح الشرقي',
      type: CalendarEventType.holiday),
  AcademicEvent(id: 'ev-s2-08', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 4, 18), endDate: DateTime(2026, 4, 27),
      titleAr: 'فترة الامتحان النصفي',
      type: CalendarEventType.midtermExam),
  AcademicEvent(id: 'ev-s2-09', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 4, 28),
      titleAr: 'موعد تقديم امتحان غير مكتمل للامتحان النصفي',
      type: CalendarEventType.makeup),
  AcademicEvent(id: 'ev-s2-10', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 5, 27), endDate: DateTime(2026, 5, 30),
      titleAr: 'عطلة عيد الأضحى (تقديري)',
      type: CalendarEventType.holiday),
  AcademicEvent(id: 'ev-s2-11', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 6, 6),
      titleAr: 'انتهاء فترة الانسحاب المتأخر',
      type: CalendarEventType.withdrawal),
  AcademicEvent(id: 'ev-s2-12', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 6, 10),
      titleAr: 'آخر موعد لإرسال قوائم الحرمان',
      type: CalendarEventType.privationNotice),
  AcademicEvent(id: 'ev-s2-13', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 6, 13), endDate: DateTime(2026, 6, 22),
      titleAr: 'فترة الامتحانات النهائية',
      type: CalendarEventType.finalExam),
  AcademicEvent(id: 'ev-s2-14', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 6, 23),
      titleAr: 'موعد تقديم امتحان غير مكتمل للامتحان النهائي',
      type: CalendarEventType.makeup),
  AcademicEvent(id: 'ev-s2-15', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 6, 27),
      titleAr: 'آخر موعد لتسليم العلامات إلى دائرة التسجيل',
      type: CalendarEventType.adminDeadline),
  AcademicEvent(id: 'ev-s2-16', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 6, 28),
      titleAr: 'إعلان نتائج مواد الفصل الدراسي الثاني',
      type: CalendarEventType.resultsAnnounced),
  AcademicEvent(id: 'ev-s2-17', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 6, 29), endDate: DateTime(2026, 7, 1),
      titleAr: 'فترة الاعتراض على نتيجة الامتحانات النهائية',
      type: CalendarEventType.objection),
  AcademicEvent(id: 'ev-s2-18', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 7, 4),
      titleAr: 'آخر موعد لتسليم نتائج الاعتراضات',
      type: CalendarEventType.adminDeadline),
  AcademicEvent(id: 'ev-s2-19', semesterId: _s2, semesterName: _s2n,
      startDate: DateTime(2026, 7, 8),
      titleAr: 'آخر موعد لإرسال برنامج الفصل الصيفي 20253',
      type: CalendarEventType.semesterBroadcast),

  // ════════════════════════════════════════════════════════════════════════════
  // SUMMER SEMESTER — 20253
  // ════════════════════════════════════════════════════════════════════════════
  AcademicEvent(id: 'ev-s3-01', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 7, 11), endDate: DateTime(2026, 7, 18),
      titleAr: 'فترة التسجيل لمواد الفصل الصيفي',
      type: CalendarEventType.registration),
  AcademicEvent(id: 'ev-s3-02', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 7, 19),
      titleAr: 'بدء الدراسة للفصل الدراسي الصيفي',
      type: CalendarEventType.studyStart),
  AcademicEvent(id: 'ev-s3-03', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 7, 19), endDate: DateTime(2026, 7, 22),
      titleAr: 'فترة السحب والإضافة',
      type: CalendarEventType.addDrop),
  AcademicEvent(id: 'ev-s3-04', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 7, 25),
      titleAr: 'آخر موعد لإلغاء الشعب وإعلان القوائم النهائية',
      type: CalendarEventType.lastDay),
  AcademicEvent(id: 'ev-s3-05', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 8, 8), endDate: DateTime(2026, 8, 11),
      titleAr: 'فترة الامتحان النصفي',
      type: CalendarEventType.midtermExam),
  AcademicEvent(id: 'ev-s3-06', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 8, 12),
      titleAr: 'موعد تقديم امتحان غير مكتمل للامتحان النصفي',
      type: CalendarEventType.makeup),
  AcademicEvent(id: 'ev-s3-07', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 8, 22),
      titleAr: 'انتهاء فترة الانسحاب المتأخر',
      type: CalendarEventType.withdrawal),
  AcademicEvent(id: 'ev-s3-08', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 8, 26),
      titleAr: 'آخر موعد لإرسال قوائم الحرمان',
      type: CalendarEventType.privationNotice),
  AcademicEvent(id: 'ev-s3-09', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 8, 29), endDate: DateTime(2026, 9, 1),
      titleAr: 'فترة الامتحانات النهائية',
      type: CalendarEventType.finalExam),
  AcademicEvent(id: 'ev-s3-10', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 9, 2),
      titleAr: 'موعد تقديم امتحان غير مكتمل للامتحان النهائي',
      type: CalendarEventType.makeup),
  AcademicEvent(id: 'ev-s3-11', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 9, 5),
      titleAr: 'آخر موعد لتسليم العلامات إلى دائرة التسجيل',
      type: CalendarEventType.adminDeadline),
  AcademicEvent(id: 'ev-s3-12', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 9, 6),
      titleAr: 'إعلان نتائج مواد الفصل الدراسي الصيفي',
      type: CalendarEventType.resultsAnnounced),
  AcademicEvent(id: 'ev-s3-13', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 9, 7), endDate: DateTime(2026, 9, 9),
      titleAr: 'فترة الاعتراض على نتيجة الامتحانات النهائية',
      type: CalendarEventType.objection),
  AcademicEvent(id: 'ev-s3-14', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 9, 12),
      titleAr: 'آخر موعد لتسليم نتائج الاعتراضات',
      type: CalendarEventType.adminDeadline),
  AcademicEvent(id: 'ev-s3-15', semesterId: _s3, semesterName: _s3n,
      startDate: DateTime(2026, 9, 12),
      titleAr: 'آخر موعد لإرسال برنامج الفصل الأول 20261',
      type: CalendarEventType.semesterBroadcast),
];

// ── Helper: nearest upcoming event ────────────────────────────────────────────
AcademicEvent? get kNextAcademicEvent {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final upcoming = kAcademicCalendar.where((e) {
    final end = e.endDate ?? e.startDate;
    return !end.isBefore(today);
  }).toList();
  if (upcoming.isEmpty) return null;
  upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
  return upcoming.first;
}
