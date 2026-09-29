// ─────────────────────────────────────────────────────────────────────────────
// Student Session Service
// Manages the currently logged-in student session.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import '../models/student_models.dart';
import '../data/student_repository.dart';

class StudentSession {
  static String? _activeStudentId;

  static final ValueNotifier<String?> activeStudentIdNotifier =
      ValueNotifier<String?>(null);

  /// Current logged-in studentId
  static String get currentStudentId => _activeStudentId ?? '';

  static bool get hasActiveSession =>
      _activeStudentId != null && _activeStudentId!.isNotEmpty;

  /// Set the active studentId upon login
  static void setActiveStudentId(String studentId) {
    _activeStudentId = studentId;
    activeStudentIdNotifier.value = studentId;
  }

  /// Current student profile (never falls back to Hamza if different/empty)
  static StudentProfile get currentProfile {
    final sid = _activeStudentId;
    if (sid == null || sid.isEmpty) return StudentProfile.empty();
    return StudentRepository.getStudent(sid) ?? StudentProfile.empty(sid);
  }

  /// Current student's enrolled courses
  static List<Course> get currentEnrolledCourses {
    final sid = _activeStudentId;
    if (sid == null || sid.isEmpty) return [];
    return StudentRepository.getEnrolledCourses(sid);
  }

  /// Current student's schedule sessions
  static List<ScheduleSession> get currentScheduleSessions {
    final sid = _activeStudentId;
    if (sid == null || sid.isEmpty) return [];
    return StudentRepository.getScheduleSessions(sid);
  }

  /// Current student's historical grades
  static List<Grade> get currentGrades {
    final sid = _activeStudentId;
    if (sid == null || sid.isEmpty) return [];
    return StudentRepository.getGrades(sid);
  }

  /// Check if the active student has passed a course
  static bool hasPassedCourse(StudyPlanCourse course) {
    final sid = _activeStudentId;
    if (sid == null || sid.isEmpty) return false;
    return StudentRepository.hasPassedCourse(sid, course);
  }

  /// Clear session upon logout or before a new login
  static void clearSession() {
    _activeStudentId = null;
    activeStudentIdNotifier.value = null;
  }
}

