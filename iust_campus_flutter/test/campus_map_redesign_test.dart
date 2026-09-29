import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/data/campus_map_data.dart';
import 'package:iust_campus_flutter/screens/campus_map_screen.dart';
import 'package:iust_campus_flutter/screens/department_map_viewer_screen.dart';
import 'package:iust_campus_flutter/screens/engineering_building_4_screen.dart';

Widget createTestApp(Widget child, {Size size = const Size(360, 800)}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: const EdgeInsets.only(top: 24, bottom: 16),
        viewInsets: EdgeInsets.zero,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    ),
  );
}

void main() {
  const testWidths = [360.0, 390.0, 412.0];

  for (final width in testWidths) {
    testWidgets(
        'CampusMapScreen renders parent card with zero overflow at width $width',
        (tester) async {
      final size = Size(width, 800);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester
          .pumpWidget(createTestApp(const CampusMapScreen(), size: size));
      await tester.pumpAndSettle();

      // Verify title is present
      expect(find.text('الخريطة التفاعلية للحرم الجامعي'), findsOneWidget);

      // Verify ONE parent card: كلية الهندسة – البناء الرابع
      expect(find.text('كلية الهندسة – البناء الرابع'), findsOneWidget);
      expect(find.text('خرائط أقسام البناء الرابع'), findsOneWidget);
      expect(find.text('4 خرائط متاحة'), findsOneWidget);

      // Department cards MUST NOT appear directly on CampusMapScreen
      expect(find.text('قسم المتطلبات'), findsNothing);
      expect(find.text('الهندسة المدنية'), findsNothing);
      expect(find.text('الهندسة المعلوماتية'), findsNothing);
      expect(find.text('هندسة الاتصالات'), findsNothing);
    });
  }

  testWidgets(
      'Tapping Building 4 card opens EngineeringBuilding4Screen with 4 department cards in exact order',
      (tester) async {
    final size = const Size(390, 800);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester
        .pumpWidget(createTestApp(const CampusMapScreen(), size: size));
    await tester.pumpAndSettle();

    await tester.tap(find.text('كلية الهندسة – البناء الرابع'));
    await tester.pumpAndSettle();

    expect(find.byType(EngineeringBuilding4Screen), findsOneWidget);
    expect(find.text('كلية الهندسة – البناء الرابع'), findsOneWidget);

    // Verify exactly four department cards in exact order
    final departments = CampusMapData.engineeringBuilding4Departments;
    expect(departments.length, 4);
    expect(departments[0].title, 'قسم المتطلبات');
    expect(departments[0].imageAsset, 'assets/img/iust 0.jpg');

    expect(departments[1].title, 'الهندسة المدنية');
    expect(departments[1].imageAsset, 'assets/img/iust 1.jpg');

    expect(departments[2].title, 'الهندسة المعلوماتية');
    expect(departments[2].imageAsset, 'assets/img/iust 2.jpg');

    expect(departments[3].title, 'هندسة الاتصالات');
    expect(departments[3].imageAsset, 'assets/img/iust 3.jpg');

    expect(find.text('قسم المتطلبات'), findsOneWidget);
    expect(find.text('الهندسة المدنية'), findsOneWidget);
    expect(find.text('الهندسة المعلوماتية'), findsOneWidget);
    expect(find.text('هندسة الاتصالات'), findsOneWidget);
    expect(find.text('خريطة متاحة'), findsNWidgets(4));
  });

  testWidgets(
      'Each department card opens dedicated DepartmentMapViewerScreen with correct 1-to-1 image',
      (tester) async {
    final size = const Size(390, 800);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
        createTestApp(const EngineeringBuilding4Screen(), size: size));
    await tester.pumpAndSettle();

    // 1. Test قسم المتطلبات -> iust 0
    await tester.ensureVisible(find.text('قسم المتطلبات'));
    await tester.tap(find.text('قسم المتطلبات'));
    await tester.pumpAndSettle();

    expect(find.byType(DepartmentMapViewerScreen), findsOneWidget);
    expect(find.text('خريطة قسم المتطلبات'), findsOneWidget);
    final viewer0 =
        tester.widget<DepartmentMapViewerScreen>(find.byType(DepartmentMapViewerScreen));
    expect(viewer0.imagePath, 'assets/img/iust 0.jpg');
    expect(find.byType(InteractiveViewer), findsOneWidget);

    // Go back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 2. Test الهندسة المدنية -> iust 1
    await tester.ensureVisible(find.text('الهندسة المدنية'));
    await tester.tap(find.text('الهندسة المدنية'));
    await tester.pumpAndSettle();

    expect(find.text('خريطة الهندسة المدنية'), findsOneWidget);
    final viewer1 =
        tester.widget<DepartmentMapViewerScreen>(find.byType(DepartmentMapViewerScreen));
    expect(viewer1.imagePath, 'assets/img/iust 1.jpg');

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 3. Test الهندسة المعلوماتية -> iust 2
    await tester.ensureVisible(find.text('الهندسة المعلوماتية'));
    await tester.tap(find.text('الهندسة المعلوماتية'));
    await tester.pumpAndSettle();

    expect(find.text('خريطة الهندسة المعلوماتية'), findsOneWidget);
    final viewer2 =
        tester.widget<DepartmentMapViewerScreen>(find.byType(DepartmentMapViewerScreen));
    expect(viewer2.imagePath, 'assets/img/iust 2.jpg');

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 4. Test هندسة الاتصالات -> iust 3
    await tester.ensureVisible(find.text('هندسة الاتصالات'));
    await tester.tap(find.text('هندسة الاتصالات'));
    await tester.pumpAndSettle();

    expect(find.text('خريطة هندسة الاتصالات'), findsOneWidget);
    final viewer3 =
        tester.widget<DepartmentMapViewerScreen>(find.byType(DepartmentMapViewerScreen));
    expect(viewer3.imagePath, 'assets/img/iust 3.jpg');
  });
}
