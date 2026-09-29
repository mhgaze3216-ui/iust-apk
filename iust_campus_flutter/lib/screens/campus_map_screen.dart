import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/campus_map_data.dart';
import '../theme/app_theme.dart';
import 'engineering_building_4_screen.dart';
import 'faculty_empty_map_screen.dart';

class CampusMapScreen extends StatelessWidget {
  const CampusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.getBg(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                _buildCardsList(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cardBg = AppTheme.getCardBg(context);
    final textMain = AppTheme.getTextMain(context);
    final textSub = AppTheme.getTextSub(context);
    final border = AppTheme.getBorder(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الرئيسية / الخريطة التفاعلية',
                style: GoogleFonts.cairo(
                  color: textSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'الخريطة التفاعلية للحرم الجامعي',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textMain,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'استكشف مخططات الكليات والمباني الجامعية، وتعرّف على تفاصيل الأقسام والقاعات والمرافق المعتمدة.',
                style: GoogleFonts.cairo(
                  color: textSub,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardsList(BuildContext context) {
    final groups = CampusMapData.allGroups;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _buildGroupCard(context, groups[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, CampusMapGroup group) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBg(context);
    final textMain = AppTheme.getTextMain(context);
    final textSub = AppTheme.getTextSub(context);

    // Accent border for primary landmarks
    final isPrimaryLandmark = group.type == CampusMapType.fullUniversity ||
        group.type == CampusMapType.building;
    final borderColor = isPrimaryLandmark
        ? (isDark
            ? AppTheme.gold.withValues(alpha: 0.45)
            : AppTheme.gold.withValues(alpha: 0.55))
        : AppTheme.getBorder(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: isPrimaryLandmark ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (group.type == CampusMapType.building &&
                group.id == 'engineering_b4') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EngineeringBuilding4Screen(),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FacultyEmptyMapScreen(
                    title: group.viewerTitle,
                    emptyMessage: group.emptyMessage,
                    imageAssets: group.imageAssets,
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Leading Icon Container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1B3248)
                        : AppTheme.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    group.icon,
                    size: 28,
                    color: isDark
                        ? const Color(0xFF90CAF9)
                        : AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 16),

                // Title, Subtitle, and Availability Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textMain,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        group.subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: textSub,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Responsive Badge
                      _buildAvailabilityBadge(context, group),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Trailing Action Arrow
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppTheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge(BuildContext context, CampusMapGroup group) {
    final isDark = AppTheme.isDark(context);

    if (group.isAvailable && group.hasMaps) {
      // Available Maps Badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF132F2B) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? const Color(0xFF2E7D32) : const Color(0xFFA5D6A7),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 13,
              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${group.mapsCount} خرائط متاحة',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty / Pending Badge
    final isFullUniversity = group.type == CampusMapType.fullUniversity;
    final badgeLabel = isFullUniversity
        ? 'لم تتم إضافة الخريطة الكاملة بعد'
        : 'لم تتم إضافة الخرائط بعد';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              badgeLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
