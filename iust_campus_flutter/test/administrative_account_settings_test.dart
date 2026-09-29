import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/screens/university_services/university_account_screen.dart';
import 'package:iust_campus_flutter/screens/university_services/widgets/university_services_header.dart';
import 'package:iust_campus_flutter/services/administrative_staff_session.dart';

void main() {
  setUp(() {
    AdministrativeStaffSession.setActiveStaffId('EMP-071');
  });

  testWidgets(
    'UniversityAccountScreen renders matching Student/Doctor UI pattern with header logo',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: UniversityAccountScreen()),
      );
      await tester.pumpAndSettle();

      // Verify Header Logo & Name
      expect(find.byType(UniversityServicesHeader), findsOneWidget);
      expect(find.text('IUST'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // Verify Profile Card elements
      expect(find.text('الموظف الإداري'), findsOneWidget);
      expect(find.text('محمود العلي'), findsNothing);
      expect(find.text('الرقم الوظيفي'), findsOneWidget);
      expect(find.text('الصفة الوظيفية'), findsOneWidget);
      expect(find.text('حالة الحساب'), findsOneWidget);

      // Verify Section Labels
      expect(find.text('الحساب'), findsOneWidget);
      expect(find.text('التفضيلات'), findsOneWidget);
      expect(find.text('الأمان'), findsOneWidget);
      expect(find.text('الدعم'), findsOneWidget);

      // Verify Settings Items
      expect(find.text('بيانات الحساب الوظيفي'), findsOneWidget);
      expect(find.text('تعديل البيانات المسموحة'), findsOneWidget);
      expect(find.text('اللغة'), findsOneWidget);
      expect(find.text('الوضع الداكن / الفاتح'), findsOneWidget);
      expect(find.text('الإشعارات'), findsOneWidget);
      expect(find.text('تغيير كلمة المرور'), findsOneWidget);
      expect(find.text('المساعدة والدعم الفني'), findsOneWidget);
      expect(find.text('عن التطبيق'), findsOneWidget);

      // Scroll to and verify Logout Button, then tap it
      final logoutFinder = find.text('تسجيل الخروج');
      await tester.scrollUntilVisible(logoutFinder, 200);
      await tester.pumpAndSettle();
      expect(logoutFinder, findsOneWidget);
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();

      expect(find.text('هل أنت متأكد أنك تريد تسجيل الخروج؟'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('خروج'), findsOneWidget);
    },
  );

  testWidgets(
    'Edit allowed details dialog is completely keyboard-safe with 0 overflow on small mobile viewport',
    (tester) async {
      // Set small mobile screen size (e.g. 360 x 640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: UniversityAccountScreen()),
      );
      await tester.pumpAndSettle();

      // Tap "تعديل البيانات المسموحة"
      final editTile = find.text('تعديل البيانات المسموحة');
      expect(editTile, findsOneWidget);
      await tester.tap(editTile);
      await tester.pumpAndSettle();

      // Verify dialog title and description are visible
      expect(find.text('تعديل البيانات المسموحة'), findsWidgets);
      expect(
        find.textContaining('يمكنك تعديل بيانات التواصل وموقع المكتب فقط'),
        findsOneWidget,
      );
      expect(find.text('رقم الهاتف الداخلي / الجوال'), findsOneWidget);
      expect(find.text('موقع المكتب الإداري'), findsOneWidget);

      // Verify action buttons
      final cancelBtn = find.text('إلغاء');
      final saveBtn = find.text('حفظ التعديل');
      expect(cancelBtn, findsOneWidget);
      expect(saveBtn, findsOneWidget);

      // Simulate opening soft keyboard taking up 320px
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.resetViewInsets);

      // Type in the phone textfield
      final phoneField = find.byType(TextField).first;
      await tester.enterText(phoneField, '0999888777');
      await tester.pumpAndSettle();

      // Verify NO overflow errors were thrown (tester checks this automatically on each pump)
      // Tap the save button
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify dialog closed and success feedback appeared
      expect(find.text('تم حفظ البيانات بنجاح'), findsOneWidget);
    },
  );
}
