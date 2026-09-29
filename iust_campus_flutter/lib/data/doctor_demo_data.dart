// ─────────────────────────────────────────────────────────────────────────────
// DEMO DATA — replace with backend / real university data later
// Centralized prototype dataset for the Doctor area (doctor-001).
// Encapsulates profile, courses, breakdown grades, attendance, exam center,
// digital submissions, assignments, questions, and administrative transactions.
// ─────────────────────────────────────────────────────────────────────────────

import '../models/doctor_models.dart';

class DoctorDemoData {
  // ── 1. Doctor Profile ─────────────────────────────────────────────────────
  static DoctorProfile _profile = const DoctorProfile(
    doctorId: 'doctor-001',
    fullName: 'د. محمد مازن محايري',
    office: '4202',
    workingDays: 'السبت',
    officeHours: '13:00 - 14:00',
    faculty: 'كلية الهندسة المعلوماتية والاتصالات',
    department: 'قسم المعلوماتية',
    academicRank: 'عضو هيئة تدريس',
    email: 'm.mahayeri@demo.iust.edu.sy',
    coursesCount: 2,
    sectionsCount: 2,
    studentsCount: 40,
    reviewSubmissionsCount: 12,
    newQuestionsCount: 7,
    draftTemplatesCount: 2,
  );

  static DoctorProfile get profile => _profile;

  static void updateProfile({String? fullName, String? email, String? office}) {
    _profile = _profile.copyWith(
      fullName: fullName,
      email: email,
      office: office,
    );
  }

  // ── 2. Doctor Courses ─────────────────────────────────────────────────────
  static final List<DoctorCourse> courses = [
    const DoctorCourse(
      courseId: 'doctor-course-001',
      courseCode: 'DEMO-421',
      courseName: 'معالج دقيق',
      section: 1,
      sectionCount: 1,
      room: '4212',
      day: 'السبت',
      startTime: '08:00',
      endTime: '11:00',
      studentCount: 40,
      activityType: 'نظري',
      teachingNote: 'مشكلة الطلاب في المادة: عدم فهم المؤشرات وآلية عملها',
      progress: 0.72,
      midtermWeight: 0.30,
      finalWeight: 0.50,
      courseworkWeight: 0.20,
      semester: 'الفصل الصيفي 2025/2026',
    ),
    const DoctorCourse(
      courseId: 'doctor-course-002',
      courseCode: 'DEMO-422',
      courseName: 'الاحتمالات والإشارات العشوائية',
      section: 2,
      sectionCount: 1,
      room: '4212',
      day: 'السبت',
      startTime: '11:00',
      endTime: '13:00',
      studentCount: 40,
      activityType: 'نظري',
      teachingNote: 'مشكلة الطلاب في المادة: عدم فهم المؤشرات وآلية عملها',
      progress: 0.68,
      midtermWeight: 0.30,
      finalWeight: 0.50,
      courseworkWeight: 0.20,
      semester: 'الفصل الصيفي 2025/2026',
    ),
  ];

  static DoctorCourse? getCourseById(String courseId) {
    for (final c in courses) {
      if (c.courseId == courseId ||
          (courseId == 'doc-course-microprocessor' &&
              c.courseId == 'doctor-course-001') ||
          (courseId == 'doc-course-probabilities' &&
              c.courseId == 'doctor-course-002')) {
        return c;
      }
    }
    return null;
  }

