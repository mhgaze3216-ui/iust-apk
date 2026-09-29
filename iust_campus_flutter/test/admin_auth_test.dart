import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/services/mock_auth_service.dart';
import 'package:iust_campus_flutter/services/admin_session.dart';
import 'package:iust_campus_flutter/services/student_session.dart';
import 'package:iust_campus_flutter/services/doctor_session.dart';

void main() {
  group('Administration & Multi-Role Authentication Verification', () {
    test('admin and staff accounts resolve to their own roles', () async {
      final res = await MockAuthService.login('admin', '12345');
      expect(res.success, isTrue);
      expect(res.role, equals(UserRole.admin));
      expect(MockAuthService.homeRouteForRole(res.role!), equals('/admin'));
      expect(AdminSession.activeAdminId, equals('admin-001'));
      expect(StudentSession.hasActiveSession, isFalse);
      expect(DoctorSession.currentDoctorId, equals(''));

      final staffRes = await MockAuthService.login('edari', '12345');
      expect(staffRes.success, isTrue);
      expect(staffRes.role, equals(UserRole.administrativeStaff));
      expect(staffRes.staffId, equals('EMP-071'));
      expect(StudentSession.hasActiveSession, isFalse);
    });

    test('Doctor / 12345 preserves Doctor account', () async {
      final res = await MockAuthService.login('Doctor', '12345');
      expect(res.success, isTrue);
      expect(res.role, equals(UserRole.doctor));
      expect(res.doctorId, equals('doctor-001'));
      expect(MockAuthService.homeRouteForRole(res.role!), equals('/doctor'));
      expect(DoctorSession.currentDoctorId, equals('doctor-001'));
      expect(StudentSession.hasActiveSession, isFalse);
    });

    test('hamza / 12345 preserves Hamza student account', () async {
      final res = await MockAuthService.login('hamza', '12345');
      expect(res.success, isTrue);
      expect(res.role, equals(UserRole.student));
      expect(res.studentId, equals('student-dentistry-001'));
      expect(MockAuthService.homeRouteForRole(res.role!), equals('/student'));
      expect(StudentSession.currentStudentId, equals('student-dentistry-001'));
      expect(StudentSession.currentProfile.fullName, equals('طالب'));
      expect(StudentSession.currentEnrolledCourses, isEmpty);
    });

    test('mustafa / 12345 preserves Mustafa student account', () async {
      final res = await MockAuthService.login('mustafa', '12345');
      expect(res.success, isTrue);
      expect(res.role, equals(UserRole.student));
      expect(res.studentId, equals('student-informatics-002'));
      expect(MockAuthService.homeRouteForRole(res.role!), equals('/student'));
      expect(
        StudentSession.currentStudentId,
        equals('student-informatics-002'),
      );
      expect(StudentSession.currentProfile.fullName, equals('طالب'));
      expect(StudentSession.currentEnrolledCourses, isEmpty);
    });
  });
}
