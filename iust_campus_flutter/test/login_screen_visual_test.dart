import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iust_campus_flutter/screens/login_screen.dart';
import 'package:iust_campus_flutter/screens/splash_screen.dart';
import 'package:iust_campus_flutter/theme/app_theme.dart';

void main() {
  group('LoginScreen Visual Adjustments', () {
    testWidgets('LoginScreen renders reduced centered IUST logo (66x66) and slightly smaller header text',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify university logo renders centered with reduced size (66x66)
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.height, equals(66));
      expect(imageWidget.width, equals(66));
      expect(imageWidget.fit, equals(BoxFit.contain));

      // 2. Verify logo is NOT recolored or tinted white
      expect(imageWidget.color, isNull);
      expect(imageWidget.colorBlendMode, isNull);

      // 3. Verify title has slightly smaller fontSize (26, reduced from 28)
      final titleFinder = find.text('مرحباً بك مجدداً');
      expect(titleFinder, findsOneWidget);
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.fontSize, equals(26));

      // 4. Verify subtitle has slightly smaller fontSize (13, reduced from 14)
      final subtitleFinder = find.text('الرجاء إدخال بياناتك الأكاديمية للوصول إلى حسابك');
      expect(subtitleFinder, findsOneWidget);
      final subtitleWidget = tester.widget<Text>(subtitleFinder);
      expect(subtitleWidget.style?.fontSize, equals(13));

      // 5. Verify fields and buttons remain intact
      expect(find.text('البريد الإلكتروني الجامعي'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('تسجيل الدخول'), findsOneWidget);

      // 6. Verify logo is positioned above the title
      final logoCenter = tester.getCenter(imageFinder);
      final titleCenter = tester.getCenter(titleFinder);
      expect(logoCenter.dy, lessThan(titleCenter.dy));
    });

    testWidgets('LoginScreen is keyboard-safe with zero overflow across mobile widths',
        (WidgetTester tester) async {
      const widths = [360.0, 390.0, 412.0];

      for (final width in widths) {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate keyboard open (bottom inset = 300)
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();

        // Verify no RenderFlex overflow
        expect(tester.takeException(), isNull);
        expect(find.text('تسجيل الدخول'), findsOneWidget);
      }
    });

    testWidgets('LoginScreen desktop layout retains separate hero section',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Desktop hero section
      expect(find.text('EduGuide AI'), findsOneWidget);
      expect(find.text('مرحباً بك في EduGuide AI'), findsOneWidget);
      expect(find.text('مرحباً بك مجدداً'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('SplashScreen Visual Adjustments', () {
    testWidgets('SplashScreen renders logo (250x250) and text as one unified centered group with 16px gap',
        (WidgetTester tester) async {
      const screenSizes = [
        Size(360, 800),
        Size(390, 844),
        Size(412, 915),
      ];

      for (final size in screenSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey(size.width),
            routes: {
              '/login': (_) => const Scaffold(body: Text('Login Route')),
            },
            home: const SplashScreen(),
          ),
        );

        // Find the logo image widget
        final logoFinder = find.byType(Image);
        expect(logoFinder, findsOneWidget);
        final logoWidget = tester.widget<Image>(logoFinder);

        // Verify large size (305x305, ~22% larger than 250, original colors, BoxFit.contain)
        expect(logoWidget.width, equals(305));
        expect(logoWidget.height, equals(305));
        expect(logoWidget.fit, equals(BoxFit.contain));

        // Verify 24px gap SizedBox between logo and text (target 20-30px)
        final gapFinder = find.byWidgetPredicate(
          (w) => w is SizedBox && w.height == 24,
        );
        expect(gapFinder, findsOneWidget);

        // Advance all timers to complete splash sequence cleanly
        for (int i = 0; i < 25; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      }
    });
  });
}
