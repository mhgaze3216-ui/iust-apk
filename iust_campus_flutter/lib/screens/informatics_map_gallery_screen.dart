import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/campus_map_data.dart';
import '../theme/app_theme.dart';

/// Screen displaying the 4 floor map images for the Informatics building.
class InformaticsMapGalleryScreen extends StatefulWidget {
  final int initialIndex;

  const InformaticsMapGalleryScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<InformaticsMapGalleryScreen> createState() =>
      _InformaticsMapGalleryScreenState();
}

class _InformaticsMapGalleryScreenState
    extends State<InformaticsMapGalleryScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  static const List<String> _mapLabels = [
    'الخريطة 0',
    'الخريطة 1',
    'الخريطة 2',
    'الخريطة 3',
  ];

  final List<TransformationController> _transformControllers = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
    _pageController = PageController(initialPage: _currentIndex);
    for (int i = 0; i < 4; i++) {
      _transformControllers.add(TransformationController());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _transformControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _jumpToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _resetCurrentZoom() {
    _transformControllers[_currentIndex].value = Matrix4.identity();
  }

  void _openFullScreen(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenMapViewer(
          initialIndex: index,
          mapImages: CampusMapData.informaticsMapImages,
          mapLabels: _mapLabels,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final bg = AppTheme.getBg(context);
    final cardBg = AppTheme.getCardBg(context);
    final textMain = AppTheme.getTextMain(context);
    final textSub = AppTheme.getTextSub(context);
    final border = AppTheme.getBorder(context);

    final mapImages = CampusMapData.informaticsMapImages;

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
            'خرائط كلية الهندسة المعلوماتية',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textMain,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'ملء الشاشة',
              icon: const Icon(Icons.fullscreen_rounded),
              onPressed: () => _openFullScreen(_currentIndex),
            ),
            IconButton(
              tooltip: 'إعادة ضبط التكبير',
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: _resetCurrentZoom,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Selector Bar (chips for الخريطة 0, الخريطة 1, الخريطة 2, الخريطة 3)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border(bottom: BorderSide(color: border)),
                ),
                child: Row(
                  children: List.generate(_mapLabels.length, (i) {
                    final isSelected = i == _currentIndex;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () => _jumpToPage(i),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppTheme.primary : AppTheme.darkBlue)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.gold
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _mapLabels[i],
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : textSub,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Sub-header info / hint banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isDark
                    ? const Color(0xFF0D2536)
                    : const Color(0xFFEAF4FB),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_outlined,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'اسحب للتنقل بين الخرائط · قرّب بأصبعين للتكبير والتنقل · اضغط لملء الشاشة',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF90CAF9)
                              : AppTheme.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${mapImages.length}',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Swipeable Map Area
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: mapImages.length,
                  itemBuilder: (context, index) {
                    final imagePath = mapImages[index];
                    final transformController = _transformControllers[index];

                    return GestureDetector(
                      onTap: () => _openFullScreen(index),
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.3 : 0.05,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Interactive Viewer around the image
                            Positioned.fill(
                              child: InteractiveViewer(
                                transformationController: transformController,
                                minScale: 1.0,
                                maxScale: 5.0,
                                clipBehavior: Clip.none,
                                child: Center(
                                  child: Image.asset(
                                    imagePath,
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
                                            Text(
                                              imagePath,
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

                            // Map Title badge on bottom
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? AppTheme.darkSurface
                                          : AppTheme.darkBlue)
                                      .withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.map_rounded,
                                      size: 14,
                                      color: AppTheme.gold,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _mapLabels[index],
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Expand icon badge on bottom left
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isDark
                                          ? AppTheme.darkSurface
                                          : AppTheme.darkBlue)
                                      .withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white24,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.fullscreen_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Indicator Row (dots + quick controls)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18),
                      tooltip: 'الخريطة السابقة',
                      onPressed: _currentIndex > 0
                          ? () => _jumpToPage(_currentIndex - 1)
                          : null,
                    ),

                    // Dot Indicators
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(mapImages.length, (i) {
                        final active = i == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? AppTheme.gold
                                : border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Next button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18),
                      tooltip: 'الخريطة التالية',
                      onPressed: _currentIndex < mapImages.length - 1
                          ? () => _jumpToPage(_currentIndex + 1)
                          : null,
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

/// Full screen interactive zoom/pan map viewer
class FullScreenMapViewer extends StatefulWidget {
  final int initialIndex;
  final List<String> mapImages;
  final List<String> mapLabels;

  const FullScreenMapViewer({
    super.key,
    required this.initialIndex,
    required this.mapImages,
    required this.mapLabels,
  });

  @override
  State<FullScreenMapViewer> createState() => _FullScreenMapViewerState();
}

class _FullScreenMapViewerState extends State<FullScreenMapViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  final List<TransformationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    for (int i = 0; i < widget.mapImages.length; i++) {
      _controllers.add(TransformationController());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _resetZoom() {
    _controllers[_currentIndex].value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            widget.mapLabels[_currentIndex],
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'إعادة ضبط',
              icon: const Icon(Icons.restart_alt_rounded, color: Colors.white),
              onPressed: _resetZoom,
            ),
          ],
        ),
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: widget.mapImages.length,
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    transformationController: _controllers[index],
                    minScale: 1.0,
                    maxScale: 8.0,
                    child: Image.asset(
                      widget.mapImages[index],
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                );
              },
            ),

            // Bottom indicator bar
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_currentIndex + 1} / ${widget.mapImages.length} · ',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        widget.mapLabels[_currentIndex],
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gold,
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
    );
  }
}
