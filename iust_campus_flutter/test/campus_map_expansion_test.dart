import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/data/campus_map_data.dart';
import 'package:iust_campus_flutter/screens/campus_map_screen.dart';
import 'package:iust_campus_flutter/screens/engineering_building_4_screen.dart';
import 'package:iust_campus_flutter/screens/faculty_empty_map_screen.dart';
import 'package:iust_campus_flutter/theme/app_theme.dart';

void main() {
  test('CampusMapData.allGroups contains exactly the 7 required entries in exact order', () {
    final groups = CampusMapData.allGroups;
    expect(groups.length, equals(7));

    // 1. خريطة الجامعة الكاملة
    expect(groups[0].title, equals('خريطة الجامعة الكاملة'));
    expect(groups[0].type, equals(CampusMapType.fullUniversity));
    expect(groups[0].imageAssets, isEmpty);
    expect(groups[0].isAvailable, isFalse);
    expect(groups[0].emptyMessage, equals('لم تتم إضافة الخريطة الكاملة بعد'));

    // 2. كلية الهندسة – البناء الرابع
    expect(groups[1].title, equals('كلية الهندسة – البناء الرابع'));
    expect(groups[1].type, equals(CampusMapType.building));
    expect(groups[1].departments.length, equals(4));
    expect(groups[1].departments[0].title, equals('قسم المتطلبات'));
    expect(groups[1].departments[0].imageAsset, equals('assets/img/iust 0.jpg'));
    expect(groups[1].departments[1].title, equals('الهندسة المدنية'));
    expect(groups[1].departments[1].imageAsset, equals('assets/img/iust 1.jpg'));
    expect(groups[1].departments[2].title, equals('الهندسة المعلوماتية'));
    expect(groups[1].departments[2].imageAsset, equals('assets/img/iust 2.jpg'));
    expect(groups[1].departments[3].title, equals('هندسة الاتصالات'));
    expect(groups[1].departments[3].imageAsset, equals('assets/img/iust 3.jpg'));
    expect(groups[1].isAvailable, isTrue);

    // 3. كلية طب الأسنان
    expect(groups[2].title, equals('كلية طب الأسنان'));
    expect(groups[2].viewerTitle, equals('خرائط كلية طب الأسنان'));
    expect(groups[2].type, equals(CampusMapType.faculty));
    expect(groups[2].imageAssets, isEmpty);
    expect(groups[2].isAvailable, isFalse);
    expect(groups[2].emptyMessage, equals('لم تتم إضافة الخرائط بعد'));

    // 4. كلية الصيدلة
    expect(groups[3].title, equals('كلية الصيدلة'));
    expect(groups[3].viewerTitle, equals('خرائط كلية الصيدلة'));
    expect(groups[3].type, equals(CampusMapType.faculty));
    expect(groups[3].imageAssets, isEmpty);
    expect(groups[3].isAvailable, isFalse);
    expect(groups[3].emptyMessage, equals('لم تتم إضافة الخرائط بعد'));

    // 5. كلية الآداب والعلوم
    expect(groups[4].title, equals('كلية الآداب والعلوم'));
    expect(groups[4].viewerTitle, equals('خرائط كلية الآداب والعلوم'));
    expect(groups[4].type, equals(CampusMapType.faculty));
    expect(groups[4].imageAssets, isEmpty);
    expect(groups[4].isAvailable, isFalse);
    expect(groups[4].emptyMessage, equals('لم تتم إضافة الخرائط بعد'));

    // 6. كلية هندسة العمارة
    expect(groups[5].title, equals('كلية هندسة العمارة'));
    expect(groups[5].viewerTitle, equals('خرائط كلية هندسة العمارة'));
    expect(groups[5].type, equals(CampusMapType.faculty));
    expect(groups[5].imageAssets, isEmpty);
    expect(groups[5].isAvailable, isFalse);
    expect(groups[5].emptyMessage, equals('لم تتم إضافة الخرائط بعد'));

    // 7. كلية إدارة الأعمال
    expect(groups[6].title, equals('كلية إدارة الأعمال'));
    expect(groups[6].viewerTitle, equals('خرائط كلية إدارة الأعمال'));
    expect(groups[6].type, equals(CampusMapType.faculty));
    expect(groups[6].imageAssets, isEmpty);
    expect(groups[6].isAvailable, isFalse);
    expect(groups[6].emptyMessage, equals('لم تتم إضافة الخرائط بعد'));
  });

  testWidgets('CampusMapScreen displays all 7 cards in exact order without overflow',
      (WidgetTester tester) async {
    const widths = [360.0, 390.0, 412.0];

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CampusMapScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 7 card titles are present
      expect(find.text('خريطة الجامعة الكاملة'), findsOneWidget);
      expect(find.text('كلية الهندسة – البناء الرابع'), findsOneWidget);
      expect(find.text('كلية طب الأسنان'), findsOneWidget);
      expect(find.text('كلية الصيدلة'), findsOneWidget);
      expect(find.text('كلية الآداب والعلوم'), findsOneWidget);
      expect(find.text('كلية هندسة العمارة'), findsOneWidget);
      expect(find.text('كلية إدارة الأعمال'), findsOneWidget);

      // Verify Building 4 has 4 available maps badge
      expect(find.text('4 خرائط متاحة'), findsOneWidget);

      // Verify empty badges
      expect(find.text('لم تتم إضافة الخريطة الكاملة بعد'), findsOneWidget);
      expect(find.text('لم تتم إضافة الخرائط بعد'), findsNWidgets(5));

      // Verify no RenderFlex overflow
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Tapping Full University Map card opens empty state screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CampusMapScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('خريطة الجامعة الكاملة'));
    await tester.pumpAndSettle();

    expect(find.byType(FacultyEmptyMapScreen), findsOneWidget);
    expect(find.text('خريطة الجامعة الكاملة'), findsWidgets);
    expect(find.text('لم تتم إضافة الخريطة الكاملة بعد'), findsOneWidget);
  });

  testWidgets('Tapping Engineering Building 4 card opens Building 4 screen with 4 departments',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CampusMapScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('كلية الهندسة – البناء الرابع'));
    await tester.pumpAndSettle();

    expect(find.byType(EngineeringBuilding4Screen), findsOneWidget);
    expect(find.text('قسم المتطلبات'), findsOneWidget);
    expect(find.text('الهندسة المدنية'), findsOneWidget);
    expect(find.text('الهندسة المعلوماتية'), findsOneWidget);
    expect(find.text('هندسة الاتصالات'), findsOneWidget);
  });

  testWidgets('Tapping Dentistry card opens FacultyEmptyMapScreen with matching title',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CampusMapScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('كلية طب الأسنان'));
    await tester.pumpAndSettle();

    expect(find.byType(FacultyEmptyMapScreen), findsOneWidget);
    expect(find.text('خرائط كلية طب الأسنان'), findsOneWidget);
    expect(find.text('لم تتم إضافة الخرائط بعد'), findsOneWidget);
  });
}
