import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'department_map_viewer_screen.dart';

/// Reusable screen displaying maps or a clean empty state for faculties and university maps.
/// If [imageAssets] is empty, displays the clean empty state.
/// If [imageAssets] has images in the future, automatically renders the map viewer without redesigning.
class FacultyEmptyMapScreen extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final String? emptyDescription;
  final List<String> imageAssets;

  const FacultyEmptyMapScreen({
    super.key,
    required this.title,
    this.emptyMessage = 'لم تتم إضافة الخرائط بعد',
    this.emptyDescription,
    this.imageAssets = const [],
  });

  @override
  Widget build(BuildContext context) {
    // If real image assets exist in the future, seamlessly display via the existing map viewer
    if (imageAssets.isNotEmpty) {
      if (imageAssets.length == 1) {
        return DepartmentMapViewerScreen(
          title: title,
          imagePath: imageAssets.first,
        );
      }
      return _buildMultipleMapsView(context);
    }

    final bg = AppTheme.getBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final textMain = AppTheme.getTextMain(context);
    final textSub = AppTheme.getTextSub(context);
    final border = AppTheme.getBorder(context);
    final isDark = AppTheme.isDark(context);

    final defaultDesc = emptyMessage == 'لم تتم إضافة الخريطة الكاملة بعد'
        ? 'لم يتم اعتماد المخطط العام الكامل للجامعة في النظام بعد. سيتم توفيره فور اعتماده رسمياً.'
        : 'لم يتم اعتماد المخططات والخرائط التفصيلية لهذه الكلية في النظام بعد. سيتم توفيرها فور اعتمادها رسمياً من الجامعة.';

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
            title,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textMain,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF142B3E)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: isDark ? const Color(0xFF64B5F6) : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      emptyMessage,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textMain,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      emptyDescription ?? defaultDesc,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: textSub,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(
                        'العودة لقائمة الخرائط',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textMain,
                        side: BorderSide(color: border),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleMapsView(BuildContext context) {
    final bg = AppTheme.getBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final textMain = AppTheme.getTextMain(context);
    final textSub = AppTheme.getTextSub(context);
    final border = AppTheme.getBorder(context);

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
            title,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textMain,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: imageAssets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final mapPath = imageAssets[index];
              return Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const Icon(Icons.map_rounded, color: AppTheme.primary),
                  title: Text(
                    'خريطة ${index + 1}',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textMain,
                    ),
                  ),
                  subtitle: Text(
                    mapPath,
                    style: GoogleFonts.cairo(fontSize: 12, color: textSub),
                  ),
                  trailing: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DepartmentMapViewerScreen(
                          title: '$title - خريطة ${index + 1}',
                          imagePath: mapPath,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
