// ─────────────────────────────────────────────────────────────────────────────
// TEMPORARY MOCK AUTH SERVICE
//
// This file is a development stub only.
// Replace MockAuthService with the real AuthService when the backend is ready.
//
// The real service should:
//   1. POST credentials to the API endpoint.
//   2. Receive a token + user object including the role field.
//   3. Return an AuthResult with that role.
//   4. Store the token securely (e.g. flutter_secure_storage).
//
// Then update login_screen.dart to call AuthService.login() instead.
// ─────────────────────────────────────────────────────────────────────────────

import 'student_session.dart';
import 'doctor_session.dart';
import 'admin_session.dart';
import 'administrative_staff_session.dart';

/// Supported roles. Extend this enum when new roles are added.
enum UserRole { student, doctor, admin, administrativeStaff }

/// Result object returned by the auth service.
class AuthResult {
  /// Whether authentication succeeded.
  final bool success;

  /// The authenticated user's role. Null when [success] is false.
  final UserRole? role;

  /// The internal student ID returned by auth. Null for non-student roles.
  final String? studentId;

  /// The internal doctor ID returned by auth. Null for non-doctor roles.
  final String? doctorId;

  /// The internal employee/staff ID returned by auth. Null for non-staff roles.
  final String? staffId;

  /// Human-readable error message (Arabic). Null when [success] is true.
  final String? errorMessage;

  const AuthResult._({
    required this.success,
    this.role,
    this.studentId,
    this.doctorId,
    this.staffId,
    this.errorMessage,
  });

  factory AuthResult.success(
    UserRole role, {
    String? studentId,
    String? doctorId,
    String? staffId,
  }) =>
      AuthResult._(
        success: true,
        role: role,
        studentId: studentId,
        doctorId: doctorId,
        staffId: staffId,
      );

  factory AuthResult.failure(String message) =>
      AuthResult._(success: false, errorMessage: message);
}

/// Temporary mock implementation.
/// Delete this class and swap in a real network-based service later.
class MockAuthService {
  // ── Test accounts ──────────────────────────────────────────────────────
  // Add more accounts here while backend is not yet connected.
  static final _accounts = <String, ({
    String password,
    UserRole role,
    String? studentId,
    String? doctorId,
    String? staffId,
  })>{
    'hamza':    (password: '12345', role: UserRole.student,             studentId: 'student-dentistry-001',   doctorId: null,         staffId: null),
    'mustafa':  (password: '12345', role: UserRole.student,             studentId: 'student-informatics-002', doctorId: null,         staffId: null),
    'doctor':   (password: '12345', role: UserRole.doctor,              studentId: null,                     doctorId: 'doctor-001', staffId: null),
    'admin':    (password: '12345', role: UserRole.admin,               studentId: null,                     doctorId: null,         staffId: null),
    // Administrative staff account requested by user
    'edari':    (password: '12345', role: UserRole.administrativeStaff, studentId: null,                     doctorId: null,         staffId: 'EMP-071'),
    // Existing university administrative staff accounts
    'm.ali':    (password: '12345', role: UserRole.administrativeStaff, studentId: null,                     doctorId: null,         staffId: 'EMP-071'),
    'r.khaled': (password: '12345', role: UserRole.administrativeStaff, studentId: null,                     doctorId: null,         staffId: 'EMP-084'),
    'emp-071':  (password: '12345', role: UserRole.administrativeStaff, studentId: null,                     doctorId: null,         staffId: 'EMP-071'),
    'emp-084':  (password: '12345', role: UserRole.administrativeStaff, studentId: null,                     doctorId: null,         staffId: 'EMP-084'),
  };

  /// Change doctor password locally
  static bool changeDoctorPassword({
    required String currentPassword,
    required String newPassword,
  }) {
    final entry = _accounts['doctor'];
    if (entry == null || entry.password != currentPassword) {
      return false;
    }
    _accounts['doctor'] = (
      password: newPassword,
      role: entry.role,
      studentId: entry.studentId,
      doctorId: entry.doctorId,
      staffId: entry.staffId,
    );
    return true;
  }

  /// Change admin password locally
  static bool changeAdminPassword({
    required String currentPassword,
    required String newPassword,
  }) {
    final entry = _accounts['admin'];
    if (entry == null || entry.password != currentPassword) {
      return false;
    }
    _accounts['admin'] = (
      password: newPassword,
      role: entry.role,
      studentId: entry.studentId,
      doctorId: entry.doctorId,
      staffId: entry.staffId,
    );
    return true;
  }

  /// Change administrative employee password locally
  static bool changeAdministrativeStaffPassword({
    required String username,
    required String currentPassword,
    required String newPassword,
  }) {
    final key = username.trim().toLowerCase();
    final entry = _accounts[key];
    if (entry == null || entry.password != currentPassword) {
      return false;
    }
    _accounts[key] = (
      password: newPassword,
      role: entry.role,
      studentId: entry.studentId,
      doctorId: entry.doctorId,
      staffId: entry.staffId,
    );
    return true;
  }

  // ── Public API ─────────────────────────────────────────────────────────
  /// Attempt login with [username] and [password].
  static Future<AuthResult> login(String username, String password) async {
    // Simulate a small network delay so UI loading states are visible
    await Future.delayed(const Duration(milliseconds: 400));

    final trimmed = username.trim().toLowerCase();
    final entry = _accounts[trimmed];

    if (entry != null && entry.password == password) {
      // Clear all sessions first to prevent cross-account / cross-role pollution
      StudentSession.clearSession();
      DoctorSession.clearSession();
      AdminSession.clearSession();
      AdministrativeStaffSession.clearSession();

      if (entry.role == UserRole.student && entry.studentId != null) {
        StudentSession.setActiveStudentId(entry.studentId!);
      } else if (entry.role == UserRole.doctor && entry.doctorId != null) {
        DoctorSession.setActiveDoctorId(entry.doctorId!);
      } else if (entry.role == UserRole.admin) {
        AdminSession.setActiveAdminId('admin-001');
      } else if (entry.role == UserRole.administrativeStaff && entry.staffId != null) {
        AdministrativeStaffSession.setActiveStaffId(entry.staffId!);
      }

      return AuthResult.success(
        entry.role,
        studentId: entry.studentId,
        doctorId: entry.doctorId,
        staffId: entry.staffId,
      );
    }

    return AuthResult.failure('اسم المستخدم أو كلمة المرور غير صحيحة');
  }

  // ── Role → route helper ────────────────────────────────────────────────
  /// Returns the named route for the given role's home screen.
  static String homeRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return '/student';       // StudentShell with bottom nav
      case UserRole.doctor:
        return '/doctor';        // DoctorShell with bottom nav
      case UserRole.admin:
        return '/admin';         // UniversityAdministrationShell (Master Admin)
      case UserRole.administrativeStaff:
        return '/administrative'; // UniversityServicesShell (Administrative Staff)
    }
  }
}
