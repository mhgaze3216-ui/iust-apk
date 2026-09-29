// ─────────────────────────────────────────────────────────────────────────────
// Administrative Staff Session Service
// Manages the currently logged-in university administrative employee session.
// Completely isolated from AdminSession (Master Admin) and Student/Doctor sessions.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';

import '../data/university_admin_repository.dart';

/// Represents an isolated session for university administrative staff employees.
///
/// This session is strictly separated from [AdminSession] (which belongs exclusively
/// to the Master Admin).
class AdministrativeStaffSession {
  static String? _activeStaffId;

  static final ValueNotifier<String?> activeStaffIdNotifier =
      ValueNotifier<String?>(null);

  /// Current logged-in staff identifier (e.g., 'EMP-071')
  static String get currentStaffId => _activeStaffId ?? '';

  /// Whether an administrative staff employee is currently logged in
  static bool get hasActiveSession =>
      _activeStaffId != null && _activeStaffId!.isNotEmpty;

  /// Sets the active staff ID upon employee login
  static void setActiveStaffId(String staffId) {
    _activeStaffId = staffId;
    activeStaffIdNotifier.value = staffId;
  }

  /// Retrieves the current staff account model from repository
  static AdminUserAccount? get currentAccount {
    final sid = _activeStaffId;
    if (sid == null || sid.isEmpty) return null;
    try {
      final lower = sid.toLowerCase();
      return UniversityAdminRepository.accounts.firstWhere(
        (acc) =>
            acc.userNumber.toLowerCase() == lower ||
            acc.targetId.toLowerCase() == lower ||
            acc.username.toLowerCase() == lower,
      );
    } catch (_) {
      return null;
    }
  }

  /// Employee display properties
  static String get currentStaffName =>
      currentAccount?.name ?? 'الموظف الإداري';

  static String get currentDepartment => currentAccount?.facultyOrDept ?? '';

  static String get currentJobTitle => currentAccount?.jobTitle ?? '';

  static String get currentEmail => currentAccount?.email ?? '';

  static String get currentUserNumber =>
      currentAccount?.userNumber ?? (_activeStaffId ?? '');

  static List<String> get currentPermissions =>
      currentAccount?.permissions ?? const [];

  /// Checks if active staff member has a specific permission
  static bool hasPermission(String permission) =>
      currentPermissions.contains(permission);

  /// Clears the session on employee logout or before a different role logs in
  static void clearSession() {
    _activeStaffId = null;
    activeStaffIdNotifier.value = null;
  }
}