  // ── 3. 40-Student Roster ──────────────────────────────────────────────────
  static const List<({String id, String name})> roster = [
    (id: 'doctor001-student-001', name: 'حمزة السعدي'),
    (id: 'doctor001-student-002', name: 'نائلة الحمد'),
    (id: 'doctor001-student-003', name: 'محمد غازي الجاسم'),
    (id: 'doctor001-student-004', name: 'أنس الحموي'),
    (id: 'doctor001-student-005', name: 'مظهر جعفو'),
    (id: 'doctor001-student-006', name: 'أليسار عليا'),
    (id: 'doctor001-student-007', name: 'روني سلوم'),
    (id: 'doctor001-student-008', name: 'أوس الرحبي'),
    (id: 'doctor001-student-009', name: 'محمد شاهد'),
    (id: 'doctor001-student-010', name: 'عبد الرحمن فرستقي'),
    (id: 'doctor001-student-011', name: 'عبد الرحمن غريواتي'),
    (id: 'doctor001-student-012', name: 'محمد نويلاتي'),
    (id: 'doctor001-student-013', name: 'محمد البني'),
    (id: 'doctor001-student-014', name: 'انس العنيد'),
    (id: 'doctor001-student-015', name: 'سارة الجزار'),
    (id: 'doctor001-student-016', name: 'نور كبوش'),
    (id: 'doctor001-student-017', name: 'سارة خالد'),
    (id: 'doctor001-student-018', name: 'محمد جباوي'),
    (id: 'doctor001-student-019', name: 'عمر الدالاتي'),
    (id: 'doctor001-student-020', name: 'ريم البوشي'),
    (id: 'doctor001-student-021', name: 'باسل شرف الدين'),
    (id: 'doctor001-student-022', name: 'مايا الخطيب'),
    (id: 'doctor001-student-023', name: 'يمان القطان'),
    (id: 'doctor001-student-024', name: 'هبة البيطار'),
    (id: 'doctor001-student-025', name: 'كريم الحكيم'),
    (id: 'doctor001-student-026', name: 'سالي مراد'),
    (id: 'doctor001-student-027', name: 'جاد الحلبي'),
    (id: 'doctor001-student-028', name: 'شهد الكردي'),
    (id: 'doctor001-student-029', name: 'حازم الرفاعي'),
    (id: 'doctor001-student-030', name: 'لمى الحافظ'),
    (id: 'doctor001-student-031', name: 'طارق العظم'),
    (id: 'doctor001-student-032', name: 'نادين عرابي'),
    (id: 'doctor001-student-033', name: 'مجد الزين'),
    (id: 'doctor001-student-034', name: 'تالا شمعة'),
    (id: 'doctor001-student-035', name: 'عمار الباشا'),
    (id: 'doctor001-student-036', name: 'لين المصري'),
    (id: 'doctor001-student-037', name: 'سامر الصباغ'),
    (id: 'doctor001-student-038', name: 'فرح النحاس'),
    (id: 'doctor001-student-039', name: 'زياد الأيوبي'),
    (id: 'doctor001-student-040', name: 'ديما الجندي'),
  ];

