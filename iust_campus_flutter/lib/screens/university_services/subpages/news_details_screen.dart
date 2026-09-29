import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_services_demo_data.dart';
import '../widgets/university_services_header.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class NewsDetailsScreen extends StatelessWidget {
  final UniversityNewsItem newsItem;

  const NewsDetailsScreen({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityServicesHeader(
                title: newsItem.category,
                subtitle: newsItem.date,
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    // News Hero Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF4FB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  newsItem.category,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _blue,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.calendar_today_rounded, size: 14, color: _textSub),
                              const SizedBox(width: 4),
                              Text(
                                newsItem.date,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: _textSub,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            newsItem.title,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textMain,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFEDF2F7)),
                          const SizedBox(height: 12),
                          Text(
                            newsItem.fullContent,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: _textMain,
                              height: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Additional notes / Share card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBCE0F7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: _blue, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'للمزيد من التفاصيل أو الاستفسار عن هذا الإعلان، يمكنك إرسال استفسار مباشر إلى الإدارة المختصة.',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: _navy,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
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
