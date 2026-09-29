// ─────────────────────────────────────────────────────────────────────────────
// REAL STUDENT DATA — Hamza Talib Lababidi
// ─────────────────────────────────────────────────────────────────────────────
// Source: confirmed university portal data.
// DEMO/mock posts are clearly marked and can be deleted without data loss.
// All null fields are intentionally null — no data was available.
// TODO: Remove this file and replace every consumer with real NestJS API calls.
// ─────────────────────────────────────────────────────────────────────────────

import '../models/student_models.dart';
import '../models/feed_models.dart';

// ── Student profile ───────────────────────────────────────────────────────────
final kHamzaProfile = const StudentProfile(
  userId:           'user-student-dentistry-001',
  studentId:        'student-dentistry-001',
  universityId:     '202410520',
  username:         'hamza',
  fullName:         'حمزة طالب لبابيدي',
  firstName:        'حمزة',
  middleName:       'طالب',
  lastName:         'لبابيدي',
  role:             'student',
  universityEmail:  null,
  profileImageUrl:  null,

  facultyId:        'faculty-dentistry',
  facultyNameAr:    'طب الأسنان',
  facultyNameEn:    'Dentistry',
  majorId:          'major-dentistry',
  majorNameAr:      'طب الأسنان',
  majorNameEn:      'Dentistry',
  academicYear:     'الثالثة',
  academicYearNumber: 3,
  admissionYear:    2024,

  currentSemesterId:      'semester-2026-summer',
  currentSemesterNameAr:  'الفصل الصيفي',
  currentSemesterNameEn:  'Summer Semester',
  academicStatus:         'regular',
  academicStatusAr:       'منتظم',

  semesterGpa:                  3.57,
  cumulativeGpa:                3.45,
  completedCreditHours:         72,
  requiredCreditHours:          180,
  remainingCreditHours:         108,
  currentRegisteredCreditHours: 4,
  currentCoursesCount:          2,

  academicAdvisorId:     'doctor-dean-dentistry',
  academicAdvisorName:   'أ.د. محمد سالم ركاب',
  academicAdvisorOffice: 'عميد كلية طب الأسنان',
);

// ── Doctors ───────────────────────────────────────────────────────────────────
const kDoctorMiqdad = Doctor(
  doctorId: 'doctor-mohammad-miqdad',
  name:     'محمد مقداد',
);
const kDoctorManadili = Doctor(
  doctorId: 'doctor-manadili',
  name:     'مناديلي',
);
const kDoctorEibesh = Doctor(
  doctorId: 'doctor-fouad-eibesh',
  name:     'فؤاد إيبش',
);

// ── Rooms ─────────────────────────────────────────────────────────────────────
const kRoom6128 = Room(
  roomId:          'room-6128',
  roomNumber:      '6128',
  buildingId:      'building-dentistry',
  buildingNameAr:  'مبنى طب الأسنان',
  locationType:    'classroom',
);
const kRoom6120 = Room(
  roomId:          'room-6120',
  roomNumber:      '6120',
  buildingId:      'building-dentistry',
  buildingNameAr:  'مبنى طب الأسنان',
  locationType:    'classroom',
);
const kLab1 = Room(
  roomId:          'lab-1',
  roomNumber:      'مخبر 1',
  buildingId:      null,
  buildingNameAr:  null,
  locationType:    'lab',
);

// ── Schedule sessions ─────────────────────────────────────────────────────────

// Course 701241 — علم الجنين — Sunday theory
const kScheduleEmbryologyTheory = ScheduleSession(
  scheduleId:      'schedule-701241-sunday-theory',
  courseId:        'course-701241',
  sectionId:       'section-701241-1',
  doctorId:        'doctor-mohammad-miqdad',
  doctorName:      'محمد مقداد',
  activityType:    'theory',
  activityTypeAr:  'نظري',
  dayOfWeek:       'Sunday',
  dayOfWeekAr:     'الأحد',
  startTime:       '12:00',
  endTime:         '14:00',
  roomId:          'room-6128',
  roomDisplay:     '6128',
  buildingNameAr:  'مبنى طب الأسنان',
  mapNodeId:       null,
);

