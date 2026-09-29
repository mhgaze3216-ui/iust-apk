import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/doctor_demo_data.dart';
import '../../models/doctor_models.dart';
import 'widgets/doctor_page_header.dart';
import 'widgets/doctor_back_button.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _border = Color(0xFFDCE8EE);

class DoctorAnnouncementsScreen extends StatefulWidget {
  final bool openNewAnnouncementOnLaunch;

  const DoctorAnnouncementsScreen({
    super.key,
    this.openNewAnnouncementOnLaunch = false,
  });

  @override
  State<DoctorAnnouncementsScreen> createState() =>
      _DoctorAnnouncementsScreenState();
}

class _DoctorAnnouncementsScreenState extends State<DoctorAnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openNewAnnouncementOnLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openNewAnnouncementSheet();
      });
    }
  }

  void _openNewAnnouncementSheet() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    String targetCourse = 'معالج دقيق';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
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
                Text(
                  'إعلان جديد للشعب المسندة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: targetCourse,
                  decoration: InputDecoration(
                    labelText: 'المقرر المستهدف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'معالج دقيق',
                      child: Text('معالج دقيق (الشعبة 1)'),
                    ),
                    DropdownMenuItem(
                      value: 'الاحتمالات والإشارات العشوائية',
                      child: Text('الاحتمالات والإشارات (الشعبة 2)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => targetCourse = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'عنوان الإعلان',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'نص الإعلان أو التنبيه',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isNotEmpty) {
                        DoctorDemoData.addAnnouncement(
                          DoctorAnnouncement(
                            id: 'ann-${DateTime.now().millisecondsSinceEpoch}',
                            doctorId: 'doctor-001',
                            courseId: targetCourse == 'معالج دقيق'
                                ? 'doctor-course-001'
                                : 'doctor-course-002',
                            title: titleCtrl.text.trim(),
                            content: bodyCtrl.text.trim(),
                            createdAt: DateTime.now(),
                            status: 'منشور',
                          ),
                        );
                        Navigator.pop(ctx);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم نشر الإعلان بنجاح',
                                style: GoogleFonts.cairo()),
                            backgroundColor: _navy,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: _white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('نشر الإعلان الآن',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ).then((_) {
    titleCtrl.dispose();
    bodyCtrl.dispose();
  });
}

  @override
  Widget build(BuildContext context) {
    final announcements = DoctorDemoData.announcements;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: const DoctorPageHeader(
          title: 'إعلانات المقررات',
          subtitle: 'نشر تنبيه أو تعليمات أكاديمية للطلاب',
          showBackButton: true,
        ),
        body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'الإعلانات النشطة (${announcements.length})',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textMain,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _openNewAnnouncementSheet,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('إعلان جديد',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: _white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...announcements.map((ann) {
              final isPublished = ann.status == 'منشور';
              final courseName = ann.courseId == 'doctor-course-001'
                  ? 'معالج دقيق'
                  : (ann.courseId == 'doctor-course-002'
                      ? 'الاحتمالات والإشارات العشوائية'
                      : 'إعلان عام');

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _white,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ann.title,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isPublished
                                ? const Color(0xFFEDFAF1)
                                : const Color(0xFFFDF2E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ann.status,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isPublished
                                  ? const Color(0xFF2E9B5F)
                                  : const Color(0xFFE67E22),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المقرر: $courseName',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ann.content,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: _textMain,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );
  }
}