  // ── 4. Breakdown Demo Grades (60–100 total) ───────────────────────────────
  // Stored once, fixed and persistent
  static final Map<String, ({int midterm, int coursework, int finalExam, int total})>
      _course1Grades = {
    'doctor001-student-001': (midterm: 26, coursework: 17, finalExam: 42, total: 85),
    'doctor001-student-002': (midterm: 28, coursework: 19, finalExam: 45, total: 92),
    'doctor001-student-003': (midterm: 23, coursework: 15, finalExam: 40, total: 78),
    'doctor001-student-004': (midterm: 20, coursework: 13, finalExam: 32, total: 65),
    'doctor001-student-005': (midterm: 27, coursework: 18, finalExam: 43, total: 88),
    'doctor001-student-006': (midterm: 29, coursework: 19, finalExam: 46, total: 94),
    'doctor001-student-007': (midterm: 22, coursework: 14, finalExam: 36, total: 72),
    'doctor001-student-008': (midterm: 25, coursework: 16, finalExam: 40, total: 81),
    'doctor001-student-009': (midterm: 21, coursework: 13, finalExam: 34, total: 68),
    'doctor001-student-010': (midterm: 27, coursework: 18, finalExam: 45, total: 90),
    'doctor001-student-011': (midterm: 23, coursework: 15, finalExam: 37, total: 75),
    'doctor001-student-012': (midterm: 25, coursework: 17, finalExam: 41, total: 83),
    'doctor001-student-013': (midterm: 19, coursework: 12, finalExam: 31, total: 62),
    'doctor001-student-014': (midterm: 26, coursework: 18, finalExam: 43, total: 87),
    'doctor001-student-015': (midterm: 29, coursework: 19, finalExam: 48, total: 96),
    'doctor001-student-016': (midterm: 21, coursework: 14, finalExam: 35, total: 70),
    'doctor001-student-017': (midterm: 27, coursework: 18, finalExam: 44, total: 89),
    'doctor001-student-018': (midterm: 24, coursework: 15, finalExam: 38, total: 77),
    'doctor001-student-019': (midterm: 19, coursework: 13, finalExam: 32, total: 64),
    'doctor001-student-020': (midterm: 28, coursework: 18, finalExam: 45, total: 91),
    'doctor001-student-021': (midterm: 25, coursework: 16, finalExam: 41, total: 82),
    'doctor001-student-022': (midterm: 30, coursework: 20, finalExam: 48, total: 98),
    'doctor001-student-023': (midterm: 22, coursework: 15, finalExam: 36, total: 73),
    'doctor001-student-024': (midterm: 26, coursework: 17, finalExam: 43, total: 86),
    'doctor001-student-025': (midterm: 21, coursework: 14, finalExam: 34, total: 69),
    'doctor001-student-026': (midterm: 28, coursework: 19, finalExam: 46, total: 93),
    'doctor001-student-027': (midterm: 23, coursework: 15, finalExam: 38, total: 76),
    'doctor001-student-028': (midterm: 25, coursework: 17, finalExam: 42, total: 84),
    'doctor001-student-029': (midterm: 20, coursework: 13, finalExam: 33, total: 66),
    'doctor001-student-030': (midterm: 27, coursework: 18, finalExam: 44, total: 89),
    'doctor001-student-031': (midterm: 22, coursework: 14, finalExam: 35, total: 71),
    'doctor001-student-032': (midterm: 29, coursework: 19, finalExam: 47, total: 95),
    'doctor001-student-033': (midterm: 24, coursework: 16, finalExam: 39, total: 79),
    'doctor001-student-034': (midterm: 26, coursework: 17, finalExam: 44, total: 87),
    'doctor001-student-035': (midterm: 19, coursework: 13, finalExam: 31, total: 63),
    'doctor001-student-036': (midterm: 27, coursework: 18, finalExam: 45, total: 90),
    'doctor001-student-037': (midterm: 24, coursework: 16, finalExam: 40, total: 80),
    'doctor001-student-038': (midterm: 29, coursework: 20, finalExam: 48, total: 97),
    'doctor001-student-039': (midterm: 23, coursework: 15, finalExam: 36, total: 74),
    'doctor001-student-040': (midterm: 26, coursework: 17, finalExam: 42, total: 85),
  };