// Course 701351 — التشريح المرضي — Sunday theory
const kSchedulePathologyTheory = ScheduleSession(
  scheduleId:      'schedule-701351-sunday-theory',
  courseId:        'course-701351',
  sectionId:       'section-701351-1',
  doctorId:        'doctor-manadili',
  doctorName:      'مناديلي',
  activityType:    'theory',
  activityTypeAr:  'نظري',
  dayOfWeek:       'Sunday',
  dayOfWeekAr:     'الأحد',
  startTime:       '08:00',
  endTime:         '12:00',
  roomId:          'room-6120',
  roomDisplay:     '6120',
  buildingNameAr:  'مبنى طب الأسنان',
  mapNodeId:       null,
);

// Course 701351 — التشريح المرضي — Tuesday practical
const kSchedulePathologyPractical = ScheduleSession(
  scheduleId:      'schedule-701351-tuesday-practical',
  courseId:        'course-701351',
  sectionId:       'section-701351-1',
  doctorId:        'doctor-fouad-eibesh',
  doctorName:      'فؤاد إيبش',
  activityType:    'practical',
  activityTypeAr:  'عملي',
  dayOfWeek:       'Tuesday',
  dayOfWeekAr:     'الثلاثاء',
  startTime:       '08:00',
  endTime:         '12:00',
  roomId:          'lab-1',
  roomDisplay:     'مخبر 1',
  buildingNameAr:  null,
  mapNodeId:       null,
);

// ── Courses ───────────────────────────────────────────────────────────────────
final kCourseEmbryology = Course(
  courseId:      'course-701241',
  courseCode:    '701241',
  courseNameAr:  'علم الجنين الخاص بالفم والأسنان',
  courseNameEn:  null,
  creditHours:   1,
  courseType:    'required',
  sessions:      const [kScheduleEmbryologyTheory],
);

final kCoursePathology = Course(
  courseId:      'course-701351',
  courseCode:    '701351',
  courseNameAr:  'التشريح المرضي العام',
  courseNameEn:  null,
  creditHours:   3,
  courseType:    'required',
  sessions:      const [kSchedulePathologyTheory, kSchedulePathologyPractical],
);

/// All current enrolled courses for Hamza.
final kEnrolledCourses = [kCourseEmbryology, kCoursePathology];

/// All schedule sessions for Hamza — used for next-lecture calculation.
final kAllSessions = [
  kSchedulePathologyTheory,    // Sunday 08:00
  kScheduleEmbryologyTheory,   // Sunday 12:00
  kSchedulePathologyPractical, // Tuesday 08:00
];

// ── Enrollments ───────────────────────────────────────────────────────────────
const kEnrollmentEmbryology = Enrollment(
  enrollmentId:      'enrollment-202410520-701241',
  studentId:         'student-dentistry-001',
  courseId:          'course-701241',
  sectionId:         'section-701241-1',
  sectionNumber:     1,
  semesterId:        'semester-2026-summer',
  enrollmentStatus:  'registered',
);
const kEnrollmentPathology = Enrollment(
  enrollmentId:      'enrollment-202410520-701351',
  studentId:         'student-dentistry-001',
  courseId:          'course-701351',
  sectionId:         'section-701351-1',
  sectionNumber:     1,
  semesterId:        'semester-2026-summer',
  enrollmentStatus:  'registered',
);

