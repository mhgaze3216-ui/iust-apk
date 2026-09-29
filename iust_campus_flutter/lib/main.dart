import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/guest/guest_shell.dart';
import 'screens/guest/guest_help_and_contact_screen.dart';
import 'screens/guest_inquiry_screen.dart';
import 'screens/campus_map_screen.dart';
import 'screens/informatics_map_gallery_screen.dart';
import 'screens/login_screen.dart';
import 'screens/university_info_screen.dart';
import 'screens/scholarships_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/financial_procedures_screen.dart';
import 'screens/dentistry_faculty_screen.dart';
import 'screens/pharmacy_faculty_screen.dart';
import 'screens/engineering_faculty_screen.dart';
import 'screens/business_faculty_screen.dart';
import 'screens/architecture_faculty_screen.dart';
import 'screens/arts_sciences_faculty_screen.dart';
import 'screens/student/student_shell.dart';
import 'screens/doctor/doctor_shell.dart';
import 'screens/admin/admin_shell.dart';

import 'package:flutter/services.dart';

import 'theme/theme_controller.dart';
import 'screens/university_admin/university_administration_shell.dart';
import 'screens/university_services/university_services_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.initialize();
  runApp(const IustCampusApp());
}

class IustCampusApp extends StatelessWidget {
  const IustCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeModeNotifier,
      builder: (context, currentMode, _) {
        SystemChrome.setSystemUIOverlayStyle(
          currentMode == ThemeMode.dark
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: AppTheme.darkBackground,
                  systemNavigationBarIconBrightness: Brightness.light,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: AppTheme.lightBg,
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
        );

        return MaterialApp(
          title: 'IUST Guide',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/welcome': (context) => const GuestShell(),
            '/guest/help': (context) => const GuestHelpAndContactScreen(),
            '/guest/inquiry': (context) => const GuestInquiryScreen(),
            '/map': (context) => const CampusMapScreen(),
            '/map/informatics': (context) =>
                const InformaticsMapGalleryScreen(),
            '/login': (context) => const LoginScreen(),
            '/info/university': (context) => const UniversityInfoScreen(),
            '/info/scholarships': (context) => const ScholarshipsScreen(),
            '/info/documents': (context) => const DocumentsScreen(),
            '/info/faq': (context) => const FaqScreen(),
            '/info/financial': (context) => const FinancialProceduresScreen(),
            '/faculty/dentistry': (context) => const DentistryFacultyScreen(),
            '/faculty/pharmacy': (context) => const PharmacyFacultyScreen(),
            '/faculty/engineering': (context) =>
                const EngineeringFacultyScreen(),
            '/faculty/business': (context) => const BusinessFacultyScreen(),
            '/faculty/architecture': (context) =>
                const ArchitectureFacultyScreen(),
            '/faculty/arts-sciences': (context) =>
                const ArtsSciencesFacultyScreen(),
            '/student': (context) => const StudentShell(),
            '/doctor': (context) => const DoctorShell(),
            '/admin': (context) => const UniversityAdministrationShell(),
            '/admin_old': (context) => const AdminShell(),
            '/administrative': (context) => const UniversityServicesShell(),
            '/university-services': (context) =>
                const UniversityServicesShell(),
          },
        );
      },
    );
  }
}
