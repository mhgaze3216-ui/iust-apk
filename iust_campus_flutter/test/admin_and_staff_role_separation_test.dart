import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/services/mock_auth_service.dart';
import 'package:iust_campus_flutter/services/admin_session.dart';
import 'package:iust_campus_flutter/services/administrative_staff_session.dart';
import 'package:iust_campus_flutter/services/student_session.dart';
import 'package:iust_campus_flutter/services/doctor_session.dart';

void main() {
  group('Admin and Administrative Staff Role Separation Tests', () {
    setUp(() {
      StudentSession.clearSession();
      DoctorSession.clearSession();
      AdminSession.clearSession();
      AdministrativeStaffSession.clearSession();
    });

    test('1. Master Admin login (admin / 12345) maps strictly to UserRole.admin and /admin', () async {
      final res = await MockAuthService.login('admin', '12345');
      expect(res.success, isTrue);
      expect(res.role, equals(UserRole.admin));
      expect(res.studentId, isNull);
      expect(res.doctorId, isNull);
      expect(res.staffId, isNull);

      final route = MockAuthService.homeRouteForRole(res.role!);
      expect(route, equals('/admin'));

      // Session isolation: AdminSession active, AdministrativeStaffSession inactive
      expect(AdminSession.activeAdminId, equals('admin-001'));
      expect(AdministrativeStaffSession.hasActiveSession, isFalse);
      expect(AdministrativeStaffSession.currentStaffId, isEmpty);
    });

    test('2. Administrative Staff login (edari / 12345) maps strictly to UserRole.administrativeStaff and /administrative', () async {
      final res = await MockAuthService.login('edari', '12345');
      expect(res.success, isTrue);
      expect(res.role, equals(UserRole.administrativeStaff));
      expect(res.staffId, isNotNull);

      final route = MockAuthService.homeRouteForRole(res.role!);
      expect(route, equals('/administrative'));

      // Session isolation: AdministrativeStaffSession active, AdminSession inactive
      expect(AdministrativeStaffSession.hasActiveSession, isTrue);
      expect(AdministrativeStaffSession.currentStaffId, equals('EMP-071'));
      expect(
        AdministrativeStaffSession.currentStaffName,
        equals('الموظف الإداري'),
      );
      expect(AdministrativeStaffSession.currentDepartment, isEmpty);
      expect(AdministrativeStaffSession.currentPermissions, isEmpty);
      expect(AdminSession.isRolePreviewMode, isFalse);
    });

    test('3. Administrative Staff login (m.ali / 12345) maps strictly to UserRole.administrativeStaff and /administrative', () async {
      final res = await MockAuthService.login('m.ali', '12345');
      expect(res.success, isTrue);
      expect(res.role, equals(UserRole.administrativeStaff));
      expect(res.staffId, equals('EMP-071'));

      final route = MockAuthService.homeRouteForRole(res.role!);
      expect(route, equals('/administrative'));

      // Session isolation: AdministrativeStaffSession active with Mahmoud Al-Ali
      expect(AdministrativeStaffSession.hasActiveSession, isTrue);
      expect(AdministrativeStaffSession.currentStaffId, equals('EMP-071'));
      expect(
        AdministrativeStaffSession.currentStaffName,
        equals('الموظف الإداري'),
      );
      expect(AdministrativeStaffSession.currentDepartment, isEmpty);
      expect(AdministrativeStaffSession.currentJobTitle, isEmpty);
      expect(AdministrativeStaffSession.currentPermissions, isEmpty);
    });

    test('4. Administrative Staff login (r.khaled / 12345) maps to UserRole.administrativeStaff and /administrative', () async {
      final res = await MockAuthService.login('r.khaled', '12345');
      expect(res.success, isTrue);
      expect(res.role, equals(UserRole.administrativeStaff));
      expect(res.staffId, equals('EMP-084'));

      final route = MockAuthService.homeRouteForRole(res.role!);
      expect(route, equals('/administrative'));

      expect(AdministrativeStaffSession.hasActiveSession, isTrue);
      expect(AdministrativeStaffSession.currentStaffId, equals('EMP-084'));
      expect(
        AdministrativeStaffSession.currentStaffName,
        equals('الموظف الإداري'),
      );
      expect(AdministrativeStaffSession.currentDepartment, isEmpty);
      expect(AdministrativeStaffSession.currentPermissions, isEmpty);
    });

    test('4. Cross-role session clearance guarantees zero leakage between Master Admin and Staff', () async {
      // First, log in as Master Admin
      await MockAuthService.login('admin', '12345');
      expect(AdminSession.activeAdminId, equals('admin-001'));
      expect(AdministrativeStaffSession.hasActiveSession, isFalse);

      // Now log in as Administrative Staff
      await MockAuthService.login('m.ali', '12345');
      expect(AdministrativeStaffSession.hasActiveSession, isTrue);
      expect(AdministrativeStaffSession.currentStaffId, equals('EMP-071'));

      // Now log in as Student
      await MockAuthService.login('hamza', '12345');
      expect(StudentSession.hasActiveSession, isTrue);
      expect(AdministrativeStaffSession.hasActiveSession, isFalse);
      expect(AdministrativeStaffSession.currentStaffId, isEmpty);
    });

    test('5. Student and Doctor logins remain unaffected', () async {
      final sRes = await MockAuthService.login('hamza', '12345');
      expect(sRes.success, isTrue);
      expect(sRes.role, equals(UserRole.student));
      expect(MockAuthService.homeRouteForRole(sRes.role!), equals('/student'));

      final dRes = await MockAuthService.login('doctor', '12345');
      expect(dRes.success, isTrue);
      expect(dRes.role, equals(UserRole.doctor));
      expect(MockAuthService.homeRouteForRole(dRes.role!), equals('/doctor'));
    });
  });
}
