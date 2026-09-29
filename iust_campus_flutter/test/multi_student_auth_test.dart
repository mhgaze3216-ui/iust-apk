import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/services/mock_auth_service.dart';
import 'package:iust_campus_flutter/services/student_session.dart';
import 'package:iust_campus_flutter/data/student_repository.dart';
import 'package:iust_campus_flutter/data/transport_data.dart';
import 'package:iust_campus_flutter/data/academic_calendar_data.dart';
import 'package:iust_campus_flutter/services/mock_notifications_service.dart';
import 'package:iust_campus_flutter/services/doctor_session.dart';
import 'package:iust_campus_flutter/services/mock_chat_service.dart';
import 'package:iust_campus_flutter/models/chat_models.dart';
import 'package:iust_campus_flutter/data/doctor_repository.dart';

void main() {
  group('Multi-Student Authentication and Data Isolation Tests', () {
    test('TEST 1: Hamza login does not expose unhydrated demo data', () async {
      final authResult = await MockAuthService.login('hamza', '12345');
      expect(authResult.success, isTrue);
      expect(authResult.role, equals(UserRole.student));
      expect(authResult.studentId, equals('student-dentistry-001'));

      expect(StudentSession.currentStudentId, equals('student-dentistry-001'));
      final profile = StudentSession.currentProfile;
      expect(profile.studentId, equals('student-dentistry-001'));
      expect(profile.fullName, equals('طالب'));
      expect(StudentSession.currentEnrolledCourses, isEmpty);
    });

    test('Logout clears session cleanly without fallback to Hamza', () {
      StudentSession.clearSession();
      expect(StudentSession.currentStudentId, equals(''));
      expect(StudentSession.hasActiveSession, isFalse);
      expect(StudentSession.currentProfile.fullName, isNot(contains('حمزة')));
      expect(StudentSession.currentEnrolledCourses, isEmpty);
      expect(StudentSession.currentScheduleSessions, isEmpty);
      expect(StudentSession.currentGrades, isEmpty);
    });

    test(
      'TEST 2: Mustafa login does not expose another student’s data',
      () async {
        final authResult = await MockAuthService.login('mustafa', '12345');
        expect(authResult.success, isTrue);
        expect(authResult.role, equals(UserRole.student));
        expect(authResult.studentId, equals('student-informatics-002'));

        expect(
          StudentSession.currentStudentId,
          equals('student-informatics-002'),
        );
        final profile = StudentSession.currentProfile;
        expect(profile.studentId, equals('student-informatics-002'));
        expect(profile.fullName, equals('طالب'));
        expect(StudentSession.currentEnrolledCourses, isEmpty);
      },
    );

    test('Zero cross-leakage between accounts', () {
      // Direct repository queries
      final hamzaCourses = StudentRepository.getEnrolledCourses(
        'student-dentistry-001',
      );
      final mustafaCourses = StudentRepository.getEnrolledCourses(
        'student-informatics-002',
      );

      expect(hamzaCourses, isEmpty);
      expect(mustafaCourses, isEmpty);
      expect(StudentRepository.getStudent('student-dentistry-001'), isNull);
      expect(StudentRepository.getStudent('student-informatics-002'), isNull);
    });

    test('TEST 3: Library references are empty until loaded from the API', () {
      final hamzaRefs = StudentRepository.getLibraryReferences(
        'student-dentistry-001',
      );
      final mustafaRefs = StudentRepository.getLibraryReferences(
        'student-informatics-002',
      );

      expect(hamzaRefs, isEmpty);
      expect(mustafaRefs, isEmpty);
    });

    test(
      'TEST 4: Transport schedule and academic calendar are global datasets',
      () {
        // Transport is imported directly from transport_data.dart
        // Verify waves exist and are global
        expect(kMorning1, isNotEmpty);
        expect(kMorning2, isNotEmpty);
        expect(kMorning3, isNotEmpty);
        expect(kReturnTrips, isNotEmpty);

        // Verify academic calendar has 20251, 20252, 20253
        final s1Events = kAcademicCalendar
            .where((e) => e.semesterId == '20251')
            .toList();
        final s2Events = kAcademicCalendar
            .where((e) => e.semesterId == '20252')
            .toList();
        final s3Events = kAcademicCalendar
            .where((e) => e.semesterId == '20253')
            .toList();

        expect(s1Events, isNotEmpty);
        expect(s2Events, isNotEmpty);
        expect(s3Events, isNotEmpty);
      },
    );

    test('TEST 5: Grades are not fabricated before an API response', () {
      final mustafaGrades = StudentRepository.getGrades(
        'student-informatics-002',
      );
      final hamzaGrades = StudentRepository.getGrades('student-dentistry-001');
      expect(mustafaGrades, isEmpty);
      expect(hamzaGrades, isEmpty);
    });

    test('TEST 6: Doctor contacts are not populated from local fixtures', () {
      final mustafaDocs = StudentRepository.getDoctors(
        'student-informatics-002',
      );
      final hamzaDocs = StudentRepository.getDoctors('student-dentistry-001');
      expect(mustafaDocs, isEmpty);
      expect(hamzaDocs, isEmpty);
    });

    test('TEST 7: Exams are not fabricated before an API response', () {
      final exams = StudentRepository.getFinalExams('student-informatics-002');
      expect(exams, isEmpty);
      expect(StudentRepository.getFinalExams('student-dentistry-001'), isEmpty);
    });

    test('TEST 8: Study plans are not fabricated before an API response', () {
      final mustafaPlan = StudentRepository.getStudyPlanCourses(
        'student-informatics-002',
      );
      expect(mustafaPlan, isEmpty);
      expect(
        StudentRepository.getStudyPlanCourses('student-dentistry-001'),
        isEmpty,
      );
      expect(StudentRepository.getStudyPlan('student-informatics-002'), isNull);
    });

    test('TEST 9: Notification bell data, unread badge, and personal isolation', () {
      MockNotificationsService.resetForTesting();

      // ── Hamza notifications ───────────────────────────────────────────────
      final hamzaNotifs = MockNotificationsService.getNotifier(
        'student-dentistry-001',
      ).value;
      expect(hamzaNotifs.length, equals(4));

      // Global notifications present for Hamza
      expect(
        hamzaNotifs.any(
          (n) => n.id == 'notif-global-final-exam' && n.studentId == null,
        ),
        isTrue,
      );
      expect(
        hamzaNotifs.any(
          (n) => n.id == 'notif-global-calendar' && n.studentId == null,
        ),
        isTrue,
      );
      expect(
        hamzaNotifs.any(
          (n) => n.id == 'notif-global-transport' && n.studentId == null,
        ),
        isTrue,
      );

      // Hamza personal notification
      final hamzaPersonal = hamzaNotifs
          .where((n) => n.studentId == 'student-dentistry-001')
          .toList();
      expect(hamzaPersonal.length, equals(1));
      expect(hamzaPersonal.first.title, equals('تذكير أكاديمي'));
      expect(
        hamzaPersonal.first.message,
        equals('راجع موادك الحالية وجدولك الدراسي.'),
      );

      // Mustafa personal notification MUST NOT be present for Hamza
      expect(
        hamzaNotifs.any((n) => n.id == 'notif-mustafa-final-exam'),
        isFalse,
      );
      expect(
        hamzaNotifs.any((n) => n.studentId == 'student-informatics-002'),
        isFalse,
      );

      // Unread count
      expect(
        MockNotificationsService.getUnreadCount('student-dentistry-001'),
        equals(4),
      );

      // Marking one as read
      MockNotificationsService.markAsRead(
        'notif-global-final-exam',
        'student-dentistry-001',
      );
      expect(
        MockNotificationsService.getUnreadCount('student-dentistry-001'),
        equals(3),
      );
      final updatedHamzaNotifs = MockNotificationsService.getNotifier(
        'student-dentistry-001',
      ).value;
      // Read notification remains visible
      expect(updatedHamzaNotifs.length, equals(4));
      expect(
        updatedHamzaNotifs
            .firstWhere((n) => n.id == 'notif-global-final-exam')
            .isRead,
        isTrue,
      );

      // ── Mustafa notifications ─────────────────────────────────────────────
      final mustafaNotifs = MockNotificationsService.getNotifier(
        'student-informatics-002',
      ).value;
      expect(mustafaNotifs.length, equals(4));

      // Global notifications present for Mustafa
      expect(
        mustafaNotifs.any(
          (n) => n.id == 'notif-global-final-exam' && n.studentId == null,
        ),
        isTrue,
      );
      expect(
        mustafaNotifs.any(
          (n) => n.id == 'notif-global-calendar' && n.studentId == null,
        ),
        isTrue,
      );
      expect(
        mustafaNotifs.any(
          (n) => n.id == 'notif-global-transport' && n.studentId == null,
        ),
        isTrue,
      );

      // Mustafa personal notification
      final mustafaPersonal = mustafaNotifs
          .where((n) => n.studentId == 'student-informatics-002')
          .toList();
      expect(mustafaPersonal.length, equals(1));
      expect(mustafaPersonal.first.title, equals('تنبيه فاينل'));
      expect(
        mustafaPersonal.first.message,
        contains('امتحان مهارات اللغة الإنكليزية (2)'),
      );

      // Hamza personal notification MUST NOT be present for Mustafa
      expect(
        mustafaNotifs.any((n) => n.id == 'notif-hamza-academic-reminder'),
        isFalse,
      );
      expect(
        mustafaNotifs.any((n) => n.studentId == 'student-dentistry-001'),
        isFalse,
      );

      // Mustafa unread count is independent (still 4 even though Hamza read a global notification)
      expect(
        MockNotificationsService.getUnreadCount('student-informatics-002'),
        equals(4),
      );
    });

    test('TEST 10: Nearest transport trip dynamic calculation and no-trips-left handling', () {
      // Shared global transport dataset verified
      expect(kMorning1, isNotEmpty);
      expect(kMorning2, isNotEmpty);
      expect(kMorning3, isNotEmpty);
      expect(kReturnTrips, isNotEmpty);

      // Morning 1 test (at 06:15)
      final earlyMorning = getNearestTrip(DateTime(2026, 9, 17, 6, 15));
      expect(earlyMorning.hasTripsLeft, isTrue);
      expect(earlyMorning.waveName, equals('الصباحي الأول'));
      expect(earlyMorning.departureTime, equals('06:30'));
      expect(earlyMorning.tripType, equals('انطلاق نحو الجامعة'));

      // Morning 2 test (at 07:30)
      final midMorning = getNearestTrip(DateTime(2026, 9, 17, 7, 30));
      expect(midMorning.hasTripsLeft, isTrue);
      expect(midMorning.waveName, equals('الصباحي الثاني'));
      expect(midMorning.departureTime, equals('08:15'));
      expect(midMorning.tripType, equals('انطلاق نحو الجامعة'));

      // Morning 3 test (at 09:00)
      final lateMorning = getNearestTrip(DateTime(2026, 9, 17, 9, 0));
      expect(lateMorning.hasTripsLeft, isTrue);
      expect(lateMorning.waveName, equals('الصباحي الثالث'));
      expect(lateMorning.departureTime, equals('09:15'));
      expect(lateMorning.tripType, equals('انطلاق نحو الجامعة'));

      // Return trip test (at 13:30)
      final afternoonReturn = getNearestTrip(DateTime(2026, 9, 17, 13, 30));
      expect(afternoonReturn.hasTripsLeft, isTrue);
      expect(afternoonReturn.waveName, equals('العودة من الجامعة'));
      expect(afternoonReturn.departureTime, equals('14:00'));
      expect(afternoonReturn.tripType, equals('رحلة عودة من الجامعة'));

      // After 15:45 (at 19:30) -> No trips remaining today
      final evening = getNearestTrip(DateTime(2026, 9, 17, 19, 30));
      expect(evening.hasTripsLeft, isFalse);
    });

    test('Doctor login, session isolation, and logout', () async {
      // 1. Doctor login
      final authResult = await MockAuthService.login('Doctor', '12345');
      expect(authResult.success, isTrue);
      expect(authResult.role, equals(UserRole.doctor));
      expect(authResult.doctorId, equals('doctor-001'));
      expect(authResult.studentId, isNull);
      expect(
        MockAuthService.homeRouteForRole(authResult.role!),
        equals('/doctor'),
      );

      // 2. DoctorSession verified
      expect(DoctorSession.hasActiveSession, isTrue);
      expect(DoctorSession.currentDoctorId, equals('doctor-001'));
      expect(DoctorSession.currentDoctorProfile.id, equals('doctor-001'));
      expect(
        DoctorSession.currentDoctorProfile.fullName,
        equals('غير مضاف بعد'),
      );

      // 3. StudentSession is cleared and completely isolated
      expect(StudentSession.hasActiveSession, isFalse);
      expect(StudentSession.currentStudentId, equals(''));
      expect(StudentSession.currentEnrolledCourses, isEmpty);

      // 4. Logout clears DoctorSession
      DoctorSession.clearSession();
      expect(DoctorSession.hasActiveSession, isFalse);
      expect(DoctorSession.currentDoctorId, equals(''));

      // 5. Cross-role isolation: Student login clears DoctorSession
      DoctorSession.setActiveDoctorId('doctor-001');
      expect(DoctorSession.hasActiveSession, isTrue);

      final studentLogin = await MockAuthService.login('mustafa', '12345');
      expect(studentLogin.success, isTrue);
      expect(DoctorSession.hasActiveSession, isFalse);
      expect(DoctorSession.currentDoctorId, equals(''));
      expect(StudentSession.hasActiveSession, isTrue);
      expect(
        StudentSession.currentStudentId,
        equals('student-informatics-002'),
      );
    });

    test(
      'Doctor chat service returns conversations dynamically without fake data',
      () {
        DoctorSession.setActiveDoctorId('doctor-chat-isolation-test');

        const isolatedDoctorId = 'doctor-chat-isolation-test';
        final before = MockChatService.getConversationsForDoctor(
          isolatedDoctorId,
        );
        final existingConversationIds = before
            .map((conversation) => conversation.conversationId)
            .toSet();

        // Student starts a conversation with doctor-001
        final created = MockChatService.getOrCreateConversation(
          doctorId: isolatedDoctorId,
          doctorName: 'الدكتور المشرف',
          courseId: '301446',
          courseName: 'ذكاء صنعي',
          studentId: 'student-informatics-002',
        );

        expect(created.doctorId, equals(isolatedDoctorId));
        expect(created.studentId, equals('student-informatics-002'));

        // Now doctor sees this real conversation
        final doctorConvs = MockChatService.getConversationsForDoctor(
          isolatedDoctorId,
        );
        expect(doctorConvs.length, equals(before.length + 1));
        expect(
          doctorConvs.map((conversation) => conversation.conversationId),
          contains(created.conversationId),
        );
        expect(
          existingConversationIds,
          isNot(contains(created.conversationId)),
        );

        // Doctor replies
        final reply = MockChatService.sendMessage(
          conversationId: created.conversationId,
          receiverUserId: 'student-informatics-002',
          body: 'أهلاً بك، تفضل بالسؤال.',
          senderUserId: 'doctor-001',
          senderRole: SenderRole.doctor,
        );

        expect(reply.senderRole, equals(SenderRole.doctor));
        expect(reply.body, equals('أهلاً بك، تفضل بالسؤال.'));

        final messages = MockChatService.getMessages(created.conversationId);
        expect(messages.length, equals(1));
        expect(messages.first.body, equals('أهلاً بك، تفضل بالسؤال.'));
      },
    );

    test('Doctor profile edit and password change tests', () async {
      DoctorSession.setActiveDoctorId('doctor-001');

      // 1. Initial profile
      final initial = DoctorSession.currentProfile;
      expect(initial.doctorId, equals('doctor-001'));

      // The API contract only permits editing the office field.
      await expectLater(
        DoctorRepository.updateProfile(fullName: 'د. سامر المحمود'),
        throwsUnsupportedError,
      );
      await expectLater(
        DoctorRepository.updateProfile(email: 'samer@iust.edu.sy'),
        throwsUnsupportedError,
      );

      // 3. Password change: wrong current password fails
      final wrongPassResult = MockAuthService.changeDoctorPassword(
        currentPassword: 'wrongpassword',
        newPassword: 'newpass123',
      );
      expect(wrongPassResult, isFalse);

      // 4. Password change: correct current password succeeds
      final successPassResult = MockAuthService.changeDoctorPassword(
        currentPassword: '12345',
        newPassword: 'newpass123',
      );
      expect(successPassResult, isTrue);

      // 5. Verify login with new password works
      final newLogin = await MockAuthService.login('doctor', 'newpass123');
      expect(newLogin.success, isTrue);
      expect(newLogin.doctorId, equals('doctor-001'));

      // Restore password back to 12345
      MockAuthService.changeDoctorPassword(
        currentPassword: 'newpass123',
        newPassword: '12345',
      );

      // 6. Hamza and Mustafa passwords unchanged
      final hamzaLogin = await MockAuthService.login('hamza', '12345');
      expect(hamzaLogin.success, isTrue);
      expect(hamzaLogin.studentId, equals('student-dentistry-001'));

      final mustafaLogin = await MockAuthService.login('mustafa', '12345');
      expect(mustafaLogin.success, isTrue);
      expect(mustafaLogin.studentId, equals('student-informatics-002'));
    });

    test(
      'TEST 11: Doctor repository does not expose unhydrated demo records',
      () {
        final profile = DoctorRepository.profile;
        expect(profile.doctorId, equals('doctor-001'));
        expect(profile.fullName, equals('غير مضاف بعد'));
        expect(DoctorRepository.courses, isEmpty);
        expect(DoctorRepository.roster, isEmpty);
        expect(
          DoctorRepository.getGradesForCourse('doctor-course-001'),
          isEmpty,
        );
        expect(
          DoctorRepository.getAttendanceForCourse('doctor-course-001'),
          isEmpty,
        );
      },
    );
  });
}
