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
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);

class DoctorAssignmentsScreen extends StatefulWidget {
  final String? initialCourseId;
  final bool openNewAssignmentOnLaunch;

  const DoctorAssignmentsScreen({
    super.key,
    this.initialCourseId,
    this.openNewAssignmentOnLaunch = false,
  });

  @override
  State<DoctorAssignmentsScreen> createState() =>
      _DoctorAssignmentsScreenState();
}

class _DoctorAssignmentsScreenState extends State<DoctorAssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openNewAssignmentOnLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openNewAssignmentSheet();
      });
    }
  }

  void _openNewAssignmentSheet() {
    String courseName = 'معالج دقيق';
    final titleCtrl = TextEditingController();
    final deadlineCtrl = TextEditingController(text: '2026-09-15');

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
                  'تكليف دراسي جديد',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: courseName,
                  decoration: InputDecoration(
                    labelText: 'المقرر',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'معالج دقيق', child: Text('معالج دقيق')),
                    DropdownMenuItem(
                        value: 'الاحتمالات والإشارات العشوائية',
                        child: Text('الاحتمالات والإشارات العشوائية')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => courseName = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'عنوان التكليف',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deadlineCtrl,
                  decoration: InputDecoration(
                    labelText: 'موعد التسليم النهائي',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final assign = DoctorAssignment(
                        id: 'assign-${DateTime.now().millisecondsSinceEpoch}',
                        courseId: courseName == 'معالج دقيق'
                            ? 'doctor-course-001'
                            : 'doctor-course-002',
                        courseName: courseName,
                        title: titleCtrl.text.trim(),
                        deadline: deadlineCtrl.text.trim(),
                        submittedCount: 0,
                        totalCount: 40,
                        status: 'نشط',
                      );
                      DoctorDemoData.addAssignment(assign);
                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم نشر التكليف بنجاح لجميع الطلاب',
                              style: GoogleFonts.cairo()),
                          backgroundColor: _navy,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: _white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('حفظ ونشر التكليف',
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
    deadlineCtrl.dispose();
  });
  }

  @override
  Widget build(BuildContext context) {
    final assignments = DoctorDemoData.assignments;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) DoctorBackButton.safePop(context);
      },
      child: Scaffold(
        backgroundColor: _lightBg,
        appBar: const DoctorPageHeader(
          title: 'التكليفات والواجبات',
          subtitle: 'متابعة تسليمات ونشاطات الطلاب',
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
                    'التكليفات الأكاديمية (${assignments.length})',
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
                  onPressed: _openNewAssignmentSheet,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('تكليف جديد',
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
            ...assignments.map((a) {
              final percent = a.totalCount > 0
                  ? (a.submittedCount / a.totalCount)
                  : 0.0;

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
                            a.title,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _textMain,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDFAF1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            a.status,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E9B5F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'المقرر: ${a.courseName}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: _textSub,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.alarm_rounded,
                            size: 15, color: _blue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'موعد التسليم: ${a.deadline}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'التسليمات: ${a.submittedCount} / ${a.totalCount}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: _lightBg,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(_blue),
                        minHeight: 6,
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
