import 'package:flutter/material.dart';
import '../models/map_models.dart';

/// Central data repository for the Campus Map.
/// All old website-derived mock and hardcoded records have been cleared.
/// Currently contains 0 records, awaiting official new university campus data.
class CampusMapData {
  /// All buildings on campus (currently 0)
  static final List<Building> buildings = [];

  /// All floors (currently 0)
  static final List<Floor> floors = [];

  /// All rooms (currently 0)
  static final List<Room> rooms = [];

  /// All map markers (currently 0)
  static final List<MapMarker> markers = [];

  /// All campus search locations / popular locations (currently 0)
  static final List<MapLocation> locations = [];

  /// Official Informatics building floor map images in exact specified order
  static const List<String> informaticsMapImages = [
    'assets/img/iust 0.jpg',
    'assets/img/iust 1.jpg',
    'assets/img/iust 2.jpg',
    'assets/img/iust 3.jpg',
  ];

  /// Departments of Engineering Building 4 with exact 1-to-1 map image mappings
  static const List<DepartmentMapItem> engineeringBuilding4Departments = [
    DepartmentMapItem(
      id: 'requirements',
      title: 'قسم المتطلبات',
      viewerTitle: 'خريطة قسم المتطلبات',
      imageAsset: 'assets/img/iust 0.jpg',
      icon: Icons.menu_book_rounded,
    ),
    DepartmentMapItem(
      id: 'civil',
      title: 'الهندسة المدنية',
      viewerTitle: 'خريطة الهندسة المدنية',
      imageAsset: 'assets/img/iust 1.jpg',
      icon: Icons.architecture_rounded,
    ),
    DepartmentMapItem(
      id: 'informatics',
      title: 'الهندسة المعلوماتية',
      viewerTitle: 'خريطة الهندسة المعلوماتية',
      imageAsset: 'assets/img/iust 2.jpg',
      icon: Icons.computer_rounded,
    ),
    DepartmentMapItem(
      id: 'communications',
      title: 'هندسة الاتصالات',
      viewerTitle: 'خريطة هندسة الاتصالات',
      imageAsset: 'assets/img/iust 3.jpg',
      icon: Icons.cell_tower_rounded,
    ),
  ];

  /// Shared Building 4 group
  static const BuildingMapGroup engineeringBuilding4 = BuildingMapGroup(
    id: 'engineering_b4',
    title: 'كلية الهندسة – البناء الرابع',
    subtitle: 'خرائط أقسام البناء الرابع',
    icon: Icons.apartment_rounded,
    departments: engineeringBuilding4Departments,
  );