  static final Map<String, ({int midterm, int coursework, int finalExam, int total})>
      _course2Grades = {
    'doctor001-student-001': (midterm: 24, coursework: 16, finalExam: 39, total: 79),
    'doctor001-student-002': (midterm: 27, coursework: 18, finalExam: 43, total: 88),
    'doctor001-student-003': (midterm: 28, coursework: 18, finalExam: 45, total: 91),
    'doctor001-student-004': (midterm: 21, coursework: 14, finalExam: 35, total: 70),
    'doctor001-student-005': (midterm: 25, coursework: 17, finalExam: 42, total: 84),
    'doctor001-student-006': (midterm: 27, coursework: 18, finalExam: 45, total: 90),
    'doctor001-student-007': (midterm: 20, coursework: 13, finalExam: 33, total: 66),
    'doctor001-student-008': (midterm: 26, coursework: 17, finalExam: 44, total: 87),
    'doctor001-student-009': (midterm: 23, coursework: 15, finalExam: 37, total: 75),
    'doctor001-student-010': (midterm: 28, coursework: 19, finalExam: 46, total: 93),
    'doctor001-student-011': (midterm: 25, coursework: 16, finalExam: 41, total: 82),
    'doctor001-student-012': (midterm: 24, coursework: 16, finalExam: 38, total: 78),
    'doctor001-student-013': (midterm: 21, coursework: 14, finalExam: 34, total: 69),
    'doctor001-student-014': (midterm: 28, coursework: 18, finalExam: 46, total: 92),
    'doctor001-student-015': (midterm: 27, coursework: 18, finalExam: 44, total: 89),
    'doctor001-student-016': (midterm: 23, coursework: 15, finalExam: 39, total: 77),
    'doctor001-student-017': (midterm: 29, coursework: 19, finalExam: 46, total: 94),
    'doctor001-student-018': (midterm: 25, coursework: 17, finalExam: 41, total: 83),
    'doctor001-student-019': (midterm: 22, coursework: 14, finalExam: 35, total: 71),
    'doctor001-student-020': (midterm: 26, coursework: 17, finalExam: 43, total: 86),
    'doctor001-student-021': (midterm: 23, coursework: 15, finalExam: 38, total: 76),
    'doctor001-student-022': (midterm: 29, coursework: 19, finalExam: 47, total: 95),
    'doctor001-student-023': (midterm: 24, coursework: 16, finalExam: 40, total: 80),
    'doctor001-student-024': (midterm: 28, coursework: 18, finalExam: 45, total: 91),
    'doctor001-student-025': (midterm: 20, coursework: 13, finalExam: 31, total: 64),
    'doctor001-student-026': (midterm: 27, coursework: 18, finalExam: 43, total: 88),
    'doctor001-student-027': (midterm: 25, coursework: 16, finalExam: 41, total: 82),
    'doctor001-student-028': (midterm: 27, coursework: 18, finalExam: 45, total: 90),
    'doctor001-student-029': (midterm: 22, coursework: 15, finalExam: 36, total: 73),
    'doctor001-student-030': (midterm: 29, coursework: 19, finalExam: 48, total: 96),
    'doctor001-student-031': (midterm: 21, coursework: 13, finalExam: 33, total: 67),
    'doctor001-student-032': (midterm: 27, coursework: 18, finalExam: 44, total: 89),
    'doctor001-student-033': (midterm: 25, coursework: 17, finalExam: 42, total: 84),
    'doctor001-student-034': (midterm: 28, coursework: 18, finalExam: 46, total: 92),
    'doctor001-student-035': (midterm: 19, coursework: 12, finalExam: 30, total: 61),
    'doctor001-student-036': (midterm: 26, coursework: 17, finalExam: 42, total: 85),
    'doctor001-student-037': (midterm: 24, coursework: 16, finalExam: 38, total: 78),
    'doctor001-student-038': (midterm: 28, coursework: 19, finalExam: 46, total: 93),
    'doctor001-student-039': (midterm: 25, coursework: 16, finalExam: 40, total: 81),
    'doctor001-student-040': (midterm: 27, coursework: 18, finalExam: 43, total: 88),
  };

  static Map<String, ({int midterm, int coursework, int finalExam, int total})>
      _getCourseGradeMap(String courseId) {
    if (courseId == 'doctor-course-001' || courseId == 'doc-course-microprocessor') {
      return _course1Grades;
    } else {
      return _course2Grades;
    }
  }

  static List<DoctorStudentGrade> getGradesForCourse(String courseId) {
    final gradeMap = _getCourseGradeMap(courseId);
    return roster.map((s) {
      final g = gradeMap[s.id] ?? (midterm: 24, coursework: 16, finalExam: 40, total: 80);
      return DoctorStudentGrade(
        studentId: s.id,
        studentName: s.name,
        courseId: courseId,
        midtermGrade: g.midterm,
        courseworkGrade: g.coursework,
        finalExamGrade: g.finalExam,
        numericGrade: g.total,
        gradeStatus: g.total >= 60 ? 'ناجح' : 'راسب',
      );
    }).toList();
  }

