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

class UniversityDepartmentsScreen extends StatelessWidget {
  const UniversityDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final depts = UniversityServicesRepository.departments;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9FC),
        body: SafeArea(
          child: Column(
            children: [
              UniversityServicesHeader(
                title: 'الجهات والإدارات الجامعية',
                subtitle: 'دليل شامل للجهات الإدارية وخدماتها وآليات التواصل',
                showBackButton: true,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  itemCount: depts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final dept = depts[index];

                    return Container(
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF4FB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(dept.icon, color: _blue, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dept.name,
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _navy,
                                      ),
                                    ),
                                    Text(
                                      '${dept.services.length} خدمات معتمدة',
                                      style: GoogleFonts.cairo(fontSize: 11.5, color: _blue, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            dept.description,
                            style: GoogleFonts.cairo(fontSize: 12.5, color: _textSub, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFEDF2F7)),
                          const SizedBox(height: 8),
                          Text(
                            'الخدمات المتاحة:',
                            style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: _navy),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: dept.services.map((srv) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F9FC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _border),
                                ),
                                child: Text(
                                  srv,
                                  style: GoogleFonts.cairo(fontSize: 11, color: _textMain),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NewInquiryScreen(
                                      initialType: dept.name,
                                      initialSubject: 'استفسار موجه إلى ${dept.name}',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.outgoing_mail, size: 16, color: _blue),
                              label: Text(
                                'إرسال استفسار لهذه الإدارة',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _blue,
                                ),
                              ),
                            ),
                          ),
                        ],
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
