// ─────────────────────────────────────────────────────────────────────────────
// Student domain models
// Designed for NestJS backend consumption.
// All IDs are internal database IDs (not university codes).
// universityId ≠ studentId. courseCode ≠ courseId.
// TODO: Replace fromJson factories with real API parsing when backend is ready.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── Faculty ───────────────────────────────────────────────────────────────────
class Faculty {
  final String facultyId;
  final String facultyNameAr;
  final String? facultyNameEn;

  const Faculty({
    required this.facultyId,
    required this.facultyNameAr,
    this.facultyNameEn,
  });
}

// ── Major ─────────────────────────────────────────────────────────────────────
class Major {
  final String majorId;
  final String facultyId;
  final String majorNameAr;
  final String? majorNameEn;

  const Major({
    required this.majorId,
    required this.facultyId,
    required this.majorNameAr,
    this.majorNameEn,
  });
}

// ── StudyPlan ─────────────────────────────────────────────────────────────────
class StudyPlan {
  final String studyPlanId;
  final String majorId;
  final int requiredCreditHours;
  final int completedCreditHours;
  final int currentRegisteredCreditHours;
  final int remainingCreditHours;
  final int? studyPlanYear;

  const StudyPlan({
    required this.studyPlanId,
    required this.majorId,
    required this.requiredCreditHours,
    required this.completedCreditHours,
    required this.currentRegisteredCreditHours,
    required this.remainingCreditHours,
    this.studyPlanYear,
  });
}

// ── Student ───────────────────────────────────────────────────────────────────
class StudentProfile {
  /// Internal DB ID (UUID in production).
  final String userId;
  final String studentId;

  /// University number (e.g. 202410520). NOT the DB primary key.
  final String universityId;

  final String username;
  final String fullName;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String role; // 'student'

  final String? universityEmail;
  final String? profileImageUrl;

  // ── Academic placement ───────────────────────────────────────────────────
  final String facultyId;
  final String facultyNameAr;
  final String? facultyNameEn;
  final String majorId;
  final String majorNameAr;
  final String? majorNameEn;
  final String academicYear; // e.g. "الثالثة"
  final int academicYearNumber; // e.g. 3
  final int admissionYear; // e.g. 2024
  final String currentSemesterId;
  final String currentSemesterNameAr;
  final String? currentSemesterNameEn;
  final String academicStatus; // internal code e.g. "regular"
  final String academicStatusAr; // e.g. "منتظم"

  // ── GPA / credit hours ───────────────────────────────────────────────────
  final double semesterGpa;
  final double cumulativeGpa;
  final int completedCreditHours;
  final int requiredCreditHours;
  final int remainingCreditHours;
  final int currentRegisteredCreditHours;
  final int currentCoursesCount;

  // ── Advisor (null until data is available) ───────────────────────────────
  final String? academicAdvisorId;
  final String? academicAdvisorName;
  final String? academicAdvisorRole;
  final String? academicAdvisorOffice;

  const StudentProfile({
    required this.userId,
    required this.studentId,
    required this.universityId,
    required this.username,
    required this.fullName,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.role,
    this.universityEmail,
    this.profileImageUrl,
    required this.facultyId,
    required this.facultyNameAr,
    this.facultyNameEn,
    required this.majorId,
    required this.majorNameAr,
    this.majorNameEn,
    required this.academicYear,
    required this.academicYearNumber,
    required this.admissionYear,
    required this.currentSemesterId,
    required this.currentSemesterNameAr,
    this.currentSemesterNameEn,
    required this.academicStatus,
    required this.academicStatusAr,
    required this.semesterGpa,
    required this.cumulativeGpa,
    required this.completedCreditHours,
    required this.requiredCreditHours,
    required this.remainingCreditHours,
    required this.currentRegisteredCreditHours,
    required this.currentCoursesCount,
    this.academicAdvisorId,
    this.academicAdvisorName,
    this.academicAdvisorRole,
    this.academicAdvisorOffice,
  });

