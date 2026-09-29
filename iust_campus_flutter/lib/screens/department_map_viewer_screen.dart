import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Screen displaying a dedicated single department map with InteractiveViewer.
class DepartmentMapViewerScreen extends StatefulWidget {
  final String title;
  final String imagePath;

  const DepartmentMapViewerScreen({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  State<DepartmentMapViewerScreen> createState() =>
      _DepartmentMapViewerScreenState();
}

class _DepartmentMapViewerScreenState extends State<DepartmentMapViewerScreen> {
  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.getBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final textMain = AppTheme.getTextMain(context);
    final textSub = AppTheme.getTextSub(context);
    final isDark = AppTheme.isDark(context);

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
            widget.title,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textMain,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'إعادة ضبط التكبير',
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: _resetZoom,
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Main InteractiveViewer displaying the single map image
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 6.0,
                  clipBehavior: Clip.none,
                  child: Center(
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.broken_image_rounded,
                                size: 48,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'تعذر تحميل الخريطة',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.imagePath,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: textSub,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Bottom hint overlay
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.darkSurface : AppTheme.darkBlue)
                          .withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pinch_rounded,
                          size: 14,
                          color: AppTheme.gold,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'قرّب بأصبعين للتكبير وتفقد القاعات والمخابر',
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
