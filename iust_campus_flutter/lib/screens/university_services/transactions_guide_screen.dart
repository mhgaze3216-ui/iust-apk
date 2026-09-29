import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/university_services_demo_data.dart';
import 'widgets/university_services_header.dart';
import 'subpages/transaction_details_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class TransactionsGuideScreen extends StatelessWidget {
  final bool showBackButton;

  const TransactionsGuideScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final list = UniversityServicesRepository.transactions;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityServicesHeader(
                title: 'دليل المعاملات',
                showBackButton: showBackButton || Navigator.canPop(context),
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final trn = list[index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionDetailsScreen(transaction: trn),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Right (leading in RTL): transaction icon
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF4FB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(trn.icon, color: _blue, size: 22),
                            ),
                            const SizedBox(width: 12),

                            // Center / main area: title, description, category chip, bottom row
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title (wraps properly, no overflow)
                                  Text(
                                    trn.title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: _navy,
                                      height: 1.3,
                                    ),
                                    softWrap: true,
                                  ),
                                  const SizedBox(height: 4),

                                  // Short description (wraps naturally)
                                  Text(
                                    trn.description,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.5,
                                      color: _textSub,
                                      height: 1.4,
                                    ),
                                    softWrap: true,
                                  ),
                                  const SizedBox(height: 6),

                                  // Category chip
                                  Wrap(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          trn.department,
                                          style: GoogleFonts.cairo(
                                            fontSize: 10.5,
                                            color: _textSub,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Responsive bottom row: duration + details button (wraps without overflow)
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 12,
                                    runSpacing: 6,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.schedule_rounded,
                                            size: 13,
                                            color: _blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            trn.expectedDuration,
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              color: _navy,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'عرض التفاصيل والشروط',
                                            style: GoogleFonts.cairo(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: _blue,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.arrow_back_ios_new_rounded,
                                            size: 11,
                                            color: _blue,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
