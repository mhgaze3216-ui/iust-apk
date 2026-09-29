import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_home_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_quick_actions_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_courses_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_grades_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_attendance_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_account_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_chat_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_notifications_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_transport_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_exam_center_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_academic_submission_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_midterm_template_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_final_exam_template_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_midterm_schedule_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_final_schedule_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_exam_instructions_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_student_questions_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_assignments_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_announcements_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_help_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_settings_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_edit_profile_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_administrative_center_screen.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_shell.dart';
import 'package:iust_campus_flutter/services/doctor_session.dart';

Widget wrapWidget(Widget widget, {Size size = const Size(360, 800)}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: const EdgeInsets.only(top: 24, bottom: 16),
        viewInsets: EdgeInsets.zero,
      ),
      child: Directionality(textDirection: TextDirection.rtl, child: widget),
    ),
  );
}

void main() {
  setUp(() {
    DoctorSession.setActiveDoctorId('doctor-001');
  });

  const sizes = [Size(360, 800), Size(390, 844)];

  for (final size in sizes) {
    group('Doctor screens layout test (${size.width}x${size.height})', () {
      testWidgets('DoctorHomeScreen renders without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(DoctorHomeScreen(onSelectTab: (_) {}), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorQuickActionsScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorQuickActionsScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorCoursesScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorCoursesScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorGradesScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorGradesScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorAttendanceScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorAttendanceScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorAccountScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorAccountScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorChatScreen renders without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorChatScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorNotificationsScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorNotificationsScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorTransportScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorTransportScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorExamCenterScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorExamCenterScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorAcademicSubmissionScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorAcademicSubmissionScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorMidtermTemplateScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorMidtermTemplateScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorFinalExamTemplateScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorFinalExamTemplateScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorMidtermScheduleScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorMidtermScheduleScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorFinalScheduleScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorFinalScheduleScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorExamInstructionsScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorExamInstructionsScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorStudentQuestionsScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorStudentQuestionsScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorAssignmentsScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorAssignmentsScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorAnnouncementsScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorAnnouncementsScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorHelpScreen renders without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorHelpScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorSettingsScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorSettingsScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorEditProfileScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorEditProfileScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorAdministrativeCenterScreen renders without overflow', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          wrapWidget(const DoctorAdministrativeCenterScreen(), size: size),
        );
        await tester.pumpAndSettle();
      });

      testWidgets('DoctorShell renders without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(wrapWidget(const DoctorShell(), size: size));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(tester.takeException(), isNull);
      });
    });
  }
}
