import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/screens/guest/guest_shell.dart';
import 'package:iust_campus_flutter/screens/guest/guest_help_and_contact_screen.dart';
import 'package:iust_campus_flutter/screens/guest_inquiry_screen.dart';
import 'package:iust_campus_flutter/theme/app_theme.dart';

void main() {
  testWidgets('GuestShell renders 5 tabs and floating contact button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const GuestShell(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify 5 tabs in floating navigation
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('الكليات'), findsOneWidget);
    expect(find.text('الخريطة'), findsOneWidget);
    expect(find.text('الخدمات'), findsOneWidget);
    expect(find.text('عن الجامعة'), findsWidgets);

    // Verify floating contact/help button
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Switch to 'الكليات' tab
    await tester.tap(find.text('الكليات'));
    await tester.pumpAndSettle();
    expect(find.text('كليات الجامعة'), findsOneWidget);

    // Switch to 'عن الجامعة' tab (target the tab item specifically)
    final aboutTabs = find.text('عن الجامعة');
    await tester.tap(aboutTabs.last);
    await tester.pumpAndSettle();
    expect(find.text('الجامعة الدولية الخاصة للعلوم والتكنولوجيا'), findsOneWidget);

    // Switch to 'الخدمات' tab
    await tester.tap(find.text('الخدمات'));
    await tester.pumpAndSettle();
    expect(find.text('دليل خدمات الزوار'), findsOneWidget);
  });

  testWidgets('GuestHelpAndContactScreen displays categories and leads to Inquiry', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const GuestHelpAndContactScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Check title and banner
    expect(find.text('الأسئلة والتواصل'), findsOneWidget);
    expect(find.text('تواصل مع الإدارة'), findsOneWidget);

    // Tap contact button to open GuestInquiryScreen
    await tester.tap(find.text('إرسال استفسار جديد'));
    await tester.pumpAndSettle();

    expect(find.text('نموذج الاستفسار الإداري'), findsOneWidget);
    expect(find.text('نوع الاستفسار *'), findsOneWidget);
  });

  testWidgets('GuestInquiryScreen can submit form and generate reference code', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const GuestInquiryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Fill in subject and message
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(5));
    // 0: name, 1: email, 2: phone, 3: subject, 4: message
    await tester.enterText(textFields.at(3), 'استفسار بخصوص التسجيل');
    await tester.enterText(textFields.at(4), 'أرجو توضيح الأوراق والشهادات المطلوبة للقبول.');
    await tester.pumpAndSettle();

    // Tap submit button
    final submitBtn = find.text('إرسال الاستفسار');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Success screen should be shown with reference badge
    expect(find.text('تم إرسال استفسارك بنجاح'), findsOneWidget);
    expect(find.textContaining('INQ-GUEST-'), findsOneWidget);
  });

  testWidgets('Simplified GuestHeader renders only language button, logo, and IUST text', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const GuestShell(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Language button [ EN / AR ] exists
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('/'), findsOneWidget);
    expect(find.text('AR'), findsOneWidget);

    // 2. IUST text and university logo exist
    expect(find.text('IUST'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    // 3. Removed elements: NO notifications bell, NO hamburger menu, NO avatar circle 'ز'
    expect(find.byIcon(Icons.notifications_outlined), findsNothing);
    expect(find.byIcon(Icons.notifications), findsNothing);
    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.byIcon(Icons.menu_rounded), findsNothing);
    expect(find.text('ز'), findsNothing);

    // 4. Test language toggle works
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Language set to English (EN)'), findsOneWidget);

    await tester.tap(find.text('AR'));
    await tester.pumpAndSettle();
    expect(find.text('تم ضبط اللغة: العربية (AR)'), findsOneWidget);
  });
}