// ── Historical grades (portal-confirmed) ──────────────────────────────────────
final kHistoricalGrades = <Grade>[
  const Grade(id: 'grade-202410520-101201',  studentId: 'student-dentistry-001', courseCode: '101201',  courseNameAr: 'مواد سنية (1)',                       activityType: 'theory',    gradeValue: 3.25, letterGrade: 'B+', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-101234',  studentId: 'student-dentistry-001', courseCode: '101234',  courseNameAr: 'مداواة الأسنان المحافظة (1)',           activityType: 'theory',    gradeValue: 3.50, letterGrade: 'A-', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-201102',  studentId: 'student-dentistry-001', courseCode: '201102',  courseNameAr: 'علم الحياة الجزيئية',                   activityType: 'theory',    gradeValue: 3.75, letterGrade: 'A',  resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-602108',  studentId: 'student-dentistry-001', courseCode: '602108',  courseNameAr: 'كيمياء حيوية (1)',                       activityType: 'theory',    gradeValue: 4.00, letterGrade: 'A+', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-602109',  studentId: 'student-dentistry-001', courseCode: '602109',  courseNameAr: 'كيمياء حيوية (1)',                       activityType: 'practical', gradeValue: 3.75, letterGrade: 'A',  resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-701113',  studentId: 'student-dentistry-001', courseCode: '701113',  courseNameAr: 'علم وظائف الأعضاء',                     activityType: 'theory',    gradeValue: 3.00, letterGrade: 'B',  resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-701119',  studentId: 'student-dentistry-001', courseCode: '701119',  courseNameAr: 'علم وظائف الأعضاء - القسم العملي',     activityType: 'practical', gradeValue: 4.00, letterGrade: 'A+', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-701251',  studentId: 'student-dentistry-001', courseCode: '701251',  courseNameAr: 'علم النسج (1)',                          activityType: 'theory',    gradeValue: 3.50, letterGrade: 'A-', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-701241',  studentId: 'student-dentistry-001', courseCode: '701241',  courseNameAr: 'علم الجنين الخاص بالفم والأسنان',       activityType: 'theory',    gradeValue: 3.25, letterGrade: 'B+', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-701351',  studentId: 'student-dentistry-001', courseCode: '701351',  courseNameAr: 'التشريح المرضي العام',                   activityType: 'theory',    gradeValue: 3.50, letterGrade: 'A-', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-101221',  studentId: 'student-dentistry-001', courseCode: '101221',  courseNameAr: 'طب الأسنان الوقائي',                     activityType: 'theory',    gradeValue: 3.50, letterGrade: 'A-', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-201123',  studentId: 'student-dentistry-001', courseCode: '201123',  courseNameAr: 'كيمياء عضوية نظري',                     activityType: 'theory',    gradeValue: 3.50, letterGrade: 'A-', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-201127',  studentId: 'student-dentistry-001', courseCode: '201127',  courseNameAr: 'كيمياء عضوية عملي',                     activityType: 'practical', gradeValue: 3.25, letterGrade: 'B+', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-401201',  studentId: 'student-dentistry-001', courseCode: '401201',  courseNameAr: 'مهارات الحاسوب (2)',                     activityType: 'theory',    gradeValue: 2.75, letterGrade: 'B-', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-701122',  studentId: 'student-dentistry-001', courseCode: '701122',  courseNameAr: 'تشريح ورسم الأسنان',                    activityType: 'theory',    gradeValue: 3.00, letterGrade: 'B',  resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-701221',  studentId: 'student-dentistry-001', courseCode: '701221',  courseNameAr: 'التشريح العام',                          activityType: 'theory',    gradeValue: 3.25, letterGrade: 'B+', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-101231',  studentId: 'student-dentistry-001', courseCode: '101231',  courseNameAr: 'علم الأشعة السنية',                     activityType: 'theory',    gradeValue: 3.50, letterGrade: 'A-', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-101334',  studentId: 'student-dentistry-001', courseCode: '101334',  courseNameAr: 'مداواة الأسنان المحافظة (2)',            activityType: 'theory',    gradeValue: 3.75, letterGrade: 'A',  resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-101381',  studentId: 'student-dentistry-001', courseCode: '101381',  courseNameAr: 'التخدير والقلع (1)',                     activityType: 'theory',    gradeValue: 3.50, letterGrade: 'A-', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-701212',  studentId: 'student-dentistry-001', courseCode: '701212',  courseNameAr: 'كيمياء حيوية (2)',                       activityType: 'theory',    gradeValue: 3.00, letterGrade: 'B',  resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-701272',  studentId: 'student-dentistry-001', courseCode: '701272',  courseNameAr: 'علم النسج الفموي (2)',                   activityType: 'theory',    gradeValue: 3.25, letterGrade: 'B+', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-701281',  studentId: 'student-dentistry-001', courseCode: '701281',  courseNameAr: 'علم الأحياء الدقيقة',                   activityType: 'theory',    gradeValue: 3.25, letterGrade: 'B+', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-401101',  studentId: 'student-dentistry-001', courseCode: '401101',  courseNameAr: 'مهارات الحاسوب (1)',                     activityType: 'theory',    gradeValue: 3.00, letterGrade: 'B',  resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-601110',  studentId: 'student-dentistry-001', courseCode: '601110',  courseNameAr: 'فيزياء عامة للعلوم الطبية (طب)',        activityType: 'theory',    gradeValue: 3.25, letterGrade: 'B+', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-602103',  studentId: 'student-dentistry-001', courseCode: '602103',  courseNameAr: 'كيمياء عامة للعلوم الطبية (طب)',        activityType: 'theory',    gradeValue: 3.50, letterGrade: 'A-', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-602105',  studentId: 'student-dentistry-001', courseCode: '602105',  courseNameAr: 'كيمياء عامة للعلوم الطبية (عملي)',      activityType: 'practical', gradeValue: 3.75, letterGrade: 'A',  resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-603101',  studentId: 'student-dentistry-001', courseCode: '603101',  courseNameAr: 'مهارات اللغة العربية (1)',               activityType: 'theory',    gradeValue: 2.75, letterGrade: 'B-', resultStatus: 'passed'),
  const Grade(id: 'grade-202410520-608103',  studentId: 'student-dentistry-001', courseCode: '608103',  courseNameAr: 'مبادئ علم النفس',                       activityType: 'theory',    gradeValue: 3.50, letterGrade: 'A-', resultStatus: 'passed'),
];

