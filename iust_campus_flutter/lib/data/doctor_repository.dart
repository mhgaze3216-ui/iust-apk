import '../models/doctor_models.dart';
import '../services/api_client.dart';

class DoctorRepository {
  static DoctorProfile? _profile;
  static List<DoctorCourse> _courses = const [];
  static final Map<String, List<({String id, String name})>> _rosters = {};
  static final Map<String, List<DoctorStudentGrade>> _grades = {};
  static final Map<String, Map<String, AttendanceStatus>> _attendance = {};
  static final Map<String, String> _attendanceSessionIds = {};

  static Map<String, dynamic> _map(Object? value, String field) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('The API returned an invalid $field object.');
  }

  static List<Map<String, dynamic>> _list(Object? response, String field) {
    final value = response is Map<String, dynamic>
        ? response['data'] ?? response
        : response;
    if (value is! List) {
      throw FormatException('The API returned an invalid $field list.');
    }
    return value.map((item) => _map(item, field)).toList(growable: false);
  }

  static String _text(Object? value, [String fallback = '']) =>
      value?.toString() ?? fallback;

  static int _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static Future<void> initializeFromApi() async {
    final profileResponse = await ApiClient.instance.get('/doctors/me');
    final profile = _map(
      profileResponse['data'] ?? profileResponse,
      'doctor profile',
    );
    final courseRows = _list(
      await ApiClient.instance.get('/doctors/me/courses'),
      'course',
    );
    final courses = <DoctorCourse>[];
    for (final item in courseRows) {
      final sectionId = _text(item['sectionId']);
      final schedule = item['schedule'];
      final scheduleEntries = schedule is List ? schedule : const [];
      final firstSchedule =
          scheduleEntries.isNotEmpty &&
              scheduleEntries.first is Map<String, dynamic>
          ? scheduleEntries.first as Map<String, dynamic>
          : const <String, dynamic>{};
      courses.add(
        DoctorCourse(
          courseId: sectionId,
          courseCode: _text(item['code']),
          courseName: _text(item['courseName']),
          section: _int(item['sectionNumber']),
          sectionCount: 1,
          studentCount: 0,
          room: item['room']?.toString(),
          day: _text(firstSchedule['dayOfWeekAr'] ?? firstSchedule['day']),
          startTime: _text(
            firstSchedule['startTime'] ?? firstSchedule['start'],
          ),
          endTime: _text(firstSchedule['endTime'] ?? firstSchedule['end']),
          semester: _text(item['termName']),
        ),
      );
    }

    final rosterResults = await Future.wait(
      courses.map(
        (course) => ApiClient.instance.get(
          '/doctors/me/sections/${course.courseId}/roster',
        ),
      ),
    );
    final gradeResults = await Future.wait(
      courses.map(
        (course) => ApiClient.instance.get(
          '/doctors/me/sections/${course.courseId}/grades',
        ),
      ),
    );
    final attendanceResults = await Future.wait(
      courses.map(
        (course) => ApiClient.instance.get(
          '/doctors/me/sections/${course.courseId}/attendance',
        ),
      ),
    );

    final rosters = <String, List<({String id, String name})>>{};
    final grades = <String, List<DoctorStudentGrade>>{};
    final attendance = <String, Map<String, AttendanceStatus>>{};
    final attendanceSessions = <String, String>{};
    for (var index = 0; index < courses.length; index++) {
      final sectionId = courses[index].courseId;
      rosters[sectionId] = _list(rosterResults[index], 'roster student')
          .map(
            (student) =>
                (id: _text(student['id']), name: _text(student['fullName'])),
          )
          .toList(growable: false);
      grades[sectionId] = _list(gradeResults[index], 'grade')
          .map((item) {
            final components = item['components'] is Map<String, dynamic>
                ? item['components'] as Map<String, dynamic>
                : const <String, dynamic>{};
            return DoctorStudentGrade(
              studentId: _text(item['studentId']),
              studentName: _text(item['studentName']),
              courseId: sectionId,
              midtermGrade: _int(components['midterm']),
              courseworkGrade: _int(components['coursework']),
              finalExamGrade: _int(components['final']),
              numericGrade: _int(item['total']),
              gradeStatus: _text(item['letterGrade'], 'غير منشور'),
            );
          })
          .toList(growable: false);
      final sessions = _list(attendanceResults[index], 'attendance session');
      if (sessions.isNotEmpty) {
        final latest = sessions.first;
        attendanceSessions[sectionId] = _text(latest['id']);
        final records = latest['records'];
        if (records is List) {
          attendance[sectionId] = {
            for (final value in records)
              if (value is Map<String, dynamic>)
                _text(value['studentId']): _attendanceStatus(
                  _text(value['status']),
                ),
          };
        }
      } else {
        attendance[sectionId] = {};
      }
    }

    _profile = DoctorProfile(
      doctorId: _text(profile['id']),
      fullName: _text(profile['fullName']),
      faculty: _text(profile['facultyName']),
      department: _text(profile['departmentName']),
      academicRank: _text(profile['academicRank']),
      office: profile['office']?.toString(),
      email: profile['email']?.toString(),
      officeHours: profile['officeHours']?.toString(),
      coursesCount: courses.length,
      sectionsCount: courses.length,
      studentsCount: rosters.values.fold<int>(
        0,
        (count, roster) => count + roster.length,
      ),
    );
    _courses = List.unmodifiable(courses);
    _rosters
      ..clear()
      ..addAll(rosters);
    _grades
      ..clear()
      ..addAll(grades);
    _attendance
      ..clear()
      ..addAll(attendance);
    _attendanceSessionIds
      ..clear()
      ..addAll(attendanceSessions);
  }

  static AttendanceStatus _attendanceStatus(String value) => switch (value) {
    'late' => AttendanceStatus.late,
    'absent' => AttendanceStatus.absent,
    _ => AttendanceStatus.present,
  };

  static DoctorProfile get profile => _profile ?? DoctorProfile.empty();

  static Future<void> updateProfile({
    String? fullName,
    String? email,
    String? office,
  }) async {
    if (fullName != null || email != null) {
      throw UnsupportedError(
        'The API does not support changing doctor name or email.',
      );
    }
    if (office == null) return;
    final response = await ApiClient.instance.patch(
      '/doctors/me',
      body: {'office': office},
    );
    final data = _map(response['data'] ?? response, 'doctor profile');
    final current = profile;
    _profile = current.copyWith(office: data['office']?.toString() ?? office);
  }

  static List<DoctorCourse> get courses => List.unmodifiable(_courses);

  static DoctorCourse? getCourseById(String courseId) {
    for (final course in _courses) {
      if (course.courseId == courseId) return course;
    }
    return null;
  }

  static List<({String id, String name})> get roster =>
      List.unmodifiable(_rosters.values.expand((items) => items).toSet());

  static List<({String id, String name})> getRosterForCourse(
    String sectionId,
  ) => List.unmodifiable(_rosters[sectionId] ?? const []);

  static List<DoctorStudentGrade> getGradesForCourse(String courseId) =>
      List.unmodifiable(_grades[courseId] ?? const []);

  static Future<void> updateGrade(
    String sectionId,
    String studentId,
    int newGrade, {
    int? midterm,
    int? coursework,
    int? finalExam,
  }) async {
    final response = await ApiClient.instance.put(
      '/doctors/me/sections/$sectionId/grades/$studentId',
      body: {
        'components': {
          'midterm': midterm ?? newGrade,
          'coursework': coursework ?? 0,
          'final': finalExam ?? 0,
        },
      },
    );
    final data = _map(response['data'] ?? response, 'grade');
    final list = List<DoctorStudentGrade>.from(_grades[sectionId] ?? const []);
    final index = list.indexWhere((grade) => grade.studentId == studentId);
    if (index >= 0) {
      final previous = list[index];
      list[index] = DoctorStudentGrade(
        studentId: previous.studentId,
        studentName: previous.studentName,
        courseId: sectionId,
        midtermGrade: midterm ?? previous.midtermGrade,
        courseworkGrade: coursework ?? previous.courseworkGrade,
        finalExamGrade: finalExam ?? previous.finalExamGrade,
        numericGrade: _int(data['total'] ?? newGrade),
        gradeStatus: previous.gradeStatus,
      );
      _grades[sectionId] = List.unmodifiable(list);
    }
  }

  static Map<String, AttendanceStatus> getAttendanceForCourse(
    String courseId,
  ) => Map.unmodifiable(_attendance[courseId] ?? const {});

  static Future<void> setStudentAttendance(
    String courseId,
    String studentId,
    AttendanceStatus status,
  ) async {
    final updated = Map<String, AttendanceStatus>.from(
      _attendance[courseId] ?? const {},
    );
    updated[studentId] = status;
    _attendance[courseId] = updated;
  }

  static Future<void> clearAttendance(String courseId) async {
    await reloadAttendance(courseId);
  }

  static Future<void> reloadAttendance(String sectionId) async {
    final sessions = _list(
      await ApiClient.instance.get(
        '/doctors/me/sections/$sectionId/attendance',
      ),
      'attendance session',
    );
    if (sessions.isEmpty) {
      _attendance[sectionId] = {};
      _attendanceSessionIds.remove(sectionId);
      return;
    }
    final latest = sessions.first;
    final records = latest['records'];
    _attendance[sectionId] = {
      if (records is List)
        for (final value in records)
          if (value is Map<String, dynamic>)
            _text(value['studentId']): _attendanceStatus(
              _text(value['status']),
            ),
    };
    _attendanceSessionIds[sectionId] = _text(latest['id']);
  }

  static Future<void> saveAttendance(String sectionId) async {
    final records = _attendance[sectionId] ?? const {};
    if (records.isEmpty) {
      throw StateError('There are no attendance records to save.');
    }
    var sessionId = _attendanceSessionIds[sectionId];
    if (sessionId == null) {
      final result = await ApiClient.instance.post(
        '/doctors/me/sections/$sectionId/attendance',
        body: {'heldAt': DateTime.now().toUtc().toIso8601String()},
      );
      final data = _map(result['data'] ?? result, 'attendance session');
      sessionId = _text(data['id']);
      _attendanceSessionIds[sectionId] = sessionId;
    }
    await ApiClient.instance.put(
      '/doctors/me/attendance/$sessionId/records',
      body: {
        'records': records.entries
            .map(
              (entry) => {'studentId': entry.key, 'status': entry.value.name},
            )
            .toList(growable: false),
      },
    );
    await ApiClient.instance.post('/doctors/me/attendance/$sessionId/finalize');
  }
}
