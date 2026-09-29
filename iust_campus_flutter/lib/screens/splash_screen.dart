import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ─────────────────────────── palette ────────────────────────────────────
  static const Color _bgTop    = Color(0xFF071428);
  static const Color _bgMid    = Color(0xFF0a2540);
  static const Color _bgEnd    = Color(0xFF0d3d7a);
  static const Color _gold     = Color(0xFFc9a84c);
  static const Color _white    = Colors.white;

  // ─────────────────────────── controllers ────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _lettersCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _exitCtrl;

  // logo
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  // letters  (I U S T)
  final _ltFade  = <Animation<double>>[];
  final _ltSlide = <Animation<Offset>>[];

  // gold underline
  late final Animation<double> _lineW;

  // tagline "Welcome to IUST"
  late final Animation<double> _tagFade;
  late final Animation<double> _tagShift;

  // ─────────────────────────── init ───────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _build();
    _play();
  }

  void _build() {
    // Logo – 700 ms
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _logoFade  = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.70, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    // Letters – 1 400 ms total, 4 × 300 ms windows staggered 250 ms apart
    _lettersCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    const double win  = 300 / 1400;
    const double step = 250 / 1400;
    for (int i = 0; i < 4; i++) {
      final s = (step * i).clamp(0.0, 1.0);
      final e = (s + win).clamp(0.0, 1.0);
      final iv = Interval(s, e, curve: Curves.easeOut);
      _ltFade.add(Tween<double>(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(parent: _lettersCtrl, curve: iv)));
      _ltSlide.add(Tween<Offset>(
              begin: const Offset(0, 0.55), end: Offset.zero)
          .animate(CurvedAnimation(parent: _lettersCtrl, curve: iv)));
    }
    _lineW = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _lettersCtrl,
            curve: const Interval(0.1, 1.0, curve: Curves.easeOut)));

    // Tagline – 600 ms
    _taglineCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _tagFade  = CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn);
    _tagShift = Tween<double>(begin: 14.0, end: 0.0).animate(
        CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut));

    // Exit fade – 450 ms
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
  }

  Future<void> _play() async {
    await Future.delayed(const Duration(milliseconds: 250));
    await _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 120));
    await _lettersCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 180));
    await _taglineCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 900));
    await _exitCtrl.forward();

    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _lettersCtrl.dispose();
    _taglineCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────── build ──────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _exitCtrl,
        builder: (_, child) =>
            Opacity(opacity: 1.0 - _exitCtrl.value, child: child),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bgTop, _bgMid, _bgEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // subtle radial glow
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 110),
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF1565C0).withValues(alpha: 0.40),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── centred content (Logo + Text as ONE visual group) ─────────
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 110),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo (305x305, ~22% larger, original colors, centered)
                      AnimatedBuilder(
                        animation: _logoCtrl,
                        builder: (_, _) => Opacity(
                          opacity: _logoFade.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Image.asset(
                              'assets/img/IUST-logo.png',
                              width: 305,
                              height: 305,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                    // IUST letters + underline
                    AnimatedBuilder(
                      animation: _lettersCtrl,
                      builder: (_, _) => Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(4, (i) {
                              const chars = ['I', 'U', 'S', 'T'];
                              return FadeTransition(
                                opacity: _ltFade[i],
                                child: SlideTransition(
                                  position: _ltSlide[i],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Text(
                                      chars[i],
                                      style: GoogleFonts.cairo(
                                        fontSize: 58,
                                        fontWeight: FontWeight.w800,
                                        color: _white,
                                        letterSpacing: 6,
                                        shadows: [
                                          Shadow(
                                            color: _gold.withValues(alpha: 0.45),
                                            blurRadius: 22,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 10),

                          // expanding gold underline
                          SizedBox(
                            width: 170,
                            height: 2.5,
                            child: FractionallySizedBox(
                              widthFactor: _lineW.value,
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      _gold,
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // "Welcome to IUST"
                    AnimatedBuilder(
                      animation: _taglineCtrl,
                      builder: (_, _) => Opacity(
                        opacity: _tagFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _tagShift.value),
                          child: Column(
                            children: [
                              Text(
                                'Welcome to IUST',
                                style: GoogleFonts.cairo(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w300,
                                  color: _white.withValues(alpha: 0.88),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 36,
                                height: 1,
                                color: _gold.withValues(alpha: 0.65),
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

              // bottom label
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _taglineCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _tagFade.value * 0.55,
                    child: Text(
                      'الجامعة الدولية الخاصة للعلوم والتكنولوجيا',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: _white.withValues(alpha: 0.7),
                        letterSpacing: 0.4,
                      ),
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