  static bool updateGrade(
    String courseId,
    String studentId,
    int newGrade, {
    int? midterm,
    int? coursework,
    int? finalExam,
  }) {
    if (newGrade < 0 || newGrade > 100) return false;
    final gradeMap = _getCourseGradeMap(courseId);
    final mid = midterm ?? (newGrade * 0.30).round();
    final cw = coursework ?? (newGrade * 0.20).round();
    final fin = finalExam ?? (newGrade - mid - cw);
    gradeMap[studentId] = (
      midterm: mid,
      coursework: cw,
      finalExam: fin,
      total: newGrade,
    );
    return true;
  }

  // ── 5. Attendance (Previous & Live Session) ────────────────────────────────
  static const AttendanceSession previousSessionCourse1 = AttendanceSession(
    sessionId: 'prev-session-001',
    courseId: 'doctor-course-001',
    sectionId: '1',
    date: _ConstDateTime(2026, 8, 29),
    room: '4212',
    presentCount: 36,
    lateCount: 2,
    absentCount: 2,
  );

  static const AttendanceSession previousSessionCourse2 = AttendanceSession(
    sessionId: 'prev-session-002',
    courseId: 'doctor-course-002',
    sectionId: '2',
    date: _ConstDateTime(2026, 8, 29),
    room: '4212',
    presentCount: 35,
    lateCount: 3,
    absentCount: 2,
  );

  static final Map<String, Map<String, AttendanceStatus>> _liveAttendanceSessions = {
    'doctor-course-001': {},
    'doctor-course-002': {},
    'doc-course-microprocessor': {},
    'doc-course-probabilities': {},
  };

  static Map<String, AttendanceStatus> getAttendanceForCourse(String courseId) {
    final normalized = (courseId == 'doc-course-microprocessor' ||
            courseId == 'doctor-course-001')
        ? 'doctor-course-001'
        : 'doctor-course-002';
    return _liveAttendanceSessions[normalized] ?? {};
  }

  static void setStudentAttendance(
    String courseId,
    String studentId,
    AttendanceStatus status,
  ) {
    final normalized = (courseId == 'doc-course-microprocessor' ||
            courseId == 'doctor-course-001')
        ? 'doctor-course-001'
        : 'doctor-course-002';
    _liveAttendanceSessions.putIfAbsent(normalized, () => {});
    _liveAttendanceSessions[normalized]![studentId] = status;
    // Mirror to alias
    _liveAttendanceSessions[courseId] = _liveAttendanceSessions[normalized]!;
  }

  static void clearAttendance(String courseId) {
    final normalized = (courseId == 'doc-course-microprocessor' ||
            courseId == 'doctor-course-001')
        ? 'doctor-course-001'
        : 'doctor-course-002';
    _liveAttendanceSessions[normalized]?.clear();
    _liveAttendanceSessions[courseId]?.clear();
  }

  // ── 6. Digital Submissions to Administration ──────────────────────────────
  static final List<AcademicSubmission> _submissions = [
    AcademicSubmission(
      id: 'sub-001',
      referenceNumber: 'DEMO-MID-001',
      courseId: 'doctor-course-001',
      courseName: 'معالج دقيق',
      section: 1,
      type: 'علامات الامتحان النصفي',
      studentsCount: 40,
      status: AcademicSubmissionStatus.approved,
      submittedAt: '2026-08-25 14:10',
      notes: 'تم تدقيق جميع أوراق الإجابة ومطابقة الجمع اليدوي مع الكشف الرقمي.',
    ),
    AcademicSubmission(
      id: 'sub-002',
      referenceNumber: 'DEMO-FINAL-002',
      courseId: 'doctor-course-002',
      courseName: 'الاحتمالات والإشارات العشوائية',
      section: 2,
      type: 'علامات الامتحان النهائي',
      studentsCount: 40,
      status: AcademicSubmissionStatus.draft,
      submittedAt: '2026-09-08 11:20',
      notes: 'جاهز للمراجعة بانتظار الاعتماد الرسمي النهائي من الإدارة.',
    ),
    AcademicSubmission(
      id: 'sub-003',
      referenceNumber: 'DEMO-GRADES-003',
      courseId: 'doctor-course-001',
      courseName: 'معالج دقيق',
      section: 1,
      type: 'كشف علامات الشعبة',
      studentsCount: 40,
      status: AcademicSubmissionStatus.draft,
      submittedAt: '2026-09-09 16:45',
      notes: 'كشف درجات الأعمال والمحاضرات العملية بانتظار توقيع العمادة.',
    ),
  ];