  factory StudentProfile.empty([String studentId = '']) => StudentProfile(
    userId: 'user-$studentId',
    studentId: studentId,
    universityId: '-',
    username: '',
    fullName: 'طالب',
    firstName: 'طالب',
    lastName: '',
    role: 'student',
    facultyId: '',
    facultyNameAr: 'غير محدد',
    majorId: '',
    majorNameAr: 'غير محدد',
    academicYear: '-',
    academicYearNumber: 1,
    admissionYear: 0,
    currentSemesterId: '',
    currentSemesterNameAr: '',
    academicStatus: '',
    academicStatusAr: '',
    semesterGpa: 0.0,
    cumulativeGpa: 0.0,
    completedCreditHours: 0,
    requiredCreditHours: 0,
    remainingCreditHours: 0,
    currentRegisteredCreditHours: 0,
    currentCoursesCount: 0,
  );
}

// ── Doctor ────────────────────────────────────────────────────────────────────
class Doctor {
  final String doctorId;
  final String name;
  final String? departmentId;
  final String? office;
  final String? officeLocation;
  final String? email;
  final String? phone;
  final String? officeHours;

  const Doctor({
    required this.doctorId,
    required this.name,
    this.departmentId,
    this.office,
    this.officeLocation,
    this.email,
    this.phone,
    this.officeHours,
  });
}

// ── Room ──────────────────────────────────────────────────────────────────────
class Room {
  final String roomId;
  final String roomNumber;
  final String? buildingId;
  final String? buildingNameAr;
  final String locationType; // 'classroom' | 'lab' | 'office'
  final String? floorId;
  final String? mapNodeId;

  const Room({
    required this.roomId,
    required this.roomNumber,
    this.buildingId,
    this.buildingNameAr,
    required this.locationType,
    this.floorId,
    this.mapNodeId,
  });
}

// ── ScheduleSession ───────────────────────────────────────────────────────────
/// A single teaching activity (theory OR practical) for a section.
/// One course can have multiple ScheduleSessions (e.g. theory + practical).
class ScheduleSession {
  final String scheduleId;
  final String courseId;
  final String sectionId;
  final String doctorId;
  final String doctorName;
  final String activityType; // 'theory' | 'practical'
  final String activityTypeAr; // 'نظري' | 'عملي'
  final String dayOfWeek; // 'Sunday' | 'Monday' …
  final String dayOfWeekAr;
  final String startTime; // 'HH:MM'
  final String endTime; // 'HH:MM'
  final String roomId;
  final String roomDisplay; // roomNumber or lab name for quick display
  final String? buildingNameAr;
  final String? mapNodeId;
  final String? termId;
  final bool isAdminOverride;

  const ScheduleSession({
    required this.scheduleId,
    required this.courseId,
    required this.sectionId,
    required this.doctorId,
    required this.doctorName,
    required this.activityType,
    required this.activityTypeAr,
    required this.dayOfWeek,
    required this.dayOfWeekAr,
    required this.startTime,
    required this.endTime,
    required this.roomId,
    required this.roomDisplay,
    this.buildingNameAr,
    this.mapNodeId,
    this.termId,
    this.isAdminOverride = false,
  });