  /// The 7 main Campus Map entries in exact specified order:
  /// 1. خريطة الجامعة الكاملة
  /// 2. كلية الهندسة – البناء الرابع
  /// 3. كلية طب الأسنان
  /// 4. كلية الصيدلة
  /// 5. كلية الآداب والعلوم
  /// 6. كلية هندسة العمارة
  /// 7. كلية إدارة الأعمال
  static const List<CampusMapGroup> allGroups = [
    // 1. خريطة الجامعة الكاملة
    CampusMapGroup(
      id: 'full_university',
      title: 'خريطة الجامعة الكاملة',
      subtitle: 'المخطط العام والشامل لكافة كليات ومرافق الحرم الجامعي',
      viewerTitle: 'خريطة الجامعة الكاملة',
      icon: Icons.map_rounded,
      type: CampusMapType.fullUniversity,
      imageAssets: [],
      isAvailable: false,
      emptyMessage: 'لم تتم إضافة الخريطة الكاملة بعد',
    ),
    // 2. كلية الهندسة – البناء الرابع
    CampusMapGroup(
      id: 'engineering_b4',
      title: 'كلية الهندسة – البناء الرابع',
      subtitle: 'خرائط أقسام البناء الرابع',
      viewerTitle: 'كلية الهندسة – البناء الرابع',
      icon: Icons.apartment_rounded,
      type: CampusMapType.building,
      departments: engineeringBuilding4Departments,
      isAvailable: true,
      emptyMessage: 'لم تتم إضافة الخرائط بعد',
    ),
    // 3. كلية طب الأسنان
    CampusMapGroup(
      id: 'dentistry',
      title: 'كلية طب الأسنان',
      subtitle: 'مخططات ومرافق وعيادات كلية طب الأسنان',
      viewerTitle: 'خرائط كلية طب الأسنان',
      icon: Icons.medical_services_rounded,
      type: CampusMapType.faculty,
      imageAssets: [],
      isAvailable: false,
      emptyMessage: 'لم تتم إضافة الخرائط بعد',
    ),
    // 4. كلية الصيدلة
    CampusMapGroup(
      id: 'pharmacy',
      title: 'كلية الصيدلة',
      subtitle: 'مخططات ومخابر وقاعات كلية الصيدلة',
      viewerTitle: 'خرائط كلية الصيدلة',
      icon: Icons.local_pharmacy_rounded,
      type: CampusMapType.faculty,
      imageAssets: [],
      isAvailable: false,
      emptyMessage: 'لم تتم إضافة الخرائط بعد',
    ),
    // 5. كلية الآداب والعلوم
    CampusMapGroup(
      id: 'arts_sciences',
      title: 'كلية الآداب والعلوم',
      subtitle: 'مخططات وأقسام كلية الآداب والعلوم',
      viewerTitle: 'خرائط كلية الآداب والعلوم',
      icon: Icons.science_rounded,
      type: CampusMapType.faculty,
      imageAssets: [],
      isAvailable: false,
      emptyMessage: 'لم تتم إضافة الخرائط بعد',
    ),
    // 6. كلية هندسة العمارة
    CampusMapGroup(
      id: 'architecture',
      title: 'كلية هندسة العمارة',
      subtitle: 'مخططات ومراسم وقاعات كلية الهندسة المعمارية',
      viewerTitle: 'خرائط كلية هندسة العمارة',
      icon: Icons.architecture_rounded,
      type: CampusMapType.faculty,
      imageAssets: [],
      isAvailable: false,
      emptyMessage: 'لم تتم إضافة الخرائط بعد',
    ),
    // 7. كلية إدارة الأعمال
    CampusMapGroup(
      id: 'business',
      title: 'كلية إدارة الأعمال',
      subtitle: 'مخططات وقاعات ومدرجات كلية إدارة الأعمال والتمويل',
      viewerTitle: 'خرائط كلية إدارة الأعمال',
      icon: Icons.business_center_rounded,
      type: CampusMapType.faculty,
      imageAssets: [],
      isAvailable: false,
      emptyMessage: 'لم تتم إضافة الخرائط بعد',
    ),
  ];

  /// Shared faculty map groups for the campus map section
  static const List<FacultyMapGroup> facultyMapGroups = [
    FacultyMapGroup(
      id: 'informatics',
      title: 'خريطة كلية الهندسة المعلوماتية',
      subtitle: 'مبنى كلية الهندسة وتكنولوجيا المعلومات',
      icon: Icons.computer_rounded,
      imageAssets: informaticsMapImages,
      available: true,
    ),
    FacultyMapGroup(
      id: 'civil',
      title: 'خريطة الهندسة المدنية',
      subtitle: 'أقسام ومخابر الهندسة المدنية',
      icon: Icons.architecture_rounded,
      imageAssets: [],
      available: false,
    ),
    FacultyMapGroup(
      id: 'communications',
      title: 'خريطة هندسة الاتصالات',
      subtitle: 'أقسام ومخابر هندسة الاتصالات والشبكات',
      icon: Icons.cell_tower_rounded,
      imageAssets: [],
      available: false,
    ),
  ];

