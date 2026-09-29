import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/doctor_archive_repository.dart';
import '../../models/doctor_models.dart';
import 'doctor_document_preview_screen.dart';
import 'doctor_exam_instructions_screen.dart';
import 'doctor_final_exam_template_screen.dart';
import 'doctor_final_schedule_screen.dart';
import 'doctor_midterm_schedule_screen.dart';
import 'doctor_midterm_template_screen.dart';
import 'widgets/doctor_page_header.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorExamCenterScreen extends StatelessWidget {
  const DoctorExamCenterScreen({super.key});

  void _openArchiveModal(BuildContext context) {
    final archiveItems = DoctorArchiveRepository.examArchiveItems;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.archive_outlined,
                        color: _navy, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أرشيف نماذج الامتحانات',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textMain,
                          ),
                        ),
                        Text(
                          'نماذج الفصول السابقة والدورات المعتمدة (بيانات وصفية خفيفة)',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            color: _textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: _textSub),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: archiveItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _buildArchiveCard(context, archiveItems[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildArchiveCard(
    BuildContext context,
    DoctorArchiveItem item,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.courseName} · ${item.documentType}',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: item.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.semester} · ${item.date}',
            style: GoogleFonts.cairo(fontSize: 11.5, color: _textSub),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DoctorDocumentPreviewScreen(
                        documentItem: item,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.folder_open_rounded, size: 16),
                label: Text('فتح',
                    style: GoogleFonts.cairo(
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم نسخ النموذج للأرشيف المحلي',
                          style: GoogleFonts.cairo()),
                      backgroundColor: _navy,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text('نسخ',
                    style: GoogleFonts.cairo(
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: const DoctorPageHeader(
          title: 'مركز الامتحانات',
          subtitle: 'الخدمات والنماذج والجداول الامتحانية المعتمدة',
          showBackButton: true,
        ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          children: [
            _buildHeroBanner(),
            const SizedBox(height: 18),
            Text(
              'الخدمات والنماذج الامتحانية',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            const SizedBox(height: 12),
            _buildCenterCard(
              context,
              title: 'نموذج الامتحان النصفي',
              subtitle: 'معاينة وتعديل ورقة أسئلة الامتحان النصفي (معالج دقيق)',
              icon: Icons.description_outlined,
              iconColor: _blue,
              iconBg: const Color(0xFFEAF4FB),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DoctorMidtermTemplateScreen(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildCenterCard(
              context,
              title: 'نموذج الامتحان النهائي',
              subtitle:
                  'إعداد وتدقيق نموذج الامتحان النهائي والسلالم (احتمالات)',
              icon: Icons.assignment_turned_in_outlined,
              iconColor: const Color(0xFF2E9B5F),
              iconBg: const Color(0xFFEDFAF1),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DoctorFinalExamTemplateScreen(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildCenterCard(
              context,
              title: 'برنامج الامتحان النصفي',
              subtitle: 'جدول مواعيد وقاعات الامتحانات النصفية للمقررات المسندة',
              icon: Icons.event_note_outlined,
              iconColor: const Color(0xFF8E44AD),
              iconBg: const Color(0xFFF4ECF7),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DoctorMidtermScheduleScreen(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildCenterCard(
              context,
              title: 'برنامج الامتحان النهائي',
              subtitle: 'جدول مواعيد وقاعات الامتحانات النهائية الرسمية',
              icon: Icons.calendar_month_outlined,
              iconColor: const Color(0xFFE67E22),
              iconBg: const Color(0xFFFDF2E9),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DoctorFinalScheduleScreen(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildCenterCard(
              context,
              title: 'تعليمات الامتحانات',
              subtitle: 'الضوابط الأكاديمية قبل وأثناء وبعد الامتحان والاعتراضات',
              icon: Icons.gavel_rounded,
              iconColor: _navy,
              iconBg: const Color(0xFFE8F0F2),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DoctorExamInstructionsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildCenterCard(
              context,
              title: 'أرشيف النماذج',
              subtitle: 'استعراض النماذج والدورات الامتحانية السابقة وإعادة استخدامها',
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFF475569),
              iconBg: const Color(0xFFF1F5F9),
              onTap: () => _openArchiveModal(context),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.school_rounded, color: _navy, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مركز الامتحانات الأكاديمي',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
                Text(
                  'إدارة النماذج والسلالم وبرامج المراقبة والتعليمات الرسمية',
                  style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textMain,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: _textSub,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: _textSub),
            ],
          ),
        ),
      ),
    );
  }
}
