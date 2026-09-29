import '../models/admin_models.dart';
import '../data/admin_demo_data.dart';

/// Manages active admin session and role preview modes.
class AdminSession {
  static String _activeAdminId = 'admin-001';
  static bool _isRolePreviewMode = false;
  static String _previewRole = 'admin'; // 'student', 'doctor', 'admin'

  static String get activeAdminId => _activeAdminId;
  static bool get isRolePreviewMode => _isRolePreviewMode;
  static String get previewRole => _previewRole;

  static AdminProfile get currentProfile => AdminDemoData.profile;

  static void setActiveAdminId(String id) {
    _activeAdminId = id;
  }

  static void startPreview(String role) {
    _isRolePreviewMode = true;
    _previewRole = role;
  }

  static void exitPreview() {
    _isRolePreviewMode = false;
    _previewRole = 'admin';
  }

  static void clearSession() {
    _activeAdminId = 'admin-001';
    _isRolePreviewMode = false;
    _previewRole = 'admin';
  }
}
