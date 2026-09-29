import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/data/campus_map_data.dart';
import 'package:iust_campus_flutter/screens/campus_map_screen.dart';
import 'package:iust_campus_flutter/screens/informatics_map_gallery_screen.dart';

void main() {
  group('Informatics Map Images Verification', () {
    test('Verify exact four image files exist on disk', () {
      final expectedImages = [
        'assets/img/iust 0.jpg',
        'assets/img/iust 1.jpg',
        'assets/img/iust 2.jpg',
        'assets/img/iust 3.jpg',
      ];

      expect(CampusMapData.informaticsMapImages, equals(expectedImages));
      expect(CampusMapData.informaticsMapImages.length, 4);

      for (final path in expectedImages) {
        final file = File(path);
        expect(file.existsSync(), isTrue,
            reason: 'Image file $path must exist in assets');
      }
    });

    test('Verify Informatics faculty card in CampusMapData', () {
      final informatics =
          CampusMapData.faculties.firstWhere((f) => f.id == 'informatics');
      expect(informatics.name, 'كلية الهندسة والتكنولوجيا');
      expect(informatics.hasMaps, isTrue);
      expect(informatics.mapsCount, 4);
      expect(informatics.mapImages, equals(CampusMapData.informaticsMapImages));

      final otherFaculties =
          CampusMapData.faculties.where((f) => f.id != 'informatics').toList();
      for (final f in otherFaculties) {
        expect(f.hasMaps, isFalse,
            reason: '${f.name} should not have maps attached');
        expect(f.mapsCount, 0);
        expect(f.mapImages, isEmpty);
      }
    });

    testWidgets('InformaticsMapGalleryScreen displays four map labels and InteractiveViewer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InformaticsMapGalleryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('خرائط كلية الهندسة المعلوماتية'), findsOneWidget);
      expect(find.text('الخريطة 0'), findsWidgets);
      expect(find.text('الخريطة 1'), findsWidgets);
      expect(find.text('الخريطة 2'), findsWidgets);
      expect(find.text('الخريطة 3'), findsWidgets);

      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('CampusMapScreen renders Building 4 card and navigates to department cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CampusMapScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check Building 4 card
      expect(find.text('كلية الهندسة – البناء الرابع'), findsOneWidget);
      expect(find.text('خرائط أقسام البناء الرابع'), findsOneWidget);
      expect(find.text('4 خرائط متاحة'), findsOneWidget);

      // Open Building 4
      await tester.tap(find.text('كلية الهندسة – البناء الرابع'));
      await tester.pumpAndSettle();

      // Check department cards inside Building 4
      expect(find.text('قسم المتطلبات'), findsOneWidget);
      expect(find.text('الهندسة المدنية'), findsOneWidget);
      expect(find.text('الهندسة المعلوماتية'), findsOneWidget);
      expect(find.text('هندسة الاتصالات'), findsOneWidget);
    });
  });
}
