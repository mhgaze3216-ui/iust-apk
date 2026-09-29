import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/campus_map_data.dart';
import '../theme/app_theme.dart';
import 'department_map_viewer_screen.dart';

/// Screen displaying the 4 department map cards for Engineering Building 4.
class EngineeringBuilding4Screen extends StatelessWidget {
  const EngineeringBuilding4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.getBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final textMain = AppTheme.getTextMain(context);
    final textSub = AppTheme.getTextSub(context);
    final border = AppTheme.getBorder(context);

    final departments = CampusMapData.engineeringBuilding4Departments;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          scrolledUnderElevation: 1,
          iconTheme: IconThemeData(color: textMain),
          centerTitle: true,
          title: Text(
            'كلية الهندسة – البناء الرابع',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textMain,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle / Intro banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.apartment_rounded,
                              size: 20,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'خرائط أقسام ومخابر البناء الرابع المعتمدة. اختر القسم لعرض المخطط التفصيلي.',
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                color: textSub,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // The 4 department cards in exact specified order
                    ...departments.map(
                        (dept) => _buildDepartmentCard(context, dept)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(BuildContext context, DepartmentMapItem dept) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBg(context);
    final textMain = AppTheme.getTextMain(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.gold.withValues(alpha: 0.35)
              : AppTheme.gold.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DepartmentMapViewerScreen(
                  title: dept.viewerTitle,
                  imagePath: dept.imageAsset,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Department icon box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1B3248)
                        : AppTheme.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    dept.icon,
                    size: 24,
                    color: isDark ? const Color(0xFF90CAF9) : AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 14),

                // Department Title & Availability Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dept.title,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textMain,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF132F2B)
                                  : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFA5D6A7),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 13,
                                  color: isDark
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'خريطة متاحة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF4ADE80)
                                        : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'عرض الخريطة',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 11,
                                color: AppTheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Trailing Arrow
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: AppTheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
