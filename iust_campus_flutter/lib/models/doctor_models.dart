import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Doctor domain models
// Designed for NestJS backend consumption & local demo prototypes.
// ─────────────────────────────────────────────────────────────────────────────

enum AttendanceStatus { present, late, absent }

enum AnnouncementType { announcement, answer, resource }

enum AcademicSubmissionStatus { draft, submitted, approved, needsRevision }

/// Profile of a university faculty doctor.
class DoctorProfile {
  final String doctorId;
  final String fullName;
  final String faculty;
  final String department;
  final String academicRank;
  final String? office;
  final String? email;
  final String? workingDays;
  final String? officeHours;
  final int coursesCount;
  final int sectionsCount;
  final int studentsCount;
  final int reviewSubmissionsCount;
  final int newQuestionsCount;
  final int draftTemplatesCount;

  const DoctorProfile({
    required this.doctorId,
    required this.fullName,
    required this.faculty,
    required this.department,
    required this.academicRank,
    this.office,
    this.email,
    this.workingDays,
    this.officeHours,
    this.coursesCount = 0,
    this.sectionsCount = 0,
    this.studentsCount = 0,
    this.reviewSubmissionsCount = 0,
    this.newQuestionsCount = 0,
    this.draftTemplatesCount = 0,
  });

  factory DoctorProfile.empty([String doctorId = 'doctor-001']) => DoctorProfile(
    doctorId: doctorId,
    fullName: 'غير مضاف بعد',
    faculty: 'غير مضافة بعد',
    department: 'غير مضاف بعد',
    academicRank: 'غير مضاف بعد',
    office: 'غير محدد',
    email: 'Doctor@iust.edu.sy',
    workingDays: 'السبت',
    officeHours: 'السبت 13:00 - 14:00',
    coursesCount: 0,
    sectionsCount: 0,
    studentsCount: 0,
  );

  DoctorProfile copyWith({
    String? fullName,
    String? faculty,
    String? department,
    String? academicRank,
    String? office,
    String? email,
    String? workingDays,
    String? officeHours,
    int? coursesCount,
    int? sectionsCount,
    int? studentsCount,
    int? reviewSubmissionsCount,
    int? newQuestionsCount,
    int? draftTemplatesCount,
  }) {
    return DoctorProfile(
      doctorId: doctorId,
      fullName: fullName ?? this.fullName,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      academicRank: academicRank ?? this.academicRank,
      office: office ?? this.office,
      email: email ?? this.email,
      workingDays: workingDays ?? this.workingDays,
      officeHours: officeHours ?? this.officeHours,
      coursesCount: coursesCount ?? this.coursesCount,
      sectionsCount: sectionsCount ?? this.sectionsCount,
      studentsCount: studentsCount ?? this.studentsCount,
      reviewSubmissionsCount:
          reviewSubmissionsCount ?? this.reviewSubmissionsCount,
      newQuestionsCount: newQuestionsCount ?? this.newQuestionsCount,
      draftTemplatesCount: draftTemplatesCount ?? this.draftTemplatesCount,
    );
  }

  String get id => doctorId;
  String get name => fullName;
  String get academicTitle => academicRank;
  String get officeLocation => office ?? '';
}

/// Course taught by a doctor.
class DoctorCourse {
  final String courseId;
  final String courseCode;
  final String courseName;
  final int section;
  final int sectionCount;
  final int studentCount;
  final String? room;
  final String day;
  final String startTime;
  final String endTime;
  final String activityType;
  final String? teachingNote;
  final double progress;
  final String semester;
  final double midtermWeight;
  final double finalWeight;
  final double courseworkWeight;

  const DoctorCourse({
    required this.courseId,
    this.courseCode = '',
    required this.courseName,
    this.section = 1,
    this.sectionCount = 1,
    this.studentCount = 40,
    this.room,
    this.day = 'السبت',
    this.startTime = '08:00',
    this.endTime = '11:00',
    this.activityType = 'نظري',
    this.teachingNote,
    this.progress = 0.0,
    this.semester = 'الفصل الأول 2025/2026',
    this.midtermWeight = 0.30,
    this.finalWeight = 0.50,
    this.courseworkWeight = 0.20,
  });
}

/// Student numeric grade breakdown in a doctor course.
class DoctorStudentGrade {
  final String studentId;
  final String studentName;
  final String courseId;
  int midtermGrade;
  int courseworkGrade;
  int finalExamGrade;
  int numericGrade;
  final String gradeStatus;

  DoctorStudentGrade({
    required this.studentId,
    required this.studentName,
    required this.courseId,
    int? midtermGrade,
    int? courseworkGrade,
    int? finalExamGrade,
    required this.numericGrade,
    this.gradeStatus = 'ناجح',
  })  : midtermGrade = midtermGrade ?? ((numericGrade * 0.30).round()),
        courseworkGrade = courseworkGrade ?? ((numericGrade * 0.20).round()),
        finalExamGrade = finalExamGrade ?? ((numericGrade * 0.50).round());
}

