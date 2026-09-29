import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/data/student_repository.dart';
import 'package:iust_campus_flutter/models/chat_models.dart';
import 'package:iust_campus_flutter/services/mock_chat_service.dart';
import 'package:iust_campus_flutter/services/administrative_staff_session.dart';
import 'package:iust_campus_flutter/services/mock_auth_service.dart';

void main() {
  group('Administrative Staff Features Tests', () {
    setUp(() {
      AdministrativeStaffSession.setActiveStaffId('EMP-071');
    });

    test('1. Student schedules are not seeded from local fixtures', () {
      final students = StudentRepository.allStudents;
      expect(students, isEmpty);
      expect(StudentRepository.allStudents, isEmpty);
    });

    test('2. Administrative Chat categories and staff message sending', () {
      MockChatService.ensureAdministrativeStaffDemoData();

      // Check all 3 categories exist
      final studentsList = MockChatService.getAdministrativeContacts(
        'students',
      );
      final doctorsList = MockChatService.getAdministrativeContacts('doctors');
      final staffList = MockChatService.getAdministrativeContacts('staff');

      expect(studentsList, isNotEmpty);
      expect(doctorsList, isNotEmpty);
      expect(staffList, isNotEmpty);

      // Verify contact details
      final firstStudent = studentsList.first;
      expect(firstStudent.category, equals('students'));
      expect(firstStudent.conversationId, isNotEmpty);

      final firstDoctor = doctorsList.first;
      expect(firstDoctor.category, equals('doctors'));

      final firstStaff = staffList.first;
      expect(firstStaff.category, equals('staff'));

      // Send a message as staff
      final sentMsg = MockChatService.sendMessage(
        conversationId: firstStudent.conversationId,
        receiverUserId: firstStudent.id,
        body: 'تم استلام طلبكم وسيتم معالجته خلال 24 ساعة.',
        senderRole: SenderRole.staff,
      );

      expect(sentMsg.senderRole, equals(SenderRole.staff));
      expect(
        sentMsg.body,
        equals('تم استلام طلبكم وسيتم معالجته خلال 24 ساعة.'),
      );

      final allMsgs = MockChatService.getMessages(firstStudent.conversationId);
      expect(allMsgs.last.messageId, equals(sentMsg.messageId));
      expect(allMsgs.last.senderRole, equals(SenderRole.staff));
    });

    test('3. Master Admin account and routing remain untouched', () {
      expect(
        MockAuthService.homeRouteForRole(UserRole.admin),
        equals('/admin'),
      );
      expect(
        MockAuthService.homeRouteForRole(UserRole.administrativeStaff),
        equals('/administrative'),
      );
    });
  });
}