  static List<AcademicSubmission> get submissions =>
      List.unmodifiable(_submissions);

  static void addSubmission(AcademicSubmission submission) {
    _submissions.insert(0, submission);
  }

  static bool confirmSubmission(String id) {
    for (final s in _submissions) {
      if (s.id == id || s.referenceNumber == id) {
        s.status = AcademicSubmissionStatus.submitted;
        return true;
      }
    }
    return false;
  }

  // ── 7. Assignments / Tasks ────────────────────────────────────────────────
  static final List<DoctorAssignment> _assignments = [
    const DoctorAssignment(
      id: 'assign-001',
      courseId: 'doctor-course-001',
      courseName: 'معالج دقيق',
      title: 'تحليل المقاطعات في المعالج',
      deadline: '2026-09-03',
      submittedCount: 34,
      totalCount: 40,
      status: 'نشط',
    ),
    const DoctorAssignment(
      id: 'assign-002',
      courseId: 'doctor-course-002',
      courseName: 'الاحتمالات والإشارات العشوائية',
      title: 'مسائل المتغيرات العشوائية',
      deadline: '2026-09-04',
      submittedCount: 32,
      totalCount: 40,
      status: 'نشط',
    ),
  ];

  static List<DoctorAssignment> get assignments =>
      List.unmodifiable(_assignments);

  static void addAssignment(DoctorAssignment assignment) {
    _assignments.insert(0, assignment);
  }

  // ── 8. Student Questions ──────────────────────────────────────────────────
  static final List<DoctorStudentQuestion> _questions = [
    DoctorStudentQuestion(
      id: 'q-001',
      studentName: 'طالب تجريبي 1',
      courseId: 'doctor-course-001',
      courseName: 'معالج دقيق',
      question: 'ما الفرق بين المقاطعة الداخلية والخارجية؟',
      status: 'بانتظار الإجابة',
      createdAt: 'اليوم 10:15',
    ),
    DoctorStudentQuestion(
      id: 'q-002',
      studentName: 'طالب تجريبي 2',
      courseId: 'doctor-course-002',
      courseName: 'الاحتمالات والإشارات العشوائية',
      question: 'كيف نحدد نوع التوزيع الاحتمالي في المسألة؟',
      answer: 'نحدد التوزيع بناءً على طبيعة التجربة وكون المتغير متقطعاً أو مستمراً.',
      status: 'تمت الإجابة',
      createdAt: 'أمس 14:20',
    ),
    DoctorStudentQuestion(
      id: 'q-003',
      studentName: 'طالب تجريبي 3',
      courseId: 'doctor-course-001',
      courseName: 'معالج دقيق',
      question: 'هل مثال المؤشرات داخل ضمن الامتحان؟',
      status: 'جديد',
      createdAt: 'اليوم 09:00',
    ),
  ];

  static List<DoctorStudentQuestion> get questions =>
      List.unmodifiable(_questions);

  static void replyToQuestion(String questionId, String answer) {
    for (final q in _questions) {
      if (q.id == questionId) {
        q.answer = answer;
        q.status = 'تمت الإجابة';
        break;
      }
    }
  }

