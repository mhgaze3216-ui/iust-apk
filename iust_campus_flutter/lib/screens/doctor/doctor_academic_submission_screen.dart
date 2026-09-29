import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/doctor_demo_data.dart';
import '../../models/doctor_models.dart';
import 'widgets/doctor_back_button.dart';
import 'doctor_document_preview_screen.dart';

const _navy = Color(0xFF073B4C);
const _blue = Color(0xFF0F6CBD);
const _lightBg = Color(0xFFF8F9FA);
const _white = Colors.white;
const _textMain = Color(0xFF0B2E3B);
const _textSub = Color(0xFF6F7F89);
const _border = Color(0xFFDCE8EE);
const _gold = Color(0xFFF5B82E);

class DoctorAcademicSubmissionScreen extends StatefulWidget {
  const DoctorAcademicSubmissionScreen({super.key});

  @override
  State<DoctorAcademicSubmissionScreen> createState() =>
      _DoctorAcademicSubmissionScreenState();
}

class _DoctorAcademicSubmissionScreenState
    extends State<DoctorAcademicSubmissionScreen> {
  String _selectedFilter = 'الكل';
  late List<AcademicSubmission> _filteredSubmissions;

  final List<String> _filters = [
    'الكل',
    'مسودة',
    'تم الإرسال',
    'تم الاعتماد',
    'بحاجة إلى تعديل',
  ];

  @override
  void initState() {
    super.initState();
    _updateFilteredSubmissions();
  }

  void _updateFilteredSubmissions() {
    final submissions = DoctorDemoData.submissions;
    _filteredSubmissions = submissions.where((s) {
      if (_selectedFilter == 'الكل') return true;
      if (_selectedFilter == 'مسودة') {
        return s.status == AcademicSubmissionStatus.draft;
      }
      if (_selectedFilter == 'تم الإرسال') {
        return s.status == AcademicSubmissionStatus.submitted;
      }
      if (_selectedFilter == 'تم الاعتماد') {
        return s.status == AcademicSubmissionStatus.approved;
      }
      if (_selectedFilter == 'بحاجة إلى تعديل') {
        return s.status == AcademicSubmissionStatus.needsRevision;
      }
      return true;
    }).toList(growable: false);
  }

  static const List<String> submissionTypes = [
    'علامات الامتحان النصفي',
    'علامات الامتحان النهائي',
    'العلامات النهائية للمقرر',
    'علامات العملي',
    'سجل الحضور',
    'قوائم الحرمان',
    'علامات غير المكتمل',
    'نتائج الاعتراضات',
    'كشف علامات الشعبة',
    'محضر اعتماد النتائج',
  ];

  void _openNewSubmissionSheet() {
    String selectedCourse = 'معالج دقيق';
    int selectedSection = 1;
    String selectedType = submissionTypes[0];
    String semester = 'الفصل الصيفي 2025/2026';
    final notesController = TextEditingController();
    String? attachedFile;

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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.upload_file_rounded,
                            color: _blue, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'رفع معاملة أكاديمية جديدة',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _textMain,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'إرسال إلكتروني مباشر للإدارة والعمادة',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                color: _textSub,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: _border),
                  const SizedBox(height: 16),

                  // المقرر
                  Text('المقرر الدراسي',
                      style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _textMain)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCourse,
                    style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'معالج دقيق', child: Text('معالج دقيق')),
                      DropdownMenuItem(
                          value: 'الاحتمالات والإشارات العشوائية',
                          child: Text('الاحتمالات والإشارات العشوائية')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedCourse = val;
                          selectedSection = val == 'معالج دقيق' ? 1 : 2;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // الشعبة وعدد الطلاب
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الشعبة',
                                style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _textMain)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: _lightBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _border),
                              ),
                              child: Text('الشعبة $selectedSection',
                                  style: GoogleFonts.cairo(
                                      fontSize: 13, color: _textMain)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('عدد الطلاب',
                                style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _textMain)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: _lightBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _border),
                              ),
                              child: Text('40 طالباً',
                                  style: GoogleFonts.cairo(
                                      fontSize: 13, color: _textMain)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // نوع المستند
                  Text('نوع المستند أو المعاملة',
                      style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _textMain)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    isExpanded: true,
                    style: GoogleFonts.cairo(fontSize: 13, color: _textMain),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    items: submissionTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // الفصل
                  Text('الفصل الدراسي',
                      style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textMain)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _lightBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    child: Text(semester,
                        style: GoogleFonts.cairo(
                            fontSize: 13, color: _textMain)),
                  ),
                  const SizedBox(height: 12),

                  // ملاحظات الدكتور
                  Text('ملاحظات الدكتور وتوصيات الاعتماد',
                      style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textMain)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    style: GoogleFonts.cairo(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'اكتب أي ملاحظة أو تدقيق للإدارة الأكاديمية...',
                      hintStyle: GoogleFonts.cairo(fontSize: 12, color: _textSub),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // إرفاق ملف
                  OutlinedButton.icon(
                    onPressed: () {
                      setModalState(() {
                        attachedFile = 'كشف_رقمي_${DateTime.now().millisecondsSinceEpoch}.pdf';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'اختيار ملف تجريبي — سيتم ربطه بالنظام الخلفي لاحقاً',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: _navy,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: Icon(
                      attachedFile != null
                          ? Icons.check_circle_outline
                          : Icons.attach_file_rounded,
                      color: attachedFile != null
                          ? const Color(0xFF2E9B5F)
                          : _blue,
                      size: 18,
                    ),
                    label: Text(
                      attachedFile ??
                          'إرفاق ملف (سيتم ربطه بالنظام الخلفي لاحقاً)',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: attachedFile != null
                            ? const Color(0xFF2E9B5F)
                            : _blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: attachedFile != null
                              ? const Color(0xFF2E9B5F)
                              : _blue),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // أزرار الحفظ والإرسال
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final newSub = AcademicSubmission(
                          id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
                          referenceNumber:
                              'DEMO-SUB-${(DoctorDemoData.submissions.length + 1).toString().padLeft(3, '0')}',
                          courseId: selectedCourse == 'معالج دقيق'
                              ? 'doctor-course-001'
                              : 'doctor-course-002',
                          courseName: selectedCourse,
                          section: selectedSection,
                          type: selectedType,
                          studentsCount: 40,
                          status: AcademicSubmissionStatus.draft,
                          submittedAt: 'الآن',
                          notes: notesController.text.trim().isNotEmpty
                              ? notesController.text.trim()
                              : 'معاملة رقمية مرفوعة عبر لوحة الدكتور.',
                          attachedFileName: attachedFile,
                        );

                        DoctorDemoData.addSubmission(newSub);
                        Navigator.pop(ctx);
                        _updateFilteredSubmissions();
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم إنشاء المعاملة وحفظها كمسودة بنجاح',
                              style:
                                  GoogleFonts.cairo(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: _navy,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: _white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'حفظ المعاملة كمسودة',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) => notesController.dispose());
  }

  void _showSubmitConfirmationDialog(AcademicSubmission submission) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.send_rounded, color: _blue, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                'تأكيد الإرسال',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سيتم إرسال هذا السجل إلى الإدارة للمراجعة.',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textMain,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'المقرر: ${submission.courseName} (الشعبة ${submission.section})\nنوع المستند: ${submission.type}\nالرمز المرجعي: ${submission.referenceNumber}',
                style: GoogleFonts.cairo(fontSize: 12, color: _textSub),
              ),
              const SizedBox(height: 12),
              Text(
                'هل تريد المتابعة؟',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                    color: _textSub, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  submission.status = AcademicSubmissionStatus.submitted;
                  _updateFilteredSubmissions();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إرسال النتائج بنجاح',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    backgroundColor: const Color(0xFF2E9B5F),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: _white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'تأكيد الإرسال',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
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
        appBar: AppBar(
          backgroundColor: _white,
          elevation: 0,
          centerTitle: true,
          leading: const DoctorBackButton(),
          title: Text(
            'رفع النتائج للإدارة',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'بيانات تجريبية',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB78103),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    children: [
                      // ── Hero Banner ──
                      _buildHeroBanner(),
                      const SizedBox(height: 16),

                      // ── Filter Chips ──
                      _buildFilterPills(),
                      const SizedBox(height: 16),

                      // ── Section Title & Action Button ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'المعاملات الرقمية المسجلة (${_filteredSubmissions.length})',
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
                            onPressed: _openNewSubmissionSheet,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text('رفع جديد',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w700, fontSize: 12.5)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
                              foregroundColor: _white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── Submissions Lazy List ──
              if (_filteredSubmissions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: _white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: Center(
                        child: Text(
                          'لا توجد معاملات مطابقة لهذا الفلتر',
                          style: GoogleFonts.cairo(fontSize: 13, color: _textSub),
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverList.separated(
                    itemCount: _filteredSubmissions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildSubmissionCard(_filteredSubmissions[index]);
                    },
                  ),
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
              color: _blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.cloud_done_rounded,
                color: _blue, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رفع النتائج للإدارة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
                Text(
                  'إرسال النتائج والنماذج الأكاديمية إلكترونياً بدلاً من المعاملات الورقية',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: _textSub,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? _white : _textMain,
                ),
              ),
              selected: isSelected,
              selectedColor: _navy,
              backgroundColor: _white,
              side: BorderSide(
                color: isSelected ? _navy : _border,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedFilter = filter;
                    _updateFilteredSubmissions();
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmissionCard(AcademicSubmission s) {
    final statusBadge = _resolveStatusBadge(s.status);

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
                  s.type,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBadge.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusBadge.label,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: statusBadge.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${s.courseName} · الشعبة ${s.section} · ${s.studentsCount} طالباً',
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: _textSub,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _lightBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'الرقم المرجعي: ${s.referenceNumber}',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                ),
                Text(
                  s.submittedAt,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: _textSub,
                  ),
                ),
              ],
            ),
          ),
          if (s.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              s.notes,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                color: const Color(0xFF556972),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  final archiveItem = DoctorArchiveItem(
                    id: s.id,
                    title: s.type,
                    courseName: s.courseName,
                    documentType: s.type,
                    semester: 'الفصل الصيفي 2025/2026',
                    date: s.submittedAt,
                    status: statusBadge.label,
                    statusColor: statusBadge.color,
                    filePath: s.attachedFileName,
                    notes: s.notes,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DoctorDocumentPreviewScreen(
                        documentItem: archiveItem,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.folder_open_rounded, size: 16),
                label: Text(
                  'فتح',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (s.status == AcademicSubmissionStatus.draft)
                ElevatedButton.icon(
                  onPressed: () => _showSubmitConfirmationDialog(s),
                  icon: const Icon(Icons.send_rounded, size: 14),
                  label: Text('إرسال للإدارة',
                      style: GoogleFonts.cairo(
                          fontSize: 11.5, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: _white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ({String label, Color color, Color bg}) _resolveStatusBadge(
      AcademicSubmissionStatus status) {
    switch (status) {
      case AcademicSubmissionStatus.approved:
        return (
          label: 'تم الاعتماد',
          color: const Color(0xFF2E9B5F),
          bg: const Color(0xFFEDFAF1),
        );
      case AcademicSubmissionStatus.submitted:
        return (
          label: 'تم الإرسال',
          color: _blue,
          bg: const Color(0xFFEAF4FB),
        );
      case AcademicSubmissionStatus.needsRevision:
        return (
          label: 'بحاجة إلى تعديل',
          color: const Color(0xFFE74C3C),
          bg: const Color(0xFFFDEDEC),
        );
      case AcademicSubmissionStatus.draft:
        return (
          label: 'مسودة',
          color: const Color(0xFFE67E22),
          bg: const Color(0xFFFDF2E9),
        );
    }
  }
}