  /// Parses startTime string (HH:MM) into TimeOfDay.
  TimeOfDay get startTimeOfDay {
    final parts = startTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Parses endTime string (HH:MM) into TimeOfDay.
  TimeOfDay get endTimeOfDay {
    final parts = endTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

// ── Course ────────────────────────────────────────────────────────────────────
/// A university course. courseCode is the business code, courseId is DB id.
class Course {
  final String courseId;
  final String courseCode;
  final String courseNameAr;
  final String? courseNameEn;
  final int creditHours;
  final String courseType; // 'required' | 'elective'
  final List<ScheduleSession> sessions;

  const Course({
    required this.courseId,
    required this.courseCode,
    required this.courseNameAr,
    this.courseNameEn,
    required this.creditHours,
    required this.courseType,
    this.sessions = const [],
  });
}

// ── Enrollment ────────────────────────────────────────────────────────────────
class Enrollment {
  final String enrollmentId;
  final String studentId;
  final String courseId;
  final String sectionId;
  final int sectionNumber;
  final String semesterId;
  final String enrollmentStatus; // 'registered' | 'completed' | 'withdrawn'

  const Enrollment({
    required this.enrollmentId,
    required this.studentId,
    required this.courseId,
    required this.sectionId,
    required this.sectionNumber,
    required this.semesterId,
    required this.enrollmentStatus,
  });
}

// ── Grade ─────────────────────────────────────────────────────────────────────
class Grade {
  final String id;
  final String studentId;
  final String? courseId;
  final String courseCode;
  final String courseNameAr;
  final String? sectionId;
  final String? semesterId;
  final String activityType; // 'theory' | 'practical'
  final double gradeValue;
  final String? letterGrade;
  final String resultStatus; // 'passed' | 'failed'
  final int? creditHours;

  // Current-semester breakdown — null until confirmed
  final double? courseworkGrade;
  final double? midtermGrade;
  final double? practicalGrade;
  final double? finalGrade;
  final double? currentTotal;

  const Grade({
    required this.id,
    required this.studentId,
    this.courseId,
    required this.courseCode,
    required this.courseNameAr,
    this.sectionId,
    this.semesterId,
    required this.activityType,
    required this.gradeValue,
    this.letterGrade,
    required this.resultStatus,
    this.creditHours,
    this.courseworkGrade,
    this.midtermGrade,
    this.practicalGrade,
    this.finalGrade,
    this.currentTotal,
  });

  bool get isPassed => resultStatus == 'passed';
}

// ── StudyPlanCourse ───────────────────────────────────────────────────────────
/// One row in an official study plan.
/// courseCode is the university's business code (nullable for courses whose
/// official code was not supplied). courseId is the internal DB id.
class StudyPlanCourse {
  final String id; // e.g. spc-dentistry-y1s1-1
  final String studyPlanId;
  final String majorId;
  final int yearNumber; // 1–5
  final int semesterNumber; // 1 or 2

  /// Internal DB id — null when the course record does not yet exist.
  final String? courseId;

  /// University business code — null when not provided in the official plan.
  final String? courseCode;

  /// For courses with combined theory+practical the plan may list two codes.
  /// Store the secondary one here.
  final String? secondaryCourseCode;

  final String courseNameAr;
  final int credits;

  /// Raw label from the plan, e.g. "1+2", "1+1", "3". For display only.
  final String? rawCreditsLabel;

  /// Prerequisite course IDs (internal DB ids, not codes).
  final List<String> prerequisiteCourseIds;

  /// Human-readable prerequisite description as printed in the plan.
  final String? prerequisiteText;

  /// Minimum completed credit hours required before enrollment (e.g. 30, 70).
  final int? minimumCompletedCredits;

  /// Category section (e.g. 'متطلبات جامعية إجبارية', 'متطلبات تخصص إجبارية').
  final String? category;

  /// Direct prerequisite course codes (e.g. ['401203', '604101']).
  final List<String> prerequisites;

  const StudyPlanCourse({
    required this.id,
    required this.studyPlanId,
    required this.majorId,
    this.yearNumber = 1,
    this.semesterNumber = 1,
    this.courseId,
    this.courseCode,
    this.secondaryCourseCode,
    required this.courseNameAr,
    required this.credits,
    this.rawCreditsLabel,
    this.prerequisiteCourseIds = const [],
    this.prerequisiteText,
    this.minimumCompletedCredits,
    this.category,
    this.prerequisites = const [],
  });
}

// ── FinalExam ─────────────────────────────────────────────────────────────────
/// Confirmed university final exam schedule entry.
class FinalExam {
  final String courseCode;
  final String courseName;
  final String examType; // e.g. 'نهائي'
  final String date; // 'YYYY-MM-DD'
  final String day; // e.g. 'الأحد'
  final String startTime; // '09:00'
  final String endTime; // '10:15'
  final String semesterCode; // '20253'
  final bool isConfirmed;

  const FinalExam({
    required this.courseCode,
    required this.courseName,
    this.examType = 'نهائي',
    required this.date,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.semesterCode,
    this.isConfirmed = true,
  });
}
