import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);

class AdminWeeklyChart extends StatelessWidget {
  final List<({String day, double percentage})> data;

  const AdminWeeklyChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const double maxBarHeight = 96.0;
    const double percentLabelHeight = 16.0;
    const double dayLabelHeight = 22.0;
    const double topGap = 6.0;
    const double bottomGap = 8.0;
    const double safetyPadding = 10.0;

    // Total height for bars area: explicitly sized to fit all labels + bars + safety margin
    const double totalBarsAreaHeight =
        percentLabelHeight + topGap + maxBarHeight + bottomGap + dayLabelHeight + safetyPadding;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY ACTIVITY',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: _textSub,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'نشاط المنصة',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textMain,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDFAF1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E9B5F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'معدل نشط',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E9B5F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bars row
          SizedBox(
            height: totalBarsAreaHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final barHeight = (item.percentage / 100.0) * maxBarHeight;
                final isPeak = item.percentage >= 90.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: percentLabelHeight,
                          child: Center(
                            child: Text(
                              '${item.percentage.toInt()}%',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isPeak ? _blue : _textSub,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: topGap),
                        SizedBox(
                          height: maxBarHeight,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: barHeight,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isPeak ? _navy : _blue.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isPeak
                                      ? [const Color(0xFF073B4C), const Color(0xFF0F6CBD)]
                                      : [const Color(0xFF0F6CBD), const Color(0xFF5BA4E6)],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: bottomGap),
                        SizedBox(
                          height: dayLabelHeight,
                          child: Center(
                            child: Text(
                              item.day,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _textMain,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: safetyPadding),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
