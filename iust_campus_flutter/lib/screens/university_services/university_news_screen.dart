import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/university_services_demo_data.dart';
import 'widgets/university_services_header.dart';
import 'subpages/news_details_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class UniversityNewsScreen extends StatelessWidget {
  final bool showBackButton;

  const UniversityNewsScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final list = UniversityServicesRepository.news;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityServicesHeader(
                title: 'أخبار الجامعة والإعلانات',
                showBackButton: showBackButton || Navigator.canPop(context),
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = list[index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewsDetailsScreen(newsItem: item),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF4FB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: _blue,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.calendar_today_rounded, size: 13, color: _textSub),
                                const SizedBox(width: 4),
                                Text(
                                  item.date,
                                  style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F9FC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _border),
                                  ),
                                  child: Icon(item.icon, color: _navy, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _navy,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: _textSub,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'قراءة المزيد',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _blue,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_back_ios_new_rounded, size: 11, color: _blue),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
