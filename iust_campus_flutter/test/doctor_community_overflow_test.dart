import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/screens/doctor/doctor_community_screen.dart';
import 'package:iust_campus_flutter/services/doctor_session.dart';

Widget wrapWidget(Widget widget, {Size size = const Size(360, 800)}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: const EdgeInsets.only(top: 24, bottom: 16),
        viewInsets: EdgeInsets.zero,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: widget,
      ),
    ),
  );
}

void main() {
  setUp(() {
    DoctorSession.setActiveDoctorId('doctor-001');
  });

  const testWidths = [360.0, 390.0, 412.0];

  for (final width in testWidths) {
    testWidgets('DoctorCommunityScreen renders with zero overflow at width $width',
        (tester) async {
      final size = Size(width, 800);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWidget(const DoctorCommunityScreen(), size: size));
      await tester.pumpAndSettle();

      // Verify title is visible and readable
      expect(find.text('مجتمع المقررات الأكاديمي'), findsOneWidget);

      // Verify badge is visible and readable
      expect(find.text('بيانات تجريبية'), findsOneWidget);

      // Verify icon is present
      expect(find.byIcon(Icons.forum_outlined), findsOneWidget);

      // Verify buttons below are present and unchanged
      expect(find.text('إعلان جديد'), findsOneWidget);
      expect(find.text('مناقشة جديدة'), findsOneWidget);

      // Let framework assert
      expect(find.text('إعلان جديد'), findsOneWidget);
    });
  }
}