  /// Shared faculty/building map directory for campus map views
  static final List<FacultyMapItem> faculties = [
    const FacultyMapItem(
      id: 'informatics',
      name: 'كلية الهندسة والتكنولوجيا',
      subName: 'الهندسة المعلوماتية',
      englishName: 'Faculty of Engineering & Technology',
      image: 'assets/img/information.jpeg',
      tagline: 'الهندسة المدنية والاتصالات وهندسة البرمجيات ونظم المعلومات',
      mapImages: informaticsMapImages,
      route: '/faculty/engineering',
    ),
    const FacultyMapItem(
      id: 'dentistry',
      name: 'كلية طب الأسنان',
      subName: 'طب الأسنان',
      englishName: 'Faculty of Dentistry',
      image: 'assets/img/teeth.jpeg',
      tagline: 'الرعاية الفموية والتدريب السريري التخصصي والبحث العلمي',
      mapImages: [],
      route: '/faculty/dentistry',
    ),
    const FacultyMapItem(
      id: 'pharmacy',
      name: 'كلية الصيدلة',
      subName: 'الصيدلة',
      englishName: 'Faculty of Pharmacy',
      image: 'assets/img/pharmaceutics.jpeg',
      tagline: 'العلوم الدوائية والسريرية والتحاليل الحيوية والمخبرية',
      mapImages: [],
      route: '/faculty/pharmacy',
    ),
    const FacultyMapItem(
      id: 'business',
      name: 'كلية إدارة الأعمال والتمويل',
      subName: 'إدارة الأعمال',
      englishName: 'Faculty of Business Administration & Finance',
      image: 'assets/img/works.jpeg',
      tagline: 'الإدارة الحديثة والمحاسبة والتمويل والمصارف والتسويق الإلكتروني',
      mapImages: [],
      route: '/faculty/business',
    ),
    const FacultyMapItem(
      id: 'architecture',
      name: 'كلية الهندسة المعمارية',
      subName: 'الهندسة المعمارية',
      englishName: 'Faculty of Architecture',
      image: 'assets/img/architecture.jpeg',
      tagline: 'التصميم المعماري والتخطيط العمراني والاستدامة والتصميم البيئي',
      mapImages: [],
      route: '/faculty/architecture',
    ),
    const FacultyMapItem(
      id: 'arts_sciences',
      name: 'كلية الآداب والعلوم',
      subName: 'الآداب والعلوم',
      englishName: 'Faculty of Arts & Sciences',
      image: 'assets/img/sciences.jpeg',
      tagline: 'التصميم الداخلي والغرافيكي واللغة الإنجليزية والترجمة',
      mapImages: [],
      route: '/faculty/arts-sciences',
    ),
  ];

  /// Helper to check if any map data is available
  static bool get hasData =>
      buildings.isNotEmpty || markers.isNotEmpty || locations.isNotEmpty;
}

/// Model representing a faculty/building card in the campus map
class FacultyMapItem {
  final String id;
  final String name;
  final String subName;
  final String englishName;
  final String image;
  final String tagline;
  final List<String> mapImages;
  final String route;

  const FacultyMapItem({
    required this.id,
    required this.name,
    this.subName = '',
    required this.englishName,
    required this.image,
    this.tagline = '',
    this.mapImages = const [],
    this.route = '',
  });

  bool get hasMaps => mapImages.isNotEmpty;
  int get mapsCount => mapImages.length;
}

/// Shared model representing a faculty map group card in the campus map
class FacultyMapGroup {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> imageAssets;
  final bool available;

  const FacultyMapGroup({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.icon,
    this.imageAssets = const [],
    required this.available,
  });

  bool get hasMaps => available && imageAssets.isNotEmpty;
  int get mapsCount => imageAssets.length;
}

/// Model representing a single department map in Building 4
class DepartmentMapItem {
  final String id;
  final String title;
  final String viewerTitle;
  final String imageAsset;
  final IconData icon;

  const DepartmentMapItem({
    required this.id,
    required this.title,
    required this.viewerTitle,
    required this.imageAsset,
    required this.icon,
  });
}

/// Model representing a parent building with department maps
class BuildingMapGroup {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<DepartmentMapItem> departments;

  const BuildingMapGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.departments,
  });

  int get mapsCount => departments.length;
}

/// Type of Campus Map entry
enum CampusMapType {
  fullUniversity,
  building,
  faculty,
}

/// Unified model representing any top-level group or card in the Campus Map
class CampusMapGroup {
  final String id;
  final String title;
  final String subtitle;
  final String viewerTitle;
  final IconData icon;
  final CampusMapType type;
  final List<String> imageAssets;
  final List<DepartmentMapItem> departments;
  final bool isAvailable;
  final String emptyMessage;

  const CampusMapGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.viewerTitle,
    required this.icon,
    required this.type,
    this.imageAssets = const [],
    this.departments = const [],
    required this.isAvailable,
    this.emptyMessage = 'لم تتم إضافة الخرائط بعد',
  });

  bool get hasMaps => isAvailable && (imageAssets.isNotEmpty || departments.isNotEmpty);
  int get mapsCount =>
      type == CampusMapType.building ? departments.length : imageAssets.length;
}