  // ── 9. Course Announcements ───────────────────────────────────────────────
  static final List<DoctorAnnouncement> _announcements = [
    DoctorAnnouncement(
      id: 'ann-001',
      doctorId: 'doctor-001',
      courseId: 'doctor-course-001',
      title: 'تذكير بموعد التكليف',
      content: 'آخر موعد لتسليم التكليف هو يوم الخميس القادم الساعة 23:59.',
      createdAt: DateTime(2026, 8, 30),
      status: 'منشور',
    ),
    DoctorAnnouncement(
      id: 'ann-002',
      doctorId: 'doctor-001',
      courseId: 'doctor-course-002',
      title: 'مراجعة قبل الفاينل',
      content: 'ستخصص المحاضرة القادمة لمراجعة أهم أفكار المقرر وحل نماذج امتحانية.',
      createdAt: DateTime(2026, 9, 2),
      status: 'منشور',
    ),
    DoctorAnnouncement(
      id: 'ann-003',
      doctorId: 'doctor-001',
      title: 'تغيير موعد الساعات المكتبية',
      content: 'تم تعديل الساعات المكتبية لهذا الأسبوع لتصبح السبت 14:00 - 15:00 بشكل تجريبي.',
      createdAt: DateTime(2026, 9, 5),
      status: 'مسودة',
    ),
  ];

  static List<DoctorAnnouncement> get announcements =>
      List.unmodifiable(_announcements);

  static void addAnnouncement(DoctorAnnouncement announcement) {
    _announcements.insert(0, announcement);
  }

  // ── 10. Doctor Notifications ──────────────────────────────────────────────
  static final List<DoctorNotificationItem> _notifications = [
    DoctorNotificationItem(
      id: 'notif-001',
      title: 'أسئلة جديدة',
      message: 'لديك 7 أسئلة جديدة من طلاب مقرراتك.',
      time: '10:30',
      type: 'questions',
      isRead: false,
    ),
    DoctorNotificationItem(
      id: 'notif-002',
      title: 'تسليمات بانتظار المراجعة',
      message: 'يوجد 12 تكليفاً بانتظار المراجعة.',
      time: '09:15',
      type: 'assignments',
      isRead: false,
    ),
    DoctorNotificationItem(
      id: 'notif-003',
      title: 'تنبيه العلامات',
      message: 'يرجى مراجعة سجل العلامات قبل إرسال النتائج إلى الإدارة.',
      time: 'أمس',
      type: 'grades',
      isRead: false,
    ),
    DoctorNotificationItem(
      id: 'notif-004',
      title: 'رفع النتائج',
      message: 'يوجد كشف علامات جاهز للمراجعة قبل الإرسال إلى الإدارة.',
      time: 'أمس',
      type: 'submission',
      isRead: false,
    ),
    DoctorNotificationItem(
      id: 'notif-005',
      title: 'الامتحان النهائي',
      message: 'يوجد نموذج امتحان نهائي بانتظار المراجعة.',
      time: 'منذ يومين',
      type: 'exam',
      isRead: true,
    ),
    DoctorNotificationItem(
      id: 'notif-006',
      title: 'الساعات المكتبية',
      message: 'الساعات المكتبية يوم السبت من 13:00 إلى 14:00 في المكتب 4202.',
      time: 'منذ 3 أيام',
      type: 'officeHours',
      isRead: true,
    ),
    DoctorNotificationItem(
      id: 'notif-007',
      title: 'محاضرات السبت',
      message: 'لديك محاضرتان يوم السبت في القاعة 4212.',
      time: 'منذ 3 أيام',
      type: 'schedule',
      isRead: true,
    ),
    DoctorNotificationItem(
      id: 'notif-008',
      title: 'النقل الجامعي',
      message: 'يمكنك مراجعة أقرب رحلة ومواعيد النقل الجامعي.',
      time: 'اليوم',
      type: 'transport',
      isRead: false,
    ),
  ];

