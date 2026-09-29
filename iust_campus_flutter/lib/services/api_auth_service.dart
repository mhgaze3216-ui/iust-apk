import '../services/administrative_staff_session.dart';
import '../services/admin_session.dart';
import '../services/api_client.dart';
import '../services/doctor_session.dart';
import '../services/mock_auth_service.dart';
import '../services/student_session.dart';

class ApiAuthService {
  static Future<AuthResult> login(String username, String password) async {
    final data = await ApiClient.instance.post(
      '/auth/login',
      body: {'username': username, 'password': password},
    );
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw const ApiException(502, 'INVALID_RESPONSE', 'The login response has no user.');
    }

    final accessToken = data['accessToken'];
    final refreshToken = data['refreshToken'];
    final id = user['id'];
    final roleName = user['role'];
    if (accessToken is! String ||
        refreshToken is! String ||
        id is! String ||
        roleName is! String) {
      throw const ApiException(502, 'INVALID_RESPONSE', 'The login response is incomplete.');
    }

    final UserRole role;
    switch (roleName) {
      case 'student':
        role = UserRole.student;
        break;
      case 'doctor':
        role = UserRole.doctor;
        break;
      case 'staff':
        role = UserRole.administrativeStaff;
        break;
      case 'admin':
        role = UserRole.admin;
        break;
      default:
        throw ApiException(502, 'INVALID_ROLE', 'The server returned an unsupported role: $roleName.');
    }

    await ApiClient.instance.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    StudentSession.clearSession();
    DoctorSession.clearSession();
    AdminSession.clearSession();
    AdministrativeStaffSession.clearSession();

    switch (role) {
      case UserRole.student:
        StudentSession.setActiveStudentId(id);
        break;
      case UserRole.doctor:
        DoctorSession.setActiveDoctorId(id);
        break;
      case UserRole.admin:
        AdminSession.setActiveAdminId(id);
        break;
      case UserRole.administrativeStaff:
        AdministrativeStaffSession.setActiveStaffId(id);
        break;
    }

    return AuthResult.success(
      role,
      studentId: role == UserRole.student ? id : null,
      doctorId: role == UserRole.doctor ? id : null,
      staffId: role == UserRole.administrativeStaff ? id : null,
    );
  }

  static Future<void> logout() async {
    final refreshToken = await ApiClient.instance.refreshToken;
    if (refreshToken != null) {
      await ApiClient.instance.post(
        '/auth/logout',
        body: {'refreshToken': refreshToken},
      );
    }
    await ApiClient.instance.clearTokens();
    StudentSession.clearSession();
    DoctorSession.clearSession();
    AdminSession.clearSession();
    AdministrativeStaffSession.clearSession();
  }
}
