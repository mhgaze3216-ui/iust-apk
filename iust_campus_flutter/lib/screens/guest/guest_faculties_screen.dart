import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/guest_header.dart';

const _navy      = Color(0xFF073B4C);
const _blue      = Color(0xFF0F6CBD);
const _lightBg   = Color(0xFFF6F9FC);
const _gold      = Color(0xFFF5B82E);
const _white     = Colors.white;
const _textMain  = Color(0xFF0B2E3B);
const _textSub   = Color(0xFF6F7F89);
const _border    = Color(0xFFDCE8EE);

class _FacultyData {
  final String name;
  final String englishName;
  final String tagline;
  final String image;
  final String route;
  final String studyYears;
  final String degree;

  const _FacultyData({
    required this.name,
    required this.englishName,
    required this.tagline,
    required this.image,
    required this.route,
    required this.studyYears,
    required this.degree,
  });
}

class GuestFacultiesScreen extends StatefulWidget {
  const GuestFacultiesScreen({super.key});

  @override
  State<GuestFacultiesScreen> createState() => _GuestFacultiesScreenState();
}

class _GuestFacultiesScreenState extends State<GuestFacultiesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static const List<_FacultyData> _faculties = [
    _FacultyData(
      name: 'كلية الهندسة والتكنولوجيا',
      englishName: 'Faculty of Engineering & Technology',
      tagline: 'الهندسة المدنية والاتصالات وهندسة البرمجيات ونظم المعلومات',
      image: 'assets/img/information.jpeg',
      route: '/faculty/engineering',
      studyYears: '5 سنوات',
      degree: 'بكالوريوس هندسة',
    ),
    _FacultyData(
      name: 'كلية طب الأسنان',
      englishName: 'Faculty of Dentistry',
      tagline: 'الرعاية الفموية والتدريب السريري التخصصي والبحث العلمي',
      image: 'assets/img/teeth.jpeg',
      route: '/faculty/dentistry',
      studyYears: '5 سنوات',
      degree: 'دكتور في طب الأسنان',
    ),
    _FacultyData(
      name: 'كلية الصيدلة',
      englishName: 'Faculty of Pharmacy',
      tagline: 'العلوم الدوائية والسريرية والتحاليل الحيوية والمخبرية',
      image: 'assets/img/pharmaceutics.jpeg',
      route: '/faculty/pharmacy',
      studyYears: '5 سنوات',
      degree: 'بكالوريوس صيدلة',
    ),
    _FacultyData(
      name: 'كلية إدارة الأعمال والتمويل',
      englishName: 'Faculty of Business Administration & Finance',
      tagline: 'الإدارة الحديثة والمحاسبة والتمويل والمصارف والتسويق الإلكتروني',
      image: 'assets/img/works.jpeg',
      route: '/faculty/business',
      studyYears: '4 سنوات',
      degree: 'بكالوريوس إدارة أعمال',
    ),
    _FacultyData(
      name: 'كلية الهندسة المعمارية',
      englishName: 'Faculty of Architecture',
      tagline: 'التصميم المعماري والتخطيط العمراني والاستدامة والتصميم البيئي',
      image: 'assets/img/architecture.jpeg',
      route: '/faculty/architecture',
      studyYears: '5 سنوات',
      degree: 'بكالوريوس عمارة',
    ),
    _FacultyData(
      name: 'كلية الآداب والعلوم',
      englishName: 'Faculty of Arts & Sciences',
      tagline: 'التصميم الداخلي والغرافيكي واللغة الإنجليزية والترجمة',
      image: 'assets/img/sciences.jpeg',
      route: '/faculty/arts-sciences',
      studyYears: '4 سنوات',
      degree: 'بكالوريوس آداب وفنون',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_FacultyData> get _filteredFaculties {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _faculties;
    return _faculties.where((f) {
      return f.name.toLowerCase().contains(q) ||
          f.englishName.toLowerCase().contains(q) ||
          f.tagline.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredFaculties;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _lightBg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const GuestHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  children: [
              // Top Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_navy, _blue],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'كليات الجامعة',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'برامج وتخصصات أكاديمية معتمدة تلبي احتياجات سوق العمل والبحث العلمي.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Search Box
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن كلية أو تخصص...',
                    hintStyle: GoogleFonts.cairo(fontSize: 12.5, color: _textSub),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: _textSub),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: _textSub),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Faculty Cards List
              ...items.map((faculty) => _buildFacultyCard(faculty)),
            ],
          ),
        ),
      ],
    ),
  ),
),
);
  }

  Widget _buildFacultyCard(_FacultyData f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(f.route),
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image with badges
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  children: [
                    Image.asset(
                      f.image,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 140,
                        color: const Color(0xFFE2E8F4),
                        alignment: Alignment.center,
                        child: const Icon(Icons.account_balance_rounded, size: 40, color: _navy),
                      ),
                    ),
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: f.route == '/faculty/engineering'
                              ? _navy.withValues(alpha: 0.90)
                              : Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: f.route == '/faculty/engineering'
                                ? _gold
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              f.route == '/faculty/engineering'
                                  ? Icons.map_rounded
                                  : Icons.info_outline_rounded,
                              size: 12,
                              color: f.route == '/faculty/engineering'
                                  ? _gold
                                  : Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              f.route == '/faculty/engineering'
                                  ? '4 خرائط متاحة'
                                  : 'لا توجد خرائط مضافة حالياً',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: f.route == '/faculty/engineering'
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 12,
                      left: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: _navy.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              f.studyYears,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: _gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              f.degree,
                              style: GoogleFonts.cairo(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: _navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Faculty Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      f.englishName,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      f.tagline,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: _textSub,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'عرض تفاصيل الكلية',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _navy,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: _navy),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
