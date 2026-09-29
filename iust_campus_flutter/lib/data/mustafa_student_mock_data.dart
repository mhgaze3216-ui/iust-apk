import '../models/student_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mustafa Student Mock Data
// Account: mustafa / 12345
// studentId: student-informatics-002
// Faculty: الهندسة المعلوماتية
// ─────────────────────────────────────────────────────────────────────────────

final kMustafaProfile = const StudentProfile(
  userId:           'user-student-informatics-002',
  studentId:        'student-informatics-002',
  universityId:     '202010290',
  username:         'mustafa',
  fullName:         'مصطفى زكريا سعيد',
  firstName:        'مصطفى',
  middleName:       'زكريا',
  lastName:         'سعيد',
  role:             'student',
  universityEmail:  null,
  profileImageUrl:  null,

  facultyId:        'faculty-engineering',
  facultyNameAr:    'الهندسة المعلوماتية',
  facultyNameEn:    'Information Technology Engineering',
  majorId:          'major-informatics',
  majorNameAr:      'الهندسة المعلوماتية',
  majorNameEn:      'Information Technology Engineering',
  academicYear:     '2025/2026',
  academicYearNumber: 5,
  admissionYear:    2020,

  currentSemesterId:      '20253',
  currentSemesterNameAr:  'الفصل الصيفي 2025/2026',
  currentSemesterNameEn:  'Summer Semester 2025/2026',
  academicStatus:         'regular',
  academicStatusAr:       'منتظم',

  semesterGpa:                  2.65,
  cumulativeGpa:                2.65,
  completedCreditHours:         163,
  requiredCreditHours:          168,
  remainingCreditHours:         5,
  currentRegisteredCreditHours: 8,
  currentCoursesCount:          5,

  academicAdvisorId:     'advisor-informatics-002',
  academicAdvisorName:   'بسمة خليل',
  academicAdvisorRole:   'المرشد الأكاديمي',
  academicAdvisorOffice: null,
);

// ── Mustafa's Current Courses (Total: 8 credits) ─────────────────────────────
const kMustafaCourse301446 = Course(
  courseId:     'course-301446',
  courseCode:   '301446',
  courseNameAr: 'مختبر اتصالات (لغير طلبة الهندسة الكهربائية)',
  creditHours:  1,
  courseType:   'required',
  sessions:     [],
);

const kMustafaCourse304132 = Course(
  courseId:     'course-304132',
  courseCode:   '304132',
  courseNameAr: 'رسم هندسي',
  creditHours:  2,
  courseType:   'required',
  sessions:     [],
);

const kMustafaCourse306132 = Course(
  courseId:     'course-306132',
  courseCode:   '306132',
  courseNameAr: 'رسوميات الحاسوب',
  creditHours:  1,
  courseType:   'required',
  sessions:     [],
);

const kMustafaCourse601108 = Course(
  courseId:     'course-601108',
  courseCode:   '601108',
  courseNameAr: 'فيزياء عامة (2) عملي',
  creditHours:  1,
  courseType:   'required',
  sessions:     [],
);

const kMustafaCourse604102 = Course(
  courseId:     'course-604102',
  courseCode:   '604102',
  courseNameAr: 'مهارات اللغة الإنكليزية (2)',
  creditHours:  3,
  courseType:   'required',
  sessions:     [],
);

const kMustafaEnrolledCourses = [
  kMustafaCourse301446,
  kMustafaCourse304132,
  kMustafaCourse306132,
  kMustafaCourse601108,
  kMustafaCourse604102,
];

// ── Mustafa's Current Results (Confirmed portal results) ──────────────────────
final kMustafaGrades = <Grade>[
  const Grade(
    id:           'grade-mustafa-301446',
    studentId:    'student-informatics-002',
    courseId:     'course-301446',
    courseCode:   '301446',
    courseNameAr: 'مختبر اتصالات (لغير طلبة الهندسة الكهربائية)',
    activityType: 'practical',
    gradeValue:   2.75,
    letterGrade:  null,
    resultStatus: 'passed',
    semesterId:   '20253',
    creditHours:  1,
  ),
  const Grade(
    id:           'grade-mustafa-304132',
    studentId:    'student-informatics-002',
    courseId:     'course-304132',
    courseCode:   '304132',
    courseNameAr: 'رسم هندسي',
    activityType: 'practical',
    gradeValue:   4.00,
    letterGrade:  null,
    resultStatus: 'passed',
    semesterId:   '20253',
    creditHours:  2,
  ),
  const Grade(
    id:           'grade-mustafa-306132',
    studentId:    'student-informatics-002',
    courseId:     'course-306132',
    courseCode:   '306132',
    courseNameAr: 'رسوميات الحاسوب',
    activityType: 'practical',
    gradeValue:   3.50,
    letterGrade:  null,
    resultStatus: 'passed',
    semesterId:   '20253',
    creditHours:  1,
  ),
  const Grade(
    id:           'grade-mustafa-601108',
    studentId:    'student-informatics-002',
    courseId:     'course-601108',
    courseCode:   '601108',
    courseNameAr: 'فيزياء عامة (2) عملي',
    activityType: 'practical',
    gradeValue:   2.25,
    letterGrade:  null,
    resultStatus: 'passed',
    semesterId:   '20253',
    creditHours:  1,
  ),
  const Grade(
    id:           'grade-mustafa-604102',
    studentId:    'student-informatics-002',
    courseId:     'course-604102',
    courseCode:   '604102',
    courseNameAr: 'مهارات اللغة الانكليزية (2)',
    activityType: 'theory',
    gradeValue:   2.00,
    letterGrade:  null,
    resultStatus: 'passed',
    semesterId:   '20253',
    creditHours:  3,
  ),
];

// ── Mustafa's Confirmed Final Exams ──────────────────────────────────────────
const kMustafaFinalExams = <FinalExam>[
  FinalExam(
    courseCode:   '604102',
    courseName:   'مهارات اللغة الانكليزية 2',
    examType:     'نهائي',
    date:         '2026-09-06',
    day:          'الأحد',
    startTime:    '09:00',
    endTime:      '10:15',
    semesterCode: '20253',
    isConfirmed:  true,
  ),
];

// ── Mustafa's StudyPlan Summary ──────────────────────────────────────────────
final kMustafaStudyPlan = const StudyPlan(
  studyPlanId:                  'study-plan-informatics-2021-2024',
  majorId:                      'major-informatics',
  requiredCreditHours:          168,
  completedCreditHours:         163,
  currentRegisteredCreditHours: 8,
  remainingCreditHours:         5,
);
