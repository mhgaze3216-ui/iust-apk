import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _navy     = Color(0xFF073B4C);
const _blue     = Color(0xFF0d6efd);
const _lightBg  = Color(0xFFF4F7FE);
const _white    = Colors.white;
const _textDark = Color(0xFF0a2540);
const _textMute = Color(0xFF64748B);
const _border   = Color(0xFFE2E8F4);

class PharmacyFacultyScreen extends StatelessWidget {
  const PharmacyFacultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: _navy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/img/pharmaceutics.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => Container(
                  decoration: const BoxDecoration(color: _navy),
                  child: const Icon(Icons.local_pharmacy_rounded,
                      color: _white, size: 60),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('كلية الصيدلة',
                        style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _textDark)),
                    const SizedBox(height: 2),
                    Text('Faculty of Pharmacy',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _textMute)),
                    const SizedBox(height: 16),
                    _BodyCard(
                      'تركز الكلية على إعداد الصيادلة والباحثين من خلال '
                      'دراسة العلوم الطبية الحيوية والدوائية والسريرية، '
                      'مع وجود جانب عملي وبحثي واضح.',
                    ),
                    _SectionTitle('الأقسام'),
                    _BulletCard(items: const [
                      'العلوم البيولوجية والطبية',
                      'علم الأدوية والسموم',
                      'الكيمياء والكيمياء التحليلية',
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── shared widgets ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Row(children: [
          Container(
              width: 4, height: 20,
              decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(text,
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textDark)),
        ]),
      );
}

class _BodyCard extends StatelessWidget {
  const _BodyCard(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Text(text,
            style: GoogleFonts.cairo(
                fontSize: 14, color: _textMute, height: 1.7)),
      );
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({required this.items});
  final List<String> items;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                            padding: EdgeInsets.only(top: 7),
                            child: Icon(Icons.circle,
                                size: 7, color: _blue)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(e,
                                style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: _textMute,
                                    height: 1.6))),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
}
