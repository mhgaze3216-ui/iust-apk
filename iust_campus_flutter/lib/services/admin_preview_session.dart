import 'package:flutter/material.dart';
import 'student_session.dart';
import 'doctor_session.dart';
import 'admin_session.dart';
import 'administrative_staff_session.dart';
import '../data/university_admin_repository.dart';
import '../screens/student/student_shell.dart';
import '../screens/doctor/doctor_shell.dart';
import '../screens/university_services/university_services_shell.dart';
import '../screens/university_admin/widgets/admin_preview_wrapper.dart';

/// Manages isolated preview / impersonation state for the Administration Master Control Center.
///
/// Ensures the authenticated Master Admin credentials and session are never replaced or lost
/// when previewing Student, Doctor, or Administrative Staff interfaces.
class AdminPreviewSession {
  static bool _isAdminPreview = false;
  static String _originalAdminId = 'ADM-018';
  static String _previewRole = 'admin'; // 'student', 'doctor', 'administrativeStaff'
  static String _previewUserId = '';
  static String _previewUserName = '';
  static String _previewUserNumber = '';
  static String _previewFaculty = '';

  // ── Getters ────────────────────────────────────────────────────────────────
  static bool get isAdminPreview => _isAdminPreview;
  static String get originalAdminId => _originalAdminId;
  static String get previewRole => _previewRole;
  static String get previewUserId => _previewUserId;
  static String get previewUserName => _previewUserName;
  static String get previewUserNumber => _previewUserNumber;
  static String get previewFaculty => _previewFaculty;

  /// Starts an isolated preview session for a target user account.
  static void startPreview({
    required String role,
    required String userId,
    required String userName,
    required String userNumber,
    String faculty = '',
    String? adminId,
  }) {
    _isAdminPreview = true;
    _previewRole = role;
    _previewUserId = userId;
    _previewUserName = userName;
    _previewUserNumber = userNumber;
    _previewFaculty = faculty;
    if (adminId != null && adminId.isNotEmpty) {
      _originalAdminId = adminId;
    }
  }

  /// Safely launches the real shell for [account] wrapped in [AdminPreviewWrapper].
  static void launchUserPreview(BuildContext context, AdminUserAccount account) {
    final role = account.role;
    final targetId = account.targetId.isNotEmpty ? account.targetId : account.userNumber;

    if (role == 'طالب') {
      startPreview(
        role: 'student',
        userId: targetId,
        userName: account.name,
        userNumber: account.userNumber,
        faculty: account.facultyOrDept,
      );
      // Activate student session specifically for this target student
      StudentSession.setActiveStudentId(targetId);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AdminPreviewWrapper(
            roleLabel: 'طالب',
            userName: account.name,
            userId: account.userNumber,
            child: StudentShell(studentId: targetId),
          ),
        ),
      );
    } else if (role == 'دكتور') {
      startPreview(
        role: 'doctor',
        userId: targetId,
        userName: account.name,
        userNumber: account.userNumber,
        faculty: account.facultyOrDept,
      );
      // Activate doctor session specifically for this target doctor
      DoctorSession.setActiveDoctorId(targetId);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AdminPreviewWrapper(
            roleLabel: 'دكتور',
            userName: account.name,
            userId: account.userNumber,
            child: DoctorShell(doctorId: targetId),
          ),
        ),
      );
    } else if (role == 'إداري' || role == 'موظف') {
      // Administrative Staff preview (opens separate staff interface /administrative)
      startPreview(
        role: 'administrativeStaff',
        userId: targetId,
        userName: account.name,
        userNumber: account.userNumber,
        faculty: account.facultyOrDept,
      );
      // Activate staff session specifically for this target employee
      AdministrativeStaffSession.setActiveStaffId(targetId);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AdminPreviewWrapper(
            roleLabel: 'الإداري',
            userName: account.name,
            userId: account.userNumber,
            child: const UniversityServicesShell(),
          ),
        ),
      );
    } else {
      // Master Admin account is already in Master Admin
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أنت متواجد بالفعل في واجهة الأدمن الرئيسية'),
          backgroundColor: Color(0xFF073B4C),
        ),
      );
    }
  }

  /// Exits the preview session, resets preview state, and pops back to Administration.
  static void exitPreview(BuildContext context) {
    _isAdminPreview = false;
    _previewRole = 'admin';
    _previewUserId = '';
    _previewUserName = '';
    _previewUserNumber = '';
    _previewFaculty = '';

    // Clear temporary student/doctor/staff sessions
    StudentSession.clearSession();
    DoctorSession.clearSession();
    AdministrativeStaffSession.clearSession();

    // Pop the preview wrapper screen
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Logs out of Administration entirely when requested inside a preview session.
  static void logoutAdmin(BuildContext context) {
    _isAdminPreview = false;
    _previewRole = 'admin';
    _previewUserId = '';
    _previewUserName = '';
    _previewUserNumber = '';
    _previewFaculty = '';

    StudentSession.clearSession();
    DoctorSession.clearSession();
    AdminSession.clearSession();
    AdministrativeStaffSession.clearSession();

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