/// Specific section taught by a doctor.
class DoctorSection {
  final String sectionId;
  final String courseId;
  final int sectionNumber;
  final int studentCount;
  final String? room;
  final String? dayOfWeek;
  final String? startTime;
  final String? endTime;

  const DoctorSection({
    required this.sectionId,
    required this.courseId,
    required this.sectionNumber,
    this.studentCount = 0,
    this.room,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
  });
}

/// Attendance session for a specific course and section.
class AttendanceSession {
  final String sessionId;
  final String courseId;
  final String sectionId;
  final DateTime date;
  final String? room;
  final int presentCount;
  final int lateCount;
  final int absentCount;

  const AttendanceSession({
    required this.sessionId,
    required this.courseId,
    required this.sectionId,
    required this.date,
    this.room,
    this.presentCount = 0,
    this.lateCount = 0,
    this.absentCount = 0,
  });
}

/// A student's attendance record within a session.
class AttendanceRecord {
  final String recordId;
  final String sessionId;
  final String studentId;
  final String studentName;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.recordId,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.status,
  });
}

/// Digital submission of grades/results to administration.
class AcademicSubmission {
  final String id;
  final String referenceNumber;
  final String courseId;
  final String courseName;
  final int section;
  final String type;
  final int studentsCount;
  AcademicSubmissionStatus status;
  final String submittedAt;
  final String notes;
  final String? attachedFileName;

  AcademicSubmission({
    required this.id,
    required this.referenceNumber,
    required this.courseId,
    required this.courseName,
    required this.section,
    required this.type,
    required this.studentsCount,
    required this.status,
    required this.submittedAt,
    this.notes = '',
    this.attachedFileName,
  });
}

/// Doctor assignment / task.
class DoctorAssignment {
  final String id;
  final String courseId;
  final String courseName;
  final String title;
  final String deadline;
  final int submittedCount;
  final int totalCount;
  final String status;

  const DoctorAssignment({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.deadline,
    required this.submittedCount,
    required this.totalCount,
    this.status = 'نشط',
  });
}

/// Student question directed to the doctor.
class DoctorStudentQuestion {
  final String id;
  final String studentName;
  final String courseId;
  final String courseName;
  final String question;
  String? answer;
  String status;
  final String createdAt;

  DoctorStudentQuestion({
    required this.id,
    required this.studentName,
    required this.courseId,
    required this.courseName,
    required this.question,
    this.answer,
    required this.status,
    required this.createdAt,
  });
}

/// Doctor notification item.
class DoctorNotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type;
  bool isRead;

  DoctorNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.type = 'general',
    this.isRead = false,
  });
}

/// Administrative affairs item (deprivation, objection, incomplete, minutes).
class AdministrativeRequest {
  final String id;
  final String type;
  final String courseName;
  final String studentName;
  final String details;
  final String status;
  final String date;

  const AdministrativeRequest({
    required this.id,
    required this.type,
    required this.courseName,
    required this.studentName,
    required this.details,
    required this.status,
    required this.date,
  });
}

/// Exam schedule item.
class ExamScheduleItem {
  final String id;
  final String courseName;
  final int section;
  final String examType;
  final String date;
  final String timeRange;
  final String room;

  const ExamScheduleItem({
    required this.id,
    required this.courseName,
    required this.section,
    required this.examType,
    required this.date,
    required this.timeRange,
    required this.room,
  });
}

/// An announcement or post created by a doctor.
class DoctorAnnouncement {
  final String id;
  final String doctorId;
  final String? courseId;
  final String title;
  final String content;
  final AnnouncementType type;
  final DateTime createdAt;
  final bool isPinned;
  final String status;

  const DoctorAnnouncement({
    required this.id,
    required this.doctorId,
    this.courseId,
    required this.title,
    required this.content,
    this.type = AnnouncementType.announcement,
    required this.createdAt,
    this.isPinned = false,
    this.status = 'منشور',
  });
}

/// Lightweight metadata model for Doctor Archive and Documents.
/// Contains ONLY lightweight strings and metadata — NO binary PDF/image/base64 bytes.
class DoctorArchiveItem {
  final String id;
  final String title;
  final String courseName;
  final String documentType;
  final String semester;
  final String date;
  final String status;
  final Color statusColor;
  final String? filePath;
  final String? fileSize;
  final String? notes;

  const DoctorArchiveItem({
    required this.id,
    required this.title,
    required this.courseName,
    required this.documentType,
    required this.semester,
    required this.date,
    required this.status,
    required this.statusColor,
    this.filePath,
    this.fileSize,
    this.notes,
  });
}
