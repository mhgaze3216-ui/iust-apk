import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/university_services_demo_data.dart';
import '../widgets/university_services_header.dart';
import 'new_inquiry_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class TransactionDetailsScreen extends StatelessWidget {
  final UniversityTransaction transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

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
                title: transaction.title,
                subtitle: transaction.department,
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    // Header Overview Card
                    Container(
                      padding: const EdgeInsets.all(18),
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF4FB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(transaction.icon, color: _blue, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction.title,
                                      style: GoogleFonts.cairo(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: _textMain,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'الجهة المسؤولة: ${transaction.department}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: _textSub,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            transaction.description,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: _textMain,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetaPill(
                                  Icons.timer_outlined,
                                  'المدة المتوقعة',
                                  transaction.expectedDuration,
                                  const Color(0xFF0F6CBD),
                                  const Color(0xFFEAF4FB),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildMetaPill(
                                  Icons.payments_outlined,
                                  'الرسوم المقررة',
                                  transaction.fees,
                                  const Color(0xFF16A34A),
                                  const Color(0xFFEDFAF1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Requirements Card
                    _buildSectionCard(
                      title: 'المتطلبات والشروط',
                      icon: Icons.checklist_rounded,
                      children: transaction.requirements.map((req) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  req,
                                  style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Required Documents Card
                    _buildSectionCard(
                      title: 'الوثائق المطلوبة',
                      icon: Icons.folder_open_rounded,
                      children: transaction.documents.map((doc) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.attach_file_rounded, color: _blue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  doc,
                                  style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Procedure Steps Card
                    _buildSectionCard(
                      title: 'خطوات الإجراء',
                      icon: Icons.format_list_numbered_rounded,
                      children: List.generate(transaction.steps.length, (idx) {
                        final step = transaction.steps[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _navy,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${idx + 1}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  step,
                                  style: GoogleFonts.cairo(fontSize: 13, color: _textMain, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Start Request Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewInquiryScreen(
                              initialType: transaction.department,
                              initialSubject: 'طلب: ${transaction.title}',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      label: Text(
                        'بدء الطلب الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
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

  Widget _buildMetaPill(IconData icon, String label, String value, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.cairo(fontSize: 11, color: _textSub),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _textMain,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFEDF2F7)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
