import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _navy = Color(0xFF073B4C);
const _lightBg = Color(0xFFF6F9FC);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);
const _gold = Color(0xFFF5B82E);

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            color: _navy,
            tooltip: 'رجوع',
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).maybePop();
              }
            },
          ),
          title: Text(
            'عن التطبيق',
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: _border, height: 1),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _border, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: _navy.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/img/logo iust.webp',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.school_rounded,
                          color: _navy,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'IUST Campus Guide',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المنصة الرقمية الذكية لجامعة القلمون الدولية الخاصة',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _textSub,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'الإصدار v1.0.0 (2026)',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB78103),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نبذة عن المنصة',
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تطبيق IUST Campus Guide هو بيئة جامعية رقمية متكاملة تهدف إلى تيسير الوصول للخدمات الأكاديمية وجداول المحاضرات والنقل الجامعي وإدارة المقررات للطلاب وأعضاء الهيئة التدريسية على حد سواء بكل يسر وموثوقية.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: const Color(0xFF334155),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('الجهة المطورة', 'فريق هندسة البرمجيات والأنظمة'),
                    const Divider(height: 16, color: _border),
                    _buildInfoRow('الجامعة', 'جامعة القلمون الدولية الخاصة (IUST)'),
                    const Divider(height: 16, color: _border),
                    _buildInfoRow('حقوق النشر', '© 2026 جميع الحقوق محفوظة'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12.5, color: _textSub),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: _textMain,
          ),
        ),
      ],
    );
  }
}