// ── Class Feed — DEMO posts only (not real student data) ──────────────────────
// These are UI-demonstration posts. Delete or replace when real backend exists.
final kDemoFeedPosts = <FeedPost>[
  FeedPost(
    id: 'demo-p1',
    studentId: 'demo-student-1',
    studentName: 'طالب تجريبي أ',
    courseId: 'course-701351',
    courseName: 'التشريح المرضي العام',
    title: 'سؤال عن المحاضرة',
    content: '[منشور تجريبي للعرض فقط] هل يشمل الامتحان مادة المحاضرة الأولى؟',
    postType: PostType.question,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    likesCount: 4, commentsCount: 2,
  ),
  FeedPost(
    id: 'demo-p2',
    studentId: 'demo-student-2',
    studentName: 'طالب تجريبي ب',
    courseId: 'course-701241',
    courseName: 'علم الجنين الخاص بالفم والأسنان',
    content: '[منشور تجريبي للعرض فقط] مذكرة المحاضرة الأولى متوفرة.',
    postType: PostType.resource,
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    likesCount: 7, commentsCount: 1,
  ),
];

/// Enrolled course IDs for use in feed filters.
const kEnrolledCourseIds = ['course-701241', 'course-701351'];

/// Course name lookup used by feed filters.
const kEnrolledCourseNames = {
  'course-701241': 'علم الجنين الخاص بالفم والأسنان',
  'course-701351': 'التشريح المرضي العام',
};

/// Course records as (id, name) tuples for feed/task dropdowns.
const kEnrolledCourseTuples = [
  ('course-701241', 'علم الجنين الخاص بالفم والأسنان'),
  ('course-701351', 'التشريح المرضي العام'),
];

// ── Hamza's StudyPlan summary (links to the official dentistry plan) ──────────
final kHamzaStudyPlan = StudyPlan(
  studyPlanId:                   'study-plan-dentistry',
  majorId:                       'major-dentistry',
  requiredCreditHours:           180,
  completedCreditHours:          kHamzaProfile.completedCreditHours,  // 72
  currentRegisteredCreditHours:  kHamzaProfile.currentRegisteredCreditHours, // 4
  remainingCreditHours:          kHamzaProfile.remainingCreditHours,  // 108
  studyPlanYear:                 null,
);