  static List<DoctorNotificationItem> get notifications => _notifications;

  static int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  static void markNotificationAsRead(String id) {
    for (final n in _notifications) {
      if (n.id == id) {
        n.isRead = true;
        break;
      }
    }
  }

  static void markAllNotificationsAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
  }

  // ── 11. Exam Schedules ────────────────────────────────────────────────────
  static const List<ExamScheduleItem> midtermSchedule = [
    ExamScheduleItem(
      id: 'exam-mid-001',
      courseName: 'معالج دقيق',
      section: 1,
      examType: 'امتحان نصفي',
      date: '2026-08-08',
      timeRange: '10:00 - 11:00',
      room: '4212',
    ),
    ExamScheduleItem(
      id: 'exam-mid-002',
      courseName: 'الاحتمالات والإشارات العشوائية',
      section: 2,
      examType: 'امتحان نصفي',
      date: '2026-08-10',
      timeRange: '11:00 - 12:00',
      room: '4212',
    ),
  ];

  static const List<ExamScheduleItem> finalSchedule = [
    ExamScheduleItem(
      id: 'exam-fin-001',
      courseName: 'معالج دقيق',
      section: 1,
      examType: 'امتحان نهائي',
      date: '2026-09-05',
      timeRange: '11:00 - 12:30',
      room: '4212',
    ),
    ExamScheduleItem(
      id: 'exam-fin-002',
      courseName: 'الاحتمالات والإشارات العشوائية',
      section: 2,
      examType: 'امتحان نهائي',
      date: '2026-09-07',
      timeRange: '13:00 - 14:30',
      room: '4212',
    ),
  ];

  // ── 12. Administrative Center Requests ────────────────────────────────────
  static final List<AdministrativeRequest> administrativeRequests = [
    const AdministrativeRequest(
      id: 'adm-001',
      type: 'قوائم الحرمان',
      courseName: 'معالج دقيق — الشعبة 1',
      studentName: 'طالب تجريبي A، طالب تجريبي B (2 طلاب)',
      details: 'تجاوز نسبة الغياب المسموح بها قانونياً (15%) دون عذر مقبول.',
      status: 'مسودة',
      date: '2026-09-01',
    ),
    const AdministrativeRequest(
      id: 'adm-002',
      type: 'الاعتراضات',
      courseName: 'الاحتمالات والإشارات العشوائية',
      studentName: 'طالب تجريبي',
      details: 'طلب إعادة تدقيق جمع درجات الامتحان النصفي (العلامة السابقة: 72).',
      status: 'قيد المراجعة',
      date: '2026-08-28',
    ),
    const AdministrativeRequest(
      id: 'adm-003',
      type: 'غير المكتمل',
      courseName: 'معالج دقيق',
      studentName: 'طالب تجريبي C',
      details: 'تأجيل الامتحان النهائي بعذر طبي معتمد من الإدارة الطبية بالجامعة.',
      status: 'معتمد',
      date: '2026-09-04',
    ),
    const AdministrativeRequest(
      id: 'adm-004',
      type: 'محاضر النتائج',
      courseName: 'معالج دقيق — الشعبة 1',
      studentName: 'كامل طلاب الشعبة (40 طالباً)',
      details: 'محضر إقرار نتائج الأعمال والامتحان النصفي لتقديمه لعمادة الكلية.',
      status: 'جاهز للأرشفة',
      date: '2026-08-26',
    ),
  ];
}

class _ConstDateTime implements DateTime {
  final int _year;
  final int _month;
  final int _day;

  const _ConstDateTime(this._year, this._month, this._day);

  @override
  int get year => _year;
  @override
  int get month => _month;
  @override
  int get day => _day;
  @override
  int get hour => 0;
  @override
  int get minute => 0;
  @override
  int get second => 0;
  @override
  int get millisecond => 0;
  @override
  int get microsecond => 0;
  @override
  bool get isUtc => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
