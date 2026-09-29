import '../models/library_model.dart';
import '../models/student_models.dart';
import '../services/api_client.dart';

class StudentRepository {
  static final Map<String, StudentProfile> _students = {};
  static final Map<String, List<Course>> _enrolledCourses = {};
  static final Map<String, List<ScheduleSession>> _schedules = {};
  static final Map<String, List<Enrollment>> _enrollments = {};
  static final Map<String, List<Grade>> _grades = {};
  static final Map<String, Set<String>> _completedCourseCodes = {};
  static final Map<String, StudyPlan> _studyPlans = {};
  static final Map<String, List<StudyPlanCourse>> _studyPlanCourses = {};
  static final Map<
    String,
    List<
      ({
        String doctorId,
        String doctorName,
        String? courseId,
        String? courseName,
      })
    >
  >
  _doctors = {};
  static final Map<String, List<LibraryReference>> _library = {};
  static final Map<String, List<FinalExam>> _finalExams = {};
  static List<StudentProfile> _adminStudents = const [];

  static Map<String, dynamic> _map(Object? value, String field) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('The API returned an invalid $field object.');
  }

  static List<Map<String, dynamic>> _list(Object? value, String field) {
    final data = value is Map<String, dynamic> ? value['data'] : value;
    if (data is! List) {
      throw FormatException('The API returned an invalid $field list.');
    }
    return data.map((item) => _map(item, field)).toList(growable: false);
  }

  static Object? _payload(Map<String, dynamic> response) =>
      response['data'] ?? response;

  static String _text(Object? value, [String fallback = '']) =>
      value?.toString() ?? fallback;

  static String _requiredText(Object? value, String field) {
    final text = value?.toString();
    if (text == null || text.trim().isEmpty) {
      throw FormatException('The API omitted the required $field field.');
    }
    return text;
  }

  static int _integer(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static double _decimal(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static String _weekday(DateTime date) => const [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ][date.weekday - 1];

  static const _weekdayNames = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  static int _weekdayIndex(String value) {
    final numeric = int.tryParse(value);
    if (numeric != null && numeric >= 0 && numeric <= 6) return numeric;
    final index = _weekdayNames.indexOf(value);
    if (index >= 0) return index;
    throw FormatException('The schedule day "$value" is invalid.');
  }

  static String _weekdayName(Object? value) {
    final numeric = value is num ? value.toInt() : int.tryParse('$value');
    if (numeric != null && numeric >= 0 && numeric <= 6) {
      return _weekdayNames[numeric];
    }
    final text = _text(value);
    return text;
  }

  static Future<void> initializeFromApi(String studentId) async {
    final results = await Future.wait([
      ApiClient.instance.get('/students/me'),
      ApiClient.instance.get('/students/me/courses'),
      ApiClient.instance.get('/students/me/grades'),
      ApiClient.instance.get('/students/me/schedule'),
      ApiClient.instance.get('/students/me/study-plan'),
      ApiClient.instance.get('/students/me/exams'),
      ApiClient.instance.get('/students/me/doctors'),
      ApiClient.instance.get('/students/me/library'),
    ]);

    final profile = _map(_payload(results[0]), 'student profile');
    final profileName = _requiredText(profile['fullName'], 'student name');
    final splitName = profileName.trim().split(RegExp(r'\s+'));
    final studyPlan = _map(_payload(results[4]), 'study plan');
    final courseRows = _list(results[1], 'course');
    final scheduleRows = _list(results[3], 'schedule');
    final scheduleSessions = <ScheduleSession>[];

    final courses = <Course>[];
    final enrollments = <Enrollment>[];
    for (final item in courseRows) {
      final courseId = _text(item['id']);
      final sectionId = _text(item['sectionId']);
      final course = Course(
        courseId: courseId,
        courseCode: _text(item['code']),
        courseNameAr: _text(item['nameAr']),
        courseNameEn: item['nameEn']?.toString(),
        creditHours: _integer(item['creditHours']),
        courseType: 'required',
        sessions: const [],
      );
      courses.add(course);
      enrollments.add(
        Enrollment(
          enrollmentId: _text(item['enrollmentId'], sectionId),
          studentId: studentId,
          courseId: courseId,
          sectionId: sectionId,
          sectionNumber: _integer(item['sectionNumber']),
          semesterId: _text(item['termId']),
          enrollmentStatus: 'registered',
        ),
      );
    }

    for (final item in scheduleRows) {
      final schedule = item['schedule'];
      if (schedule is! List) continue;
      for (final entryValue in schedule) {
        if (entryValue is! Map<String, dynamic>) continue;
        final entry = entryValue;
        final day = _weekdayName(entry['dayOfWeek'] ?? entry['day']);
        final start = _text(entry['startTime'] ?? entry['start']);
        final end = _text(entry['endTime'] ?? entry['end']);
        if (day.isEmpty || start.isEmpty || end.isEmpty) continue;
        scheduleSessions.add(
          ScheduleSession(
            scheduleId: _text(entry['id'], '${item['sectionId']}-$day-$start'),
            courseId: _text(item['courseId']),
            sectionId: _text(item['sectionId']),
            doctorId: _text(item['instructorId']),
            doctorName: _text(item['instructorName']),
            activityType: _text(entry['activityType'], 'theory'),
            activityTypeAr: _text(entry['activityTypeAr'], 'نظري'),
            dayOfWeek: day,
            dayOfWeekAr: _text(entry['dayOfWeekAr'], day),
            startTime: start,
            endTime: end,
            roomId: _text(entry['roomId']),
            roomDisplay: _text(entry['room'], item['room']?.toString() ?? ''),
            buildingNameAr: entry['buildingNameAr']?.toString(),
            mapNodeId: entry['mapNodeId']?.toString(),
            termId: item['termId']?.toString(),
          ),
        );
      }
    }

    final grades = _list(results[2], 'grade')
        .map((item) {
          final components = item['components'] is Map<String, dynamic>
              ? item['components'] as Map<String, dynamic>
              : const <String, dynamic>{};
          final total = _decimal(item['total']);
          return Grade(
            id: _text(item['gradeId'], _text(item['courseId'])),
            studentId: studentId,
            courseId: item['courseId']?.toString(),
            courseCode: _text(item['code']),
            courseNameAr: _text(item['courseName']),
            sectionId: item['sectionId']?.toString(),
            semesterId: item['semesterId']?.toString(),
            activityType: 'theory',
            gradeValue: total,
            letterGrade: item['letterGrade']?.toString(),
            resultStatus: total >= 60 ? 'passed' : 'failed',
            courseworkGrade: components['coursework'] == null
                ? null
                : _decimal(components['coursework']),
            midtermGrade: components['midterm'] == null
                ? null
                : _decimal(components['midterm']),
            practicalGrade: components['practical'] == null
                ? null
                : _decimal(components['practical']),
            finalGrade: components['final'] == null
                ? null
                : _decimal(components['final']),
            currentTotal: item['total'] == null ? null : total,
          );
        })
        .toList(growable: false);

    final planCourses = (studyPlan['courses'] as List? ?? const [])
        .map((value) => _map(value, 'study-plan course'))
        .map(
          (item) => StudyPlanCourse(
            id: _text(item['id']),
            studyPlanId: _text(studyPlan['id']),
            majorId: _text(profile['departmentId']),
            yearNumber: _integer(item['yearNumber']),
            semesterNumber: _integer(item['semesterNumber']),
            courseId: item['courseId']?.toString(),
            courseCode: item['courseCode']?.toString(),
            courseNameAr: _text(item['courseName']),
            credits: _integer(item['credits']),
            prerequisiteCourseIds:
                (item['prerequisiteCourseIds'] as List? ?? const [])
                    .map((id) => id.toString())
                    .toList(growable: false),
            category: item['isRequired'] == true ? 'إجباري' : 'اختياري',
          ),
        )
        .toList(growable: false);

    final requiredHours = _integer(studyPlan['requiredCreditHours']);
    final completedHours = _integer(studyPlan['completedCreditHours']);
    final registeredHours = _integer(studyPlan['currentRegisteredCreditHours']);
    final year = _integer(profile['academicYear']);
    final student = StudentProfile(
      userId: _text(profile['id'], studentId),
      studentId: studentId,
      universityId: _text(profile['universityNumber']),
      username: _text(profile['username']),
      fullName: profileName,
      firstName: splitName.first,
      middleName: splitName.length > 2 ? splitName[1] : null,
      lastName: splitName.length > 1 ? splitName.last : '',
      role: 'student',
      universityEmail: profile['email']?.toString(),
      facultyId: _text(profile['facultyId']),
      facultyNameAr: _text(profile['facultyName'], 'غير محدد'),
      majorId: _text(profile['departmentId']),
      majorNameAr: _text(profile['departmentName'], 'غير محدد'),
      academicYear: _text(profile['academicYear']),
      academicYearNumber: year,
      admissionYear: _integer(profile['admissionYear']),
      currentSemesterId: '',
      currentSemesterNameAr: '',
      academicStatus: _text(profile['academicStatus']),
      academicStatusAr: _text(profile['academicStatus']),
      semesterGpa: 0,
      cumulativeGpa: 0,
      completedCreditHours: completedHours,
      requiredCreditHours: requiredHours,
      remainingCreditHours: _integer(studyPlan['remainingCreditHours']),
      currentRegisteredCreditHours: registeredHours,
      currentCoursesCount: courses.length,
    );

    final exams = _list(results[5], 'exam')
        .map((item) {
          final start = DateTime.parse(_text(item['startsAt']));
          final end = DateTime.parse(_text(item['endsAt']));
          return FinalExam(
            courseCode: _text(item['courseCode']),
            courseName: _text(item['courseName']),
            examType: _text(item['examType']),
            date: start.toIso8601String().substring(0, 10),
            day: _weekday(start),
            startTime:
                '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
            endTime:
                '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
            semesterCode: _text(item['termId']),
            isConfirmed: true,
          );
        })
        .toList(growable: false);

    _students[studentId] = student;
    _enrolledCourses[studentId] = List.unmodifiable(courses);
    _schedules[studentId] = List.unmodifiable(scheduleSessions);
    _enrollments[studentId] = List.unmodifiable(enrollments);
    _grades[studentId] = List.unmodifiable(grades);
    _completedCourseCodes[studentId] = Set.unmodifiable(
      grades.where((grade) => grade.isPassed).map((grade) => grade.courseCode),
    );
    _studyPlans[studentId] = StudyPlan(
      studyPlanId: _text(studyPlan['id']),
      majorId: _text(profile['departmentId']),
      requiredCreditHours: requiredHours,
      completedCreditHours: completedHours,
      currentRegisteredCreditHours: registeredHours,
      remainingCreditHours: _integer(studyPlan['remainingCreditHours']),
      studyPlanYear: year,
    );
    _studyPlanCourses[studentId] = List.unmodifiable(planCourses);
    _doctors[studentId] = _list(results[6], 'doctor')
        .map(
          (item) => (
            doctorId: _text(item['doctorId']),
            doctorName: _text(item['fullName']),
            courseId: item['courseId']?.toString(),
            courseName: item['courseName']?.toString(),
          ),
        )
        .toList(growable: false);
    _library[studentId] = _list(results[7], 'library reference')
        .map(
          (item) => LibraryReference(
            referenceId: _text(item['id']),
            facultyId: _text(item['facultyId']),
            title: _text(item['title']),
            authors: item['authors'] is List
                ? (item['authors'] as List).join(', ')
                : _text(item['authors']),
            category: _text(item['category']),
          ),
        )
        .toList(growable: false);
    _finalExams[studentId] = List.unmodifiable(exams);
  }

  static Future<void> initializeAdminStudents() async {
    final response = await ApiClient.instance.get(
      '/admin/users',
      query: {'q': ''},
    );
    _adminStudents = _list(response, 'user')
        .where((item) => item['role'] == 'student')
        .map((item) {
          final name = _requiredText(item['fullName'], 'student name');
          final parts = name.trim().split(RegExp(r'\s+'));
          final id = _text(item['id']);
          return StudentProfile(
            userId: id,
            studentId: id,
            universityId: _text(item['username']),
            username: _text(item['username']),
            fullName: name,
            firstName: parts.first,
            lastName: parts.length > 1 ? parts.last : '',
            role: 'student',
            universityEmail: item['email']?.toString(),
            facultyId: '',
            facultyNameAr: '',
            majorId: '',
            majorNameAr: '',
            academicYear: '',
            academicYearNumber: 0,
            admissionYear: 0,
            currentSemesterId: '',
            currentSemesterNameAr: '',
            academicStatus: '',
            academicStatusAr: '',
            semesterGpa: 0,
            cumulativeGpa: 0,
            completedCreditHours: 0,
            requiredCreditHours: 0,
            remainingCreditHours: 0,
            currentRegisteredCreditHours: 0,
            currentCoursesCount: 0,
          );
        })
        .toList(growable: false);
    for (final student in _adminStudents) {
      _students[student.studentId] = student;
    }

    final schedules = await Future.wait(
      _adminStudents.map(
        (student) => ApiClient.instance.get(
          '/admin/students/${Uri.encodeComponent(student.studentId)}/schedule',
        ),
      ),
    );
    for (var index = 0; index < _adminStudents.length; index++) {
      final studentId = _adminStudents[index].studentId;
      _loadAdminSchedule(
        studentId,
        _list(schedules[index], 'student schedule'),
      );
    }
  }

  static void _loadAdminSchedule(
    String studentId,
    List<Map<String, dynamic>> rows,
  ) {
    final courses = <String, Course>{};
    final enrollments = <Enrollment>[];
    final sessions = <ScheduleSession>[];
    for (final row in rows) {
      final courseId = _requiredText(row['courseId'], 'schedule course ID');
      final termId = row['termId']?.toString();
      final code = _text(row['courseCode']);
      final name = _text(row['courseName']);
      courses[courseId] = Course(
        courseId: courseId,
        courseCode: code,
        courseNameAr: name,
        creditHours: 0,
        courseType: 'required',
      );
      final sectionId = row['sectionId']?.toString();
      if (sectionId != null && termId != null) {
        enrollments.add(
          Enrollment(
            enrollmentId: sectionId,
            studentId: studentId,
            courseId: courseId,
            sectionId: sectionId,
            sectionNumber: _integer(row['sectionNumber']),
            semesterId: termId,
            enrollmentStatus: 'registered',
          ),
        );
      }
      final schedule = row['schedule'];
      if (schedule is! List) continue;
      for (final value in schedule) {
        if (value is! Map<String, dynamic>) continue;
        final day = _weekdayName(value['dayOfWeek'] ?? value['day']);
        final start = _text(value['startTime'] ?? value['start']);
        final end = _text(value['endTime'] ?? value['end']);
        if (start.isEmpty || end.isEmpty || day.isEmpty) continue;
        sessions.add(
          ScheduleSession(
            scheduleId: _text(
              row['scheduleId'],
              '${row['sectionId'] ?? courseId}-$day-$start',
            ),
            courseId: courseId,
            sectionId: _text(row['sectionNumber']),
            doctorId: '',
            doctorName: _text(row['instructorName']),
            activityType: 'theory',
            activityTypeAr: 'نظري',
            dayOfWeek: day,
            dayOfWeekAr: day,
            startTime: start,
            endTime: end,
            roomId: _text(row['room']),
            roomDisplay: _text(row['room']),
            termId: termId,
            isAdminOverride: row['entryType'] == 'manual',
          ),
        );
      }
    }
    _enrolledCourses[studentId] = List.unmodifiable(courses.values);
    _enrollments[studentId] = List.unmodifiable(enrollments);
    _schedules[studentId] = List.unmodifiable(sessions);
  }

  static StudentProfile? getStudent(String studentId) => _students[studentId];
  static bool hasStudent(String studentId) => _students.containsKey(studentId);
  static List<Course> getEnrolledCourses(String studentId) =>
      List.unmodifiable(_enrolledCourses[studentId] ?? const []);
  static List<ScheduleSession> getScheduleSessions(String studentId) =>
      List.unmodifiable(_schedules[studentId] ?? const []);
  static List<Enrollment> getEnrollments(String studentId) =>
      List.unmodifiable(_enrollments[studentId] ?? const []);
  static List<Grade> getGrades(String studentId) =>
      List.unmodifiable(_grades[studentId] ?? const []);
  static Set<String> getCompletedCourseCodes(String studentId) =>
      Set.unmodifiable(_completedCourseCodes[studentId] ?? const {});
  static bool hasPassedCourse(String studentId, StudyPlanCourse course) {
    final passedCodes = _completedCourseCodes[studentId] ?? const <String>{};
    return (course.courseCode != null &&
            passedCodes.contains(course.courseCode)) ||
        (course.secondaryCourseCode != null &&
            passedCodes.contains(course.secondaryCourseCode));
  }

  static StudyPlan? getStudyPlan(String studentId) => _studyPlans[studentId];
  static List<StudyPlanCourse> getStudyPlanCourses(String studentId) =>
      List.unmodifiable(_studyPlanCourses[studentId] ?? const []);
  static String getCourseName(String studentId, String courseId) =>
      _enrolledCourses[studentId]
          ?.where((course) => course.courseId == courseId)
          .map((course) => course.courseNameAr)
          .firstOrNull ??
      courseId;
  static List<({String id, String name})> getAvailableCourseTuples(
    String studentId,
  ) => (_enrolledCourses[studentId] ?? const [])
      .map((course) => (id: course.courseId, name: course.courseNameAr))
      .toList(growable: false);
  static List<
    ({String doctorId, String doctorName, String? courseId, String? courseName})
  >
  getDoctors(String studentId) =>
      List.unmodifiable(_doctors[studentId] ?? const []);
  static List<LibraryReference> getLibraryReferences(String studentId) =>
      List.unmodifiable(_library[studentId] ?? const []);
  static List<LibraryReference> getLibraryReferencesByFaculty(
    String facultyId,
  ) => _library.values
      .expand((items) => items)
      .where((item) => item.facultyId == facultyId)
      .toList(growable: false);
  static List<FinalExam> getFinalExams(String studentId) =>
      List.unmodifiable(_finalExams[studentId] ?? const []);
  static List<StudentProfile> get allStudents =>
      List.unmodifiable(_adminStudents);

  static Future<void> addScheduleSession(
    String studentId,
    ScheduleSession session,
  ) async {
    final termId = _termForScheduleSession(studentId, session);
    await ApiClient.instance.post(
      '/admin/students/${Uri.encodeComponent(studentId)}/schedule',
      body: {
        'courseId': session.courseId,
        'termId': termId,
        'dayOfWeek': _weekdayIndex(session.dayOfWeek),
        'startTime': session.startTime,
        'endTime': session.endTime,
        'room': session.roomDisplay,
      },
    );
    await _reloadAdminSchedule(studentId);
  }

  static Future<void> updateScheduleSession(
    String studentId,
    ScheduleSession session,
  ) async {
    final termId = _termForScheduleSession(studentId, session);
    await ApiClient.instance.patch(
      '/admin/students/${Uri.encodeComponent(studentId)}/schedule/'
      '${Uri.encodeComponent(session.scheduleId)}',
      body: {
        'courseId': session.courseId,
        'termId': termId,
        'dayOfWeek': _weekdayIndex(session.dayOfWeek),
        'startTime': session.startTime,
        'endTime': session.endTime,
        'room': session.roomDisplay,
      },
    );
    await _reloadAdminSchedule(studentId);
  }

  static Future<void> removeScheduleSession(
    String studentId,
    String scheduleId,
  ) async {
    await ApiClient.instance.delete(
      '/admin/students/${Uri.encodeComponent(studentId)}/schedule/'
      '${Uri.encodeComponent(scheduleId)}',
    );
    await _reloadAdminSchedule(studentId);
  }

  static String _termForScheduleSession(
    String studentId,
    ScheduleSession session,
  ) {
    final termId =
        session.termId ??
        _enrollments[studentId]
            ?.where((enrollment) => enrollment.courseId == session.courseId)
            .map((enrollment) => enrollment.semesterId)
            .firstOrNull;
    if (termId == null || termId.isEmpty) {
      throw StateError(
        'No active enrollment term is available for this course.',
      );
    }
    return termId;
  }

  static Future<void> _reloadAdminSchedule(String studentId) async {
    final response = await ApiClient.instance.get(
      '/admin/students/${Uri.encodeComponent(studentId)}/schedule',
    );
    _loadAdminSchedule(studentId, _list(response, 'student schedule'));
  }
}
